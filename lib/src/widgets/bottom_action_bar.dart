import 'package:flutter/material.dart';

/// 底部操作栏组件
///
/// 包含取消和确认按钮，常用于多选模式。
class BottomActionBar extends StatelessWidget {
  /// 已选中数量
  final int selectedCount;

  /// 查看已选项回调（点击"已选 N 项"时触发）
  final VoidCallback? onViewSelected;

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
    this.onViewSelected,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        border: Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 左侧：已选数量提示（点击可查看已选项）
            SizedBox(
              height: 40,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                onPressed: selectedCount > 0 ? onViewSelected : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  foregroundColor: selectedCount > 0 ? theme.textTheme.bodyMedium?.color : theme.hintColor,
                ),
                label: Text('已选 $selectedCount 项', style: const TextStyle(fontSize: 14)),
              ),
            ),
            // 右侧：按钮组
            Row(
              children: [
                SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      foregroundColor: theme.textTheme.bodyMedium?.color,
                    ),
                    label: Text(cancelLabel, style: const TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 18),
                    onPressed: canConfirm ? onConfirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canConfirm ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: canConfirm ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    label: Text(confirmLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
