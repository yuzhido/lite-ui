import 'package:flutter/material.dart';

import 'model.dart';

/// 弹窗标题区域：可选图标 + 标题 + 可选内容文本，居中布局
class DialogTitleSection extends StatelessWidget {
  /// 主标题
  final String? title;

  /// 内容文本
  final String? content;

  /// 自定义图标 Widget（优先级高于 [presetIcon]）
  final Widget? icon;

  /// 预设图标类型（当 [icon] 未指定时生效）
  final DialogPresetIcon? presetIcon;

  const DialogTitleSection({this.title, this.content, this.icon, this.presetIcon, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconWidget = icon ?? _buildPresetIcon(theme);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 图标区域
          if (iconWidget != null) ...[iconWidget, const SizedBox(height: 12)],
          // 标题
          if (title != null)
            Text(
              title!,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
              textAlign: TextAlign.center,
            ),
          if (title != null && content != null) const SizedBox(height: 8),
          // 内容
          if (content != null)
            Text(
              content!,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65), height: 1.5),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  /// 根据预设类型构建图标
  Widget? _buildPresetIcon(ThemeData theme) {
    if (presetIcon == null) return null;

    final IconData iconData;
    final Color color;

    switch (presetIcon!) {
      case DialogPresetIcon.success:
        iconData = Icons.check_circle_rounded;
        color = Colors.green;
      case DialogPresetIcon.warning:
        iconData = Icons.warning_amber_rounded;
        color = Colors.orange;
      case DialogPresetIcon.error:
        iconData = Icons.cancel_rounded;
        color = theme.colorScheme.error;
      case DialogPresetIcon.info:
        iconData = Icons.info_outline_rounded;
        color = theme.colorScheme.primary;
    }

    return Icon(iconData, color: color, size: 48);
  }
}

/// 弹窗底部按钮栏：iOS 风格分割线布局
///
/// - 横向模式（alert/confirm/input）：按钮等宽排列，中间竖线分隔，顶部横线分隔
/// - 纵向模式（multiAction）：按钮纵向堆叠，每个按钮间横线分隔
class DialogButtonBar extends StatelessWidget {
  /// 按钮列表
  final List<DialogActionButton> buttons;

  /// 按钮点击回调
  final VoidCallback? Function(dynamic value)? onPressed;

  /// 是否为纵向排列（multiAction 模式）
  final bool isVertical;

  const DialogButtonBar({required this.buttons, this.onPressed, this.isVertical = false, super.key});

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return _buildVerticalLayout(context);
    }
    return _buildHorizontalLayout(context);
  }

  /// iOS 风格横向按钮布局：等宽 + 竖线分隔
  Widget _buildHorizontalLayout(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor.withValues(alpha: 0.25);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 顶部分割线
        Divider(height: 0.5, thickness: 0.5, color: dividerColor),
        // 按钮行
        IntrinsicHeight(
          child: Row(
            children: buttons.asMap().entries.map((entry) {
              final index = entry.key;
              final button = entry.value;
              return Expanded(
                child: Row(
                  children: [
                    // 按钮间的竖线分隔
                    if (index > 0) Container(width: 0.5, color: dividerColor),
                    // 等宽按钮
                    Expanded(child: _buildIOSButton(context, theme, button)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// iOS 风格纵向按钮布局：横线分隔
  Widget _buildVerticalLayout(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor.withValues(alpha: 0.25);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 顶部分割线
        Divider(height: 0.5, thickness: 0.5, color: dividerColor),
        // 按钮列表
        ...buttons.asMap().entries.map((entry) {
          final index = entry.key;
          final button = entry.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 按钮间的横线分隔
              if (index > 0) Divider(height: 0.5, thickness: 0.5, color: dividerColor),
              _buildIOSButton(context, theme, button, expanded: true),
            ],
          );
        }),
      ],
    );
  }

  /// 构建 iOS 风格单个按钮
  Widget _buildIOSButton(BuildContext context, ThemeData theme, DialogActionButton button, {bool expanded = false}) {
    final color = _getButtonColor(theme, button.style);
    final isPrimary = button.style == DialogButtonStyle.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: button.disabled
            ? null
            : () {
                onPressed?.call(button.value)?.call();
              },
        highlightColor: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        splashColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        child: Container(
          width: expanded ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          alignment: Alignment.center,
          child: Text(
            button.label,
            style: TextStyle(fontSize: 16, fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400, color: button.disabled ? theme.disabledColor : color, letterSpacing: -0.2),
          ),
        ),
      ),
    );
  }

  /// 根据按钮样式获取颜色
  Color? _getButtonColor(ThemeData theme, DialogButtonStyle style) {
    switch (style) {
      case DialogButtonStyle.normal:
        return theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.85);
      case DialogButtonStyle.primary:
        return theme.colorScheme.primary;
      case DialogButtonStyle.destructive:
        return theme.colorScheme.error;
    }
  }
}

/// 弹窗输入框组件
class DialogInputField extends StatelessWidget {
  /// 输入控制器
  final TextEditingController controller;

  /// 输入变化回调
  final ValueChanged<String>? onChanged;

  /// 提示文本
  final String? hintText;

  /// 最大长度
  final int? maxLength;

  /// 是否显示清除按钮
  final bool showClearButton;

  const DialogInputField({required this.controller, this.onChanged, this.hintText, this.maxLength, this.showClearButton = true, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLength: maxLength,
        autofocus: true,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4)),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerLowest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
          suffixIcon: showClearButton
              ? ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    return value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              controller.clear();
                              onChanged?.call('');
                            },
                          )
                        : const SizedBox.shrink();
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
