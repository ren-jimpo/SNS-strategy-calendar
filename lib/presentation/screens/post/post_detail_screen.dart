import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/post_model.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel? post;
  final DateTime selectedDate;

  const PostDetailScreen({
    super.key,
    this.post,
    required this.selectedDate,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
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
    } else {
      _scheduledDate = widget.selectedDate;
      _scheduledTime = TimeOfDay.now();
      _targetLikesController.text = '100';
      _targetImpressionsController.text = '2000';
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _memoController.dispose();
    _targetLikesController.dispose();
    _targetImpressionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.post != null;
    
    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      appBar: _buildAppBar(isEditing),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isEditing) {
    return AppBar(
      backgroundColor: AppColors.systemGroupedBackground,
      elevation: 0,
      title: Text(
        isEditing ? '投稿を編集' : '新しい投稿',
        style: AppTypography.navigationTitle,
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.xmark),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _savePost,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  '保存',
                  style: AppTypography.button.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildContentSection(),
          const SizedBox(height: 24),
          _buildScheduleSection(),
          const SizedBox(height: 24),
          _buildCategorySection(),
          const SizedBox(height: 24),
          _buildTagsSection(),
          const SizedBox(height: 24),
          _buildKPISection(),
          const SizedBox(height: 24),
          _buildMemoSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return _buildSection(
      title: '投稿内容',
      icon: CupertinoIcons.textformat,
      child: TextFormField(
        controller: _contentController,
        maxLines: 6,
        style: AppTypography.body,
        decoration: InputDecoration(
          hintText: 'SNS投稿の内容を入力してください...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.systemGray4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.systemGray4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '投稿内容を入力してください';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildScheduleSection() {
    return _buildSection(
      title: 'スケジュール',
      icon: CupertinoIcons.calendar,
      child: Column(
        children: [
          _buildDateTimeTile(
            '日付',
            DateFormat('yyyy年M月d日(E)', 'ja').format(_scheduledDate),
            () => _selectDate(),
          ),
          const SizedBox(height: 12),
          _buildDateTimeTile(
            '時刻',
            _scheduledTime.format(context),
            () => _selectTime(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return _buildSection(
      title: 'カテゴリ',
      icon: CupertinoIcons.folder,
      child: Column(
        children: [
          _buildDropdown(
            '投稿フェーズ',
            _selectedPhase.displayName,
            PostPhase.values,
            (phase) => setState(() => _selectedPhase = phase),
            (phase) => phase.displayName,
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            '投稿タイプ',
            _selectedType.displayName,
            PostType.values,
            (type) => setState(() => _selectedType = type),
            (type) => type.displayName,
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
            child: TextFormField(
              controller: _targetLikesController,
              keyboardType: TextInputType.number,
              style: AppTypography.body,
              decoration: InputDecoration(
                labelText: 'いいね数',
                hintText: '100',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '目標値を入力';
                }
                if (int.tryParse(value) == null) {
                  return '数値で入力';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _targetImpressionsController,
              keyboardType: TextInputType.number,
              style: AppTypography.body,
              decoration: InputDecoration(
                labelText: 'インプレッション数',
                hintText: '2000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '目標値を入力';
                }
                if (int.tryParse(value) == null) {
                  return '数値で入力';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoSection() {
    return _buildSection(
      title: 'メモ',
      icon: CupertinoIcons.pencil,
      child: TextFormField(
        controller: _memoController,
        maxLines: 3,
        style: AppTypography.body,
        decoration: InputDecoration(
          hintText: 'メモや注意事項があれば記入してください...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.systemGray4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.systemGray4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.headline,
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDateTimeTile(String label, String value, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.systemGray4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          label,
          style: AppTypography.footnote.copyWith(
            color: AppColors.secondaryLabel,
          ),
        ),
        subtitle: Text(
          value,
          style: AppTypography.body,
        ),
        trailing: const Icon(
          CupertinoIcons.chevron_right,
          color: AppColors.systemGray,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDropdown<T>(
    String label,
    String currentValue,
    List<T> items,
    Function(T) onChanged,
    String Function(T) displayName,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.systemGray4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<T>(
        value: items.firstWhere((item) => displayName(item) == currentValue),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(displayName(item)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }

  Widget _buildSelectedTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$tag',
            style: AppTypography.footnote.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTags.remove(tag);
              });
            },
            child: Icon(
              CupertinoIcons.xmark,
              size: 14,
              color: AppColors.primary,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.systemGray4, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.add,
              size: 16,
              color: AppColors.systemGray,
            ),
            const SizedBox(width: 4),
            Text(
              'タグを追加',
              style: AppTypography.footnote.copyWith(
                color: AppColors.systemGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _scheduledDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );
    
    if (time != null) {
      setState(() {
        _scheduledTime = time;
      });
    }
  }

  void _showTagSelector() {
    final availableTags = _availableTags
        .where((tag) => !_selectedTags.contains(tag))
        .toList();

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.secondarySystemGroupedBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Text(
                'タグを選択',
                style: AppTypography.headline,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: availableTags.length,
                  itemBuilder: (context, index) {
                    final tag = availableTags[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTags.add(tag);
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.systemGray6,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$tag',
                          style: AppTypography.footnote.copyWith(
                            color: AppColors.label,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // モック保存処理（2秒待機）
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

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
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      
      Navigator.pop(context);
    }
  }
} 