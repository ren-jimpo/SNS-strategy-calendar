import '../../core/supabase_config.dart';
import '../models/custom_tag.dart';

class CustomTagRepository {
  static const String _tableName = 'custom_tags';
  
  final _supabase = SupabaseConfig.client;

  // すべてのカスタムタグを取得
  Future<List<CustomTag>> getAllCustomTags() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return response
          .map<CustomTag>((data) => CustomTag.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('カスタムタグの取得に失敗しました: $e');
    }
  }

  // IDでカスタムタグを取得
  Future<CustomTag?> getCustomTagById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();
      
      return CustomTag.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // タグ名で検索（重複チェック用）
  Future<CustomTag?> getCustomTagByTag(String tag) async {
    try {
      final normalizedTag = _normalizeTag(tag);
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('tag', normalizedTag)
          .eq('is_active', true)
          .maybeSingle();
      
      if (response == null) return null;
      return CustomTag.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // カスタムタグを作成
  Future<CustomTag> createCustomTag(String tag) async {
    try {
      final normalizedTag = _normalizeTag(tag);
      
      // 重複チェック
      final existingTag = await getCustomTagByTag(normalizedTag);
      if (existingTag != null) {
        throw Exception('このタグは既に存在します');
      }

      final customTag = CustomTag(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tag: normalizedTag,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await _supabase
          .from(_tableName)
          .insert(customTag.toJson())
          .select()
          .single();
      
      return CustomTag.fromJson(response);
    } catch (e) {
      throw Exception('カスタムタグの作成に失敗しました: $e');
    }
  }

  // カスタムタグを更新
  Future<CustomTag> updateCustomTag(CustomTag customTag) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update(customTag.toJson())
          .eq('id', customTag.id)
          .select()
          .single();
      
      return CustomTag.fromJson(response);
    } catch (e) {
      throw Exception('カスタムタグの更新に失敗しました: $e');
    }
  }

  // カスタムタグを削除（論理削除）
  Future<void> deleteCustomTag(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'is_active': false, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw Exception('カスタムタグの削除に失敗しました: $e');
    }
  }

  // カスタムタグを物理削除
  Future<void> permanentDeleteCustomTag(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('カスタムタグの削除に失敗しました: $e');
    }
  }

  // タグを正規化（#付与、小文字変換、空白除去）
  String _normalizeTag(String tag) {
    String normalized = tag.trim();
    
    // #で始まっていない場合は追加
    if (!normalized.startsWith('#')) {
      normalized = '#$normalized';
    }
    
    // 空白を除去
    normalized = normalized.replaceAll(RegExp(r'\s+'), '');
    
    return normalized;
  }

  // タグの検証
  bool isValidTag(String tag) {
    final normalized = _normalizeTag(tag);
    
    // 最小長チェック（#を除いて1文字以上）
    if (normalized.length <= 1) return false;
    
    // 最大長チェック（#を除いて30文字以下）
    if (normalized.length > 31) return false;
    
    // 使用可能文字チェック（英数字、日本語、一部記号）
    final validPattern = RegExp(r'^#[a-zA-Z0-9\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF_]+$');
    return validPattern.hasMatch(normalized);
  }
} 