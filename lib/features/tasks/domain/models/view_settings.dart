/// 视图设置模型
/// 用于存储任务列表的显示设置，包括隐藏详情、分组方式、排序方式
library;

/// 分组方式枚举
enum GroupBy {
  /// 不分组
  none('none', '不分组'),

  /// 按分组
  group('group', '按分组'),

  /// 按时间
  dueDate('dueDate', '按时间'),

  /// 按优先级
  priority('priority', '按优先级');

  final String value;
  final String label;

  const GroupBy(this.value, this.label);

  /// 从字符串值获取枚举
  static GroupBy fromValue(String value) {
    return GroupBy.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GroupBy.none,
    );
  }
}

/// 排序方式枚举
enum SortBy {
  /// 按创建时间
  createdAt('createdAt', '创建时间'),

  /// 按截止时间
  dueDate('dueDate', '截止时间'),

  /// 按优先级
  priority('priority', '优先级');

  final String value;
  final String label;

  const SortBy(this.value, this.label);

  /// 从字符串值获取枚举
  static SortBy fromValue(String value) {
    return SortBy.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SortBy.createdAt,
    );
  }
}

/// 排序顺序枚举
enum SortOrder {
  /// 升序
  ascending('asc', '升序'),

  /// 降序
  descending('desc', '降序');

  final String value;
  final String label;

  const SortOrder(this.value, this.label);

  /// 从字符串值获取枚举
  static SortOrder fromValue(String value) {
    return SortOrder.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SortOrder.descending,
    );
  }
}

/// 视图设置类
class ViewSettings {
  /// 是否隐藏详情
  final bool hideDetails;

  /// 分组方式
  final GroupBy groupBy;

  /// 排序方式
  final SortBy sortBy;

  /// 排序顺序
  final SortOrder sortOrder;

  /// 上次查看的筛选器ID
  /// 用于记录用户离开时正在查看的分组/筛选器
  final String? lastFilterId;

  const ViewSettings({
    this.hideDetails = false,
    this.groupBy = GroupBy.none,
    this.sortBy = SortBy.createdAt,
    this.sortOrder = SortOrder.descending,
    this.lastFilterId,
  });

  /// 默认设置
  static const ViewSettings defaultSettings = ViewSettings();

  /// 复制并修改
  ViewSettings copyWith({
    bool? hideDetails,
    GroupBy? groupBy,
    SortBy? sortBy,
    SortOrder? sortOrder,
    String? lastFilterId,
  }) {
    return ViewSettings(
      hideDetails: hideDetails ?? this.hideDetails,
      groupBy: groupBy ?? this.groupBy,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      lastFilterId: lastFilterId ?? this.lastFilterId,
    );
  }

  /// 转换为 Map（用于持久化）
  Map<String, dynamic> toMap() {
    return {
      'hideDetails': hideDetails,
      'groupBy': groupBy.value,
      'sortBy': sortBy.value,
      'sortOrder': sortOrder.value,
      'lastFilterId': lastFilterId,
    };
  }

  /// 从 Map 创建（用于持久化）
  factory ViewSettings.fromMap(Map<String, dynamic> map) {
    return ViewSettings(
      hideDetails: map['hideDetails'] as bool? ?? false,
      groupBy: GroupBy.fromValue(map['groupBy'] as String? ?? 'none'),
      sortBy: SortBy.fromValue(map['sortBy'] as String? ?? 'createdAt'),
      sortOrder: SortOrder.fromValue(map['sortOrder'] as String? ?? 'desc'),
      lastFilterId: map['lastFilterId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ViewSettings &&
        other.hideDetails == hideDetails &&
        other.groupBy == groupBy &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder &&
        other.lastFilterId == lastFilterId;
  }

  @override
  int get hashCode {
    return Object.hash(hideDetails, groupBy, sortBy, sortOrder, lastFilterId);
  }

  @override
  String toString() {
    return 'ViewSettings(hideDetails: $hideDetails, groupBy: ${groupBy.label}, sortBy: ${sortBy.label}, sortOrder: ${sortOrder.label}, lastFilterId: $lastFilterId)';
  }
}
