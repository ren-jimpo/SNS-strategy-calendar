-- SNS戦略カレンダー データベーススキーマ
-- このSQLファイルをSupabaseのSQLエディタで実行してください

-- 拡張機能の有効化
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- SNSアカウントテーブル
CREATE TABLE IF NOT EXISTS sns_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_name VARCHAR(255) NOT NULL,
    platform VARCHAR(50) NOT NULL CHECK (platform IN ('instagram', 'twitter', 'facebook', 'youtube', 'tiktok', 'linkedin')),
    profile_image_url TEXT,
    bio TEXT,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    posts_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- SNS投稿テーブル
CREATE TABLE IF NOT EXISTS sns_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID NOT NULL REFERENCES sns_accounts(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    image_urls JSONB DEFAULT '[]'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb,
    scheduled_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'scheduled', 'published', 'failed')),
    post_url TEXT,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- インデックスの作成
CREATE INDEX IF NOT EXISTS idx_sns_accounts_platform ON sns_accounts(platform);
CREATE INDEX IF NOT EXISTS idx_sns_accounts_is_active ON sns_accounts(is_active);
CREATE INDEX IF NOT EXISTS idx_sns_posts_account_id ON sns_posts(account_id);
CREATE INDEX IF NOT EXISTS idx_sns_posts_scheduled_date ON sns_posts(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_sns_posts_status ON sns_posts(status);

-- RLS (Row Level Security) の有効化
ALTER TABLE sns_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE sns_posts ENABLE ROW LEVEL SECURITY;

-- ポリシーの作成（認証されたユーザーのみアクセス可能）
CREATE POLICY "sns_accounts_policy" ON sns_accounts
    FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "sns_posts_policy" ON sns_posts
    FOR ALL USING (auth.role() = 'authenticated');

-- updated_at自動更新のためのトリガー関数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- トリガーの作成
CREATE TRIGGER update_sns_accounts_updated_at 
    BEFORE UPDATE ON sns_accounts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sns_posts_updated_at 
    BEFORE UPDATE ON sns_posts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- サンプルデータの挿入（テスト用）
INSERT INTO sns_accounts (account_name, platform, bio, followers_count, following_count, posts_count) VALUES
('マイInstagram', 'instagram', 'ライフスタイルとファッションについて投稿しています', 1250, 350, 45),
('マイTwitter', 'twitter', 'テック系の情報を発信', 850, 200, 120),
('マイYouTube', 'youtube', 'DIYとクラフトのチャンネル', 2500, 100, 25)
ON CONFLICT DO NOTHING;

-- サンプル投稿データ
WITH sample_accounts AS (
    SELECT id, platform FROM sns_accounts LIMIT 3
)
INSERT INTO sns_posts (account_id, title, content, scheduled_date, status, tags)
SELECT 
    sa.id,
    CASE sa.platform
        WHEN 'instagram' THEN '今日のコーディネート'
        WHEN 'twitter' THEN '最新のテック情報'
        WHEN 'youtube' THEN 'DIYプロジェクト紹介'
    END,
    CASE sa.platform
        WHEN 'instagram' THEN '春らしいカラーのコーディネートを組んでみました！'
        WHEN 'twitter' THEN 'AI技術の最新動向について調べてみました'
        WHEN 'youtube' THEN '簡単にできるDIYプロジェクトを紹介します'
    END,
    NOW() + INTERVAL '1 day',
    'scheduled',
    CASE sa.platform
        WHEN 'instagram' THEN '["ファッション", "コーディネート", "春服"]'::jsonb
        WHEN 'twitter' THEN '["技術", "AI", "プログラミング"]'::jsonb
        WHEN 'youtube' THEN '["DIY", "クラフト", "ハンドメイド"]'::jsonb
    END
FROM sample_accounts sa
ON CONFLICT DO NOTHING; 