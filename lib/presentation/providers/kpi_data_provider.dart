import 'package:flutter/foundation.dart';
import '../../data/models/kpi_model.dart';
import '../../data/repositories/kpi_repository.dart';
import '../../data/repositories/phase_repository.dart';

class KpiDataProvider extends ChangeNotifier {
  final KpiRepository _kpiRepository = KpiRepository();
  final PhaseRepository _phaseRepository = PhaseRepository();

  // State
  List<KpiModel> _kpis = [];
  List<PhaseModel> _phases = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<KpiModel> get kpis => _kpis;
  List<PhaseModel> get phases => _phases;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // アクティブなKPIのみを取得
  List<KpiModel> get activeKpis => _kpis.where((kpi) => kpi.isActive).toList();

  // アクティブなフェーズのみを取得
  List<PhaseModel> get activePhases => _phases.where((phase) => phase.isActive).toList();

  // KPI別の集計
  List<KpiModel> get kpiList => _kpis.where((kpi) => kpi.type == KpiType.kpi).toList();
  List<KpiModel> get kgiList => _kpis.where((kpi) => kpi.type == KpiType.kgi).toList();

  // フェーズ別KPI取得
  List<KpiModel> getKpisByPhase(String? phaseId) {
    if (phaseId == null) {
      return _kpis.where((kpi) => kpi.phaseId == null).toList();
    }
    return _kpis.where((kpi) => kpi.phaseId == phaseId).toList();
  }

  // Progress統計
  Map<String, double> get progressStats {
    if (_kpis.isEmpty) return {'average': 0.0, 'onTrack': 0.0, 'needsAttention': 0.0};
    
    final activeKpis = _kpis.where((kpi) => kpi.isActive).toList();
    if (activeKpis.isEmpty) return {'average': 0.0, 'onTrack': 0.0, 'needsAttention': 0.0};

    final averageProgress = activeKpis.map((kpi) => kpi.progress).reduce((a, b) => a + b) / activeKpis.length;
    final onTrackCount = activeKpis.where((kpi) => kpi.isOnTrack).length;
    final needsAttentionCount = activeKpis.where((kpi) => kpi.needsAttention).length;

    return {
      'average': averageProgress,
      'onTrack': (onTrackCount / activeKpis.length) * 100,
      'needsAttention': (needsAttentionCount / activeKpis.length) * 100,
    };
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
      await Future.wait([
        loadPhases(),
        loadKpis(),
      ]);
    } catch (e) {
      _setError('データの読み込みに失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // フェーズの読み込み
  Future<void> loadPhases() async {
    try {
      _phases = await _phaseRepository.getAllPhases();
      notifyListeners();
    } catch (e) {
      _setError('フェーズの読み込みに失敗しました: $e');
    }
  }

  // KPIの読み込み
  Future<void> loadKpis() async {
    try {
      _kpis = await _kpiRepository.getAllKpis();
      notifyListeners();
    } catch (e) {
      _setError('KPIの読み込みに失敗しました: $e');
    }
  }

  // フェーズの作成
  Future<bool> createPhase(PhaseModel phase) async {
    try {
      final newPhase = await _phaseRepository.createPhaseWithAutoOrder(phase);
      _phases.add(newPhase);
      _phases.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
      return true;
    } catch (e) {
      _setError('フェーズの作成に失敗しました: $e');
      return false;
    }
  }

  // フェーズの更新
  Future<bool> updatePhase(PhaseModel phase) async {
    try {
      final updatedPhase = await _phaseRepository.updatePhase(phase);
      final index = _phases.indexWhere((p) => p.id == phase.id);
      if (index != -1) {
        _phases[index] = updatedPhase;
        _phases.sort((a, b) => a.order.compareTo(b.order));
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('フェーズの更新に失敗しました: $e');
      return false;
    }
  }

  // フェーズの削除
  Future<bool> deletePhase(String id) async {
    try {
      await _phaseRepository.deletePhase(id);
      _phases.removeWhere((phase) => phase.id == id);
      // 関連するKPIのphaseIdをnullにセット
      for (int i = 0; i < _kpis.length; i++) {
        if (_kpis[i].phaseId == id) {
          _kpis[i] = _kpis[i].copyWith(phaseId: null);
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError('フェーズの削除に失敗しました: $e');
      return false;
    }
  }

  // KPIの作成
  Future<bool> createKpi(KpiModel kpi) async {
    try {
      final newKpi = await _kpiRepository.createKpi(kpi);
      _kpis.add(newKpi);
      _kpis.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
      return true;
    } catch (e) {
      _setError('KPIの作成に失敗しました: $e');
      return false;
    }
  }

  // KPIの更新
  Future<bool> updateKpi(KpiModel kpi) async {
    try {
      final updatedKpi = await _kpiRepository.updateKpi(kpi);
      final index = _kpis.indexWhere((k) => k.id == kpi.id);
      if (index != -1) {
        _kpis[index] = updatedKpi;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('KPIの更新に失敗しました: $e');
      return false;
    }
  }

  // KPIの削除
  Future<bool> deleteKpi(String id) async {
    try {
      await _kpiRepository.deleteKpi(id);
      _kpis.removeWhere((kpi) => kpi.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('KPIの削除に失敗しました: $e');
      return false;
    }
  }

  // KPIの現在値を更新
  Future<bool> updateKpiCurrentValue(String id, double currentValue) async {
    try {
      final updatedKpi = await _kpiRepository.updateKpiCurrentValue(id, currentValue);
      final index = _kpis.indexWhere((k) => k.id == id);
      if (index != -1) {
        _kpis[index] = updatedKpi;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('KPI現在値の更新に失敗しました: $e');
      return false;
    }
  }

  // フェーズの並び替え
  Future<bool> reorderPhases(List<String> phaseIds) async {
    try {
      await _phaseRepository.reorderPhases(phaseIds);
      // ローカルの順序も更新
      for (int i = 0; i < phaseIds.length; i++) {
        final index = _phases.indexWhere((p) => p.id == phaseIds[i]);
        if (index != -1) {
          _phases[index] = _phases[index].copyWith(order: i + 1);
        }
      }
      _phases.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
      return true;
    } catch (e) {
      _setError('フェーズの並び替えに失敗しました: $e');
      return false;
    }
  }

  // エラークリア
  void clearError() {
    _setError(null);
  }

  // データのリフレッシュ
  Future<void> refresh() async {
    await loadData();
  }
} 