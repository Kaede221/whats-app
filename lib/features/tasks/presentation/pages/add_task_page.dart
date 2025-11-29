import 'package:flutter/material.dart';
import '../../domain/models/models.dart';
import '../../domain/controllers/task_controller.dart';

/// 添加/编辑任务页面
/// 支持设置标题、详情、优先级、分组、日期等属性
class AddTaskPage extends StatefulWidget {
  /// 要编辑的任务（如果为 null 则为新建任务）
  final Task? task;

  const AddTaskPage({super.key, this.task});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = TaskController();
  final _formKey = GlobalKey<FormState>();
  
  // 表单控制器
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  // 任务属性
  TaskPriority _priority = TaskPriority.none;
  String _groupId = 'inbox';
  DateTime? _dueDate;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    
    if (widget.task != null) {
      _priority = widget.task!.priority;
      _groupId = widget.task!.groupId;
      _dueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑任务' : '添加任务'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 标题输入
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                hintText: '输入任务标题',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入任务标题';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // 详情输入
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '详情（可选）',
                hintText: '输入任务详情',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            
            const SizedBox(height: 24),
            
            // 优先级选择
            _buildSectionTitle(context, '优先级'),
            const SizedBox(height: 8),
            _buildPrioritySelector(context),
            
            const SizedBox(height: 24),
            
            // 分组选择
            _buildSectionTitle(context, '分组'),
            const SizedBox(height: 8),
            _buildGroupSelector(context),
            
            const SizedBox(height: 24),
            
            // 日期选择
            _buildSectionTitle(context, '截止日期'),
            const SizedBox(height: 8),
            _buildDateSelector(context),
          ],
        ),
      ),
    );
  }

  /// 构建分组标题
  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// 构建优先级选择器
  Widget _buildPrioritySelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TaskPriority.values.map((priority) {
        final isSelected = _priority == priority;
        return ChoiceChip(
          label: Text(priority.label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _priority = priority);
            }
          },
          avatar: Icon(
            priority.icon,
            size: 18,
            color: isSelected ? priority.color : null,
          ),
          selectedColor: priority.color.withOpacity(0.2),
          side: isSelected 
              ? BorderSide(color: priority.color, width: 2)
              : null,
        );
      }).toList(),
    );
  }

  /// 构建分组选择器
  Widget _buildGroupSelector(BuildContext context) {
    final theme = Theme.of(context);
    final groups = _taskController.groups;
    final currentGroup = _taskController.getGroupById(_groupId) ?? TaskGroup.inbox;
    
    return InkWell(
      onTap: () => _showGroupPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(currentGroup.icon, color: currentGroup.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                currentGroup.name,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  /// 显示分组选择器
  void _showGroupPicker(BuildContext context) {
    final groups = _taskController.groups;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '选择分组',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            ...groups.map((group) => ListTile(
              leading: Icon(group.icon, color: group.color),
              title: Text(group.name),
              trailing: _groupId == group.id
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                setState(() => _groupId = group.id);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  /// 构建日期选择器
  Widget _buildDateSelector(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: _dueDate != null 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dueDate != null 
                    ? _formatDate(_dueDate!)
                    : '未设置',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _dueDate != null 
                      ? null 
                      : theme.colorScheme.outline,
                ),
              ),
            ),
            if (_dueDate != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _dueDate = null),
                visualDensity: VisualDensity.compact,
              )
            else
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
          ],
        ),
      ),
    );
  }

  /// 选择日期
  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return '今天';
    } else if (dateOnly == tomorrow) {
      return '明天';
    } else if (date.year == now.year) {
      return '${date.month}月${date.day}日';
    } else {
      return '${date.year}年${date.month}月${date.day}日';
    }
  }

  /// 保存任务
  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    
    if (_isEditing) {
      // 更新现有任务
      final updatedTask = widget.task!.copyWith(
        title: title,
        description: description.isNotEmpty ? description : null,
        priority: _priority,
        groupId: _groupId,
        dueDate: _dueDate,
        clearDescription: description.isEmpty,
        clearDueDate: _dueDate == null,
      );
      _taskController.updateTask(updatedTask);
    } else {
      // 创建新任务
      _taskController.createTask(
        title: title,
        description: description.isNotEmpty ? description : null,
        priority: _priority,
        groupId: _groupId,
        dueDate: _dueDate,
      );
    }
    
    Navigator.pop(context, true);
  }
}