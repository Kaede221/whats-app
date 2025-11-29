import 'package:flutter/material.dart';

/// 任务分组模型
/// 用于对任务进行分类管理
class TaskGroup {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskGroup({
    required this.id,
    required this.name,
    this.color = const Color(0xFF6750A4),
    this.icon = Icons.folder_outlined,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 默认分组（收集箱）
  static TaskGroup get inbox => TaskGroup(
        id: 'inbox',
        name: '收集箱',
        color: const Color(0xFF6750A4),
        icon: Icons.inbox_outlined,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// 复制并修改
  TaskGroup copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 转换为 Map（用于持久化）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icon.codePoint,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 从 Map 创建（用于持久化）
  factory TaskGroup.fromMap(Map<String, dynamic> map) {
    return TaskGroup(
      id: map['id'] as String,
      name: map['name'] as String,
      color: Color(map['color'] as int),
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskGroup && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}