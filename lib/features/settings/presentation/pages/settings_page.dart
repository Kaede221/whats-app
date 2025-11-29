import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// 设置页面
/// 提供应用设置选项，如主题切换、通知设置等
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.titleSettings),
      ),
      body: ListView(
        children: [
          // 外观设置分组
          _buildSectionHeader(context, '外观'),
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: '深色模式',
            subtitle: '跟随系统',
            onTap: () {
              // TODO: 实现主题切换
            },
          ),
          
          const Divider(),
          
          // 关于分组
          _buildSectionHeader(context, '关于'),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: '版本',
            subtitle: AppConstants.appVersion,
            onTap: null,
          ),
        ],
      ),
    );
  }

  /// 构建设置分组标题
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 构建设置项
  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: theme.colorScheme.outline)
          : null,
      onTap: onTap,
    );
  }
}