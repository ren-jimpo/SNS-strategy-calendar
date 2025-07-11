import 'package:flutter/foundation.dart';
import '../../data/models/sns_account.dart';
import '../../data/models/sns_post.dart';
import '../../data/models/custom_tag.dart';
import '../../data/repositories/sns_account_repository.dart';
import '../../data/repositories/sns_post_repository.dart';
import '../../data/repositories/custom_tag_repository.dart';

class SnsDataProvider extends ChangeNotifier {
  final SnsAccountRepository _accountRepository = SnsAccountRepository();
  final SnsPostRepository _postRepository = SnsPostRepository();
  final CustomTagRepository _customTagRepository = CustomTagRepository();

  // State
  List<SnsAccount> _accounts = [];
  List<SnsPost> _posts = [];
  List<CustomTag> _customTags = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SnsAccount> get accounts => _accounts;
  List<SnsPost> get posts => _posts;
  List<CustomTag> get customTags => _customTags;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // プリセットタグ
  static const List<String> presetTags = [
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

  // 全タグ（プリセット + カスタム）
  List<String> get allTags {
    final List<String> tags = [...presetTags];
    tags.addAll(_customTags.map((tag) => tag.tag));
    return tags;
  }

  // カスタムタグの文字列リスト
  List<String> get customTagStrings => _customTags.map((tag) => tag.tag).toList();

  // アクティブなアカウントのみを取得
  List<SnsAccount> get activeAccounts => _accounts.where((account) => account.isActive).toList();

  // プラットフォーム別アカウント数
  Map<String, int> get accountsByPlatform {
    final Map<String, int> result = {};
    for (final account in activeAccounts) {
      result[account.platform] = (result[account.platform] ?? 0) + 1;
    }
    return result;
  }

  // 今日の投稿を取得
  List<SnsPost> get todayPosts {
    final today = DateTime.now();
    return _posts.where((post) {
      final postDate = post.scheduledDate;
      return postDate.year == today.year &&
             postDate.month == today.month &&
             postDate.day == today.day;
    }).toList();
  }

  // ステータス別投稿数
  Map<PostStatus, int> get postsByStatus {
    final Map<PostStatus, int> result = {};
    for (final status in PostStatus.values) {
      result[status] = _posts.where((post) => post.status == status).length;
    }
    return result;
  }

  // Loading状態の管理
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Error状態の管理
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // 初期データの読み込み
  Future<void> loadData() async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Supabase接続の健全性チェック
      await _checkSupabaseConnection();
      
      await Future.wait([
        loadAccounts(),
        loadPosts(),
        loadCustomTags(),
      ]);
    } catch (e) {
      _setError('データの読み込みに失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Supabase接続の健全性チェック
  Future<void> _checkSupabaseConnection() async {
    try {
      // 簡単な接続テスト（アカウントテーブルの件数を取得）
      await _accountRepository.getAllAccounts();
      
      print('✅ Supabase接続確認済み');
    } catch (e) {
      print('❌ Supabase接続エラー: $e');
      
      // 設定に関する詳細なエラーメッセージを生成
      String detailedError = _generateDetailedErrorMessage(e);
      throw Exception(detailedError);
    }
  }
  
  // 詳細なエラーメッセージを生成
  String _generateDetailedErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('connection failed') || errorString.contains('socket')) {
      return '''
🔗 Supabase接続エラー

考えられる原因：
• SupabaseのAPIキーが設定されていない
• ネットワーク接続の問題
• SupabaseのURLが正しくない

解決方法：
1. fix_supabase_personal_use.sql をSupabaseで実行
2. lib/core/supabase_config.dart にAPIキーを設定
3. ネットワーク接続を確認

詳細: $error''';
    }
    
    if (errorString.contains('permission') || errorString.contains('unauthorized')) {
      return '''
🔐 アクセス権限エラー

考えられる原因：
• RLS (Row Level Security) が有効になっている
• 認証が必要な設定になっている

解決方法：
fix_supabase_personal_use.sql をSupabaseのSQLエディタで実行してRLSを無効化してください

詳細: $error''';
    }
    
    if (errorString.contains('table') || errorString.contains('relation')) {
      return '''
📊 データベーステーブルエラー

考えられる原因：
• Supabaseでテーブルが作成されていない

解決方法：
supabase_schema.sql をSupabaseのSQLエディタで実行してテーブルを作成してください

詳細: $error''';
    }
    
    return '予期しないエラーが発生しました: $error';
  }

