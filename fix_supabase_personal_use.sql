-- 個人使用向けSupabase設定修正
-- SupabaseのSQLエディタで実行してください

-- 🔐 RLS (Row Level Security) を無効化（個人使用のため）
ALTER TABLE sns_accounts DISABLE ROW LEVEL SECURITY;
ALTER TABLE sns_posts DISABLE ROW LEVEL SECURITY;
ALTER TABLE phases DISABLE ROW LEVEL SECURITY;
ALTER TABLE kpis DISABLE ROW LEVEL SECURITY;

-- 既存のRLSポリシーを削除
DROP POLICY IF EXISTS "sns_accounts_policy" ON sns_accounts;
DROP POLICY IF EXISTS "sns_posts_policy" ON sns_posts;

-- 🚀 パフォーマンス最適化のための追加インデックス
CREATE INDEX IF NOT EXISTS idx_sns_posts_created_at ON sns_posts(created_at);
CREATE INDEX IF NOT EXISTS idx_sns_posts_updated_at ON sns_posts(updated_at);
CREATE INDEX IF NOT EXISTS idx_sns_posts_status_scheduled_date ON sns_posts(status, scheduled_date);
CREATE INDEX IF NOT EXISTS idx_sns_accounts_platform_active ON sns_accounts(platform, is_active);
CREATE INDEX IF NOT EXISTS idx_sns_posts_account_status ON sns_posts(account_id, status);

-- 🏷️ JSONB配列検索用のGINインデックス（タグ検索の高速化）
CREATE INDEX IF NOT EXISTS idx_sns_posts_tags_gin ON sns_posts USING gin(tags);
CREATE INDEX IF NOT EXISTS idx_sns_posts_image_urls_gin ON sns_posts USING gin(image_urls);

-- 📊 統計情報更新（クエリプランナーの最適化）
ANALYZE sns_accounts;
ANALYZE sns_posts;
ANALYZE phases;
ANALYZE kpis;

-- ✅ 設定確認用クエリ
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as "RLS有効" 
FROM pg_tables 
WHERE tablename IN ('sns_accounts', 'sns_posts', 'phases', 'kpis');

-- 📈 インデックス確認用クエリ
SELECT 
    t.tablename,
    i.indexname,
    array_to_string(array_agg(a.attname), ', ') as columns
FROM pg_indexes i
JOIN pg_class c ON c.relname = i.indexname
JOIN pg_attribute a ON a.attrelid = c.oid
JOIN pg_tables t ON t.tablename = i.tablename
WHERE t.tablename IN ('sns_accounts', 'sns_posts')
  AND a.attnum > 0
  AND NOT a.attisdropped
GROUP BY t.tablename, i.indexname
ORDER BY t.tablename, i.indexname; 