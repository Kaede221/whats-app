import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/shell/presentation/pages/app_shell.dart';

void main() {
  runApp(const KaedeTasksApp());
}

/// Kaede Tasks 应用入口
/// 任务管理应用，支持多平台
class KaedeTasksApp extends StatelessWidget {
  const KaedeTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // 主题配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // 跟随系统主题
      
      // 首页
      home: const AppShell(),
    );
  }
}
