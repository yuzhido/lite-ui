import 'package:flutter/material.dart';

import 'model.dart';

/// 顶部拖拽手柄指示器
///
/// 底部弹窗顶部的短横条，提示用户可拖拽关闭。
class ActionSheetDragHandle extends StatelessWidget {
  const ActionSheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final handleColor = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.2) ?? Colors.grey.shade300;

    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        decoration: BoxDecoration(color: handleColor, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}

/// ActionSheet 头部区域：左对齐标题 + 右侧关闭按钮
class ActionSheetHeader extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onClose;

  const ActionSheetHeader({this.title, this.description, this.onClose, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 4, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧：标题 + 描述
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title!, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, height: 1.3)),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(description!, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.55), height: 1.4)),
                ],
              ],
            ),
          ),
          // 右侧：关闭按钮（保证 44x44 最小触控区域）
          GestureDetector(
            onTap: onClose,
            child: Container(width: 44, height: 44, alignment: Alignment.topCenter, child: Icon(Icons.close, size: 20)),
          ),
        ],
      ),
    );
  }
}

/// ActionSheet 搜索输入框
class ActionSheetSearchField extends StatelessWidget {
  final String hint;
  final String keyword;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const ActionSheetSearchField({required this.hint, required this.keyword, required this.onChanged, required this.onClear, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: keyword.isNotEmpty
              ? SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.clear, size: 18), onPressed: onClear),
                )
              : null,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.6), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

/// 带选中勾选标记的列表项
class ActionSheetCheckListItem extends StatelessWidget {
  final ActionSheetItem item;
  final bool isSelected;
  final VoidCallback? onTap;

  const ActionSheetCheckListItem({required this.item, required this.isSelected, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label, style: theme.textTheme.titleMedium?.copyWith(color: item.textColor ?? theme.colorScheme.primary, height: 1.3)),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5), height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(11)),
                  child: Icon(Icons.check, size: 14, color: theme.colorScheme.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 多选模式底部栏：已选数量 + 确定按钮
class ActionSheetBottomBar extends StatelessWidget {
  final int selectedCount;
  final String confirmLabel;
  final VoidCallback? onConfirm;

  const ActionSheetBottomBar({required this.selectedCount, required this.confirmLabel, this.onConfirm, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        border: Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedCount > 0 ? '已选择 $selectedCount 项' : '未选择',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selectedCount > 0 ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                  fontWeight: selectedCount > 0 ? FontWeight.w500 : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: selectedCount > 0 ? onConfirm : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(88, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// 空状态占位组件
class ActionSheetEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const ActionSheetEmptyState({required this.message, this.icon = Icons.search_off, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}
