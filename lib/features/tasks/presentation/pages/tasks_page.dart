import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// 任务页面
/// 显示用户的任务列表，支持添加、编辑、删除任务
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.titleTasks),
      ),
      body: Center(
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: 实现添加任务功能
        },
        icon: const Icon(Icons.add),
        label: const Text(AppConstants.addTask),
      ),
    );
  }
}