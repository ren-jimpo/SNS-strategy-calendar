import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/kpi_model.dart';
import '../providers/kpi_data_provider.dart';

class KpiProgressEditModal extends StatefulWidget {
  final KpiModel kpi;

  const KpiProgressEditModal({
    super.key,
    required this.kpi,
  });

  @override
  State<KpiProgressEditModal> createState() => _KpiProgressEditModalState();
}

class _KpiProgressEditModalState extends State<KpiProgressEditModal> with TickerProviderStateMixin {
  late TextEditingController _currentValueController;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  late AnimationController _colorAnimationController;
  late Animation<Color?> _colorAnimation;
  
  bool _isLoading = false;
  double _sliderValue = 0.0;
  double _currentProgress = 0.0;
  bool _isSliderActive = false;

  @override
  void initState() {
    super.initState();
    _currentValueController = TextEditingController(
      text: widget.kpi.currentValue.toString(),
    );
    
    // アニメーションコントローラーの初期化
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _colorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 初期進捗値の設定
    _currentProgress = widget.kpi.progress;
    _sliderValue = widget.kpi.currentValue.clamp(0, _sliderMaxValue);
    
    // アニメーションの設定
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _currentProgress / 100,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _updateColorAnimation(_currentProgress);
    
    // 入力フィールドの変更リスナー
    _currentValueController.addListener(_onTextFieldChanged);
    
    // 初期アニメーション開始
    _progressAnimationController.forward();
    _colorAnimationController.forward();
  }

  @override
  void dispose() {
    _currentValueController.removeListener(_onTextFieldChanged);
    _currentValueController.dispose();
    _progressAnimationController.dispose();
    _colorAnimationController.dispose();
    super.dispose();
  }

  void _onTextFieldChanged() {
    if (!_isSliderActive) {
      final newValue = double.tryParse(_currentValueController.text) ?? 0;
      setState(() {
        _sliderValue = newValue.clamp(0, _sliderMaxValue);
      });
      _updateProgress(newValue);
    }
  }

