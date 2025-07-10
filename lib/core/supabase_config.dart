import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // 個人使用向けの設定（必要に応じて変更してください）
  static const String _fallbackUrl = 'https://grpbtbztxvtsbvtdqita.supabase.co';
  static const String _fallbackAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdycGJ0Ynp0eHZ0c2J2dGRxaXRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIwNzY4ODcsImV4cCI6MjA2NzY1Mjg4N30.7xi-OpL6uVIUzMf1QHHE0KxMQRxyrsUDV5vfkXDyoR0'; // Supabase APIキー設定完了
  
  static String get url {
    try {
      return dotenv.env['SUPABASE_URL'] ?? _fallbackUrl;
    } catch (e) {
      return _fallbackUrl;
    }
  }
  
  static String get anonKey {
    try {
      return dotenv.env['SUPABASE_ANON_KEY'] ?? _fallbackAnonKey;
    } catch (e) {
      return _fallbackAnonKey;
    }
  }
  
  static String get environment {
    try {
      return dotenv.env['ENVIRONMENT'] ?? 'development';
    } catch (e) {
      return 'development';
    }
  }
  
  // 個人使用向けの開発者モード設定
  static bool get isDevMode {
    try {
      return dotenv.env['DEV_MODE']?.toLowerCase() == 'true' || true; // デフォルトで開発モード
    } catch (e) {
      return true;
    }
  }
  
  static bool get skipAuth {
    try {
      return dotenv.env['SKIP_AUTH']?.toLowerCase() == 'true' || true; // デフォルトで認証スキップ
    } catch (e) {
      return true;
    }
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    try {
      // .envファイルの読み込みを試行（存在しなくてもエラーにしない）
      await dotenv.load(fileName: '.env');
    } catch (e) {
      print('⚠️ .envファイルが見つかりません。フォールバック設定を使用します。');
      print('📝 .envファイルを作成してSupabase設定を追加することをお勧めします。');
    }
    
    print('🔧 Supabase初期化開始...');
    print('🔗 URL: $url');
    print('🔑 APIキー先頭: ${anonKey.substring(0, 20)}...');
    print('🛠️ 環境: $environment');
    print('🌐 プラットフォーム: Web');
    
    try {
      // Supabaseの初期化（Web用最適化設定）
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: true, // デバッグモード有効
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.implicit, // Web用認証フロー
          pkceAsyncStorage: null, // Web用でPKCE無効化
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
          timeout: Duration(seconds: 20),
        ),
        postgrestOptions: const PostgrestClientOptions(
          schema: 'public',
        ),
        storageOptions: const StorageClientOptions(
          retryAttempts: 3,
        ),
      );
      
      print('✅ Supabase初期化完了');
      
      // 接続テスト
      await _testConnection();
      
    } catch (e) {
      print('❌ Supabase初期化エラー: $e');
      print('🔍 詳細情報:');
      print('  - URL: $url');
      print('  - APIキー設定: ${anonKey.isNotEmpty}');
      print('  - 環境: $environment');
      print('  - エラータイプ: ${e.runtimeType}');
      
      // Web特有のエラーメッセージ
      if (e.toString().contains('XMLHttpRequest error')) {
        print('💡 XMLHttpRequestエラー - CORS制限の可能性があります');
      }
      if (e.toString().contains('NetworkError') || e.toString().contains('Failed to fetch')) {
        print('💡 ネットワークエラー - ブラウザのセキュリティ制限の可能性があります');  
      }
      
      rethrow;
    }
  }
  
  // 接続テスト用メソッド
  static Future<void> _testConnection() async {
    try {
      print('🧪 Supabase接続テスト開始...');
      
      // 段階的接続テスト
      
      // 1. 基本的なヘルスチェック
      print('📡 1/3: ヘルスチェック実行中...');
      final healthResponse = await client.rpc('version');
      print('✅ ヘルスチェック成功');
      
      // 2. テーブル存在確認  
      print('📊 2/3: テーブル存在確認中...');
      final tableResponse = await client.from('sns_accounts').select('count').limit(1);
      print('✅ テーブル接続成功: ${tableResponse.length} レコード応答');
      
      // 3. フェーズテーブル確認（KPI管理で必要）
      print('📋 3/3: フェーズテーブル確認中...');
      final phaseResponse = await client.from('phases').select('count').limit(1);
      print('✅ フェーズテーブル接続成功: ${phaseResponse.length} レコード応答');
      
      print('🎉 すべてのSupabase接続テスト成功！');
      
    } catch (e) {
      print('❌ Supabase接続テストエラー: $e');
      print('🔍 エラー詳細:');
      print('  - エラータイプ: ${e.runtimeType}');
      print('  - エラー内容: ${e.toString()}');
      
      // 具体的なエラー分析
      final errorString = e.toString().toLowerCase();
      
      if (errorString.contains('cors')) {
        print('💡 CORS問題: ブラウザのCORS制限です');
        print('🔧 解決策: CORS無効化ブラウザまたはプロキシサーバーを使用');
      }
      
      if (errorString.contains('401') || errorString.contains('unauthorized')) {
        print('💡 認証エラー: APIキーまたはRLS設定を確認');
        print('🔧 解決策: fix_supabase_personal_use.sql を実行');
      }
      
      if (errorString.contains('operation not permitted') || errorString.contains('permission denied')) {
        print('💡 権限エラー: macOS/ブラウザのセキュリティ制限');
        print('🔧 解決策: CORS無効化ブラウザまたは別の接続方法を試行');
      }
      
      if (errorString.contains('network') || errorString.contains('fetch')) {
        print('💡 ネットワークエラー: 接続またはファイアウォール問題');
        print('🔧 解決策: ネットワーク設定を確認');
      }
      
      rethrow;
    }
  }
  
  // アプリ内接続テスト用メソッド（静的メソッドとして追加）
  static Future<Map<String, dynamic>> performConnectionTest() async {
    final Map<String, dynamic> result = {
      'success': false,
      'errors': <String>[],
      'details': <String, dynamic>{},
    };
    
    try {
      print('🧪 アプリ内Supabase接続テスト開始...');
      
      // 1. 基本接続テスト
      try {
        final response = await client.from('phases').select('count').limit(1);
        result['details']['phases_connection'] = true;
        result['details']['phases_count'] = response.length;
        print('✅ フェーズテーブル接続成功');
      } catch (e) {
        result['errors'].add('フェーズテーブル接続失敗: $e');
        result['details']['phases_connection'] = false;
        print('❌ フェーズテーブル接続失敗: $e');
      }
      
      // 2. SNSアカウントテーブルテスト
      try {
        final response = await client.from('sns_accounts').select('count').limit(1);
        result['details']['sns_accounts_connection'] = true;
        result['details']['sns_accounts_count'] = response.length;
        print('✅ SNSアカウントテーブル接続成功');
      } catch (e) {
        result['errors'].add('SNSアカウントテーブル接続失敗: $e');
        result['details']['sns_accounts_connection'] = false;
        print('❌ SNSアカウントテーブル接続失敗: $e');
      }
      
      // 3. 書き込みテスト（テストレコード作成・削除）
      try {
        print('📝 書き込みテスト実行中...');
        
        final testAccountId = 'test-connection-${DateTime.now().millisecondsSinceEpoch}';
        final testAccount = {
          'id': testAccountId,
          'account_name': 'connection_test',
          'platform': 'instagram',
          'bio': 'テスト用アカウント',
          'followers_count': 0,
          'following_count': 0,
          'posts_count': 0,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        // テストレコード作成
        final insertResponse = await client
            .from('sns_accounts')
            .insert(testAccount)
            .select()
            .single();
        
        result['details']['write_test'] = true;
        print('✅ 書き込みテスト成功 - レコード作成');
        
        // テストレコード削除
        await client
            .from('sns_accounts')
            .delete()
            .eq('id', testAccountId);
        
        result['details']['delete_test'] = true;
        print('✅ 書き込みテスト成功 - レコード削除');
        
      } catch (e) {
        result['errors'].add('書き込みテスト失敗: $e');
        result['details']['write_test'] = false;
        print('❌ 書き込みテスト失敗: $e');
      }
      
      // 4. 全体的な成功判定
      if (result['errors'].isEmpty) {
        result['success'] = true;
        print('🎉 すべての接続テスト成功！');
      } else {
        print('⚠️ 一部の接続テストが失敗しました');
      }
      
    } catch (e) {
      result['errors'].add('予期しないエラー: $e');
      print('❌ 予期しないエラー: $e');
    }
    
    return result;
  }
  
  // 設定状況の確認用メソッド
  static void printConfigStatus() {
    print('=== Supabase設定状況 ===');
    print('URL: $url');
    print('APIキー設定済み: ${anonKey.isNotEmpty ? "✅" : "❌"}');
    print('環境: $environment');
    print('開発モード: $isDevMode');
    print('認証スキップ: $skipAuth');
    print('====================');
  }
} 