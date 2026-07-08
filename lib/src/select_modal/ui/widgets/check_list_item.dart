import 'package:flutter/material.dart';

/// SelectModal 带选中勾选标记的列表项
class SelectModalCheckListItem extends StatelessWidget {
  /// 显示文本
  final String label;

  /// 副标题
  final String? subtitle;

  /// 图标 Widget（优先级最高）
  final Widget? icon;

  /// 图标数据（与 icon 互斥）
  final IconData? iconData;

  /// 图标颜色（仅 iconData 有效）
  final Color? iconColor;

  /// 图标大小
  final double iconSize;

  /// 是否已选中
  final bool isChecked;

  /// 是否禁用
  final bool isDisabled;

  /// 是否为多选模式
  final bool multiple;

  /// 点击回调
  final VoidCallback? onTap;

  const SelectModalCheckListItem({
    required this.label,
    required this.isChecked,
    this.subtitle,
    this.icon,
    this.iconData,
    this.iconColor,
    this.iconSize = 24,
    this.isDisabled = false,
    this.multiple = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final effectiveOnTap = isDisabled ? null : onTap;
    final bool hasIcon = icon != null || iconData != null;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: BoxDecoration(color: isChecked ? primary.withValues(alpha: 0.08) : theme.canvasColor, borderRadius: BorderRadius.circular(8)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: effectiveOnTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // 图标或圆形头像
                  if (hasIcon)
                    _buildIcon(theme)
                  else
                    // 左侧圆形头像（首字母）
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: isChecked ? primary.withValues(alpha: 0.2) : Colors.grey.shade100, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          label.isNotEmpty ? label.characters.first : '',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isChecked ? Colors.white : Colors.grey.shade700),
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
                          label,
                          style: TextStyle(fontSize: 15, color: isChecked ? primary : Colors.black87, fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5), height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // 右侧勾选标记（单选时显示）
                  if (!multiple && isChecked) Icon(Icons.check_circle, color: primary, size: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    if (icon != null) {
      return icon!;
    }

    return Icon(iconData, size: iconSize, color: iconColor ?? theme.colorScheme.primary);
  }
}
