import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/sns_post.dart';
import '../../data/models/sns_account.dart';
import '../providers/sns_data_provider.dart';

class SnsPostCreateModal extends StatefulWidget {
  final SnsPost? post;
  final DateTime selectedDate;
  final List<SnsAccount> accounts;

  const SnsPostCreateModal({
    super.key,
    this.post,
    required this.selectedDate,
    required this.accounts,
  });

  @override
  State<SnsPostCreateModal> createState() => _SnsPostCreateModalState();
}

class _SnsPostCreateModalState extends State<SnsPostCreateModal> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  late DateTime _scheduledDate;
  late TimeOfDay _scheduledTime;
  PostStatus _selectedStatus = PostStatus.draft;
  List<String> _selectedTags = [];
  bool _isLoading = false;
  SnsAccount? _selectedAccount;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _initializeAnimations();
  }

  void _initializeForm() {
    if (widget.post != null) {
      final post = widget.post!;
      _titleController.text = post.title;
      _contentController.text = post.content;
      _scheduledDate = post.scheduledDate;
      _scheduledTime = TimeOfDay.fromDateTime(post.scheduledDate);
      _selectedStatus = post.status;
      _selectedTags = List.from(post.tags);
      _selectedAccount = widget.accounts.firstWhere(
        (account) => account.id == post.accountId,
        orElse: () => widget.accounts.isNotEmpty ? widget.accounts.first : widget.accounts.first,
      );
    } else {
      _scheduledDate = widget.selectedDate;
      _scheduledTime = TimeOfDay.now();
      _selectedAccount = widget.accounts.isNotEmpty ? widget.accounts.first : null;
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
    _titleController.dispose();
    _contentController.dispose();
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
                    _buildModalHeader(),
                    Expanded(child: _buildForm()),
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
            child: Icon(
              widget.post != null ? CupertinoIcons.doc_text : CupertinoIcons.plus,
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
                  widget.post != null ? '投稿を編集' : '新しい投稿',
                  style: AppTypography.title2.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  DateFormat('yyyy年M月d日').format(_scheduledDate),
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

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountSection(),
            const SizedBox(height: 24),
            _buildTitleSection(),
            const SizedBox(height: 24),
            _buildContentSection(),
            const SizedBox(height: 24),
            _buildDateTimeSection(),
            const SizedBox(height: 24),
            _buildStatusSection(),
            const SizedBox(height: 24),
            _buildTagsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: 'アカウント選択',
      icon: CupertinoIcons.person_circle,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.systemGroupedBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.separator.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: DropdownButtonFormField<SnsAccount>(
          value: _selectedAccount,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: const Text('アカウントを選択'),
          items: widget.accounts.map((account) {
            return DropdownMenuItem(
              value: account,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getPlatformColor(account.platform),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getPlatformIcon(account.platform),
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(account.accountName),
                ],
              ),
            );
          }).toList(),
          onChanged: (account) {
            setState(() {
              _selectedAccount = account;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'アカウントを選択してください';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return _buildSection(
      title: 'タイトル',
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
          controller: _titleController,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: '投稿のタイトルを入力...',
            hintStyle: AppTypography.body.copyWith(
              color: AppColors.tertiaryLabel,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'タイトルを入力してください';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return _buildSection(
      title: '投稿内容',
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
          controller: _contentController,
          style: AppTypography.body,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: '投稿内容を入力...',
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

  Widget _buildDateTimeSection() {
    return _buildSection(
      title: '投稿日時',
      icon: CupertinoIcons.calendar,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _selectDate,
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
                    Icon(
                      CupertinoIcons.calendar,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('yyyy年M月d日').format(_scheduledDate),
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _selectTime,
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
                    Icon(
                      CupertinoIcons.clock,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _scheduledTime.format(context),
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return _buildSection(
      title: 'ステータス',
      icon: CupertinoIcons.flag,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: PostStatus.values.map((status) {
          final isSelected = _selectedStatus == status;
          final color = _getStatusColor(status);
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = status;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : AppColors.systemGroupedBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppColors.separator.withOpacity(0.5),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status.displayName,
                    style: AppTypography.body.copyWith(
                      color: isSelected ? color : AppColors.label,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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

  Widget _buildSelectedTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.engagement.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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
              CupertinoIcons.xmark,
              color: AppColors.engagement,
              size: 14,
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
            Icon(
              CupertinoIcons.plus,
              color: AppColors.engagement,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'タグを追加',
              style: AppTypography.body.copyWith(
                color: AppColors.engagement,
              ),
            ),
          ],
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
            child: CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'キャンセル',
                style: AppTypography.body.copyWith(
                  color: AppColors.systemRed,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: CupertinoButton(
              color: AppColors.primary,
              onPressed: _isLoading ? null : _savePost,
              child: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.post != null ? '更新' : '作成',
                      style: AppTypography.body.copyWith(
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

  void _showTagSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext modalContext) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: AppColors.secondarySystemGroupedBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'タグを選択',
                    style: AppTypography.headline.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(modalContext),
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: AppColors.systemGray3,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<SnsDataProvider>(
                builder: (context, provider, child) {
                  final allTags = provider.allTags;
                  final customTags = provider.customTagStrings;
                  
                  return Column(
                    children: [
                      // 新しいタグを追加ボタン
                      Container(
                        margin: const EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(modalContext);
                            _showAddCustomTagDialog();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.systemBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.systemBlue,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.add_circled_solid,
                                  color: AppColors.systemBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '新しいタグを追加',
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.systemBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // タグリスト
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: allTags.length,
                          itemBuilder: (context, index) {
                            final tag = allTags[index];
                            final isSelected = _selectedTags.contains(tag);
                            final isCustomTag = customTags.contains(tag);
                            
                            return GestureDetector(
                              onTap: () {
                                // メインのcontextでsetStateを実行
                                if (mounted) {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedTags.remove(tag);
                                    } else {
                                      _selectedTags.add(tag);
                                    }
                                  });
                                }
                                Navigator.pop(modalContext);
                                
                                // フィードバック表示
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isSelected 
                                          ? 'タグ「$tag」を削除しました' 
                                          : 'タグ「$tag」を追加しました',
                                    ),
                                    backgroundColor: isSelected 
                                        ? AppColors.systemOrange 
                                        : AppColors.systemGreen,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.engagement.withOpacity(0.1) 
                                      : AppColors.systemBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppColors.engagement 
                                        : AppColors.separator.withOpacity(0.3),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isCustomTag ? CupertinoIcons.tag_circle_fill : CupertinoIcons.tag_fill,
                                      color: isSelected 
                                          ? AppColors.engagement 
                                          : (isCustomTag ? AppColors.systemPurple : AppColors.systemGray),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tag,
                                            style: AppTypography.body.copyWith(
                                              color: isSelected 
                                                  ? AppColors.engagement 
                                                  : AppColors.label,
                                              fontWeight: isSelected 
                                                  ? FontWeight.w600 
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                          if (isCustomTag)
                                            Text(
                                              'カスタムタグ',
                                              style: AppTypography.caption2.copyWith(
                                                color: AppColors.systemPurple,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        CupertinoIcons.checkmark_circle_fill, 
                                        color: AppColors.engagement,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomTagDialog() {
    final TextEditingController tagController = TextEditingController();
    
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('新しいタグを追加'),
          content: Column(
            children: [
              const SizedBox(height: 16),
              const Text('追加したいハッシュタグを入力してください'),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: tagController,
                placeholder: 'タグ名（例：新機能）',
                prefix: Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Text(
                    '#',
                    style: AppTypography.body.copyWith(
                      color: AppColors.systemGray,
                    ),
                  ),
                ),
                maxLength: 30,
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('キャンセル'),
              onPressed: () {
                tagController.dispose();
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('追加'),
              onPressed: () async {
                final tag = tagController.text.trim();
                Navigator.pop(context);
                
                if (tag.isNotEmpty) {
                  final provider = Provider.of<SnsDataProvider>(context, listen: false);
                  final success = await provider.createCustomTag(tag);
                  
                  if (success) {
                    final normalizedTag = provider.normalizeTag(tag);
                    if (mounted) {
                      setState(() {
                        _selectedTags.add(normalizedTag);
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('カスタムタグ「$normalizedTag」を追加しました'),
                          backgroundColor: AppColors.systemGreen,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.error ?? 'タグの追加に失敗しました'),
                        backgroundColor: AppColors.systemRed,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
                
                tagController.dispose();
              },
            ),
          ],
        );
      },
    );
  }

  void _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final scheduledDateTime = DateTime(
        _scheduledDate.year,
        _scheduledDate.month,
        _scheduledDate.day,
        _scheduledTime.hour,
        _scheduledTime.minute,
      );

      final post = SnsPost(
        id: widget.post?.id ?? const Uuid().v4(),
        accountId: _selectedAccount!.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imageUrls: widget.post?.imageUrls ?? [],
        tags: _selectedTags,
        scheduledDate: scheduledDateTime,
        status: _selectedStatus,
        postUrl: widget.post?.postUrl,
        likesCount: widget.post?.likesCount ?? 0,
        commentsCount: widget.post?.commentsCount ?? 0,
        sharesCount: widget.post?.sharesCount ?? 0,
        createdAt: widget.post?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 実際のSupabase保存処理
      final provider = Provider.of<SnsDataProvider>(context, listen: false);
      bool success = false;

      if (widget.post != null) {
        // 既存投稿の更新
        success = await provider.updatePost(post);
      } else {
        // 新規投稿の作成
        success = await provider.createPost(post);
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (success) {
          // 成功時の処理
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.post != null ? '投稿を更新しました' : '投稿を作成しました'),
              backgroundColor: AppColors.systemGreen,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, post);
        } else {
          // エラー時の処理（providerでエラーが設定されている）
          final errorMessage = provider.error ?? '不明なエラーが発生しました';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('保存に失敗しました: $errorMessage'),
              backgroundColor: AppColors.systemRed,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: $e'),
            backgroundColor: AppColors.systemRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'twitter':
      case 'x':
        return const Color(0xFF1DA1F2);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'tiktok':
        return const Color(0xFF000000);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'linkedin':
        return const Color(0xFF0077B5);
      default:
        return AppColors.systemBlue;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return CupertinoIcons.camera;
      case 'twitter':
      case 'x':
        return CupertinoIcons.chat_bubble;
      case 'youtube':
        return CupertinoIcons.play_rectangle;
      case 'tiktok':
        return CupertinoIcons.music_note;
      case 'facebook':
        return CupertinoIcons.person_3;
      case 'linkedin':
        return CupertinoIcons.briefcase;
      default:
        return CupertinoIcons.at;
    }
  }

  Color _getStatusColor(PostStatus status) {
    switch (status) {
      case PostStatus.draft:
        return AppColors.systemGray;
      case PostStatus.scheduled:
        return AppColors.systemOrange;
      case PostStatus.published:
        return AppColors.systemGreen;
      case PostStatus.failed:
        return AppColors.systemRed;
    }
  }

  IconData _getStatusIcon(PostStatus status) {
    switch (status) {
      case PostStatus.draft:
        return CupertinoIcons.doc_text;
      case PostStatus.scheduled:
        return CupertinoIcons.clock;
      case PostStatus.published:
        return CupertinoIcons.checkmark_circle;
      case PostStatus.failed:
        return CupertinoIcons.exclamationmark_triangle;
    }
  }
} 