import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/version_check_service.dart';

/// 关于页面
/// 显示应用版本、作者和GitHub链接信息
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final _versionCheckService = VersionCheckService();
  VersionCheckResult? _versionResult;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    setState(() {
      _isChecking = true;
    });
    final result = await _versionCheckService.checkVersion();
    if (mounted) {
      setState(() {
        _versionResult = result;
        _isChecking = false;
      });
    }
  }

  /// 重新检查版本更新并显示提示
  Future<void> _recheckVersion() async {
    setState(() {
      _isChecking = true;
      _versionResult = null;
    });

    final result = await _versionCheckService.checkVersion();

    if (mounted) {
      setState(() {
        _versionResult = result;
        _isChecking = false;
      });

      // 显示检查结果提示
      _showVersionCheckResult(result);
    }
  }

  /// 显示版本检查结果提示
  void _showVersionCheckResult(VersionCheckResult result) {
    String message;
    IconData icon;
    Color? iconColor;

    if (result.error != null) {
      message = '检查更新失败: ${result.error}';
      icon = Icons.error_outline;
      iconColor = Theme.of(context).colorScheme.error;
    } else if (result.hasUpdate) {
      message = '发现新版本 ${result.latestVersion}，点击版本信息可前往下载';
      icon = Icons.system_update;
      iconColor = Theme.of(context).colorScheme.error;
    } else {
      message = '当前已是最新版本 (${result.currentVersion})';
      icon = Icons.check_circle;
      iconColor = Theme.of(context).colorScheme.primary;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 复制文本到剪贴板并显示提示
  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label 已复制到剪贴板'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        children: [
          // 应用图标和名称
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appSlogan,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // 版本信息
          _buildVersionTile(context),

          // 作者信息
          _buildInfoTile(
            context,
            icon: Icons.person_outline,
            title: '作者',
            value: AppConstants.appAuthor,
            onTap: () =>
                _copyToClipboard(context, AppConstants.appAuthor, '作者名'),
          ),

          // GitHub链接
          _buildInfoTile(
            context,
            icon: Icons.code,
            title: 'GitHub',
            value: AppConstants.appGithubUrl,
            onTap: () => _copyToClipboard(
              context,
              AppConstants.appGithubUrl,
              'GitHub链接',
            ),
          ),

          const SizedBox(height: 32),

          // 提示文字
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '点击版本可检查更新，点击其他条目可复制内容',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建版本信息条目
  Widget _buildVersionTile(BuildContext context) {
    final theme = Theme.of(context);

    String subtitle = '正在检查更新...';
    Widget? trailing;
    VoidCallback? onTap;

    if (_isChecking) {
      // Loading state
      trailing = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (_versionResult != null) {
      // 先检查是否有错误
      if (_versionResult!.error != null) {
        subtitle = '检查更新失败 (${_versionResult!.currentVersion})';
        trailing = Icon(Icons.refresh, color: theme.colorScheme.outline);
        onTap = _recheckVersion;
      } else if (_versionResult!.hasUpdate) {
        subtitle =
            '发现新版本: ${_versionResult!.latestVersion} (当前: ${_versionResult!.currentVersion})';
        trailing = Icon(Icons.system_update, color: theme.colorScheme.error);
        onTap = () async {
          if (_versionResult!.releaseUrl != null) {
            final success = await _versionCheckService.launchUpdateUrl(
              _versionResult!.releaseUrl!,
            );
            if (!success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('无法打开链接，请手动复制 GitHub 链接'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        };
      } else {
        subtitle = '已是最新版本 (${_versionResult!.currentVersion})';
        trailing = Icon(Icons.check_circle, color: theme.colorScheme.primary);
        onTap = _recheckVersion;
      }
    }

    return ListTile(
      leading: Icon(
        Icons.info_outline,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: const Text('版本'),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: (_versionResult?.error != null)
              ? theme.colorScheme.error
              : (_versionResult?.hasUpdate ?? false)
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  /// 构建信息条目
  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      trailing: Icon(Icons.copy, size: 20, color: theme.colorScheme.outline),
      onTap: onTap,
    );
  }
}
