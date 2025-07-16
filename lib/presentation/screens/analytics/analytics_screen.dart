import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/under_development_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UnderDevelopmentScreen(
      title: '分析',
      subtitle: 'データ分析レポート',
      icon: CupertinoIcons.graph_circle_fill,
      primaryColor: AppColors.engagement,
      description: '分析機能では投稿やアカウントの詳細なデータ分析を行います。\n'
                  'トレンド分析、パフォーマンス予測、最適投稿時間などの\n'
                  'AI駆動の分析機能を開発中です。',
    );
  }
} 