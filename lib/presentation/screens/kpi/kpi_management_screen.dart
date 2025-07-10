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
import '../../providers/kpi_data_provider.dart';

class KpiManagementScreen extends StatefulWidget {
  const KpiManagementScreen({super.key});

  @override
  State<KpiManagementScreen> createState() => _KpiManagementScreenState();
}

class _KpiManagementScreenState extends State<KpiManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  PostPhase _selectedPhase = PostPhase.planning;

  // ローディング状態
  bool _isLoading = true;

  // フェーズ別KPIデータ
  final Map<PostPhase, Map<String, dynamic>> _phaseKpis = {
    PostPhase.planning: {
      'idea_generation': {'target': 50, 'current': 42, 'label': '月間アイデア数'},
      'research_completion': {'target': 95, 'current': 88, 'label': '調査完了率(%)'},
      'strategy_alignment': {'target': 90, 'current': 85, 'label': '戦略一致度(%)'},
    },
    PostPhase.development: {
      'content_quality': {'target': 90, 'current': 85, 'label': 'コンテンツ品質(%)'},
      'production_speed': {'target': 15, 'current': 12, 'label': '週間制作数'},
      'revision_rate': {'target': 10, 'current': 15, 'label': '修正回数(%)'},
    },
    PostPhase.launch: {
      'post_frequency': {'target': 28, 'current': 25, 'label': '月間投稿数'},
      'timing_accuracy': {'target': 95, 'current': 92, 'label': '投稿時間精度(%)'},
      'platform_coverage': {'target': 6, 'current': 5, 'label': 'プラットフォーム数'},
    },
    PostPhase.growth: {
      'engagement_growth': {'target': 15, 'current': 12, 'label': 'エンゲージメント成長率(%)'},
      'reach_expansion': {'target': 25, 'current': 18, 'label': 'リーチ拡大率(%)'},
      'viral_rate': {'target': 5, 'current': 3, 'label': 'バイラル率(%)'},
    },
    PostPhase.maintenance: {
      'response_time': {'target': 2, 'current': 3, 'label': '平均応答時間(時間)'},
      'community_health': {'target': 85, 'current': 78, 'label': 'コミュニティ健全度(%)'},
      'retention_rate': {'target': 90, 'current': 85, 'label': 'フォロワー維持率(%)'},
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: PostPhase.values.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedPhase = PostPhase.values[_tabController.index];
        });
      }
    });
    
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 768;
    
    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kpiProvider.error!,
                    style: AppTypography.body.copyWith(
                      color: AppColors.secondaryLabel,
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
    return Column(
      children: [
        Flexible(
          flex: 0,
          child: _buildKgiOverview(kpiProvider),
        ),
        Flexible(
          flex: 0,
          child: _buildPhaseTabBar(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: PostPhase.values.map((phase) => _buildPhaseContent(phase)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKgiOverview(KpiDataProvider kpiProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPurple.withOpacity(0.1),
            AppColors.systemIndigo.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentPurple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                itemCount: kpiProvider.kgiList.length,
                itemBuilder: (context, index) {
                  final kgi = kpiProvider.kgiList[index];
                  return _buildKgiCard(kgi);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKgiCard(KpiModel kgi) {
    final progress = kgi.progress;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tertiarySystemBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${kgi.currentValue.toStringAsFixed(kgi.currentValue.truncateToDouble() == kgi.currentValue ? 0 : 1)}${kgi.unit}',
                style: AppTypography.headline.copyWith(
                  color: _getProgressColor(progress),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: AppTypography.caption1.copyWith(
                  color: _getProgressColor(progress),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            kgi.name,
            style: AppTypography.caption1.copyWith(
              color: AppColors.secondaryLabel,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: PostPhase.values.map((phase) {
            final isSelected = _selectedPhase == phase;
            return _buildPhaseTabItem(phase, isSelected);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPhaseTabItem(PostPhase phase, bool isSelected) {
    final phaseData = _phaseKpis[phase]!;
    final progress = _calculatePhaseProgress(phaseData);
    final color = _getPhaseColor(phase);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedPhase = phase;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getPhaseIcon(phase),
                  color: isSelected ? Colors.white : color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPhaseDisplayName(phase),
                      style: AppTypography.body.copyWith(
                        color: isSelected ? color : AppColors.label,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${phaseData.length}項目 • ${progress.toStringAsFixed(0)}%達成',
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.tertiaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              CircularProgressIndicator(
                value: progress / 100,
                strokeWidth: 3,
                backgroundColor: AppColors.systemGray5,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseTabBar() {
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
        tabs: PostPhase.values.map((phase) {
          return Tab(text: _getPhaseDisplayName(phase));
        }).toList(),
      ),
    );
  }

  Widget _buildPhaseContent(PostPhase phase) {
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

  Widget _buildPhaseDetailHeader({PostPhase? phase}) {
    final targetPhase = phase ?? _selectedPhase;
    final color = _getPhaseColor(targetPhase);
    final phaseData = _phaseKpis[targetPhase]!;
    final progress = _calculatePhaseProgress(phaseData);

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
                  _getPhaseIcon(targetPhase),
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
                      _getPhaseDisplayName(targetPhase),
                      style: AppTypography.title2.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _getPhaseDescription(targetPhase),
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.secondaryLabel,
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
  }

  Widget _buildKpiList({PostPhase? phase}) {
    final targetPhase = phase ?? _selectedPhase;
    final phaseData = _phaseKpis[targetPhase]!;

    return SingleChildScrollView(
      child: Column(
        children: phaseData.entries.map((entry) {
          return _buildKpiItem(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _buildKpiItem(String key, Map<String, dynamic> data) {
    final progress = (data['current'] / data['target'] * 100).clamp(0, 100);
    final isReverse = key.contains('revision') || key.contains('response_time');
    final adjustedProgress = isReverse ? (100 - progress).clamp(0, 100) : progress;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data['label'],
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${adjustedProgress.toStringAsFixed(0)}%',
                style: AppTypography.subhead.copyWith(
                  color: _getProgressColor(adjustedProgress),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '現在値: ${data['current']}${_getKpiUnit(key)}',
                style: AppTypography.caption1.copyWith(
                  color: AppColors.secondaryLabel,
                ),
              ),
              const Spacer(),
              Text(
                '目標値: ${data['target']}${_getKpiUnit(key)}',
                style: AppTypography.caption1.copyWith(
                  color: AppColors.tertiaryLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: adjustedProgress / 100,
            backgroundColor: AppColors.systemGray5,
            valueColor: AlwaysStoppedAnimation(_getProgressColor(adjustedProgress)),
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
    final phaseProgressData = PostPhase.values.map((phase) {
      final phaseData = _phaseKpis[phase]!;
      final progress = _calculatePhaseProgress(phaseData);
      return FlSpot(PostPhase.values.indexOf(phase).toDouble(), progress);
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
                if (value.toInt() < PostPhase.values.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _getPhaseShortName(PostPhase.values[value.toInt()]),
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
        maxX: PostPhase.values.length - 1,
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

  double _calculatePhaseProgress(Map<String, dynamic> phaseData) {
    double totalProgress = 0;
    int count = 0;
    
    for (final entry in phaseData.entries) {
      final data = entry.value as Map<String, dynamic>;
      final isReverse = entry.key.contains('revision') || entry.key.contains('response_time');
      final progress = (data['current'] / data['target'] * 100).clamp(0, 100);
      final adjustedProgress = isReverse ? (100 - progress).clamp(0, 100) : progress;
      
      totalProgress += adjustedProgress;
      count++;
    }
    
    return count > 0 ? totalProgress / count : 0;
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) return AppColors.systemGreen;
    if (progress >= 60) return AppColors.systemOrange;
    return AppColors.systemRed;
  }

  // _getUnitメソッドは削除（KpiModelのunitプロパティを使用）

  String _getKpiUnit(String key) {
    if (key.contains('rate') || key.contains('completion') || key.contains('accuracy') || 
        key.contains('health') || key.contains('retention') || key.contains('quality') ||
        key.contains('alignment') || key.contains('growth') || key.contains('expansion') ||
        key.contains('viral')) {
      return '%';
    } else if (key.contains('time')) {
      return 'h';
    } else if (key.contains('number') || key.contains('count') || key.contains('frequency') || 
               key.contains('speed') || key.contains('coverage') || key.contains('idea') ||
               key.contains('post')) {
      return '';
    }
    return '';
  }

  IconData _getPhaseIcon(PostPhase phase) {
    switch (phase) {
      case PostPhase.planning:
        return CupertinoIcons.lightbulb;
      case PostPhase.development:
        return CupertinoIcons.hammer;
      case PostPhase.launch:
        return CupertinoIcons.rocket;
      case PostPhase.growth:
        return CupertinoIcons.chart_bar_fill;
      case PostPhase.maintenance:
        return CupertinoIcons.gear;
    }
  }

  String _getPhaseDisplayName(PostPhase phase) {
    switch (phase) {
      case PostPhase.planning:
        return '企画フェーズ';
      case PostPhase.development:
        return '開発フェーズ';
      case PostPhase.launch:
        return 'ローンチフェーズ';
      case PostPhase.growth:
        return '成長フェーズ';
      case PostPhase.maintenance:
        return 'メンテナンスフェーズ';
    }
  }

  String _getPhaseShortName(PostPhase phase) {
    switch (phase) {
      case PostPhase.planning:
        return '企画';
      case PostPhase.development:
        return '開発';
      case PostPhase.launch:
        return '配信';
      case PostPhase.growth:
        return '成長';
      case PostPhase.maintenance:
        return '維持';
    }
  }

  String _getPhaseDescription(PostPhase phase) {
    switch (phase) {
      case PostPhase.planning:
        return 'アイデア創出と戦略立案';
      case PostPhase.development:
        return 'コンテンツ制作と品質管理';
      case PostPhase.launch:
        return '投稿配信と初期パフォーマンス';
      case PostPhase.growth:
        return 'エンゲージメント拡大と成長';
      case PostPhase.maintenance:
        return 'コミュニティ維持と改善';
    }
  }

  Color _getPhaseColor(PostPhase phase) {
    switch (phase) {
      case PostPhase.planning:
        return AppColors.systemGray;
      case PostPhase.development:
        return AppColors.accentOrange;
      case PostPhase.launch:
        return AppColors.primary;
      case PostPhase.growth:
        return AppColors.systemGreen;
      case PostPhase.maintenance:
        return AppColors.systemPurple;
    }
  }

  void _showAddMenu() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('追加'),
        message: const Text('何を追加しますか？'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showAddKpiDialog();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.chart_bar_fill, size: 20, color: AppColors.systemBlue),
                const SizedBox(width: 8),
                Text('KPI を追加'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showAddKgiDialog();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.star_fill, size: 20, color: AppColors.accentPurple),
                const SizedBox(width: 8),
                Text('KGI を追加'),
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
                Icon(CupertinoIcons.layers_alt, size: 20, color: AppColors.systemPurple),
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

  void _showAddKpiDialog() {
    final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KpiEditModal(phases: kpiProvider.phases),
    ).then((result) {
      if (result == true) {
        // データはプロバイダーで自動更新される
      }
    });
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
      builder: (context) => PhaseEditModal(phase: phase, existingPhases: kpiProvider.phases),
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
} 