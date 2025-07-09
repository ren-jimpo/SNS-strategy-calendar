import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/post_model.dart';
import '../../data/models/sns_account_model.dart';

class PostCreateModal extends StatefulWidget {
  final PostModel? post;
  final DateTime selectedDate;
  final Function(PostModel)? onSaved;

  const PostCreateModal({
    super.key,
    this.post,
    required this.selectedDate,
    this.onSaved,
  });

  @override
  State<PostCreateModal> createState() => _PostCreateModalState();
}

class _PostCreateModalState extends State<PostCreateModal> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _memoController = TextEditingController();
  final _targetLikesController = TextEditingController();
  final _targetImpressionsController = TextEditingController();

  late DateTime _scheduledDate;
  late TimeOfDay _scheduledTime;
  PostPhase _selectedPhase = PostPhase.planning;
  PostType _selectedType = PostType.announcement;
  List<String> _selectedTags = [];
  bool _isLoading = false;
  SNSAccount? _selectedAccount;

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
    _initializeForm();
    _initializeAnimations();
  }

  void _initializeForm() {
    if (widget.post != null) {
      final post = widget.post!;
      _contentController.text = post.content;
      _memoController.text = post.memo;
      _targetLikesController.text = post.kpi.targetLikes.toString();
      _targetImpressionsController.text = post.kpi.targetImpressions.toString();
      _scheduledDate = post.scheduledDate;
      _scheduledTime = TimeOfDay.fromDateTime(post.scheduledDate);
      _selectedPhase = post.phase;
      _selectedType = post.type;
      _selectedTags = List.from(post.tags);
      
      // アカウント情報を設定
      if (post.accountId != null) {
        _selectedAccount = AccountManager.accounts
            .firstWhere((account) => account.id == post.accountId, 
                      orElse: () => AccountManager.accounts.isNotEmpty 
                          ? AccountManager.accounts.first 
                          : AccountManager.accounts.first);
      }
    } else {
      _scheduledDate = widget.selectedDate;
      _scheduledTime = TimeOfDay.now();
      _targetLikesController.text = '100';
      _targetImpressionsController.text = '2000';
      
      // デフォルトアカウントを設定
      _selectedAccount = AccountManager.selectedAccount ?? 
          (AccountManager.accounts.isNotEmpty ? AccountManager.accounts.first : null);
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
    _contentController.dispose();
    _memoController.dispose();
    _targetLikesController.dispose();
    _targetImpressionsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.post != null;
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
                width: isWideScreen ? 600 : screenSize.width * 0.9,
                height: screenSize.height * 0.85,
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
                    _buildModalHeader(isEditing),
                    Expanded(child: _buildModalBody()),
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

  Widget _buildModalHeader(bool isEditing) {
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
            child: Icon(
              isEditing ? CupertinoIcons.pencil : CupertinoIcons.plus,
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
                  isEditing ? '投稿を編集' : '新しい投稿',
                  style: AppTypography.title2.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  DateFormat('yyyy年M月d日(E)', 'ja').format(_scheduledDate),
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

  Widget _buildModalBody() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountSection(),
            const SizedBox(height: 20),
            _buildContentSection(),
            const SizedBox(height: 20),
            _buildScheduleSection(),
            const SizedBox(height: 20),
            _buildCategorySection(),
            const SizedBox(height: 20),
            _buildTagsSection(),
            const SizedBox(height: 20),
            _buildKPISection(),
            const SizedBox(height: 20),
            _buildMemoSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModalFooter() {
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
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.systemGray4,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'キャンセル',
                style: AppTypography.button.copyWith(
                  color: AppColors.secondaryLabel,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _savePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      '保存',
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

  Widget _buildContentSection() {
    return _buildSection(
      title: '投稿内容',
      icon: CupertinoIcons.textformat,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.systemGroupedBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.separator.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: TextFormField(
          controller: _contentController,
          maxLines: 4,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: 'SNS投稿の内容を入力してください...',
            hintStyle: AppTypography.body.copyWith(
              color: AppColors.tertiaryLabel,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '投稿内容を入力してください';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return _buildSection(
      title: 'スケジュール',
      icon: CupertinoIcons.calendar,
      child: Row(
        children: [
          Expanded(
            child: _buildScheduleTile(
              '日付',
              DateFormat('M月d日(E)', 'ja').format(_scheduledDate),
              CupertinoIcons.calendar_today,
              () => _selectDate(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildScheduleTile(
              '時刻',
              _scheduledTime.format(context),
              CupertinoIcons.clock,
              () => _selectTime(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return _buildSection(
      title: 'カテゴリ',
      icon: CupertinoIcons.folder,
      child: Row(
        children: [
          Expanded(
            child: _buildCategoryDropdown(
              'フェーズ',
              _selectedPhase.displayName,
              PostPhase.values,
              (phase) => setState(() => _selectedPhase = phase),
              (phase) => phase.displayName,
              _getPhaseColor(_selectedPhase),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCategoryDropdown(
              'タイプ',
              _selectedType.displayName,
              PostType.values,
              (type) => setState(() => _selectedType = type),
              (type) => type.displayName,
              AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return _buildSection(
      title: 'タグ',
      icon: CupertinoIcons.tag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedTags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedTags.map((tag) => _buildSelectedTag(tag)).toList(),
            ),
            const SizedBox(height: 12),
          ],
          _buildAddTagButton(),
        ],
      ),
    );
  }

  Widget _buildKPISection() {
    return _buildSection(
      title: 'KPI目標',
      icon: CupertinoIcons.chart_bar,
      child: Row(
        children: [
          Expanded(
            child: _buildKPIField(
              'いいね数',
              _targetLikesController,
              CupertinoIcons.heart,
              AppColors.systemRed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildKPIField(
              'インプレッション',
              _targetImpressionsController,
              CupertinoIcons.eye,
              AppColors.systemBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoSection() {
    return _buildSection(
      title: 'メモ',
      icon: CupertinoIcons.doc_text,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.systemGroupedBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.separator.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: TextFormField(
          controller: _memoController,
          maxLines: 2,
          style: AppTypography.caption1,
          decoration: InputDecoration(
            hintText: '内部メモや注意事項を記録...',
            hintStyle: AppTypography.caption1.copyWith(
              color: AppColors.tertiaryLabel,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildScheduleTile(String label, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.systemGroupedBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.separator.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.subhead.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown<T>(
    String label,
    String currentValue,
    List<T> items,
    Function(T) onChanged,
    String Function(T) displayName,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption1.copyWith(
              color: AppColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showDropdownOptions(items, onChanged, displayName),
            child: Row(
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
                Expanded(
                  child: Text(
                    currentValue,
                    style: AppTypography.subhead.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_down,
                  color: AppColors.systemGray,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIField(String label, TextEditingController controller, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.caption1.copyWith(
                  color: AppColors.secondaryLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: AppTypography.subhead.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: '0',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '入力必須';
              }
              if (int.tryParse(value) == null) {
                return '数値で入力';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.engagement.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.engagement.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: AppTypography.caption1.copyWith(
              color: AppColors.engagement,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTags.remove(tag);
              });
            },
            child: Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppColors.engagement,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTagButton() {
    return GestureDetector(
      onTap: _showTagSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            Icon(
              CupertinoIcons.plus,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'タグを追加',
              style: AppTypography.body.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
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

  void _showDropdownOptions<T>(
    List<T> items,
    Function(T) onChanged,
    String Function(T) displayName,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: items.map((item) {
          return CupertinoActionSheetAction(
            onPressed: () {
              onChanged(item);
              Navigator.pop(context);
            },
            child: Text(displayName(item)),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  void _showTagSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('タグを選択'),
        actions: _availableTags.where((tag) => !_selectedTags.contains(tag)).map((tag) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _selectedTags.add(tag);
              });
              Navigator.pop(context);
            },
            child: Text(tag),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ja'),
    );
    
    if (picked != null && picked != _scheduledDate) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );
    
    if (picked != null && picked != _scheduledTime) {
      setState(() {
        _scheduledTime = picked;
      });
    }
  }

  void _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // モック保存処理（2秒待機）
    await Future.delayed(const Duration(seconds: 2));

    // 新しいPostModelを作成
    final scheduledDateTime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );

    final newPost = PostModel(
      id: widget.post?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: _contentController.text.trim(),
      scheduledDate: scheduledDateTime,
      publishedDate: widget.post?.publishedDate,
      phase: _selectedPhase,
      type: _selectedType,
      tags: _selectedTags,
      kpi: PostKPI(
        targetLikes: int.tryParse(_targetLikesController.text) ?? 100,
        targetImpressions: int.tryParse(_targetImpressionsController.text) ?? 2000,
        description: 'フェーズ目標達成',
      ),
      performance: widget.post?.performance ?? const PostPerformance(),
      memo: _memoController.text.trim(),
      createdAt: widget.post?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isPublished: widget.post?.isPublished ?? false,
      accountId: _selectedAccount?.id,
    );

    setState(() {
      _isLoading = false;
    });

    // コールバック呼び出し
    if (widget.onSaved != null) {
      widget.onSaved!(newPost);
    }

    // 保存完了のフィードバック
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.post != null ? '投稿を更新しました' : '投稿を作成しました',
            style: AppTypography.body.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.systemGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      
      Navigator.pop(context);
    }
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: 'SNSアカウント',
      icon: CupertinoIcons.person_2,
      child: GestureDetector(
        onTap: _showAccountSelector,
        child: Container(
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
              if (_selectedAccount != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _selectedAccount!.platformColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _selectedAccount!.platformIcon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedAccount!.displayName,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_selectedAccount!.platform.displayName} • ${_selectedAccount!.username}',
                        style: AppTypography.caption1.copyWith(
                          color: AppColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.systemGray4,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CupertinoIcons.person_crop_circle_badge_plus,
                    color: AppColors.systemGray,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'アカウントを選択してください',
                    style: AppTypography.body.copyWith(
                      color: AppColors.tertiaryLabel,
                    ),
                  ),
                ),
              ],
              Icon(
                CupertinoIcons.chevron_down,
                color: AppColors.systemGray,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountSelector() {
    final accounts = AccountManager.activeAccounts;
    
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('利用可能なアカウントがありません'),
          backgroundColor: AppColors.systemRed,
        ),
      );
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('投稿するアカウントを選択'),
        actions: accounts.map((account) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _selectedAccount = account;
              });
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: account.platformColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    account.platformIcon,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      account.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${account.platform.displayName} • ${account.username}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    PostModel? post,
    required DateTime selectedDate,
    Function(PostModel)? onSaved,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PostCreateModal(
        post: post,
        selectedDate: selectedDate,
        onSaved: onSaved,
      ),
    );
  }
} 