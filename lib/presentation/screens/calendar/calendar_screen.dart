import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/sns_account_model.dart';
import '../../../data/mock/mock_posts.dart';
import '../../widgets/post_card.dart';
import '../../widgets/post_create_modal.dart';
import '../../widgets/search_filter_modal.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late List<PostModel> _posts;
  List<PostModel> _selectedDayPosts = [];
  List<PostModel> _filteredPosts = [];
  SearchFilterConfig _currentFilter = const SearchFilterConfig();
  
  // アカウント管理
  List<SNSAccount> _accounts = [];
  SNSAccount? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _selectedDay = DateTime.now();
    _applyFilters();
    _updateSelectedDayPosts();
  }

  void _initializeData() {
    // モックアカウントを生成
    AccountManager.generateMockAccounts();
    _accounts = AccountManager.activeAccounts;
    _selectedAccount = AccountManager.selectedAccount;
    
    // モック投稿を生成（アカウント情報付き）
    _posts = MockPosts.generateMockPosts();
  }

  void _applyFilters() {
    setState(() {
      _filteredPosts = _posts.where((post) {
        // 検索・フィルター条件をチェック
        if (!_currentFilter.matchesPost(post)) return false;
        
        // アカウントフィルターをチェック
        if (_selectedAccount != null) {
          return post.accountId == _selectedAccount!.id;
        }
        
        return true;
      }).toList();
    });
  }

  void _updateSelectedDayPosts() {
    if (_selectedDay == null) return;
    
    setState(() {
      _selectedDayPosts = _filteredPosts.where((post) {
        return _isSameDay(post.scheduledDate, _selectedDay!);
      }).toList();
    });
  }

  List<PostModel> _getEventsForDay(DateTime day) {
    return _filteredPosts.where((post) {
      return _isSameDay(post.scheduledDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 768;

    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      body: SafeArea(
        child: isWideScreen
            ? _buildWideScreenLayout()
            : _buildMobileLayout(),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }



  Widget _buildWideScreenLayout() {
    return Row(
      children: [
        // 左側：カレンダー + 統計
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // カレンダー部分
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                  decoration: BoxDecoration(
                    color: AppColors.secondarySystemGroupedBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.separator.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildCalendarHeader(),
                      Expanded(child: _buildCalendar()),
                    ],
                  ),
                ),
              ),
              // 統計・クイックアクション部分
              Expanded(
                flex: 1,
                child: _buildCalendarSidebar(),
              ),
            ],
          ),
        ),
        // 右側：選択した日の詳細
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 16, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.secondarySystemGroupedBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.separator.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSelectedDaySection(),
                Expanded(child: _buildPostsList()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondarySystemGroupedBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.separator.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildCalendarHeader(),
                Expanded(child: _buildCalendar()),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.secondarySystemGroupedBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.separator.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSelectedDaySection(),
                Expanded(child: _buildPostsList()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.calendar,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'SNS投稿カレンダー',
            style: AppTypography.headline.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _buildSearchAndFilterButtons(),
          const SizedBox(width: 12),
          _buildCalendarControls(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 検索ボタン
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  CupertinoIcons.search,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () {
                  _showSearchDialog();
                },
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: const EdgeInsets.all(8),
              ),
            ),
            if (_currentFilter.searchText.isNotEmpty)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        // フィルターボタン
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.engagement.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  CupertinoIcons.line_horizontal_3_decrease,
                  color: AppColors.engagement,
                  size: 20,
                ),
                onPressed: () {
                  _showFilterDialog();
                },
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: const EdgeInsets.all(8),
              ),
            ),
            if (_currentFilter.hasFilters && _currentFilter.searchText.isEmpty)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.engagement,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarControls() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(CupertinoIcons.today),
          color: AppColors.primary,
          onPressed: () {
            setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            });
            _updateSelectedDayPosts();
          },
          tooltip: '今日に移動',
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.refresh),
          color: AppColors.primary,
          onPressed: () {
            setState(() {
              _posts = MockPosts.generateMockPosts();
            });
            _updateSelectedDayPosts();
          },
          tooltip: 'データを更新',
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TableCalendar<PostModel>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) {
          return _selectedDay != null && _isSameDay(_selectedDay!, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (_selectedDay == null || !_isSameDay(_selectedDay!, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _updateSelectedDayPosts();
          }
        },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: AppTypography.body.copyWith(
              color: AppColors.systemRed,
            ),
            holidayTextStyle: AppTypography.body.copyWith(
              color: AppColors.systemRed,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: AppColors.systemGreen,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
            canMarkersOverflow: true,
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            formatButtonTextStyle: AppTypography.caption1.copyWith(
              color: Colors.white,
            ),
            titleTextStyle: AppTypography.headline,
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return null;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: events.take(3).map((post) {
                  Color markerColor = AppColors.systemGreen;
                  if (post.phase == PostPhase.planning) {
                    markerColor = AppColors.systemGray;
                  } else if (post.phase == PostPhase.development) {
                    markerColor = AppColors.systemOrange;
                  } else if (post.phase == PostPhase.launch) {
                    markerColor = AppColors.systemBlue;
                  }
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: markerColor,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      );
  }

  Widget _buildSelectedDaySection() {
    if (_selectedDay == null) return const SizedBox();

    final dateString = DateFormat('M月d日(E)', 'ja').format(_selectedDay!);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateString,
                    style: AppTypography.title2.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${_selectedDayPosts.length}件の投稿',
                    style: AppTypography.body.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
              if (_selectedDayPosts.isNotEmpty)
                _buildQuickStats(),
            ],
          ),
          const SizedBox(height: 16),
          _buildAccountFilter(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final publishedPosts = _selectedDayPosts.where((p) => p.isPublished).length;
    final scheduledPosts = _selectedDayPosts.where((p) => !p.isPublished).length;

    return Row(
      children: [
        if (publishedPosts > 0) ...[
          _buildStatChip(
            '投稿済み',
            publishedPosts.toString(),
            AppColors.systemGreen,
          ),
          const SizedBox(width: 8),
        ],
        if (scheduledPosts > 0)
          _buildStatChip(
            '予定',
            scheduledPosts.toString(),
            AppColors.systemBlue,
          ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$label $value',
            style: AppTypography.caption1.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountFilter() {
    return Row(
      children: [
        Text(
          'アカウント:',
          style: AppTypography.caption1.copyWith(
            color: AppColors.secondaryLabel,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildAccountFilterChip(
                  null,
                  'すべて',
                  AppColors.systemGray,
                ),
                const SizedBox(width: 8),
                ..._accounts.map((account) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildAccountFilterChip(
                      account,
                      account.displayName,
                      account.platformColor,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountFilterChip(SNSAccount? account, String label, Color color) {
    final isSelected = _selectedAccount == account;
    
    return GestureDetector(
      onTap: () {
        _onAccountChanged(account);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (account != null) ...[
              Icon(
                account.platformIcon,
                size: 14,
                color: isSelected ? color : color.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTypography.caption1.copyWith(
                color: isSelected ? color : color.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    if (_selectedDayPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.calendar_badge_plus,
              size: 64,
              color: AppColors.systemGray3,
            ),
            const SizedBox(height: 16),
            Text(
              '投稿がありません',
              style: AppTypography.headline.copyWith(
                color: AppColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '新しい投稿を追加してみましょう',
              style: AppTypography.footnote.copyWith(
                color: AppColors.tertiaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedDayPosts.length,
      itemBuilder: (context, index) {
        final post = _selectedDayPosts[index];
        return PostCard(
          post: post,
          onTap: () => _navigateToPostDetail(post),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _navigateToPostDetail(null);
      },
      backgroundColor: AppColors.primary,
      child: const Icon(
        CupertinoIcons.add,
        color: Colors.white,
      ),
    );
  }

  void _navigateToPostDetail(PostModel? post) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PostCreateModal(
        post: post,
        selectedDate: _selectedDay ?? DateTime.now(),
        onSaved: (savedPost) {
          setState(() {
            if (post != null) {
              // 既存投稿の更新
              final index = _posts.indexWhere((p) => p.id == post.id);
              if (index != -1) {
                _posts[index] = savedPost;
              }
            } else {
              // 新規投稿の追加
              _posts.add(savedPost);
            }
            _applyFilters();
            _updateSelectedDayPosts();
          });
        },
      ),
    );
  }

  void _showSearchDialog() {
    _showSearchFilterModal();
  }

  void _showFilterDialog() {
    _showSearchFilterModal();
  }

  void _showSearchFilterModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SearchFilterModal(
        initialConfig: _currentFilter,
        onApply: (config) {
          setState(() {
            _currentFilter = config;
          });
          _applyFilters();
          _updateSelectedDayPosts();
        },
      ),
    );
  }

  Widget _buildCalendarSidebar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 8, 16),
      child: Row(
        children: [
          // 左側：今日の統計
          Expanded(
            child: _buildDailyStats(),
          ),
          const SizedBox(width: 16),
          // 右側：クイックアクション
          Expanded(
            child: _buildQuickActions(),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStats() {
    final today = DateTime.now();
    final todayPosts = _filteredPosts.where((post) {
      return _isSameDay(post.scheduledDate, today);
    }).toList();
    
    final publishedToday = todayPosts.where((post) => post.isPublished).length;
    final pendingToday = todayPosts.length - publishedToday;
    
    // 今週の投稿数
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekPosts = _filteredPosts.where((post) {
      return post.scheduledDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
             post.scheduledDate.isBefore(weekEnd.add(const Duration(days: 1)));
    }).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.engagement.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.chart_bar_circle_fill,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '今日の統計',
                  style: AppTypography.subhead.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatItem('投稿予定', '$pendingToday件', CupertinoIcons.clock, AppColors.systemOrange),
          const SizedBox(height: 6),
          _buildStatItem('投稿完了', '$publishedToday件', CupertinoIcons.checkmark_circle_fill, AppColors.systemGreen),
          const SizedBox(height: 6),
          _buildStatItem('今週の投稿', '$weekPosts件', CupertinoIcons.calendar_badge_plus, AppColors.engagement),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.caption1.copyWith(
              color: AppColors.secondaryLabel,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.subhead.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.1),
            AppColors.systemPink.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.bolt_fill,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'クイックアクション',
                  style: AppTypography.subhead.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            '新規投稿',
            CupertinoIcons.plus_circle_fill,
            AppColors.primary,
            () => _showCreatePostDialog(),
          ),
          const SizedBox(height: 6),
          _buildQuickActionButton(
            'テンプレート',
            CupertinoIcons.doc_text_fill,
            AppColors.systemOrange,
            () => _showTemplateDialog(),
          ),
          const SizedBox(height: 6),
          _buildQuickActionButton(
            '実績入力',
            CupertinoIcons.chart_bar_square_fill,
            AppColors.systemGreen,
            () => _showPerformanceDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.caption1.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: color.withOpacity(0.6),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePostDialog() {
    _navigateToPostDetail(null);
  }

  void _showTemplateDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('投稿テンプレート'),
        content: const Text('テンプレート機能は今後実装予定です。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showPerformanceDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('実績データ入力'),
        content: const Text('実績入力機能は投稿詳細画面で利用できます。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _onAccountChanged(SNSAccount? account) {
    setState(() {
      _selectedAccount = account;
      AccountManager.selectAccount(account?.id);
    });
    _applyFilters();
    _updateSelectedDayPosts();
  }



  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
} 