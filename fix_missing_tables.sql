-- 不足しているテーブル定義とデータ追加
-- SupabaseのSQLエディタで実行してください

-- フェーズテーブル
CREATE TABLE IF NOT EXISTS phases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    "order" INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- KPIテーブル
CREATE TABLE IF NOT EXISTS kpis (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL CHECK (type IN ('kpi', 'kgi')),
    unit VARCHAR(50) DEFAULT '',
    target_value DECIMAL(15,2) DEFAULT 0,
    current_value DECIMAL(15,2) DEFAULT 0,
    phase_id UUID REFERENCES phases(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLSを無効化（個人使用のため）
ALTER TABLE phases DISABLE ROW LEVEL SECURITY;
ALTER TABLE kpis DISABLE ROW LEVEL SECURITY;

-- インデックスの作成
CREATE INDEX IF NOT EXISTS idx_phases_order ON phases("order");
CREATE INDEX IF NOT EXISTS idx_phases_is_active ON phases(is_active);
CREATE INDEX IF NOT EXISTS idx_kpis_type ON kpis(type);
CREATE INDEX IF NOT EXISTS idx_kpis_phase_id ON kpis(phase_id);
CREATE INDEX IF NOT EXISTS idx_kpis_is_active ON kpis(is_active);

-- updated_atトリガーの作成
CREATE TRIGGER update_phases_updated_at 
    BEFORE UPDATE ON phases 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_kpis_updated_at 
    BEFORE UPDATE ON kpis 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- サンプルフェーズデータの挿入
INSERT INTO phases (name, description, "order", is_active) VALUES
('認知フェーズ', 'ブランド認知度向上を目的とした投稿', 1, true),
('関心フェーズ', 'ユーザーの関心を引く魅力的なコンテンツ', 2, true),
('検討フェーズ', 'サービス検討を促すメリット訴求', 3, true),
('行動フェーズ', 'アクション促進とコンバージョン獲得', 4, true)
ON CONFLICT DO NOTHING;

-- サンプルKPIデータの挿入
WITH sample_phases AS (
    SELECT id, name FROM phases ORDER BY "order" LIMIT 4
)
INSERT INTO kpis (name, description, type, unit, target_value, current_value, phase_id, is_active)
SELECT 
    CASE 
        WHEN p.name = '認知フェーズ' THEN 'インプレッション数'
        WHEN p.name = '関心フェーズ' THEN 'エンゲージメント率'
        WHEN p.name = '検討フェーズ' THEN 'サイト流入数'
        WHEN p.name = '行動フェーズ' THEN 'コンバージョン数'
    END as name,
    CASE 
        WHEN p.name = '認知フェーズ' THEN 'SNS投稿のリーチ・インプレッション獲得数'
        WHEN p.name = '関心フェーズ' THEN 'いいね・コメント・シェア率'
        WHEN p.name = '検討フェーズ' THEN 'SNSからWebサイトへの流入数'
        WHEN p.name = '行動フェーズ' THEN '申込み・購入・問い合わせ数'
    END as description,
    CASE 
        WHEN p.name = '行動フェーズ' THEN 'kgi'
        ELSE 'kpi'
    END as type,
    CASE 
        WHEN p.name = '認知フェーズ' THEN '回'
        WHEN p.name = '関心フェーズ' THEN '%'
        WHEN p.name = '検討フェーズ' THEN '人'
        WHEN p.name = '行動フェーズ' THEN '件'
    END as unit,
    CASE 
        WHEN p.name = '認知フェーズ' THEN 10000
        WHEN p.name = '関心フェーズ' THEN 5.0
        WHEN p.name = '検討フェーズ' THEN 500
        WHEN p.name = '行動フェーズ' THEN 20
    END as target_value,
    CASE 
        WHEN p.name = '認知フェーズ' THEN 7500
        WHEN p.name = '関心フェーズ' THEN 3.8
        WHEN p.name = '検討フェーズ' THEN 342
        WHEN p.name = '行動フェーズ' THEN 12
    END as current_value,
    p.id as phase_id,
    true as is_active
FROM sample_phases p
ON CONFLICT DO NOTHING;

-- 確認クエリ
SELECT 'phases' as table_name, count(*) as record_count FROM phases
UNION ALL
SELECT 'kpis' as table_name, count(*) as record_count FROM kpis;

-- データ確認クエリ
SELECT p.name as phase_name, k.name as kpi_name, k.type, k.current_value, k.target_value
FROM phases p
LEFT JOIN kpis k ON p.id = k.phase_id
ORDER BY p."order", k.type; 