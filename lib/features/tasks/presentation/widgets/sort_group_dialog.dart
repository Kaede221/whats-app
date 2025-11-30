import 'package:flutter/material.dart';
import '../../domain/models/view_settings.dart';
import '../../domain/controllers/view_settings_controller.dart';

/// 排序和分组设置弹窗
/// 允许用户选择任务列表的分组方式和排序方式
class SortGroupDialog extends StatefulWidget {
  const SortGroupDialog({super.key});

  /// 显示排序和分组设置弹窗
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const SortGroupDialog(),
    );
  }

  @override
  State<SortGroupDialog> createState() => _SortGroupDialogState();
}

class _SortGroupDialogState extends State<SortGroupDialog> {
  final ViewSettingsController _viewSettingsController =
      ViewSettingsController();

  late GroupBy _selectedGroupBy;
  late SortBy _selectedSortBy;
  late SortOrder _selectedSortOrder;

  @override
  void initState() {
    super.initState();
    _selectedGroupBy = _viewSettingsController.groupBy;
    _selectedSortBy = _viewSettingsController.sortBy;
    _selectedSortOrder = _viewSettingsController.sortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('排序方式'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分组方式部分
            _buildSectionTitle(context, '按照分组'),
            const SizedBox(height: 8),
            _buildGroupByOptions(context),

            const SizedBox(height: 24),

            // 排序方式部分
            _buildSectionTitle(context, '按照排序'),
            const SizedBox(height: 8),
            _buildSortByOptions(context),

            const SizedBox(height: 16),

            // 排序顺序
            _buildSortOrderToggle(context),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _applySettings, child: const Text('确定')),
      ],
    );
  }

  /// 构建分组方式选项
  Widget _buildGroupByOptions(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: GroupBy.values.map((groupBy) {
        final isSelected = _selectedGroupBy == groupBy;
        return ChoiceChip(
          label: Text(groupBy.label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedGroupBy = groupBy);
            }
          },
        );
      }).toList(),
    );
  }

  /// 构建排序方式选项
  Widget _buildSortByOptions(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SortBy.values.map((sortBy) {
        final isSelected = _selectedSortBy == sortBy;
        return ChoiceChip(
          label: Text(sortBy.label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedSortBy = sortBy);
            }
          },
        );
      }).toList(),
    );
  }

  /// 构建排序顺序切换
  Widget _buildSortOrderToggle(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          '排序顺序',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        SegmentedButton<SortOrder>(
          segments: [
            ButtonSegment(
              value: SortOrder.ascending,
              label: const Text('升序'),
              icon: const Icon(Icons.arrow_upward, size: 16),
            ),
            ButtonSegment(
              value: SortOrder.descending,
              label: const Text('降序'),
              icon: const Icon(Icons.arrow_downward, size: 16),
            ),
          ],
          selected: {_selectedSortOrder},
          onSelectionChanged: (selected) {
            setState(() => _selectedSortOrder = selected.first);
          },
        ),
      ],
    );
  }

  /// 构建分区标题
  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// 应用设置
  void _applySettings() {
    _viewSettingsController.updateSettings(
      groupBy: _selectedGroupBy,
      sortBy: _selectedSortBy,
      sortOrder: _selectedSortOrder,
    );
    Navigator.pop(context);
  }
}
