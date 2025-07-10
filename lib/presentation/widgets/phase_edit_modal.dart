import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/kpi_model.dart';
import '../providers/kpi_data_provider.dart';

class PhaseEditModal extends StatefulWidget {
  final PhaseModel? phase;
  final List<PhaseModel> existingPhases;

  const PhaseEditModal({
    super.key,
    this.phase,
    required this.existingPhases,
  });

  @override
  State<PhaseEditModal> createState() => _PhaseEditModalState();
}

class _PhaseEditModalState extends State<PhaseEditModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late int _order;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController(text: widget.phase?.name ?? '');
    _descriptionController = TextEditingController(text: widget.phase?.description ?? '');
    _order = widget.phase?.order ?? (widget.existingPhases.length + 1);
    _isActive = widget.phase?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.phase != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.systemGroupedBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildForm(),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.systemPurple,
                  AppColors.systemPurple.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.layers_alt,
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
                  _isEditing ? 'フェーズ編集' : 'フェーズ追加',
                  style: AppTypography.title2.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'KPI管理のフェーズを設定',
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondaryLabel,
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
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildNameField(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 20),
          _buildOrderSelector(),
          const SizedBox(height: 20),
          _buildActiveSwitch(),
          const SizedBox(height: 20),
          _buildPhasePreview(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'フェーズ名',
          hintText: '例: 企画フェーズ',
          prefixIcon: Icon(
            CupertinoIcons.textformat,
            color: AppColors.secondaryLabel,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'フェーズ名を入力してください';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: '説明',
          hintText: 'このフェーズについて詳しく説明...',
          prefixIcon: Icon(
            CupertinoIcons.doc_text,
            color: AppColors.secondaryLabel,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '説明を入力してください';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildOrderSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.number,
                  color: AppColors.secondaryLabel,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '順序',
                  style: AppTypography.headline.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '表示順序: $_order番目',
                    style: AppTypography.body,
                  ),
                ),
                Row(
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.all(8),
                      minSize: 36,
                      color: AppColors.systemGray4,
                      borderRadius: BorderRadius.circular(8),
                      onPressed: _order > 1 ? () {
                        setState(() {
                          _order--;
                        });
                      } : null,
                      child: const Icon(
                        CupertinoIcons.minus,
                        size: 16,
                        color: AppColors.label,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CupertinoButton(
                      padding: const EdgeInsets.all(8),
                      minSize: 36,
                      color: AppColors.systemGray4,
                      borderRadius: BorderRadius.circular(8),
                      onPressed: () {
                        setState(() {
                          _order++;
                        });
                      },
                      child: const Icon(
                        CupertinoIcons.plus,
                        size: 16,
                        color: AppColors.label,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.checkmark_shield,
              color: _isActive ? AppColors.systemGreen : AppColors.systemGray,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'アクティブなフェーズ',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _isActive ? 'KPI管理に表示されます' : '非表示にします',
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoSwitch(
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhasePreview() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.eye,
                  color: AppColors.secondaryLabel,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'プレビュー',
                  style: AppTypography.headline.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.systemPurple.withOpacity(0.1),
                    AppColors.systemPurple.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.systemPurple.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.systemPurple,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '$_order',
                            style: AppTypography.caption1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _nameController.text.isEmpty ? 'フェーズ名' : _nameController.text,
                          style: AppTypography.headline.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _nameController.text.isEmpty ? AppColors.secondaryLabel : AppColors.label,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_descriptionController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _descriptionController.text,
                      style: AppTypography.body.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.separator.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: AppColors.systemGray4,
                borderRadius: BorderRadius.circular(12),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'キャンセル',
                  style: AppTypography.body.copyWith(
                    color: AppColors.label,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: AppColors.systemPurple,
                borderRadius: BorderRadius.circular(12),
                onPressed: _isLoading ? null : _savePhase,
                child: _isLoading
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : Text(
                      _isEditing ? '更新' : '追加',
                      style: AppTypography.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePhase() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
      
      final phaseData = PhaseModel(
        id: widget.phase?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        order: _order,
        isActive: _isActive,
        createdAt: widget.phase?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (_isEditing) {
        success = await kpiProvider.updatePhase(phaseData);
      } else {
        success = await kpiProvider.createPhase(phaseData);
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'フェーズを更新しました' : 'フェーズを追加しました'),
              backgroundColor: AppColors.systemGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(kpiProvider.error ?? 'エラーが発生しました'),
              backgroundColor: AppColors.systemRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: AppColors.systemRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 