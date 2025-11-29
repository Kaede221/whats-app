import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../tasks/presentation/pages/tasks_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

/// 应用外壳
/// 包含底部导航栏，管理页面切换
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // 页面列表 - 使用 IndexedStack 保持页面状态
  final List<Widget> _pages = const [
    TasksPage(),
    SettingsPage(),
  ];

  // 导航项配置
  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.task_outlined,
      selectedIcon: Icons.task,
      label: AppConstants.navTasks,
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: AppConstants.navSettings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _navItems
            .map((item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

/// 导航项数据模型
class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}