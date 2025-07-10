-- シンプルなデータ挿入 (引用符エラー回避版)
-- SupabaseのSQLエディタで実行してください

-- RLSを無効化
ALTER TABLE phases DISABLE ROW LEVEL SECURITY;
ALTER TABLE kpis DISABLE ROW LEVEL SECURITY;

-- フェーズデータの挿入
INSERT INTO phases (name, description, "order", is_active) VALUES
('認知フェーズ', 'ブランド認知度向上を目的とした投稿', 1, true),
('関心フェーズ', 'ユーザーの関心を引く魅力的なコンテンツ', 2, true),
('検討フェーズ', 'サービス検討を促すメリット訴求', 3, true),
('行動フェーズ', 'アクション促進とコンバージョン獲得', 4, true)
ON CONFLICT DO NOTHING;

-- KPIデータの挿入（段階的に）
-- 1. 認知フェーズのKPI
INSERT INTO kpis (name, description, type, unit, target_value, current_value, phase_id, is_active)
SELECT 
    'インプレッション数',
    'SNS投稿のリーチ・インプレッション獲得数',
    'kpi',
    '回',
    10000.00,
    7500.00,
    p.id,
    true
FROM phases p WHERE p.name = '認知フェーズ'
ON CONFLICT DO NOTHING;

-- 2. 関心フェーズのKPI
INSERT INTO kpis (name, description, type, unit, target_value, current_value, phase_id, is_active)
SELECT 
    'エンゲージメント率',
    'いいね・コメント・シェア率',
    'kpi',
    '%',
    5.00,
    3.80,
    p.id,
    true
FROM phases p WHERE p.name = '関心フェーズ'
ON CONFLICT DO NOTHING;

-- 3. 検討フェーズのKPI
INSERT INTO kpis (name, description, type, unit, target_value, current_value, phase_id, is_active)
SELECT 
    'サイト流入数',
    'SNSからWebサイトへの流入数',
    'kpi',
    '人',
    500.00,
    342.00,
    p.id,
    true
FROM phases p WHERE p.name = '検討フェーズ'
ON CONFLICT DO NOTHING;

-- 4. 行動フェーズのKGI
INSERT INTO kpis (name, description, type, unit, target_value, current_value, phase_id, is_active)
SELECT 
    'コンバージョン数',
    '申込み・購入・問い合わせ数',
    'kgi',
    '件',
    20.00,
    12.00,
    p.id,
    true
FROM phases p WHERE p.name = '行動フェーズ'
ON CONFLICT DO NOTHING;

-- 確認クエリ
SELECT 'phases' as table_name, count(*) as record_count FROM phases
UNION ALL
SELECT 'kpis' as table_name, count(*) as record_count FROM kpis;

-- データ確認
SELECT p.name as phase_name, k.name as kpi_name, k.type, k.current_value, k.target_value
FROM phases p
LEFT JOIN kpis k ON p.id = k.phase_id
ORDER BY p."order", k.type; 