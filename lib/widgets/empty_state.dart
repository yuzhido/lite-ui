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

  const EmptyState({required this.message, this.icon = Icons.search_off, this.iconSize = 40, super.key});

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
        ],
      ),
    );
  }
}
