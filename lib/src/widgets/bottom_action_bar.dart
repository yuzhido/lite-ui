import 'package:flutter/material.dart';

/// 底部操作栏组件
///
/// 包含取消和确认按钮，常用于多选模式。
class BottomActionBar extends StatelessWidget {
  /// 已选中数量
  final int selectedCount;

  /// 取消按钮文字
  final String cancelLabel;

  /// 确认按钮文字
  final String confirmLabel;

  /// 取消按钮点击回调
  final VoidCallback? onCancel;

  /// 确认按钮点击回调
  final VoidCallback? onConfirm;

  /// 选中数量为 0 时是否禁用确认按钮，默认 true
  final bool disableWhenEmpty;

  const BottomActionBar({
    required this.selectedCount,
    required this.cancelLabel,
    required this.confirmLabel,
    this.onCancel,
    this.onConfirm,
    this.disableWhenEmpty = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canConfirm = !disableWhenEmpty || selectedCount > 0;

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
              onPressed: canConfirm ? onConfirm : null,
              style: ElevatedButton.styleFrom(disabledBackgroundColor: theme.colorScheme.outlineVariant),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ),
    );
  }
}
