-- SNSアカウントと投稿のサンプルデータ追加
-- SupabaseのSQLエディタで実行してください

-- サンプルSNSアカウントデータの挿入
INSERT INTO sns_accounts (platform, account_name, bio, followers_count, following_count, posts_count, is_active) VALUES
('instagram', 'mycompany_official', '公式Instagramアカウント🌟 最新情報をお届けします！', 1250, 180, 89, true),
('twitter', 'mycompany_jp', '【公式】株式会社マイカンパニー 最新ニュース・キャンペーン情報を発信中', 3400, 250, 156, true),
('youtube', 'MyCompanyOfficial', 'マイカンパニー公式YouTubeチャンネル 製品紹介・ノウハウ動画を配信', 850, 50, 24, true),
('tiktok', 'mycompany_fun', 'マイカンパニーの楽しい日常をお届け🎵', 680, 120, 45, true)
ON CONFLICT DO NOTHING;

-- 今日から近い日付の投稿データを作成
INSERT INTO sns_posts (account_id, title, content, tags, scheduled_date, status, likes_count, comments_count, shares_count, is_active)
SELECT 
    a.id,
    '新商品発表🎉',
    '待望の新商品がついに登場！✨ 詳細は公式サイトをチェック👆 #新商品 #発表 #公式',
    ARRAY['新商品', '発表', '公式'],
    CURRENT_DATE + INTERVAL '1 day',
    'scheduled',
    0,
    0,
    0,
    true
FROM sns_accounts a WHERE a.platform = 'instagram'
ON CONFLICT DO NOTHING;

INSERT INTO sns_posts (account_id, title, content, tags, scheduled_date, status, likes_count, comments_count, shares_count, is_active)
SELECT 
    a.id,
    'フォロワー感謝キャンペーン開催中',
    'フォロワーの皆様、いつもありがとうございます！ 感謝の気持ちを込めて特別キャンペーンを開催🎁 #感謝キャンペーン #プレゼント',
    ARRAY['感謝', 'キャンペーン', 'プレゼント'],
    CURRENT_DATE + INTERVAL '2 days',
    'scheduled',
    0,
    0,
    0,
    true
FROM sns_accounts a WHERE a.platform = 'twitter'
ON CONFLICT DO NOTHING;

INSERT INTO sns_posts (account_id, title, content, tags, scheduled_date, published_date, status, likes_count, comments_count, shares_count, is_active)
SELECT 
    a.id,
    '週末のお疲れ様投稿',
    '今週もお疲れ様でした！🌸 素敵な週末をお過ごしください✨ #週末 #お疲れ様 #リラックス',
    ARRAY['週末', 'お疲れ様', 'リラックス'],
    CURRENT_DATE - INTERVAL '1 day',
    CURRENT_DATE,
    'published',
    145,
    18,
    8,
    true
FROM sns_accounts a WHERE a.platform = 'instagram'
ON CONFLICT DO NOTHING;

INSERT INTO sns_posts (account_id, title, content, tags, scheduled_date, published_date, status, likes_count, comments_count, shares_count, is_active)
SELECT 
    a.id,
    '業界トレンド情報',
    '最新の業界トレンドをキャッチアップ📊 詳細レポートは公式サイトで公開中です #業界動向 #トレンド #レポート',
    ARRAY['業界動向', 'トレンド', 'レポート'],
    CURRENT_DATE - INTERVAL '2 days',
    CURRENT_DATE - INTERVAL '1 day',
    'published',
    89,
    34,
    67,
    true
FROM sns_accounts a WHERE a.platform = 'twitter'
ON CONFLICT DO NOTHING;

-- 確認クエリ
SELECT 'sns_accounts' as table_name, count(*) as record_count FROM sns_accounts
UNION ALL
SELECT 'sns_posts' as table_name, count(*) as record_count FROM sns_posts;

-- 今日前後の投稿確認
SELECT 
    a.platform,
    a.account_name,
    p.title,
    p.status,
    p.scheduled_date::date as date
FROM sns_accounts a
LEFT JOIN sns_posts p ON a.id = p.account_id
WHERE p.scheduled_date >= CURRENT_DATE - INTERVAL '3 days'
   AND p.scheduled_date <= CURRENT_DATE + INTERVAL '3 days'
ORDER BY p.scheduled_date; 