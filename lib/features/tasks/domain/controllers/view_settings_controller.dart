import 'package:flutter/material.dart';
import '../../../../core/services/storage_service.dart';
import '../models/view_settings.dart';

/// 视图设置控制器
/// 管理任务列表的视图设置状态，提供设置的读取和修改操作
class ViewSettingsController extends ChangeNotifier {
  static final ViewSettingsController _instance =
      ViewSettingsController._internal();

  factory ViewSettingsController() => _instance;

  final StorageService _storage = StorageService();

  ViewSettingsController._internal();

  // 当前视图设置
  ViewSettings _settings = ViewSettings.defaultSettings;

  // 是否已初始化
  bool _isInitialized = false;

  /// 获取当前视图设置
  ViewSettings get settings => _settings;

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 是否隐藏详情
  bool get hideDetails => _settings.hideDetails;

  /// 分组方式
  GroupBy get groupBy => _settings.groupBy;

  /// 排序方式
  SortBy get sortBy => _settings.sortBy;

  /// 排序顺序
  SortOrder get sortOrder => _settings.sortOrder;

  /// 从存储加载设置
  Future<void> loadFromStorage() async {
    final savedSettings = _storage.getViewSettings();
    if (savedSettings != null) {
      try {
        _settings = ViewSettings.fromMap(savedSettings);
      } catch (e) {
        // 如果解析失败，使用默认设置
        _settings = ViewSettings.defaultSettings;
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// 保存设置到存储
  Future<void> _saveSettings() async {
    await _storage.saveViewSettings(_settings.toMap());
  }

  /// 切换隐藏详情状态
  void toggleHideDetails() {
    _settings = _settings.copyWith(hideDetails: !_settings.hideDetails);
    _saveSettings();
    notifyListeners();
  }

  /// 设置隐藏详情状态
  void setHideDetails(bool value) {
    if (_settings.hideDetails != value) {
      _settings = _settings.copyWith(hideDetails: value);
      _saveSettings();
      notifyListeners();
    }
  }

  /// 设置分组方式
  void setGroupBy(GroupBy groupBy) {
    if (_settings.groupBy != groupBy) {
      _settings = _settings.copyWith(groupBy: groupBy);
      _saveSettings();
      notifyListeners();
    }
  }

  /// 设置排序方式
  void setSortBy(SortBy sortBy) {
    if (_settings.sortBy != sortBy) {
      _settings = _settings.copyWith(sortBy: sortBy);
      _saveSettings();
      notifyListeners();
    }
  }

  /// 设置排序顺序
  void setSortOrder(SortOrder sortOrder) {
    if (_settings.sortOrder != sortOrder) {
      _settings = _settings.copyWith(sortOrder: sortOrder);
      _saveSettings();
      notifyListeners();
    }
  }

  /// 切换排序顺序
  void toggleSortOrder() {
    final newOrder = _settings.sortOrder == SortOrder.ascending
        ? SortOrder.descending
        : SortOrder.ascending;
    _settings = _settings.copyWith(sortOrder: newOrder);
    _saveSettings();
    notifyListeners();
  }

  /// 更新所有设置
  void updateSettings({
    bool? hideDetails,
    GroupBy? groupBy,
    SortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    _settings = _settings.copyWith(
      hideDetails: hideDetails,
      groupBy: groupBy,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
    _saveSettings();
    notifyListeners();
  }

  /// 重置为默认设置
  void resetToDefault() {
    _settings = ViewSettings.defaultSettings;
    _saveSettings();
    notifyListeners();
  }
}