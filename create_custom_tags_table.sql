-- カスタムタグテーブルの作成
CREATE TABLE IF NOT EXISTS custom_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tag TEXT NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- インデックスの作成
CREATE INDEX IF NOT EXISTS idx_custom_tags_tag ON custom_tags(tag);
CREATE INDEX IF NOT EXISTS idx_custom_tags_is_active ON custom_tags(is_active);
CREATE INDEX IF NOT EXISTS idx_custom_tags_created_at ON custom_tags(created_at);

-- RLS（Row Level Security）を無効にする（個人利用のため）
ALTER TABLE custom_tags DISABLE ROW LEVEL SECURITY;

-- テーブルの確認
SELECT 'custom_tags テーブルが作成されました' AS message; 