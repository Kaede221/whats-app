import 'package:flutter/material.dart';
import '../../domain/models/models.dart';

/// 任务列表项组件
/// 显示单个任务的信息，支持完成状态切换和点击编辑
class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleCompleted;
  final VoidCallback? onDelete;

  const TaskListItem({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleCompleted,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.isCompleted;
    
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onError,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 完成状态复选框
                _buildCheckbox(context),
                const SizedBox(width: 12),
                
                // 任务内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题行
                      Row(
                        children: [
                          // 优先级指示器
                          if (task.priority != TaskPriority.none)
                            _buildPriorityIndicator(context),
                          
                          // 标题
                          Expanded(
                            child: Text(
                              task.title,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                decoration: isCompleted 
                                    ? TextDecoration.lineThrough 
                                    : null,
                                color: isCompleted 
                                    ? theme.colorScheme.outline 
                                    : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      // 详情
                      if (task.description != null && task.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            task.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              decoration: isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      
                      // 底部信息行（日期等）
                      if (task.dueDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildDueDateChip(context),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建复选框
  Widget _buildCheckbox(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.isCompleted;
    
    return GestureDetector(
      onTap: onToggleCompleted,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isCompleted 
                ? theme.colorScheme.primary 
                : task.priority.color,
            width: 2,
          ),
          color: isCompleted 
              ? theme.colorScheme.primary 
              : Colors.transparent,
        ),
        child: isCompleted
            ? Icon(
                Icons.check,
                size: 16,
                color: theme.colorScheme.onPrimary,
              )
            : null,
      ),
    );
  }

  /// 构建优先级指示器
  Widget _buildPriorityIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(
        task.priority.icon,
        size: 16,
        color: task.priority.color,
      ),
    );
  }

  /// 构建截止日期标签
  Widget _buildDueDateChip(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = _isOverdue();
    final isToday = _isToday();
    
    Color chipColor;
    Color textColor;
    
    if (task.isCompleted) {
      chipColor = theme.colorScheme.surfaceContainerHighest;
      textColor = theme.colorScheme.outline;
    } else if (isOverdue) {
      chipColor = theme.colorScheme.errorContainer;
      textColor = theme.colorScheme.error;
    } else if (isToday) {
      chipColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.primary;
    } else {
      chipColor = theme.colorScheme.surfaceContainerHighest;
      textColor = theme.colorScheme.onSurfaceVariant;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDueDate(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 检查是否过期
  bool _isOverdue() {
    if (task.dueDate == null || task.isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return task.dueDate!.isBefore(today);
  }

  /// 检查是否是今天
  bool _isToday() {
    if (task.dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      task.dueDate!.year, 
      task.dueDate!.month, 
      task.dueDate!.day,
    );
    return dueDate == today;
  }

  /// 格式化截止日期
  String _formatDueDate() {
    if (task.dueDate == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final dueDate = DateTime(
      task.dueDate!.year, 
      task.dueDate!.month, 
      task.dueDate!.day,
    );
    
    if (dueDate == today) {
      return '今天';
    } else if (dueDate == tomorrow) {
      return '明天';
    } else if (dueDate == yesterday) {
      return '昨天';
    } else if (task.dueDate!.year == now.year) {
      return '${task.dueDate!.month}月${task.dueDate!.day}日';
    } else {
      return '${task.dueDate!.year}年${task.dueDate!.month}月${task.dueDate!.day}日';
    }
  }
}