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
    final handleColor = theme.colorScheme.outlineVariant;

    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 10, bottom: 0),
        decoration: BoxDecoration(color: handleColor, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}

/// ActionSheet 头部区域：左对齐标题 + 右侧计数 + 关闭按钮
class ActionSheetHeader extends StatelessWidget {
  final String? title;
  final String? description;
  final int? itemCount;
  final VoidCallback? onClose;

  const ActionSheetHeader({this.title, this.description, this.itemCount, this.onClose, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 左侧标题
              Expanded(
                child: Text(
                  title ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // 计数
              if (itemCount != null)
                Text('共 $itemCount 项', style: TextStyle(fontSize: 16, color: theme.hintColor)),
              const SizedBox(width: 8),
              // 关闭按钮
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          // 描述（保留组件特有能力）
          if (description != null) ...[
            const SizedBox(height: 2),
            Text(
              description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.55),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ActionSheet 搜索输入框
class ActionSheetSearchField extends StatefulWidget {
  final String hint;
  final String keyword;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const ActionSheetSearchField({
    required this.hint,
    required this.keyword,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  @override
  State<ActionSheetSearchField> createState() => _ActionSheetSearchFieldState();
}

class _ActionSheetSearchFieldState extends State<ActionSheetSearchField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              suffixIcon: widget.keyword.isNotEmpty
                  ? SizedBox(
                      width: 44,
                      height: 44,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: widget.onClear,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
        ],
      ),
    );
  }
}

/// 带选中勾选标记的列表项
class ActionSheetCheckListItem extends StatelessWidget {
  final ActionSheetItem item;
  final bool isSelected;
  final bool multiple;
  final VoidCallback? onTap;

  const ActionSheetCheckListItem({
    required this.item,
    required this.isSelected,
    this.multiple = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final avatarChar = item.label.isNotEmpty ? item.label.characters.first : '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? primary.withValues(alpha: 0.08) : theme.canvasColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // 左侧圆形头像（首字母）
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? primary.withValues(alpha: 0.2) : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      avatarChar,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 文本内容
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected ? primary : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // 右侧勾选标记（单选时显示）
                if (!multiple && isSelected)
                  Icon(Icons.check_circle, color: primary, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 多选模式底部栏：取消 + 确认按钮（右对齐）
class ActionSheetBottomBar extends StatelessWidget {
  final int selectedCount;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const ActionSheetBottomBar({
    required this.selectedCount,
    required this.cancelLabel,
    required this.confirmLabel,
    this.onCancel,
    this.onConfirm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: onCancel,
              child: Text(cancelLabel, style: TextStyle(color: theme.hintColor)),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: selectedCount > 0 ? onConfirm : null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: theme.colorScheme.outlineVariant,
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
