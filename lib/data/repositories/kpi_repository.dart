import '../../core/supabase_config.dart';
import '../models/kpi_model.dart';

class KpiRepository {
  static const String _tableName = 'kpis';
  
  final _supabase = SupabaseConfig.client;

  // すべてのKPIを取得
  Future<List<KpiModel>> getAllKpis() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      
      return response
          .map<KpiModel>((data) => KpiModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('KPIの取得に失敗しました: $e');
    }
  }

  // アクティブなKPIのみを取得
  Future<List<KpiModel>> getActiveKpis() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return response
          .map<KpiModel>((data) => KpiModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('アクティブなKPIの取得に失敗しました: $e');
    }
  }

  // タイプ別KPIを取得
  Future<List<KpiModel>> getKpisByType(KpiType type) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('type', type.name)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return response
          .map<KpiModel>((data) => KpiModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('${type.displayName}の取得に失敗しました: $e');
    }
  }

  // フェーズ別KPIを取得
  Future<List<KpiModel>> getKpisByPhase(String phaseId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('phase_id', phaseId)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return response
          .map<KpiModel>((data) => KpiModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('フェーズ別KPIの取得に失敗しました: $e');
    }
  }

  // IDでKPIを取得
  Future<KpiModel?> getKpiById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();
      
      return KpiModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // KPIを作成
  Future<KpiModel> createKpi(KpiModel kpi) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(kpi.toJson())
          .select()
          .single();
      
      return KpiModel.fromJson(response);
    } catch (e) {
      throw Exception('KPIの作成に失敗しました: $e');
    }
  }

  // KPIを更新
  Future<KpiModel> updateKpi(KpiModel kpi) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update(kpi.toJson())
          .eq('id', kpi.id)
          .select()
          .single();
      
      return KpiModel.fromJson(response);
    } catch (e) {
      throw Exception('KPIの更新に失敗しました: $e');
    }
  }

  // KPIを削除
  Future<void> deleteKpi(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('KPIの削除に失敗しました: $e');
    }
  }

  // KPIの現在値を更新
  Future<KpiModel> updateKpiCurrentValue(String id, double currentValue) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update({
            'current_value': currentValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();
      
      return KpiModel.fromJson(response);
    } catch (e) {
      throw Exception('KPI現在値の更新に失敗しました: $e');
    }
  }

  // 一括でKPIの現在値を更新
  Future<List<KpiModel>> bulkUpdateCurrentValues(Map<String, double> updates) async {
    try {
      final List<KpiModel> updatedKpis = [];
      
      for (final entry in updates.entries) {
        final updatedKpi = await updateKpiCurrentValue(entry.key, entry.value);
        updatedKpis.add(updatedKpi);
      }
      
      return updatedKpis;
    } catch (e) {
      throw Exception('KPI一括更新に失敗しました: $e');
    }
  }
} 