import 'package:flutter/material.dart';

/// 底部操作栏组件
///
/// 包含取消和确认按钮，常用于多选模式。
class BottomActionBar extends StatelessWidget {
  /// 已选中数量
  final int selectedCount;

  /// 多选最大可选数量，不传则无限制
  final int? maxCount;

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
    this.maxCount,
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
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 10,
          children: [
            // 左侧：已选数量提示（点击可查看已选项）
            SizedBox(
              height: 40,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                onPressed: selectedCount > 0 ? onViewSelected : null,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  foregroundColor: selectedCount > 0 ? theme.textTheme.bodyMedium?.color : theme.hintColor,
                ),
                label: Text(maxCount != null ? '已选 $selectedCount/$maxCount 项' : '已选 $selectedCount 项', style: const TextStyle(fontSize: 14)),
              ),
            ),
            // 右侧：按钮组
            Expanded(
              child: Row(
                spacing: 10,
                children: [
                  SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        foregroundColor: theme.textTheme.bodyMedium?.color,
                      ),
                      label: Text(cancelLabel, style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        onPressed: canConfirm ? onConfirm : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          backgroundColor: canConfirm ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                          foregroundColor: canConfirm ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        label: Text(confirmLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
