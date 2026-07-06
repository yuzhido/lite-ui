import 'package:flutter/material.dart';

/// 顶部拖拽手柄指示器
class TreeSheetDragHandle extends StatelessWidget {
  const TreeSheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final handleColor = Theme.of(context).colorScheme.outlineVariant;
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 10, bottom: 0),
        decoration: BoxDecoration(
          color: handleColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// 弹窗头部：标题 + 关闭按钮
class TreeSheetHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onClose;

  const TreeSheetHeader({
    this.title,
    this.subtitle,
    this.onClose,
    super.key,
  });

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
              Expanded(
                child: Text(
                  title ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
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

/// 搜索输入框
class TreeSheetSearchField extends StatefulWidget {
  final String hint;
  final String keyword;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const TreeSheetSearchField({
    required this.hint,
    required this.keyword,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  @override
  State<TreeSheetSearchField> createState() => _TreeSheetSearchFieldState();
}

class _TreeSheetSearchFieldState extends State<TreeSheetSearchField> {
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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

/// 多选底部栏：取消 + 确认按钮
class TreeSheetBottomBar extends StatelessWidget {
  final int selectedCount;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const TreeSheetBottomBar({
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                selectedCount > 0 ? '已选 $selectedCount 项' : '请选择',
                style: TextStyle(fontSize: 13, color: theme.hintColor),
              ),
            ),
            TextButton(
              onPressed: onCancel,
              child: Text(cancelLabel,
                  style: TextStyle(color: theme.hintColor)),
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

/// 竖向树节点行
///
/// 展示展开/收起箭头 + 可选 checkbox + 缩进 + 标签文本
class TreeNodeTile extends StatelessWidget {
  /// 层级深度（从 0 开始）
  final int depth;

  /// 节点标签
  final String label;

  /// 副标题
  final String? subtitle;

  /// 是否叶子节点
  final bool isLeaf;

  /// 是否展开（非叶子节点时有效）
  final bool isExpanded;

  /// 是否已选中
  final bool isChecked;

  /// 是否部分选中（多选模式下父节点状态）
  final bool isPartial;

  /// 是否禁用
  final bool isDisabled;

  /// 是否多选模式
  final bool multiple;

  /// 点击回调
  final VoidCallback? onTap;

  /// 展开/收起回调
  final VoidCallback? onToggleExpand;

  /// 右侧额外内容（如子项计数）
  final Widget? trailing;

  const TreeNodeTile({
    required this.depth,
    required this.label,
    required this.isLeaf,
    required this.isExpanded,
    required this.isChecked,
    this.subtitle,
    this.isPartial = false,
    this.isDisabled = false,
    this.multiple = false,
    this.onTap,
    this.onToggleExpand,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final effectiveOnTap = isDisabled ? null : onTap;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
        decoration: BoxDecoration(
          color: isChecked && !multiple
              ? primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: effectiveOnTap,
            child: Padding(
              padding: EdgeInsets.only(
                left: 12.0 + depth * 24.0,
                right: 12,
                top: 10,
                bottom: 10,
              ),
              child: Row(
                children: [
                  // 展开/收起箭头
                  GestureDetector(
                    onTap: isLeaf ? null : onToggleExpand,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: isLeaf
                          ? const SizedBox.shrink()
                          : AnimatedRotation(
                              turns: isExpanded ? 0.25 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: theme.iconTheme.color
                                    ?.withValues(alpha: 0.5),
                              ),
                            ),
                    ),
                  ),
                  // 多选 checkbox
                  if (multiple) ...[
                    const SizedBox(width: 4),
                    _buildCheckbox(primary),
                    const SizedBox(width: 8),
                  ],
                  // 文本
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            color:
                                isChecked ? primary : Colors.black87,
                            fontWeight: isChecked
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.5),
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // 右侧 trailing
                  ?trailing,
                  // 单选勾选标记
                  if (!multiple && isChecked)
                    Icon(Icons.check_circle, color: primary, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(Color primary) {
    if (isPartial) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          border: Border.all(color: primary, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 2,
            color: primary,
          ),
        ),
      );
    }
    if (isChecked) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    }
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// 节点内联 loading（懒加载时显示）
class TreeNodeInlineLoading extends StatelessWidget {
  final int depth;

  const TreeNodeInlineLoading({required this.depth, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 12.0 + depth * 24.0 + 28,
        right: 12,
        top: 8,
        bottom: 8,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(
            '加载子节点...',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

/// 空状态占位组件
class TreeEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const TreeEmptyState({
    required this.message,
    this.icon = Icons.search_off,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 40,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 全局 loading 状态
class TreeLoadingState extends StatelessWidget {
  final String? message;

  const TreeLoadingState({this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
