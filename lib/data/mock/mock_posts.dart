import '../models/post_model.dart';

/// モック投稿データ生成クラス
class MockPosts {
  MockPosts._();

  /// モック投稿データリスト
  static List<PostModel> generateMockPosts() {
    final now = DateTime.now();
    final posts = <PostModel>[];

    // 過去の投稿（30件）
    for (int i = 30; i > 0; i--) {
      final postDate = now.subtract(Duration(days: i));
      posts.add(_createPastPost(i.toString(), postDate, i));
    }

    // 今日の投稿（3件）
    posts.addAll([
      _createTodayPost('today_1', now),
      _createTodayPost('today_2', now.add(const Duration(hours: 2))),
      _createTodayPost('today_3', now.add(const Duration(hours: 4))),
    ]);

    // 未来の投稿（20件）
    for (int i = 1; i <= 20; i++) {
      final postDate = now.add(Duration(days: i));
      posts.add(_createFuturePost('future_$i', postDate, i));
    }

    return posts;
  }

  /// 過去の投稿を生成
  static PostModel _createPastPost(String id, DateTime date, int daysAgo) {
    final performance = _generatePerformance(daysAgo);
    final isRecent = daysAgo <= 7;
    
    return PostModel(
      id: 'past_$id',
      content: _getPostContent(daysAgo),
      scheduledDate: date,
      publishedDate: date,
      phase: _getRandomPhase(),
      type: _getRandomType(),
      tags: _getRandomTags(),
      kpi: _generateKPI(),
      performance: performance,
      memo: _getRandomMemo(),
      createdAt: date.subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      isPublished: true,
    );
  }

  /// 今日の投稿を生成
  static PostModel _createTodayPost(String id, DateTime date) {
    return PostModel(
      id: id,
      content: _getTodayPostContent(id),
      scheduledDate: date,
      publishedDate: date,
      phase: PostPhase.launch,
      type: _getRandomType(),
      tags: _getRandomTags(),
      kpi: _generateKPI(),
      performance: _generateTodayPerformance(),
      memo: '本日公開済み',
      createdAt: date.subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now(),
      isPublished: true,
    );
  }

  /// 未来の投稿を生成
  static PostModel _createFuturePost(String id, DateTime date, int daysFromNow) {
    return PostModel(
      id: id,
      content: _getFuturePostContent(daysFromNow),
      scheduledDate: date,
      publishedDate: null,
      phase: _getFuturePhase(daysFromNow),
      type: _getRandomType(),
      tags: _getRandomTags(),
      kpi: _generateKPI(),
      performance: const PostPerformance(),
      memo: _getFutureMemo(daysFromNow),
      createdAt: DateTime.now().subtract(Duration(hours: daysFromNow)),
      updatedAt: DateTime.now(),
      isPublished: false,
    );
  }

  /// パフォーマンスデータを生成
  static PostPerformance _generatePerformance(int daysAgo) {
    if (daysAgo < 1) return const PostPerformance();

    final baseLikes = 50 + (daysAgo % 10) * 20;
    final baseImpressions = 1000 + (daysAgo % 20) * 500;

    final day1Likes = baseLikes + (daysAgo % 5) * 10;
    final day1Impressions = baseImpressions + (daysAgo % 8) * 200;

    final day7Likes = daysAgo >= 7 ? (day1Likes * 1.5).round() : 0;
    final day7Impressions = daysAgo >= 7 ? (day1Impressions * 1.8).round() : 0;

    final day30Likes = daysAgo >= 30 ? (day7Likes * 1.3).round() : 0;
    final day30Impressions = daysAgo >= 30 ? (day7Impressions * 1.4).round() : 0;

    return PostPerformance(
      day1Likes: day1Likes,
      day1Impressions: day1Impressions,
      day7Likes: day7Likes,
      day7Impressions: day7Impressions,
      day30Likes: day30Likes,
      day30Impressions: day30Impressions,
      day1UpdatedAt: daysAgo >= 1 ? DateTime.now().subtract(Duration(days: daysAgo - 1)) : null,
      day7UpdatedAt: daysAgo >= 7 ? DateTime.now().subtract(Duration(days: daysAgo - 7)) : null,
      day30UpdatedAt: daysAgo >= 30 ? DateTime.now().subtract(Duration(days: daysAgo - 30)) : null,
    );
  }

  /// 今日のパフォーマンスデータを生成
  static PostPerformance _generateTodayPerformance() {
    return PostPerformance(
      day1Likes: 25 + DateTime.now().hour * 2,
      day1Impressions: 500 + DateTime.now().hour * 50,
      day7Likes: 0,
      day7Impressions: 0,
      day30Likes: 0,
      day30Impressions: 0,
      day1UpdatedAt: DateTime.now(),
      day7UpdatedAt: null,
      day30UpdatedAt: null,
    );
  }

