import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/kpi_model.dart';
import '../../widgets/kpi_edit_modal.dart';
import '../../widgets/phase_edit_modal.dart';
import '../../widgets/kpi_progress_edit_modal.dart';
import '../../providers/kpi_data_provider.dart';

class KpiManagementScreen extends StatefulWidget {
  const KpiManagementScreen({super.key});

  @override
  State<KpiManagementScreen> createState() => _KpiManagementScreenState();
}

class _KpiManagementScreenState extends State<KpiManagementScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  PhaseModel? _selectedPhase;

  // ローディング状態
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Supabaseからデータを読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    await kpiProvider.loadData();
    
    if (mounted) {
      // フェーズデータが読み込まれた後にTabControllerを初期化
      _initializeTabController(kpiProvider);
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeTabController(KpiDataProvider kpiProvider) {
    final activePhases = kpiProvider.activePhases;
    
    // 既存のTabControllerを破棄
    _tabController?.dispose();
    
    if (activePhases.isNotEmpty) {
      _tabController = TabController(length: activePhases.length, vsync: this);
      _selectedPhase = activePhases.first;
      
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          setState(() {
            _selectedPhase = activePhases[_tabController!.index];
          });
        }
      });
    } else {
      _tabController = null;
      _selectedPhase = null;
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 768;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: Consumer<KpiDataProvider>(
        builder: (context, kpiProvider, child) {
          if (_isLoading || kpiProvider.isLoading) {
            return const Center(
              child: CupertinoActivityIndicator(radius: 16),
            );
          }
          
          if (kpiProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 64,
                    color: AppColors.systemRed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'エラーが発生しました',
                    style: AppTypography.title2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kpiProvider.error!,
                    style: AppTypography.body.copyWith(
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CupertinoButton.filled(
                    onPressed: _loadData,
                    child: const Text('再試行'),
                  ),
                ],
              ),
            );
          }
          
          return SafeArea(
            child: Column(
              children: [
                _buildHeader(kpiProvider),
                Expanded(
                  child: isWideScreen 
                    ? _buildWideScreenLayout(kpiProvider) 
                    : _buildMobileLayout(kpiProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(KpiDataProvider kpiProvider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPurple.withOpacity(0.1),
            AppColors.systemIndigo.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentPurple.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.separator.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accentPurple, AppColors.systemIndigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.chart_pie_fill,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KPI管理',
                  style: AppTypography.title1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentPurple,
                  ),
                ),
                Text(
                  '長期戦略・目標管理',
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.accentPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.accentPurple.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _showManagementMenu,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  CupertinoIcons.gear,
                  color: AppColors.accentPurple,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.accentPurple,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _showAddMenu,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  CupertinoIcons.plus,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWideScreenLayout(KpiDataProvider kpiProvider) {
    return Row(
      children: [
        // 左側：KGI + フェーズタブ
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildKgiOverview(kpiProvider),
                const SizedBox(height: 16),
                _buildPhaseTabSelector(),
                const SizedBox(height: 16),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: _buildKpiList(),
                ),
              ],
            ),
          ),
        ),
        // 右側：詳細ビュー
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                _buildPhaseDetailHeader(),
                const SizedBox(height: 16),
                Expanded(child: _buildPhaseAnalytics()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(KpiDataProvider kpiProvider) {
    final activePhases = kpiProvider.activePhases;
    
    return Column(
      children: [
        Flexible(
          flex: 0,
          child: _buildKgiOverview(kpiProvider),
        ),
        // フェーズがない場合は空状態を表示、ある場合はタブを表示
        if (activePhases.isEmpty) ...[
          Expanded(
            child: _buildEmptyPhaseState(),
          ),
        ] else ...[
          Flexible(
            flex: 0,
            child: _buildPhaseTabBar(),
          ),
          Expanded(
            child: _tabController != null 
              ? TabBarView(
                  controller: _tabController,
                  children: activePhases.map((phase) => _buildPhaseContent(phase)).toList(),
                )
              : _buildEmptyPhaseState(),
          ),
        ],
      ],
    );
  }

  Widget _buildKgiOverview(KpiDataProvider kpiProvider) {
    final kgiList = kpiProvider.kgiList;
    final overallProgress = kgiList.isNotEmpty 
        ? kgiList.map((kgi) => kgi.progress).reduce((a, b) => a + b) / kgiList.length
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.getSeparator(context).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accentPurple, AppColors.systemIndigo],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.chart_pie_fill,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KGI戦略目標',
                      style: AppTypography.headline.copyWith(
                        color: AppColors.accentPurple,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '長期的なビジネス成果指標',
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              // KGI追加ボタン
              GestureDetector(
                onTap: () => _showAddKgiDialog(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPurple.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.plus,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.systemGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_calculateOverallProgress(kpiProvider).toStringAsFixed(0)}%',
                  style: AppTypography.subhead.copyWith(
                    color: AppColors.systemGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // KGIが空の場合の表示
          if (kgiList.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.systemGray6.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.separator.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.star_circle,
                    size: 48,
                    color: AppColors.systemGray3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'KGIがありません',
                    style: AppTypography.headline.copyWith(
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '戦略目標を設定して成果を測定しましょう',
                    style: AppTypography.body.copyWith(
                      color: AppColors.getTertiaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _showAddKgiDialog(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accentPurple,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.plus_circle_fill,
                            color: AppColors.accentPurple,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '最初のKGIを追加',
                            style: AppTypography.body.copyWith(
                              color: AppColors.accentPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // KGI縦一列表示（KPIの表示形式を参考）
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: kgiList.length,
              itemBuilder: (context, index) {
                final kgi = kgiList[index];
                return _buildKgiCard(kgi);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKgiCard(KpiModel kgi) {
    final progress = kgi.progress;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.getSeparator(context).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.star_fill,
                  color: AppColors.accentPurple,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kgi.name,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    if (kgi.description.isNotEmpty)
                      Text(
                        kgi.description,
                        style: AppTypography.caption1.copyWith(
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: AppTypography.subhead.copyWith(
                  color: _getProgressColor(progress),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showProgressEditDialog(kgi),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.systemBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.systemBlue.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.gauge,
                    color: AppColors.systemBlue,
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showEditKpiDialog(kgi),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.systemGray6.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.separator.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.pencil,
                    color: AppColors.systemBlue,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '現在値: ${kgi.currentValue.toStringAsFixed(1)}${kgi.unit}',
                style: AppTypography.caption1.copyWith(
                  color: AppColors.secondaryLabel,
                ),
              ),
              const Spacer(),
              Text(
                '目標値: ${kgi.targetValue.toStringAsFixed(1)}${kgi.unit}',
                style: AppTypography.caption1.copyWith(
                  color: AppColors.tertiaryLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: AppColors.systemGray5,
            valueColor: AlwaysStoppedAnimation(_getProgressColor(progress)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseTabSelector() {
    return Consumer<KpiDataProvider>(
      builder: (context, kpiProvider, child) {
        final phases = kpiProvider.activePhases;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.secondarySystemGroupedBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.separator.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // フェーズセクションヘッダー
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.separator.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.layers_alt_fill,
                      color: AppColors.systemPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'フェーズ管理',
                      style: AppTypography.headline.copyWith(
                        color: AppColors.systemPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showAddPhaseDialog(),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.systemPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.plus,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              if (phases.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.layers_alt,
                        color: AppColors.secondaryLabel,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'フェーズがありません',
                        style: AppTypography.body.copyWith(
                          color: AppColors.secondaryLabel,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'フェーズを追加してKPIを整理しましょう',
                        style: AppTypography.caption1.copyWith(
                          color: AppColors.tertiaryLabel,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: phases.map((phase) {
                      final phaseKpis = kpiProvider.getKpisByPhase(phase.id);
                      final progress = _calculatePhaseKpiProgress(phaseKpis);
                      final color = _getPhaseColorFromIndex(phases.indexOf(phase));
                      
                      return _buildPhaseTabItemFromModel(phase, phaseKpis, progress, color);
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhaseTabItemFromModel(PhaseModel phase, List<KpiModel> phaseKpis, double progress, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // フェーズの詳細表示処理
          _showPhaseDetailDialog(phase);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.layers_alt,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phase.name,
                      style: AppTypography.body.copyWith(
                        color: AppColors.label,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${phaseKpis.length}個のKPI • ${progress.toStringAsFixed(0)}%達成',
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.tertiaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  value: progress / 100,
                  strokeWidth: 3,
                  backgroundColor: AppColors.systemGray5,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showAddKpiToPhaseDialog(phase),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    CupertinoIcons.plus,
                    color: color,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ヘルパーメソッド
  double _calculatePhaseKpiProgress(List<KpiModel> kpis) {
    if (kpis.isEmpty) return 0.0;
    return kpis.map((kpi) => kpi.progress).reduce((a, b) => a + b) / kpis.length;
  }

  Color _getPhaseColorFromIndex(int index) {
    const colors = [
      AppColors.systemBlue,
      AppColors.systemGreen,
      AppColors.systemOrange,
      AppColors.systemPurple,
      AppColors.systemPink,
      AppColors.systemIndigo,
    ];
    return colors[index % colors.length];
  }

  void _showPhaseDetailDialog(PhaseModel phase) {
    final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
    final phaseKpis = kpiProvider.getKpisByPhase(phase.id);
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.systemGroupedBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.systemBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.separator.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phase.name,
                          style: AppTypography.title2.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (phase.description.isNotEmpty)
                          Text(
                            phase.description,
                            style: AppTypography.caption1.copyWith(
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: AppColors.systemGray,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: phaseKpis.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.chart_bar,
                            color: AppColors.secondaryLabel,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'このフェーズにはKPIがありません',
                            style: AppTypography.body.copyWith(
                              color: AppColors.secondaryLabel,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CupertinoButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showAddKpiToPhaseDialog(phase);
                            },
                            child: Text('KPIを追加'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: phaseKpis.length,
                      itemBuilder: (context, index) {
                        final kpi = phaseKpis[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.systemBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.separator.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: kpi.type == KpiType.kgi 
                                    ? AppColors.accentPurple 
                                    : AppColors.systemBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                kpi.type == KpiType.kgi 
                                    ? CupertinoIcons.star_fill 
                                    : CupertinoIcons.chart_bar_fill,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              kpi.name,
                              style: AppTypography.headline.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${kpi.currentValue.toStringAsFixed(1)}${kpi.unit} / ${kpi.targetValue.toStringAsFixed(1)}${kpi.unit}',
                                  style: AppTypography.body,
                                ),
                                LinearProgressIndicator(
                                  value: kpi.progress / 100,
                                  backgroundColor: AppColors.systemGray5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    kpi.isOnTrack ? AppColors.systemGreen : 
                                    kpi.needsAttention ? AppColors.systemRed : AppColors.systemOrange,
                                  ),
                                ),
                              ],
                            ),
                            trailing: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditKpiDialog(kpi);
                              },
                              child: Icon(
                                CupertinoIcons.pencil,
                                color: AppColors.systemBlue,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddKpiToPhaseDialog(PhaseModel phase) {
    final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('${phase.name}にKPIを追加'),
        message: const Text('追加するKPIのタイプを選択してください'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showKpiEditModalForPhase(phase, KpiType.kpi);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.chart_bar_circle, size: 20, color: AppColors.systemBlue),
                const SizedBox(width: 8),
                Text('KPI（成果指標）'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showKpiEditModalForPhase(phase, KpiType.kgi);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.star_circle, size: 20, color: AppColors.accentPurple),
                const SizedBox(width: 8),
                Text('KGI（戦略目標）'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  void _showKpiEditModalForPhase(PhaseModel phase, KpiType type) {
    final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KpiEditModal(
        phases: kpiProvider.phases,
        initialType: type,
        preSelectedPhaseId: phase.id,
      ),
    ).then((result) {
      if (result == true) {
        // データはプロバイダーで自動更新される
      }
    });
  }

  Widget _buildPhaseTabBar() {
    return Consumer<KpiDataProvider>(
      builder: (context, kpiProvider, child) {
        final activePhases = kpiProvider.activePhases;
        
        if (activePhases.isEmpty || _tabController == null) {
          return const SizedBox.shrink();
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.accentPurple,
            labelColor: AppColors.accentPurple,
            unselectedLabelColor: AppColors.systemGray,
            labelStyle: AppTypography.subhead.copyWith(fontWeight: FontWeight.w600),
            unselectedLabelStyle: AppTypography.subhead,
            tabs: activePhases.map((phase) {
              return Tab(text: phase.name);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPhaseContent(PhaseModel phase) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPhaseDetailHeader(phase: phase),
          const SizedBox(height: 16),
          _buildKpiList(phase: phase),
        ],
      ),
    );
  }

  Widget _buildPhaseDetailHeader({PhaseModel? phase}) {
    return Consumer<KpiDataProvider>(
      builder: (context, kpiProvider, child) {
        final targetPhase = phase ?? _selectedPhase;
        
        if (targetPhase == null) {
          return const SizedBox.shrink();
        }
        
        final color = _getPhaseColorForModel(targetPhase);
        
        // フェーズに関連するKPIを取得
        final phaseKpis = kpiProvider.kpiList.where((kpi) => 
          kpi.phaseId == targetPhase.id
        ).toList();
        
        double progress = 0;
        if (phaseKpis.isNotEmpty) {
          progress = phaseKpis.map((kpi) => kpi.progress).reduce((a, b) => a + b) / phaseKpis.length;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getPhaseIconForModel(targetPhase),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          targetPhase.name,
                          style: AppTypography.title2.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          targetPhase.description,
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${progress.toStringAsFixed(0)}%',
                      style: AppTypography.headline.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiList({PhaseModel? phase}) {
    return Consumer<KpiDataProvider>(
      builder: (context, kpiProvider, child) {
        final kpiList = kpiProvider.kpiList;
        
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondarySystemGroupedBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.separator.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー部分
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.systemBlue.withOpacity(0.1),
                      AppColors.systemIndigo.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.systemBlue, AppColors.systemIndigo],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.systemBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.chart_bar_fill,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KPI重要指標',
                            style: AppTypography.headline.copyWith(
                              color: AppColors.systemBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '実行可能な成果測定指標',
                            style: AppTypography.caption1.copyWith(
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // KPI追加ボタン
                    GestureDetector(
                      onTap: () => _showAddKpiDialog(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.systemBlue,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.systemBlue.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.plus,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.systemBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${kpiList.length}',
                        style: AppTypography.caption1.copyWith(
                          color: AppColors.systemBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // KPIリスト部分
              if (kpiList.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.chart_bar_square,
                        size: 48,
                        color: AppColors.systemGray3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'KPIがありません',
                        style: AppTypography.headline.copyWith(
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '重要指標を設定して進捗を追跡しましょう',
                        style: AppTypography.body.copyWith(
                          color: AppColors.getTertiaryTextColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _showAddKpiDialog(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.systemBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.systemBlue,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.plus_circle_fill,
                                color: AppColors.systemBlue,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '最初のKPIを追加',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.systemBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: kpiList.length,
                    itemBuilder: (context, index) {
                      final kpi = kpiList[index];
                      return _buildRealKpiItem(kpi);
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRealKpiItem(KpiModel kpi) {
    final progress = kpi.progress;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.getSeparator(context).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.chart_bar_fill,
                  color: AppColors.systemBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kpi.name,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    if (kpi.description.isNotEmpty)
                      Text(
                        kpi.description,
                        style: AppTypography.caption1.copyWith(
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: AppTypography.subhead.copyWith(
                  color: _getProgressColor(progress),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showProgressEditDialog(kpi),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.systemBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.systemBlue.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.gauge,
                    color: AppColors.systemBlue,
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showEditKpiDialog(kpi),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.systemGray6.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.separator.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.pencil,
                    color: AppColors.systemBlue,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '現在値: ${kpi.currentValue.toStringAsFixed(1)}${kpi.unit}',
                style: AppTypography.caption1.copyWith(
                  color: AppColors.secondaryLabel,
                ),
              ),
              const Spacer(),
              Text(
                '目標値: ${kpi.targetValue.toStringAsFixed(1)}${kpi.unit}',
                style: AppTypography.caption1.copyWith(
                  color: AppColors.tertiaryLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: AppColors.systemGray5,
            valueColor: AlwaysStoppedAnimation(_getProgressColor(progress)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseAnalytics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'フェーズ別パフォーマンス',
            style: AppTypography.title3.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildPhaseChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseChart() {
    return Consumer<KpiDataProvider>(
      builder: (context, kpiProvider, child) {
        final activePhases = kpiProvider.activePhases;
        
        if (activePhases.isEmpty) {
          return Center(
            child: Text(
              'フェーズデータがありません',
              style: AppTypography.body.copyWith(
                color: AppColors.secondaryLabel,
              ),
            ),
          );
        }
        
        final phaseProgressData = activePhases.asMap().entries.map((entry) {
          final index = entry.key;
          final phase = entry.value;
          
          // フェーズに関連するKPIを取得
          final phaseKpis = kpiProvider.kpiList.where((kpi) => 
            kpi.phaseId == phase.id
          ).toList();
          
          double progress = 0;
          if (phaseKpis.isNotEmpty) {
            progress = phaseKpis.map((kpi) => kpi.progress).reduce((a, b) => a + b) / phaseKpis.length;
          }
          
          return FlSpot(index.toDouble(), progress);
        }).toList();

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppColors.systemGray5,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < activePhases.length) {
                      final phaseName = activePhases[index].name;
                      // フェーズ名を4文字以内に短縮
                      final shortName = phaseName.length > 4 
                        ? '${phaseName.substring(0, 3)}...' 
                        : phaseName;
                      
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          shortName,
                          style: AppTypography.caption2.copyWith(
                            color: AppColors.tertiaryLabel,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}%',
                      style: AppTypography.caption2.copyWith(
                        color: AppColors.tertiaryLabel,
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (activePhases.length - 1).toDouble(),
            minY: 0,
            maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: phaseProgressData,
                isCurved: true,
                gradient: LinearGradient(
                  colors: [AppColors.accentPurple, AppColors.systemIndigo],
                ),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: AppColors.accentPurple,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentPurple.withOpacity(0.2),
                      AppColors.accentPurple.withOpacity(0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper Methods
  double _calculateOverallProgress(KpiDataProvider kpiProvider) {
    final kgis = kpiProvider.kgiList;
    if (kgis.isEmpty) return 0;
    
    double totalProgress = 0;
    for (final kgi in kgis) {
      totalProgress += kgi.progress;
    }
    
    return totalProgress / kgis.length;
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) return AppColors.systemGreen;
    if (progress >= 60) return AppColors.systemOrange;
    return AppColors.systemRed;
  }

  // PhaseModel用のヘルパーメソッド
  Color _getPhaseColorForModel(PhaseModel phase) {
    // フェーズの順序や名前に基づいて色を決定
    final colorList = [
      AppColors.systemBlue,
      AppColors.systemGreen,
      AppColors.systemOrange,
      AppColors.systemPurple,
      AppColors.systemIndigo,
      AppColors.systemTeal,
      AppColors.systemPink,
    ];
    
    return colorList[phase.order % colorList.length];
  }

  IconData _getPhaseIconForModel(PhaseModel phase) {
    // フェーズの名前や順序に基づいてアイコンを決定
    final phaseName = phase.name.toLowerCase();
    
    if (phaseName.contains('企画') || phaseName.contains('計画') || phaseName.contains('planning')) {
      return CupertinoIcons.lightbulb;
    } else if (phaseName.contains('開発') || phaseName.contains('制作') || phaseName.contains('development')) {
      return CupertinoIcons.hammer;
    } else if (phaseName.contains('ローンチ') || phaseName.contains('配信') || phaseName.contains('launch')) {
      return CupertinoIcons.rocket;
    } else if (phaseName.contains('成長') || phaseName.contains('拡大') || phaseName.contains('growth')) {
      return CupertinoIcons.chart_bar_fill;
    } else if (phaseName.contains('メンテナンス') || phaseName.contains('維持') || phaseName.contains('maintenance')) {
      return CupertinoIcons.gear;
    } else if (phaseName.contains('分析') || phaseName.contains('解析') || phaseName.contains('analytics')) {
      return CupertinoIcons.chart_pie;
    } else if (phaseName.contains('テスト') || phaseName.contains('検証') || phaseName.contains('test')) {
      return CupertinoIcons.checkmark_alt_circle;
    } else {
      // デフォルトアイコン（順序に基づく）
      final iconList = [
        CupertinoIcons.circle_fill,
        CupertinoIcons.square_fill,
        CupertinoIcons.triangle_fill,
        CupertinoIcons.rhombus_fill,
        CupertinoIcons.hexagon_fill,
        CupertinoIcons.star_fill,
        CupertinoIcons.heart_fill,
      ];
      
      return iconList[phase.order % iconList.length];
    }
  }

  void _showAddMenu() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('新規追加'),
        message: const Text('追加したい項目を選択してください'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showAddKgiDialog();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.star_circle, size: 20, color: AppColors.accentPurple),
                const SizedBox(width: 8),
                Text('KGI（戦略目標）を追加'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showAddKpiDialog();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.chart_bar_circle, size: 20, color: AppColors.systemBlue),
                const SizedBox(width: 8),
                Text('KPI（成果指標）を追加'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showAddPhaseDialog();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.layers_alt_fill, size: 20, color: AppColors.systemGreen),
                const SizedBox(width: 8),
                Text('フェーズを追加'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  void _showAddKgiDialog() {
    final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KpiEditModal(
        phases: kpiProvider.phases,
        initialType: KpiType.kgi,
      ),
    ).then((result) {
      if (result == true) {
        // データはプロバイダーで自動更新される
      }
    });
  }

  void _showAddKpiDialog() {
    final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KpiEditModal(
        phases: kpiProvider.phases,
        initialType: KpiType.kpi,
      ),
    ).then((result) {
      if (result == true) {
        // データはプロバイダーで自動更新される
      }
    });
  }

  void _showEditKpiDialog(KpiModel kpi) {
    final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KpiEditModal(kpi: kpi, phases: kpiProvider.phases),
    ).then((result) {
      if (result == true) {
        // データはプロバイダーで自動更新される
      }
    });
  }

  void _showManagementMenu() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('管理'),
        message: const Text('管理したい項目を選択してください'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showKpiListDialog();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.list_bullet, size: 20, color: AppColors.systemBlue),
                const SizedBox(width: 8),
                Text('KPI/KGI一覧'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showPhaseManagementDialog();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.layers_alt, size: 20, color: AppColors.systemPurple),
                const SizedBox(width: 8),
                Text('フェーズ管理'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  void _showPhaseManagementDialog() {
    final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('フェーズ管理'),
        message: const Text('フェーズの管理を行います'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showAddPhaseDialog();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.plus_circle, size: 20),
                const SizedBox(width: 8),
                Text('新しいフェーズを追加'),
              ],
            ),
          ),
          ...kpiProvider.phases.map((phase) => CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showEditPhaseDialog(phase);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.pencil, size: 20),
                const SizedBox(width: 8),
                Text('編集: ${phase.name}'),
              ],
            ),
          )),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  void _showAddPhaseDialog() {
    final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PhaseEditModal(existingPhases: kpiProvider.phases),
    ).then((result) {
      if (result == true) {
        // データはプロバイダーで自動更新される
      }
    });
  }

  void _showEditPhaseDialog(PhaseModel phase) {
    final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PhaseEditModal(
        phase: phase,
        existingPhases: kpiProvider.phases,
      ),
    ).then((result) {
      if (result == true) {
        // データはプロバイダーで自動更新される
      }
    });
  }

  void _showKpiListDialog() {
    final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.systemGroupedBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.systemBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.separator.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'KPI/KGI一覧',
                      style: AppTypography.title2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: AppColors.systemGray,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: kpiProvider.kpis.length,
                itemBuilder: (context, index) {
                  final kpi = kpiProvider.kpis[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.systemBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.separator.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: kpi.type == KpiType.kgi 
                            ? AppColors.accentPurple 
                            : AppColors.systemBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          kpi.type == KpiType.kgi 
                            ? CupertinoIcons.star_fill 
                            : CupertinoIcons.chart_bar_fill,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        kpi.name,
                        style: AppTypography.headline.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${kpi.currentValue.toStringAsFixed(1)}${kpi.unit} / ${kpi.targetValue.toStringAsFixed(1)}${kpi.unit}',
                            style: AppTypography.body,
                          ),
                          LinearProgressIndicator(
                            value: kpi.progress / 100,
                            backgroundColor: AppColors.systemGray5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              kpi.isOnTrack ? AppColors.systemGreen : 
                              kpi.needsAttention ? AppColors.systemRed : AppColors.systemOrange,
                            ),
                          ),
                        ],
                      ),
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditKpiDialog(kpi);
                        },
                        child: Icon(
                          CupertinoIcons.pencil,
                          color: AppColors.systemBlue,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPhaseState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.layers_alt,
            size: 48,
            color: AppColors.secondaryLabel,
          ),
          const SizedBox(height: 16),
          Text(
            'フェーズがありません',
            style: AppTypography.body.copyWith(
              color: AppColors.secondaryLabel,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'フェーズを追加してKPIを整理しましょう',
            style: AppTypography.caption1.copyWith(
              color: AppColors.tertiaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showProgressEditDialog(KpiModel kpi) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => KpiProgressEditModal(kpi: kpi),
    ).then((result) {
      if (result == true) {
        // データはプロバイダーで自動更新される
      }
    });
  }
} 