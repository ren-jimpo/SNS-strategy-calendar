-- ===================================================
-- モックデータ完全削除スクリプト
-- SNS管理カレンダー - 実データテスト準備
-- ===================================================

-- 1. SNS投稿データを削除
DELETE FROM sns_posts;
TRUNCATE TABLE sns_posts RESTART IDENTITY CASCADE;

-- 2. SNSアカウントデータを削除  
DELETE FROM sns_accounts;
TRUNCATE TABLE sns_accounts RESTART IDENTITY CASCADE;

-- 3. KPIデータを削除
DELETE FROM kpis;
TRUNCATE TABLE kpis RESTART IDENTITY CASCADE;

-- 4. フェーズデータを削除（後で再作成）
DELETE FROM phases;
TRUNCATE TABLE phases RESTART IDENTITY CASCADE;

-- ===================================================
-- 基本フェーズデータの再挿入（アプリに必要）
-- ===================================================

INSERT INTO phases (id, name, description, "order", is_active, created_at, updated_at) VALUES
  (gen_random_uuid(), '認知フェーズ', 'ブランド認知度向上を目的とした投稿', 1, true, NOW(), NOW()),
  (gen_random_uuid(), '関心フェーズ', 'ユーザーの関心を引く魅力的なコンテンツ', 2, true, NOW(), NOW()),
  (gen_random_uuid(), '検討フェーズ', 'サービス検討を促すメリット訴求', 3, true, NOW(), NOW()),
  (gen_random_uuid(), '行動フェーズ', 'アクション促進とコンバージョン獲得', 4, true, NOW(), NOW());

-- ===================================================
-- データクリア完了確認
-- ===================================================

-- テーブル件数確認
SELECT 'sns_posts' as table_name, COUNT(*) as count FROM sns_posts
UNION ALL
SELECT 'sns_accounts' as table_name, COUNT(*) as count FROM sns_accounts  
UNION ALL
SELECT 'kpis' as table_name, COUNT(*) as count FROM kpis
UNION ALL
SELECT 'phases' as table_name, COUNT(*) as count FROM phases;

-- 成功メッセージ
SELECT '✅ モックデータ削除完了！実データテスト準備完了' as status; 