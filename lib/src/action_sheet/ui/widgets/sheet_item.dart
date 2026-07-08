import 'package:flutter/material.dart';

/// 普通操作项列表项（支持图标和禁用状态）
class ActionSheetItem extends StatelessWidget {
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

  /// 是否禁用
  final bool isDisabled;

  /// 禁用状态标签
  final String? disabledLabel;

  /// 是否显示禁用标签
  final bool showDisabledBadge;

  /// 点击回调
  final VoidCallback? onTap;

  const ActionSheetItem({
    required this.label,
    this.subtitle,
    this.icon,
    this.iconData,
    this.iconColor,
    this.iconSize = 24,
    this.isDisabled = false,
    this.disabledLabel,
    this.showDisabledBadge = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnTap = isDisabled ? null : onTap;

    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveOnTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1), width: 0.5)),
            ),
            child: Row(
              children: [
                // 图标区域
                if (_hasIcon) ...[_buildIcon(theme), const SizedBox(width: 12)],

                // 文字区域
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(fontSize: 17, color: _textColor(theme), fontWeight: FontWeight.normal),
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

                // 禁用标签
                if (isDisabled && showDisabledBadge && disabledLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(10)),
                    child: Text(disabledLabel!, style: const TextStyle(fontSize: 11, color: Colors.white)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasIcon => icon != null || iconData != null;

  Widget _buildIcon(ThemeData theme) {
    if (icon != null) {
      return icon!;
    }

    return Icon(iconData, size: iconSize, color: iconColor ?? _defaultIconColor(theme));
  }

  Color _textColor(ThemeData theme) {
    if (isDisabled) {
      return const Color(0xFF8E8E93); // 灰色
    }
    return theme.colorScheme.primary; // 主题色
  }

  Color _defaultIconColor(ThemeData theme) {
    if (isDisabled) {
      return const Color(0xFF8E8E93);
    }
    return theme.colorScheme.primary;
  }
}
