import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/kpi_model.dart';
import '../providers/kpi_data_provider.dart';

class KpiEditModal extends StatefulWidget {
  final KpiModel? kpi;
  final List<PhaseModel> phases;
  final KpiType? initialType;

  const KpiEditModal({
    super.key,
    this.kpi,
    required this.phases,
    this.initialType,
  });

  @override
  State<KpiEditModal> createState() => _KpiEditModalState();
}

class _KpiEditModalState extends State<KpiEditModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _unitController;
  late TextEditingController _targetController;
  late TextEditingController _currentController;
  
  KpiType _selectedType = KpiType.kpi;
  String? _selectedPhaseId;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController(text: widget.kpi?.name ?? '');
    _descriptionController = TextEditingController(text: widget.kpi?.description ?? '');
    _unitController = TextEditingController(text: widget.kpi?.unit ?? '');
    _targetController = TextEditingController(text: widget.kpi?.targetValue.toString() ?? '');
    _currentController = TextEditingController(text: widget.kpi?.currentValue.toString() ?? '0');
    
    _selectedType = widget.kpi?.type ?? widget.initialType ?? KpiType.kpi;
    _selectedPhaseId = widget.kpi?.phaseId;
    _isActive = widget.kpi?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.kpi != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
                  _selectedType == KpiType.kgi ? AppColors.accentPurple : AppColors.systemBlue,
                  (_selectedType == KpiType.kgi ? AppColors.accentPurple : AppColors.systemBlue).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _selectedType == KpiType.kgi ? CupertinoIcons.star_fill : CupertinoIcons.chart_bar_fill,
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
                  _isEditing ? '${_selectedType.displayName}編集' : '${_selectedType.displayName}追加',
                  style: AppTypography.title2.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _selectedType == KpiType.kgi ? '主要目標指標' : '重要業績評価指標',
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
          _buildTypeSelector(),
          const SizedBox(height: 20),
          _buildNameField(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          _buildUnitField(),
          const SizedBox(height: 20),
          _buildValueFields(),
          const SizedBox(height: 20),
          _buildPhaseSelector(),
          const SizedBox(height: 20),
          _buildActiveSwitch(),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
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
            child: Text(
              '指標タイプ',
              style: AppTypography.headline.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildTypeOption(KpiType.kpi),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeOption(KpiType.kgi),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTypeOption(KpiType type) {
    final isSelected = _selectedType == type;
    final color = type == KpiType.kgi ? AppColors.accentPurple : AppColors.systemBlue;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.systemGray6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.separator.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              type == KpiType.kgi ? CupertinoIcons.star_fill : CupertinoIcons.chart_bar_fill,
              color: isSelected ? color : AppColors.secondaryLabel,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              type.displayName,
              style: AppTypography.headline.copyWith(
                color: isSelected ? color : AppColors.label,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              type == KpiType.kgi ? '主要目標' : '重要業績',
              style: AppTypography.caption1.copyWith(
                color: AppColors.secondaryLabel,
              ),
            ),
          ],
        ),
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
          labelText: '指標名',
          hintText: '例: 月次フォロワー増加数',
          prefixIcon: Icon(
            CupertinoIcons.textformat,
            color: AppColors.secondaryLabel,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '指標名を入力してください';
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
          hintText: 'この指標について詳しく説明...',
          prefixIcon: Icon(
            CupertinoIcons.doc_text,
            color: AppColors.secondaryLabel,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildUnitField() {
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
        controller: _unitController,
        decoration: InputDecoration(
          labelText: '単位',
          hintText: '例: 人、%、回',
          prefixIcon: Icon(
            CupertinoIcons.number,
            color: AppColors.secondaryLabel,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildValueFields() {
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
            child: Text(
              '目標値・現在値',
              style: AppTypography.headline.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildValueField(
                    _targetController,
                    '目標値',
                    CupertinoIcons.flag,
                    AppColors.systemGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildValueField(
                    _currentController,
                    '現在値',
                    CupertinoIcons.gauge,
                    AppColors.systemBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueField(TextEditingController controller, String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTypography.caption1.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '0',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (double.tryParse(value) == null) {
                  return '数値を入力してください';
                }
              }
              return null;
            },
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseSelector() {
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
            child: Text(
              'フェーズ（任意）',
              style: AppTypography.headline.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: DropdownButtonFormField<String?>(
              value: _selectedPhaseId,
              decoration: InputDecoration(
                hintText: 'フェーズを選択（任意）',
                prefixIcon: Icon(
                  CupertinoIcons.layers,
                  color: AppColors.secondaryLabel,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.separator.withOpacity(0.3),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('フェーズなし'),
                ),
                ...widget.phases.map((phase) => DropdownMenuItem<String>(
                  value: phase.id,
                  child: Text(phase.name),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPhaseId = value;
                });
              },
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
                    'アクティブな指標',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _isActive ? 'ダッシュボードに表示されます' : '非表示にします',
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
                color: _selectedType == KpiType.kgi ? AppColors.accentPurple : AppColors.systemBlue,
                borderRadius: BorderRadius.circular(12),
                onPressed: _isLoading ? null : _saveKpi,
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

  Future<void> _saveKpi() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
      
      final kpiData = KpiModel(
        id: widget.kpi?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        unit: _unitController.text.trim(),
        targetValue: double.tryParse(_targetController.text) ?? 0,
        currentValue: double.tryParse(_currentController.text) ?? 0,
        phaseId: _selectedPhaseId,
        isActive: _isActive,
        createdAt: widget.kpi?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (_isEditing) {
        success = await kpiProvider.updateKpi(kpiData);
      } else {
        success = await kpiProvider.createKpi(kpiData);
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? '${_selectedType.displayName}を更新しました' : '${_selectedType.displayName}を追加しました'),
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