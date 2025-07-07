import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 日本語のロケール情報を初期化
  await initializeDateFormatting('ja');
  
  runApp(const SNSStrategyCalendarApp());
}

class SNSStrategyCalendarApp extends StatelessWidget {
  const SNSStrategyCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNS戦略カレンダー',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
      builder: (context, child) {
        // システムUIのオーバーレイスタイルを設定
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // フォントサイズの固定
          ),
          child: child!,
        );
      },
    );
  }
}
