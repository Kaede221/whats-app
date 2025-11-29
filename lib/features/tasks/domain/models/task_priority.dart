import 'package:flutter/material.dart';

/// 任务优先级枚举
/// 定义任务的四个优先级级别及其对应的颜色和标签
enum TaskPriority {
  none(
    label: '无',
    color: Color(0xFF9E9E9E), // 灰色
    icon: Icons.remove,
    value: 0,
  ),
  low(
    label: '低',
    color: Color(0xFF2196F3), // 蓝色
    icon: Icons.keyboard_arrow_down,
    value: 1,
  ),
  medium(
    label: '中',
    color: Color(0xFFFFC107), // 黄色
    icon: Icons.remove,
    value: 2,
  ),
  high(
    label: '高',
    color: Color(0xFFF44336), // 红色
    icon: Icons.keyboard_arrow_up,
    value: 3,
  );

  final String label;
  final Color color;
  final IconData icon;
  final int value;

  const TaskPriority({
    required this.label,
    required this.color,
    required this.icon,
    required this.value,
  });

  /// 根据数值获取优先级
  static TaskPriority fromValue(int value) {
    return TaskPriority.values.firstWhere(
      (p) => p.value == value,
      orElse: () => TaskPriority.none,
    );
  }
}