  void _onSliderChanged(double value) {
    setState(() {
      _isSliderActive = true;
      _sliderValue = value;
      _currentValueController.text = value.toStringAsFixed(1);
    });
    _updateProgress(value);
    
    // スライダー操作終了後の処理
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _isSliderActive = false;
      });
    });
  }

  void _updateProgress(double newValue) {
    final newProgress = _calculateProgress(newValue);
    
    if (newProgress != _currentProgress) {
      setState(() {
        _currentProgress = newProgress;
      });
      
      // 進捗バーアニメーション
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: _currentProgress / 100,
      ).animate(CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ));
      
      _progressAnimationController.reset();
      _progressAnimationController.forward();
      
      // 色のアニメーション更新
      _updateColorAnimation(_currentProgress);
      _colorAnimationController.reset();
      _colorAnimationController.forward();
    }
  }

  void _updateColorAnimation(double progress) {
    Color fromColor = _getProgressColor(widget.kpi.progress);
    Color toColor = _getProgressColor(progress);
    
    _colorAnimation = ColorTween(
      begin: fromColor,
      end: toColor,
    ).animate(CurvedAnimation(
      parent: _colorAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  double _calculateProgress(double currentValue) {
    if (widget.kpi.targetValue <= 0) {
      // 目標値が0以下の場合は、現在値をそのまま表示する簡易計算
      return currentValue.clamp(0, 100);
    }
    return ((currentValue / widget.kpi.targetValue) * 100).clamp(0, 100);
  }

  // スライダーの最大値を計算（目標値が0以下の場合の対応）
  double get _sliderMaxValue {
    if (widget.kpi.targetValue <= 0) {
      return 100000.0; // デフォルトの最大値
    }
    return widget.kpi.targetValue; // 100%まで
  }

  // 目標値が有効かどうかを判定
  bool get _isTargetValueValid {
    return widget.kpi.targetValue > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 500,
        ),
        decoration: BoxDecoration(
          color: AppColors.systemGroupedBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(child: _buildContent()),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
              color: widget.kpi.type == KpiType.kgi 
                ? AppColors.accentPurple 
                : AppColors.systemBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.kpi.type == KpiType.kgi 
                ? CupertinoIcons.star_fill 
                : CupertinoIcons.chart_bar_fill,
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
                  '達成度を更新',
                  style: AppTypography.title2.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.kpi.name,
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 現在の進捗表示（アニメーション付き）
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.systemBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.separator.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '進捗状況',
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.secondaryLabel,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: _colorAnimation,
                        builder: (context, child) {
                          return Text(
                            '${_currentProgress.toStringAsFixed(1)}%',
                            style: AppTypography.title1.copyWith(
                              color: _colorAnimation.value ?? _getProgressColor(_currentProgress),
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      Text(
                        _isTargetValueValid 
                          ? '目標: ${widget.kpi.targetValue.toStringAsFixed(1)}${widget.kpi.unit}'
                          : '目標値が設定されていません',
                        style: AppTypography.caption1.copyWith(
                          color: _isTargetValueValid 
                            ? AppColors.tertiaryLabel 
                            : AppColors.systemRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // アニメーション付き進捗バー
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.systemGray5,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return AnimatedBuilder(
                          animation: _colorAnimation,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: _progressAnimation.value.clamp(0.0, 1.0),
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation(
                                _colorAnimation.value ?? _getProgressColor(_currentProgress),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 進捗ラベル
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0%',
                        style: AppTypography.caption2.copyWith(
                          color: AppColors.tertiaryLabel,
                        ),
                      ),
                      Text(
                        '100%',
                        style: AppTypography.caption2.copyWith(
                          color: AppColors.tertiaryLabel,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // インタラクティブスライダー（目標値が有効な場合のみ）
            Text(
              '達成値を調整',
              style: AppTypography.headline.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.systemBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.separator.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // スライダー（目標値が有効な場合のみ表示）
                  if (_isTargetValueValid) ...[
                    Row(
                      children: [
                        Text(
                          '0',
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.tertiaryLabel,
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 12,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 20,
                              ),
                              activeTrackColor: _getProgressColor(_currentProgress),
                              inactiveTrackColor: AppColors.systemGray5,
                              thumbColor: _getProgressColor(_currentProgress),
                              overlayColor: _getProgressColor(_currentProgress).withOpacity(0.2),
                            ),
                            child: Slider(
                              value: _sliderValue.clamp(0, _sliderMaxValue),
                              min: 0,
                              max: _sliderMaxValue,
                              onChanged: _onSliderChanged,
                            ),
                          ),
                        ),
                        Text(
                          '${_sliderMaxValue.toStringAsFixed(0)}',
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.tertiaryLabel,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // 数値入力フィールド
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.systemGray6.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.separator.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _currentValueController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: AppTypography.body,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: '現在値',
                              suffix: Text(
                                widget.kpi.unit,
                                style: AppTypography.body.copyWith(
                                  color: AppColors.secondaryLabel,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                              labelStyle: AppTypography.body.copyWith(
                                color: AppColors.secondaryLabel,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // クイック設定ボタン
                      Column(
                        children: [
                          if (_isTargetValueValid) ...[
                            _buildQuickSetButton('25%', widget.kpi.targetValue * 0.25),
                            const SizedBox(height: 4),
                            _buildQuickSetButton('50%', widget.kpi.targetValue * 0.5),
                            const SizedBox(height: 4),
                            _buildQuickSetButton('100%', widget.kpi.targetValue),
                          ] else ...[
                            _buildQuickSetButton('1K', 1000),
                            const SizedBox(height: 4),
                            _buildQuickSetButton('5K', 5000),
                            const SizedBox(height: 4),
                            _buildQuickSetButton('10K', 10000),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 目標値無効時の警告メッセージ
            if (!_isTargetValueValid) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.systemOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.systemOrange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_triangle_fill,
                      color: AppColors.systemOrange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'このKGIの目標値が設定されていません。編集画面で目標値を設定してください。',
                        style: AppTypography.caption1.copyWith(
                          color: AppColors.systemOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // リアルタイムフィードバック
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getProgressColor(_currentProgress).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getProgressColor(_currentProgress).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getProgressIcon(_currentProgress),
                    color: _getProgressColor(_currentProgress),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getProgressMessage(_currentProgress),
                      style: AppTypography.caption1.copyWith(
                        color: _getProgressColor(_currentProgress),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${_sliderValue.toStringAsFixed(1)}${widget.kpi.unit}',
                    style: AppTypography.caption1.copyWith(
                      color: _getProgressColor(_currentProgress),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.separator.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
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
              color: widget.kpi.type == KpiType.kgi 
                ? AppColors.accentPurple 
                : AppColors.systemBlue,
              borderRadius: BorderRadius.circular(12),
              onPressed: _isLoading ? null : _saveProgress,
              child: _isLoading
                ? const CupertinoActivityIndicator(color: Colors.white)
                : Text(
                    '達成度を更新',
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

  Color _getProgressColor(double progress) {
    if (!_isTargetValueValid) return AppColors.systemOrange;
    if (progress >= 80) return AppColors.systemGreen;
    if (progress >= 60) return AppColors.systemOrange;
    return AppColors.systemRed;
  }

  Future<void> _saveProgress() async {
    final newValue = double.tryParse(_currentValueController.text) ?? _sliderValue;
    if (newValue < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('0以上の数値を入力してください'),
          backgroundColor: AppColors.systemRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final kpiProvider = Provider.of<KpiDataProvider>(context, listen: false);
      final success = await kpiProvider.updateKpiCurrentValue(widget.kpi.id, newValue);

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.kpi.type.displayName}の達成度を更新しました'),
              backgroundColor: AppColors.systemGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(kpiProvider.error ?? '更新に失敗しました'),
              backgroundColor: AppColors.systemRed,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: ${e.toString()}'),
            backgroundColor: AppColors.systemRed,
            duration: const Duration(seconds: 3),
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

  Widget _buildQuickSetButton(String label, double value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _sliderValue = value;
          _currentValueController.text = value.toStringAsFixed(1);
        });
        _updateProgress(value);
      },
      child: Container(
        width: 40,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.systemBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.systemBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.caption2.copyWith(
              color: AppColors.systemBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getProgressIcon(double progress) {
    if (!_isTargetValueValid) return CupertinoIcons.exclamationmark_triangle;
    if (progress >= 100) return CupertinoIcons.checkmark_circle_fill;
    if (progress >= 80) return CupertinoIcons.arrow_up_circle_fill;
    if (progress >= 60) return CupertinoIcons.arrow_right_circle_fill;
    return CupertinoIcons.exclamationmark_circle_fill;
  }

  String _getProgressMessage(double progress) {
    if (!_isTargetValueValid) {
      return '目標値を設定して進捗を計算しましょう';
    }
    if (progress >= 100) return '目標達成！素晴らしい成果です';
    if (progress >= 80) return '目標まであと少し！順調に進んでいます';
    if (progress >= 60) return '良いペースです。継続していきましょう';
    return '目標達成に向けて頑張りましょう';
  }
} 