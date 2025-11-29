import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/models.dart';
import '../../domain/controllers/task_controller.dart';
import '../widgets/task_list_item.dart';
import 'add_task_page.dart';

/// 任务页面
/// 显示用户的任务列表，支持添加、编辑、删除任务
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TaskController _taskController = TaskController();

  @override
  void initState() {
    super.initState();
    _taskController.addListener(_onTasksChanged);
  }

  @override
  void dispose() {
    _taskController.removeListener(_onTasksChanged);
    super.dispose();
  }

  void _onTasksChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final incompleteTasks = _taskController.incompleteTasks;
    final completedTasks = _taskController.completedTasks;
    final hasAnyTasks = incompleteTasks.isNotEmpty || completedTasks.isNotEmpty;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.titleTasks),
        actions: [
          if (completedTasks.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_completed') {
                  _showClearCompletedDialog(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_completed',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep_outlined),
                      SizedBox(width: 8),
                      Text('清除已完成'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: hasAnyTasks
          ? _buildTaskList(context, incompleteTasks, completedTasks)
          : _buildEmptyState(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddTask(context),
        icon: const Icon(Icons.add),
        label: const Text(AppConstants.addTask),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            AppConstants.noTasks,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加新任务',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建任务列表
  Widget _buildTaskList(
    BuildContext context,
    List<Task> incompleteTasks,
    List<Task> completedTasks,
  ) {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      children: [
        // 未完成的任务
        ...incompleteTasks.map((task) => TaskListItem(
          key: Key(task.id),
          task: task,
          onTap: () => _navigateToEditTask(context, task),
          onToggleCompleted: () => _taskController.toggleTaskCompleted(task.id),
          onDelete: () => _deleteTask(context, task),
        )),
        
        // 已完成的任务（可折叠）
        if (completedTasks.isNotEmpty)
          _buildCompletedSection(context, completedTasks),
      ],
    );
  }

  /// 构建已完成任务分组
  Widget _buildCompletedSection(BuildContext context, List<Task> completedTasks) {
    final theme = Theme.of(context);
    
    return ExpansionTile(
      initiallyExpanded: false,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        '已完成 (${completedTasks.length})',
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      children: completedTasks.map((task) => TaskListItem(
        key: Key(task.id),
        task: task,
        onTap: () => _navigateToEditTask(context, task),
        onToggleCompleted: () => _taskController.toggleTaskCompleted(task.id),
        onDelete: () => _deleteTask(context, task),
      )).toList(),
    );
  }

  /// 导航到添加任务页面
  Future<void> _navigateToAddTask(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskPage(),
      ),
    );
    
    // 如果返回 true，表示任务已添加
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('任务已添加'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 导航到编辑任务页面
  Future<void> _navigateToEditTask(BuildContext context, Task task) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskPage(task: task),
      ),
    );
    
    // 如果返回 true，表示任务已更新
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('任务已更新'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 删除任务
  void _deleteTask(BuildContext context, Task task) {
    _taskController.deleteTask(task.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已删除 "${task.title}"'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            _taskController.addTask(task);
          },
        ),
      ),
    );
  }

  /// 显示清除已完成任务对话框
  void _showClearCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除已完成任务'),
        content: Text('确定要删除所有 ${_taskController.completedTasks.length} 个已完成的任务吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              _taskController.clearCompletedTasks();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已清除所有已完成任务'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}