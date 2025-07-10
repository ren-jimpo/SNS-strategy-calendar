import '../../core/supabase_config.dart';
import '../models/sns_account.dart';

class SnsAccountRepository {
  static const String _tableName = 'sns_accounts';
  
  final _supabase = SupabaseConfig.client;

  // すべてのアカウントを取得
  Future<List<SnsAccount>> getAllAccounts() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      
      return response
          .map<SnsAccount>((data) => SnsAccount.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('アカウントの取得に失敗しました: $e');
    }
  }

  // アクティブなアカウントのみを取得
  Future<List<SnsAccount>> getActiveAccounts() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return response
          .map<SnsAccount>((data) => SnsAccount.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('アクティブなアカウントの取得に失敗しました: $e');
    }
  }

  // IDでアカウントを取得
  Future<SnsAccount?> getAccountById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();
      
      return SnsAccount.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // プラットフォームでアカウントを取得
  Future<List<SnsAccount>> getAccountsByPlatform(String platform) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('platform', platform)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return response
          .map<SnsAccount>((data) => SnsAccount.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('プラットフォーム別アカウントの取得に失敗しました: $e');
    }
  }

  // アカウントを作成
  Future<SnsAccount> createAccount(SnsAccount account) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(account.toJson())
          .select()
          .single();
      
      return SnsAccount.fromJson(response);
    } catch (e) {
      throw Exception('アカウントの作成に失敗しました: $e');
    }
  }

  // アカウントを更新
  Future<SnsAccount> updateAccount(SnsAccount account) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update(account.toJson())
          .eq('id', account.id)
          .select()
          .single();
      
      return SnsAccount.fromJson(response);
    } catch (e) {
      throw Exception('アカウントの更新に失敗しました: $e');
    }
  }

  // アカウントを削除
  Future<void> deleteAccount(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('アカウントの削除に失敗しました: $e');
    }
  }

  // アカウントの統計情報を更新
  Future<SnsAccount> updateAccountStats({
    required String id,
    required int followersCount,
    required int followingCount,
    required int postsCount,
  }) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update({
            'followers_count': followersCount,
            'following_count': followingCount,
            'posts_count': postsCount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();
      
      return SnsAccount.fromJson(response);
    } catch (e) {
      throw Exception('アカウント統計の更新に失敗しました: $e');
    }
  }
} 