import 'package:flutter/material.dart';

/// 空状态占位组件
///
/// 用于列表为空时显示提示信息。
class EmptyState extends StatelessWidget {
  /// 提示信息
  final String message;

  /// 图标
  final IconData icon;

  /// 图标大小，默认 40
  final double iconSize;

  /// 是否显示新增按钮，默认 false
  final bool showAdd;

  /// 新增按钮文字，默认 '新增'
  final String addLabel;

  /// 新增按钮点击回调
  final VoidCallback? onAdd;

  const EmptyState({required this.message, this.icon = Icons.search_off, this.iconSize = 40, this.showAdd = false, this.addLabel = '新增', this.onAdd, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4))),
          if (showAdd && onAdd != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: Text(addLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
