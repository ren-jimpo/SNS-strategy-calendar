-- サンプルフェーズデータの追加
INSERT INTO phases (name, description, "order", is_active) VALUES
('企画フェーズ', 'アイデア創出と戦略立案', 1, true),
('開発フェーズ', 'コンテンツ制作と品質管理', 2, true),
('ローンチフェーズ', '投稿実行とタイミング管理', 3, true),
('成長フェーズ', 'エンゲージメント向上とリーチ拡大', 4, true),
('メンテナンスフェーズ', 'コミュニティ維持と継続的改善', 5, true)
ON CONFLICT (name) DO NOTHING;

-- フェーズIDを取得してKPIに使用
DO $$
DECLARE
    planning_phase_id UUID;
    development_phase_id UUID;
    launch_phase_id UUID;
    growth_phase_id UUID;
    maintenance_phase_id UUID;
BEGIN
    -- フェーズIDを取得
    SELECT id INTO planning_phase_id FROM phases WHERE name = '企画フェーズ' LIMIT 1;
    SELECT id INTO development_phase_id FROM phases WHERE name = '開発フェーズ' LIMIT 1;
    SELECT id INTO launch_phase_id FROM phases WHERE name = 'ローンチフェーズ' LIMIT 1;
    SELECT id INTO growth_phase_id FROM phases WHERE name = '成長フェーズ' LIMIT 1;
    SELECT id INTO maintenance_phase_id FROM phases WHERE name = 'メンテナンスフェーズ' LIMIT 1;

    -- KGI（戦略目標）のサンプルデータ
    INSERT INTO kpis (name, description, type, unit, target_value, current_value, phase_id, is_active) VALUES
    ('月間総エンゲージメント', 'すべてのプラットフォームでの総エンゲージメント数', 'kgi', '', 50000, 42000, growth_phase_id, true),
    ('ブランド認知度向上', 'ブランド認知度の向上率', 'kgi', '%', 25, 18, growth_phase_id, true),
    ('収益成長率', '月間収益の成長率', 'kgi', '%', 20, 15, growth_phase_id, true);

    -- KPI（成果指標）のサンプルデータ
    INSERT INTO kpis (name, description, type, unit, target_value, current_value, phase_id, is_active) VALUES
    
    -- 企画フェーズのKPI
    ('月間アイデア数', '月間で創出するコンテンツアイデア数', 'kpi', '件', 50, 42, planning_phase_id, true),
    ('調査完了率', 'マーケット調査の完了率', 'kpi', '%', 95, 88, planning_phase_id, true),
    ('戦略一致度', 'ブランド戦略との一致度', 'kpi', '%', 90, 85, planning_phase_id, true),
    
    -- 開発フェーズのKPI
    ('コンテンツ品質', 'コンテンツ品質スコア', 'kpi', '%', 90, 85, development_phase_id, true),
    ('週間制作数', '週間でのコンテンツ制作数', 'kpi', '件', 15, 12, development_phase_id, true),
    ('修正回数', 'コンテンツあたりの平均修正回数', 'kpi', '回', 2, 3, development_phase_id, true),
    
    -- ローンチフェーズのKPI
    ('月間投稿数', '月間の投稿数', 'kpi', '件', 28, 25, launch_phase_id, true),
    ('投稿時間精度', 'スケジュール通りの投稿率', 'kpi', '%', 95, 92, launch_phase_id, true),
    ('プラットフォーム数', 'アクティブなプラットフォーム数', 'kpi', '個', 6, 5, launch_phase_id, true),
    
    -- 成長フェーズのKPI
    ('エンゲージメント成長率', '月間エンゲージメント成長率', 'kpi', '%', 15, 12, growth_phase_id, true),
    ('リーチ拡大率', '月間リーチ拡大率', 'kpi', '%', 25, 18, growth_phase_id, true),
    ('バイラル率', 'コンテンツのバイラル率', 'kpi', '%', 5, 3, growth_phase_id, true),
    
    -- メンテナンスフェーズのKPI
    ('平均応答時間', 'コメントへの平均応答時間', 'kpi', '時間', 2, 3, maintenance_phase_id, true),
    ('コミュニティ健全度', 'コミュニティの健全度スコア', 'kpi', '%', 85, 78, maintenance_phase_id, true),
    ('フォロワー維持率', '月間フォロワー維持率', 'kpi', '%', 90, 85, maintenance_phase_id, true);

END $$;

-- データの確認
SELECT 'KPI/KGIサンプルデータが追加されました' AS message;
SELECT 
    COUNT(*) as total_kpis,
    SUM(CASE WHEN type = 'kgi' THEN 1 ELSE 0 END) as kgi_count,
    SUM(CASE WHEN type = 'kpi' THEN 1 ELSE 0 END) as kpi_count
FROM kpis; 