import '../../core/supabase_config.dart';
import '../models/kpi_model.dart';

class PhaseRepository {
  static const String _tableName = 'phases';
  
  final _supabase = SupabaseConfig.client;

  // すべてのフェーズを取得
  Future<List<PhaseModel>> getAllPhases() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('order', ascending: true);
      
      return response
          .map<PhaseModel>((data) => PhaseModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('フェーズの取得に失敗しました: $e');
    }
  }

  // アクティブなフェーズのみを取得
  Future<List<PhaseModel>> getActivePhases() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('order', ascending: true);
      
      return response
          .map<PhaseModel>((data) => PhaseModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('アクティブなフェーズの取得に失敗しました: $e');
    }
  }

  // IDでフェーズを取得
  Future<PhaseModel?> getPhaseById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();
      
      return PhaseModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // フェーズを作成
  Future<PhaseModel> createPhase(PhaseModel phase) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(phase.toJson())
          .select()
          .single();
      
      return PhaseModel.fromJson(response);
    } catch (e) {
      throw Exception('フェーズの作成に失敗しました: $e');
    }
  }

  // フェーズを更新
  Future<PhaseModel> updatePhase(PhaseModel phase) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update(phase.toJson())
          .eq('id', phase.id)
          .select()
          .single();
      
      return PhaseModel.fromJson(response);
    } catch (e) {
      throw Exception('フェーズの更新に失敗しました: $e');
    }
  }

  // フェーズを削除
  Future<void> deletePhase(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('フェーズの削除に失敗しました: $e');
    }
  }

  // フェーズの順序を更新
  Future<void> updatePhaseOrder(String id, int newOrder) async {
    try {
      await _supabase
          .from(_tableName)
          .update({
            'order': newOrder,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('フェーズ順序の更新に失敗しました: $e');
    }
  }

  // 複数フェーズの順序を一括更新
  Future<void> reorderPhases(List<String> phaseIds) async {
    try {
      for (int i = 0; i < phaseIds.length; i++) {
        await updatePhaseOrder(phaseIds[i], i + 1);
      }
    } catch (e) {
      throw Exception('フェーズの並び替えに失敗しました: $e');
    }
  }

  // 最大順序番号を取得
  Future<int> getMaxOrder() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('order')
          .order('order', ascending: false)
          .limit(1);
      
      if (response.isEmpty) return 0;
      return response.first['order'] as int;
    } catch (e) {
      return 0;
    }
  }

  // 新しいフェーズに自動で順序を割り当てて作成
  Future<PhaseModel> createPhaseWithAutoOrder(PhaseModel phase) async {
    try {
      final maxOrder = await getMaxOrder();
      final phaseWithOrder = phase.copyWith(order: maxOrder + 1);
      return await createPhase(phaseWithOrder);
    } catch (e) {
      throw Exception('フェーズの作成に失敗しました: $e');
    }
  }
} 