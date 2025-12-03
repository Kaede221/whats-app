import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionCheckService {
  static const String _githubApiUrl =
      'https://api.github.com/repos/Kaede221/whats-now/releases/latest';
  static const String _githubReleaseUrl =
      'https://github.com/Kaede221/whats-now/releases/latest';

  Future<VersionCheckResult> checkVersion() async {
    String currentVersion = 'Unknown';

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentVersion = packageInfo.version;

      final response = await http
          .get(Uri.parse(_githubApiUrl))
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw const SocketException('连接超时'),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String tagName = data['tag_name'] ?? '';
        // Remove 'v' prefix if present
        final latestVersion = tagName.startsWith('v')
            ? tagName.substring(1)
            : tagName;

        final hasUpdate = _compareVersions(latestVersion, currentVersion) > 0;

        return VersionCheckResult(
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          hasUpdate: hasUpdate,
          releaseUrl: data['html_url'] ?? _githubReleaseUrl,
        );
      } else if (response.statusCode == 403) {
        return VersionCheckResult(
          currentVersion: currentVersion,
          latestVersion: null,
          hasUpdate: false,
          error: 'API请求次数超限，请稍后再试',
          isNetworkError: false,
        );
      } else if (response.statusCode == 404) {
        return VersionCheckResult(
          currentVersion: currentVersion,
          latestVersion: null,
          hasUpdate: false,
          error: '未找到发布版本',
          isNetworkError: false,
        );
      } else {
        return VersionCheckResult(
          currentVersion: currentVersion,
          latestVersion: null,
          hasUpdate: false,
          error: '服务器错误 (${response.statusCode})',
          isNetworkError: false,
        );
      }
    } on SocketException catch (e) {
      // 网络连接错误（包括DNS解析失败）
      String errorMessage;
      if (e.message.contains('Failed host lookup') ||
          e.message.contains('No address associated with hostname') ||
          e.osError?.message.contains('No address associated') == true) {
        errorMessage = '无法连接到服务器，请检查网络连接';
      } else if (e.message.contains('连接超时') ||
          e.message.contains('timed out')) {
        errorMessage = '连接超时，请检查网络后重试';
      } else {
        errorMessage = '网络连接失败，请检查网络设置';
      }
      return VersionCheckResult(
        currentVersion: currentVersion,
        latestVersion: null,
        hasUpdate: false,
        error: errorMessage,
        isNetworkError: true,
      );
    } on http.ClientException catch (e) {
      // HTTP客户端异常
      String errorMessage;
      if (e.message.contains('SocketException') ||
          e.message.contains('Failed host lookup') ||
          e.message.contains('No address associated')) {
        errorMessage = '无法连接到服务器，请检查网络连接';
      } else {
        errorMessage = '网络请求失败，请稍后重试';
      }
      return VersionCheckResult(
        currentVersion: currentVersion,
        latestVersion: null,
        hasUpdate: false,
        error: errorMessage,
        isNetworkError: true,
      );
    } on FormatException {
      return VersionCheckResult(
        currentVersion: currentVersion,
        latestVersion: null,
        hasUpdate: false,
        error: '服务器响应格式错误',
        isNetworkError: false,
      );
    } catch (e) {
      // 检查是否是网络相关错误
      final errorStr = e.toString().toLowerCase();
      bool isNetworkError =
          errorStr.contains('socket') ||
          errorStr.contains('network') ||
          errorStr.contains('host lookup') ||
          errorStr.contains('connection') ||
          errorStr.contains('errno = 7');

      String errorMessage;
      if (isNetworkError) {
        errorMessage = '网络连接失败，请检查网络设置';
      } else {
        errorMessage = '检查更新失败，请稍后重试';
      }

      return VersionCheckResult(
        currentVersion: currentVersion,
        latestVersion: null,
        hasUpdate: false,
        error: errorMessage,
        isNetworkError: isNetworkError,
      );
    }
  }

  int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.tryParse).toList();
    final v2Parts = v2.split('.').map(int.tryParse).toList();

    // Compare major, minor, patch
    for (int i = 0; i < 3; i++) {
      final p1 = (i < v1Parts.length) ? (v1Parts[i] ?? 0) : 0;
      final p2 = (i < v2Parts.length) ? (v2Parts[i] ?? 0) : 0;

      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }
    return 0;
  }

  Future<bool> launchUpdateUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
      return false;
    }
  }
}

class VersionCheckResult {
  final String currentVersion;
  final String? latestVersion;
  final bool hasUpdate;
  final String? releaseUrl;
  final String? error;
  final bool isNetworkError;

  VersionCheckResult({
    required this.currentVersion,
    this.latestVersion,
    required this.hasUpdate,
    this.releaseUrl,
    this.error,
    this.isNetworkError = false,
  });
}