  /// KPI目標値を生成
  static PostKPI _generateKPI() {
    final targetLikes = [100, 150, 200, 250, 300][(DateTime.now().millisecond % 5)];
    final targetImpressions = [2000, 3000, 4000, 5000, 6000][(DateTime.now().microsecond % 5)];
    
    return PostKPI(
      targetLikes: targetLikes,
      targetImpressions: targetImpressions,
      description: 'フェーズ目標達成',
    );
  }

  /// ランダムなフェーズを取得
  static PostPhase _getRandomPhase() {
    final phases = PostPhase.values;
    return phases[DateTime.now().microsecond % phases.length];
  }

  /// 未来の投稿のフェーズを取得
  static PostPhase _getFuturePhase(int daysFromNow) {
    if (daysFromNow <= 3) return PostPhase.launch;
    if (daysFromNow <= 7) return PostPhase.development;
    return PostPhase.planning;
  }

  /// ランダムなタイプを取得
  static PostType _getRandomType() {
    final types = PostType.values;
    return types[DateTime.now().millisecond % types.length];
  }

  /// ランダムなタグを取得
  static List<String> _getRandomTags() {
    final allTags = [
      'プロダクト',
      'アップデート',
      'ユーザー向け',
      '技術',
      'お知らせ',
      '機能紹介',
      'チュートリアル',
      'イベント',
      'キャンペーン',
      'フィードバック',
    ];
    
    final tagCount = 1 + (DateTime.now().second % 3);
    final selectedTags = <String>[];
    
    for (int i = 0; i < tagCount; i++) {
      final tag = allTags[(DateTime.now().millisecond + i * 13) % allTags.length];
      if (!selectedTags.contains(tag)) {
        selectedTags.add(tag);
      }
    }
    
    return selectedTags;
  }

  /// 投稿内容を取得
  static String _getPostContent(int daysAgo) {
    final contents = [
      '新機能をリリースしました！📱\nユーザビリティが大幅に向上し、より快適にご利用いただけます。',
      'アップデート情報をお知らせします 🚀\n今回のバージョンでは、パフォーマンスの改善を行いました。',
      'ユーザーの皆様からのフィードバックを反映 💭\n使いやすさを追求した新しいUIをご体験ください。',
      'チュートリアル動画を公開しました 🎥\n初心者の方でも簡単に始められるガイドをご用意しています。',
      'メンテナンス完了のお知らせ ⚙️\nサービスが正常に復旧いたしました。ご迷惑をおかけして申し訳ありませんでした。',
    ];
    return contents[daysAgo % contents.length];
  }

  /// 今日の投稿内容を取得
  static String _getTodayPostContent(String id) {
    final contents = {
      'today_1': '本日の機能アップデートをお知らせします！🎉\n皆様のご要望にお応えした新機能を追加いたしました。',
      'today_2': 'リアルタイム通知機能が利用可能になりました 🔔\nより便利にサービスをご活用いただけます。',
      'today_3': '週末限定キャンペーン開始！🎁\n特別な特典をご用意しております。ぜひこの機会をお見逃しなく。',
    };
    return contents[id] ?? '本日の投稿です';
  }

  /// 未来の投稿内容を取得
  static String _getFuturePostContent(int daysFromNow) {
    final contents = [
      '次回アップデート予告 🔮\n来週、大型アップデートを予定しています。',
      'イベント開催予告 📅\nコミュニティイベントを企画中です。',
      '新機能開発中 🛠️\nユーザー体験向上のため、新機能を開発しています。',
      'ベータテスト募集予定 🧪\n新機能のテスターを募集する予定です。',
      'パートナーシップ発表予定 🤝\n新しいパートナーとの提携をお知らせする予定です。',
    ];
    return contents[daysFromNow % contents.length];
  }

  /// ランダムなメモを取得
  static String _getRandomMemo() {
    final memos = [
      'エンゲージメント率が高め',
      'ターゲット層にリーチ',
      'フォロワー増加効果あり',
      '次回改善点：画像追加',
      'リツイート数が予想以上',
      '',
    ];
    return memos[DateTime.now().second % memos.length];
  }

  /// 未来の投稿メモを取得
  static String _getFutureMemo(int daysFromNow) {
    if (daysFromNow <= 3) return '近日公開予定';
    if (daysFromNow <= 7) return '最終確認中';
    return '企画段階';
  }
} 