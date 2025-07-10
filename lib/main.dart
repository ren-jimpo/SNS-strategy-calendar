import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/supabase_config.dart';
import 'presentation/providers/sns_data_provider.dart';
import 'presentation/providers/kpi_data_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 日本語のロケール情報を初期化
  await initializeDateFormatting('ja');
  
  // Supabaseの初期化
  try {
    await SupabaseConfig.initialize();
    print('✅ Supabase initialized successfully');
    
    // 開発者向け設定状況の表示
    if (SupabaseConfig.isDevMode) {
      SupabaseConfig.printConfigStatus();
    }
  } catch (e) {
    print('❌ Supabase initialization failed: $e');
  }
  
  runApp(const SNSStrategyCalendarApp());
}

class SNSStrategyCalendarApp extends StatelessWidget {
  const SNSStrategyCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SnsDataProvider()),
        ChangeNotifierProvider(create: (_) => KpiDataProvider()),
      ],
      child: MaterialApp(
        title: 'SNS戦略カレンダー',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: SupabaseConfig.skipAuth ? const MainScreen() : const LoginScreen(),
        builder: (context, child) {
          // システムUIのオーバーレイスタイルを設定
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0), // フォントサイズの固定
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
