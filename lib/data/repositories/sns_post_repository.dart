import '../../core/supabase_config.dart';
import '../models/sns_post.dart';

class SnsPostRepository {
  static const String _tableName = 'sns_posts';
  
  final _supabase = SupabaseConfig.client;

  // すべての投稿を取得
  Future<List<SnsPost>> getAllPosts() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('scheduled_date', ascending: false);
      
      return response
          .map<SnsPost>((data) => SnsPost.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('投稿の取得に失敗しました: $e');
    }
  }

  // 日付範囲で投稿を取得
  Future<List<SnsPost>> getPostsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .gte('scheduled_date', startDate.toIso8601String())
          .lte('scheduled_date', endDate.toIso8601String())
          .order('scheduled_date', ascending: true);
      
      return response
          .map<SnsPost>((data) => SnsPost.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('日付範囲の投稿取得に失敗しました: $e');
    }
  }

  // 特定の日の投稿を取得
  Future<List<SnsPost>> getPostsByDate(DateTime date) async {
    try {
      final startDate = DateTime(date.year, date.month, date.day);
      final endDate = startDate.add(const Duration(days: 1));
      
      final response = await _supabase
          .from(_tableName)
          .select()
          .gte('scheduled_date', startDate.toIso8601String())
          .lt('scheduled_date', endDate.toIso8601String())
          .order('scheduled_date', ascending: true);
      
      return response
          .map<SnsPost>((data) => SnsPost.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('指定日の投稿取得に失敗しました: $e');
    }
  }

  // アカウント別投稿を取得
  Future<List<SnsPost>> getPostsByAccount(String accountId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('account_id', accountId)
          .order('scheduled_date', ascending: false);
      
      return response
          .map<SnsPost>((data) => SnsPost.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('アカウント別投稿の取得に失敗しました: $e');
    }
  }

  // ステータス別投稿を取得
  Future<List<SnsPost>> getPostsByStatus(PostStatus status) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('status', status.name)
          .order('scheduled_date', ascending: false);
      
      return response
          .map<SnsPost>((data) => SnsPost.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('ステータス別投稿の取得に失敗しました: $e');
    }
  }

  // IDで投稿を取得
  Future<SnsPost?> getPostById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();
      
      return SnsPost.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 投稿を作成
  Future<SnsPost> createPost(SnsPost post) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(post.toJson())
          .select()
          .single();
      
      return SnsPost.fromJson(response);
    } catch (e) {
      throw Exception('投稿の作成に失敗しました: $e');
    }
  }

  // 投稿を更新
  Future<SnsPost> updatePost(SnsPost post) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update(post.toJson())
          .eq('id', post.id)
          .select()
          .single();
      
      return SnsPost.fromJson(response);
    } catch (e) {
      throw Exception('投稿の更新に失敗しました: $e');
    }
  }

  // 投稿を削除
  Future<void> deletePost(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('投稿の削除に失敗しました: $e');
    }
  }

  // 投稿のステータスを更新
  Future<SnsPost> updatePostStatus(String id, PostStatus status) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update({
            'status': status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();
      
      return SnsPost.fromJson(response);
    } catch (e) {
      throw Exception('投稿ステータスの更新に失敗しました: $e');
    }
  }

  // 投稿のエンゲージメント統計を更新
  Future<SnsPost> updatePostEngagement({
    required String id,
    required int likesCount,
    required int commentsCount,
    required int sharesCount,
  }) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update({
            'likes_count': likesCount,
            'comments_count': commentsCount,
            'shares_count': sharesCount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();
      
      return SnsPost.fromJson(response);
    } catch (e) {
      throw Exception('エンゲージメント統計の更新に失敗しました: $e');
    }
  }

  // 今日の投稿数を取得
  Future<int> getTodayPostsCount() async {
    try {
      final today = DateTime.now();
      final startDate = DateTime(today.year, today.month, today.day);
      final endDate = startDate.add(const Duration(days: 1));
      
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .gte('scheduled_date', startDate.toIso8601String())
          .lt('scheduled_date', endDate.toIso8601String());
      
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  // 月間投稿数を取得
  Future<int> getMonthlyPostsCount({DateTime? month}) async {
    try {
      final targetMonth = month ?? DateTime.now();
      final startDate = DateTime(targetMonth.year, targetMonth.month, 1);
      final endDate = DateTime(targetMonth.year, targetMonth.month + 1, 1);
      
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .gte('scheduled_date', startDate.toIso8601String())
          .lt('scheduled_date', endDate.toIso8601String());
      
      return response.length;
    } catch (e) {
      return 0;
    }
  }
} 