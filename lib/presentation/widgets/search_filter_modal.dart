import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/post_model.dart';

class SearchFilterModal extends StatefulWidget {
  final SearchFilterConfig? initialConfig;
  final Function(SearchFilterConfig) onApply;

  const SearchFilterModal({
    super.key,
    this.initialConfig,
    required this.onApply,
  });

  @override
  State<SearchFilterModal> createState() => _SearchFilterModalState();
}

class _SearchFilterModalState extends State<SearchFilterModal> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  
  // フィルター状態
  Set<PostPhase> _selectedPhases = {};
  Set<PostType> _selectedTypes = {};
  Set<String> _selectedTags = {};
  DateTimeRange? _dateRange;
  bool _publishedOnly = false;
  bool _unpublishedOnly = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> _availableTags = [
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

  @override
  void initState() {
    super.initState();
    _initializeValues();
    _initializeAnimations();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _initializeValues() {
    if (widget.initialConfig != null) {
      final config = widget.initialConfig!;
      _searchController.text = config.searchText;
      _selectedPhases = Set.from(config.phases);
      _selectedTypes = Set.from(config.types);
      _selectedTags = Set.from(config.tags);
      _dateRange = config.dateRange;
      _publishedOnly = config.publishedOnly;
      _unpublishedOnly = config.unpublishedOnly;
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width >= 768;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              borderRadius: BorderRadius.circular(24),
              color: Colors.transparent,
              child: Container(
                width: isWideScreen ? 700 : screenSize.width * 0.9,
                height: screenSize.height * 0.8,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.systemGroupedBackgroundDark.withOpacity(0.95)
                      : AppColors.secondarySystemGroupedBackground,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildModalHeader(),
                    _buildTabBar(),
                    Expanded(child: _buildTabContent()),
                    _buildModalFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.search,
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
                  '検索・フィルター',
                  style: AppTypography.title2.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '投稿を検索・絞り込み',
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppColors.systemGray3,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.secondaryLabel,
        labelStyle: AppTypography.subhead.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.subhead,
        tabs: const [
          Tab(
            icon: Icon(CupertinoIcons.search, size: 20),
            text: '検索',
          ),
          Tab(
            icon: Icon(CupertinoIcons.line_horizontal_3_decrease, size: 20),
            text: 'フィルター',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSearchTab(),
        _buildFilterTab(),
      ],
    );
  }

  Widget _buildSearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('投稿内容で検索', CupertinoIcons.textformat),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.systemGroupedBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.separator.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: AppTypography.body,
              decoration: InputDecoration(
                hintText: 'キーワードを入力...',
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.tertiaryLabel,
                ),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: AppColors.systemGray,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('検索オプション', CupertinoIcons.slider_horizontal_3),
          const SizedBox(height: 12),
          _buildSearchOptions(),
        ],
      ),
    );
  }

  Widget _buildFilterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('投稿フェーズ', CupertinoIcons.folder),
          const SizedBox(height: 12),
          _buildPhaseFilter(),
          const SizedBox(height: 24),
          _buildSectionTitle('投稿タイプ', CupertinoIcons.doc),
          const SizedBox(height: 12),
          _buildTypeFilter(),
          const SizedBox(height: 24),
          _buildSectionTitle('タグ', CupertinoIcons.tag),
          const SizedBox(height: 12),
          _buildTagFilter(),
          const SizedBox(height: 24),
          _buildSectionTitle('期間', CupertinoIcons.calendar),
          const SizedBox(height: 12),
          _buildDateRangeFilter(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.headline.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchOptions() {
    return Column(
      children: [
        _buildSwitchTile(
          '公開済み投稿のみ',
          '公開された投稿だけを検索対象にします',
          _publishedOnly,
          (value) {
            setState(() {
              _publishedOnly = value;
              if (value) _unpublishedOnly = false;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          '未公開投稿のみ',
          '未公開の投稿だけを検索対象にします',
          _unpublishedOnly,
          (value) {
            setState(() {
              _unpublishedOnly = value;
              if (value) _publishedOnly = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PostPhase.values.map((phase) {
        final isSelected = _selectedPhases.contains(phase);
        final color = _getPhaseColor(phase);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedPhases.remove(phase);
              } else {
                _selectedPhases.add(phase);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : AppColors.systemGroupedBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : AppColors.separator.withOpacity(0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  phase.displayName,
                  style: AppTypography.caption1.copyWith(
                    color: isSelected ? color : AppColors.label,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: color,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PostType.values.map((type) {
        final isSelected = _selectedTypes.contains(type);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedTypes.remove(type);
              } else {
                _selectedTypes.add(type);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent.withOpacity(0.2) : AppColors.systemGroupedBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.separator.withOpacity(0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  type.displayName,
                  style: AppTypography.caption1.copyWith(
                    color: isSelected ? AppColors.accent : AppColors.label,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: AppColors.accent,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTagFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableTags.map((tag) {
        final isSelected = _selectedTags.contains(tag);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedTags.remove(tag);
              } else {
                _selectedTags.add(tag);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.engagement.withOpacity(0.2) : AppColors.systemGroupedBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.engagement : AppColors.separator.withOpacity(0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.tag_fill,
                  color: isSelected ? AppColors.engagement : AppColors.systemGray,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  tag,
                  style: AppTypography.caption1.copyWith(
                    color: isSelected ? AppColors.engagement : AppColors.label,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: AppColors.engagement,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRangeFilter() {
    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.systemGroupedBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _dateRange != null ? AppColors.primary.withOpacity(0.5) : AppColors.separator.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.calendar,
              color: _dateRange != null ? AppColors.primary : AppColors.systemGray,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '期間を選択',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_dateRange != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${_dateRange!.start.month}/${_dateRange!.start.day} - ${_dateRange!.end.month}/${_dateRange!.end.day}',
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else
                    Text(
                      '全期間',
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                ],
              ),
            ),
            if (_dateRange != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _dateRange = null;
                  });
                },
                child: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: AppColors.systemGray3,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalFooter() {
    final hasFilters = _searchController.text.isNotEmpty ||
        _selectedPhases.isNotEmpty ||
        _selectedTypes.isNotEmpty ||
        _selectedTags.isNotEmpty ||
        _dateRange != null ||
        _publishedOnly ||
        _unpublishedOnly;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.systemGroupedBackground.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          if (hasFilters)
            Expanded(
              child: TextButton(
                onPressed: _clearAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.systemRed.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  'クリア',
                  style: AppTypography.button.copyWith(
                    color: AppColors.systemRed,
                  ),
                ),
              ),
            ),
          if (hasFilters) const SizedBox(width: 16),
          Expanded(
            flex: hasFilters ? 2 : 1,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                hasFilters ? '適用' : '閉じる',
                style: AppTypography.button.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
      locale: const Locale('ja'),
    );
    
    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _searchController.clear();
      _selectedPhases.clear();
      _selectedTypes.clear();
      _selectedTags.clear();
      _dateRange = null;
      _publishedOnly = false;
      _unpublishedOnly = false;
    });
  }

  void _applyFilters() {
    final config = SearchFilterConfig(
      searchText: _searchController.text.trim(),
      phases: _selectedPhases.toList(),
      types: _selectedTypes.toList(),
      tags: _selectedTags.toList(),
      dateRange: _dateRange,
      publishedOnly: _publishedOnly,
      unpublishedOnly: _unpublishedOnly,
    );
    
    widget.onApply(config);
    Navigator.pop(context);
  }

  static void show(
    BuildContext context, {
    SearchFilterConfig? initialConfig,
    required Function(SearchFilterConfig) onApply,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SearchFilterModal(
        initialConfig: initialConfig,
        onApply: onApply,
      ),
    );
  }
}

class SearchFilterConfig {
  final String searchText;
  final List<PostPhase> phases;
  final List<PostType> types;
  final List<String> tags;
  final DateTimeRange? dateRange;
  final bool publishedOnly;
  final bool unpublishedOnly;

  const SearchFilterConfig({
    this.searchText = '',
    this.phases = const [],
    this.types = const [],
    this.tags = const [],
    this.dateRange,
    this.publishedOnly = false,
    this.unpublishedOnly = false,
  });

  bool get hasFilters {
    return searchText.isNotEmpty ||
        phases.isNotEmpty ||
        types.isNotEmpty ||
        tags.isNotEmpty ||
        dateRange != null ||
        publishedOnly ||
        unpublishedOnly;
  }

  bool matchesPost(PostModel post) {
    // テキスト検索
    if (searchText.isNotEmpty) {
      if (!post.content.toLowerCase().contains(searchText.toLowerCase()) &&
          !post.memo.toLowerCase().contains(searchText.toLowerCase())) {
        return false;
      }
    }

    // フェーズフィルター
    if (phases.isNotEmpty && !phases.contains(post.phase)) {
      return false;
    }

    // タイプフィルター
    if (types.isNotEmpty && !types.contains(post.type)) {
      return false;
    }

    // タグフィルター
    if (tags.isNotEmpty) {
      final hasMatchingTag = tags.any((tag) => post.tags.contains(tag));
      if (!hasMatchingTag) {
        return false;
      }
    }

    // 期間フィルター
    if (dateRange != null) {
      final postDate = post.scheduledDate;
      if (postDate.isBefore(dateRange!.start) || postDate.isAfter(dateRange!.end)) {
        return false;
      }
    }

    // 公開状態フィルター
    if (publishedOnly && !post.isPublished) {
      return false;
    }
    if (unpublishedOnly && post.isPublished) {
      return false;
    }

    return true;
  }
} 