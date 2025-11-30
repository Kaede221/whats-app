import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionCheckService {
  static const String _githubApiUrl = 'https://api.github.com/repos/Kaede221/whats-now/releases/latest';
  static const String _githubReleaseUrl = 'https://github.com/Kaede221/whats-now/releases/latest';

  Future<VersionCheckResult> checkVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(Uri.parse(_githubApiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String tagName = data['tag_name'] ?? '';
        // Remove 'v' prefix if present
        final latestVersion = tagName.startsWith('v') ? tagName.substring(1) : tagName;

        final hasUpdate = _compareVersions(latestVersion, currentVersion) > 0;

        return VersionCheckResult(
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          hasUpdate: hasUpdate,
          releaseUrl: data['html_url'] ?? _githubReleaseUrl,
        );
      } else {
        return VersionCheckResult(
          currentVersion: currentVersion,
          latestVersion: null,
          hasUpdate: false,
          error: 'Failed to fetch release info: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Fallback to package info version if check fails
      String currentVersion = 'Unknown';
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        currentVersion = packageInfo.version;
      } catch (_) {}

      return VersionCheckResult(
        currentVersion: currentVersion,
        latestVersion: null,
        hasUpdate: false,
        error: e.toString(),
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

  VersionCheckResult({
    required this.currentVersion,
    this.latestVersion,
    required this.hasUpdate,
    this.releaseUrl,
    this.error,
  });
}