  // アカウントの読み込み
  Future<void> loadAccounts() async {
    try {
      _accounts = await _accountRepository.getAllAccounts();
      notifyListeners();
    } catch (e) {
      _setError('アカウントの読み込みに失敗しました: $e');
    }
  }

  // 投稿の読み込み
  Future<void> loadPosts() async {
    try {
      _posts = await _postRepository.getAllPosts();
      notifyListeners();
    } catch (e) {
      _setError('投稿の読み込みに失敗しました: $e');
    }
  }

  // 特定の日の投稿を取得
  Future<List<SnsPost>> getPostsByDate(DateTime date) async {
    try {
      return await _postRepository.getPostsByDate(date);
    } catch (e) {
      _setError('投稿の取得に失敗しました: $e');
      return [];
    }
  }

  // 日付範囲の投稿を取得
  Future<List<SnsPost>> getPostsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _postRepository.getPostsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _setError('投稿の取得に失敗しました: $e');
      return [];
    }
  }

  // アカウントの作成
  Future<bool> createAccount(SnsAccount account) async {
    try {
      final newAccount = await _accountRepository.createAccount(account);
      _accounts.add(newAccount);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('アカウントの作成に失敗しました: $e');
      return false;
    }
  }

  // アカウントの更新
  Future<bool> updateAccount(SnsAccount account) async {
    try {
      final updatedAccount = await _accountRepository.updateAccount(account);
      final index = _accounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        _accounts[index] = updatedAccount;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('アカウントの更新に失敗しました: $e');
      return false;
    }
  }

  // アカウントの削除
  Future<bool> deleteAccount(String id) async {
    try {
      await _accountRepository.deleteAccount(id);
      _accounts.removeWhere((account) => account.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('アカウントの削除に失敗しました: $e');
      return false;
    }
  }

  // 投稿の作成
  Future<bool> createPost(SnsPost post) async {
    try {
      final newPost = await _postRepository.createPost(post);
      _posts.add(newPost);
      _posts.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
      notifyListeners();
      return true;
    } catch (e) {
      _setError('投稿の作成に失敗しました: $e');
      return false;
    }
  }

  // 投稿の更新
  Future<bool> updatePost(SnsPost post) async {
    try {
      final updatedPost = await _postRepository.updatePost(post);
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = updatedPost;
        _posts.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('投稿の更新に失敗しました: $e');
      return false;
    }
  }

  // 投稿の削除
  Future<bool> deletePost(String id) async {
    try {
      await _postRepository.deletePost(id);
      _posts.removeWhere((post) => post.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('投稿の削除に失敗しました: $e');
      return false;
    }
  }

  // 投稿ステータスの更新
  Future<bool> updatePostStatus(String id, PostStatus status) async {
    try {
      final updatedPost = await _postRepository.updatePostStatus(id, status);
      final index = _posts.indexWhere((p) => p.id == id);
      if (index != -1) {
        _posts[index] = updatedPost;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('投稿ステータスの更新に失敗しました: $e');
      return false;
    }
  }

  // エラーのクリア
  void clearError() {
    _setError(null);
  }

  // データのリフレッシュ
  Future<void> refreshData() async {
    await loadData();
  }

  // カスタムタグの読み込み
  Future<void> loadCustomTags() async {
    try {
      _customTags = await _customTagRepository.getAllCustomTags();
      notifyListeners();
    } catch (e) {
      _setError('カスタムタグの読み込みに失敗しました: $e');
    }
  }

  // カスタムタグの作成
  Future<bool> createCustomTag(String tag) async {
    try {
      // タグの検証
      if (!_customTagRepository.isValidTag(tag)) {
        _setError('無効なタグです。英数字、日本語、アンダースコアのみ使用可能です（1-30文字）');
        return false;
      }

      final newTag = await _customTagRepository.createCustomTag(tag);
      _customTags.add(newTag);
      _customTags.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
      return true;
    } catch (e) {
      _setError('カスタムタグの作成に失敗しました: $e');
      return false;
    }
  }

  // カスタムタグの削除
  Future<bool> deleteCustomTag(String id) async {
    try {
      await _customTagRepository.deleteCustomTag(id);
      _customTags.removeWhere((tag) => tag.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('カスタムタグの削除に失敗しました: $e');
      return false;
    }
  }

  // タグの検証
  bool isValidCustomTag(String tag) {
    return _customTagRepository.isValidTag(tag);
  }

  // タグの正規化
  String normalizeTag(String tag) {
    String normalized = tag.trim();
    if (!normalized.startsWith('#')) {
      normalized = '#$normalized';
    }
    return normalized.replaceAll(RegExp(r'\s+'), '');
  }
} 