import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/under_development_screen.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UnderDevelopmentScreen(
      title: 'ランキング',
      subtitle: 'パフォーマンス順位',
      icon: CupertinoIcons.chart_bar_fill,
      primaryColor: AppColors.accent,
      description: 'ランキング機能では投稿のパフォーマンスを様々な指標で順位付けします。\n'
                  'いいね数、インプレッション数、エンゲージメント率などの\n'
                  '詳細な分析機能を開発中です。',
    );
  }
} 