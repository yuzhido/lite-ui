import 'dart:async';
import 'package:flutter/material.dart';

/// 按钮类型枚举，对应 Flutter 当前版本的全部标准按钮
enum ActionButtonType {
  /// 凸起填充按钮，带背景色 + 阴影 → ElevatedButton
  elevated,

  /// 描边按钮，无背景色 + 边框 → OutlinedButton
  outlined,

  /// 文字按钮，无背景无边框 → TextButton
  text,

  /// 填充按钮，Material 3 风格（无阴影）→ FilledButton
  filled,

  /// 色调填充按钮，比 [filled] 更柔和 → FilledButton.tonal
  toned,

  /// 图标按钮，仅显示图标 → IconButton
  icon,
}

/// 操作按钮组件
///
/// 基于 Flutter 原生按钮二次封装，保留水波纹、无障碍、主题等能力。
///
/// 通过 [type] 切换按钮类型：
/// - [ActionButtonType.elevated]（默认）→ ElevatedButton
/// - [ActionButtonType.outlined] → OutlinedButton
/// - [ActionButtonType.text] → TextButton
/// - [ActionButtonType.filled] → FilledButton
/// - [ActionButtonType.toned] → FilledButton.tonal
/// - [ActionButtonType.icon] → IconButton
///
/// 核心特性：
/// - 通过 [onPressed] 回调的返回类型自动识别同步/异步：
///   - 同步函数（返回 void）：点击即执行，无 loading 态
///   - 异步函数（返回 Future）：自动显示加载动画，执行期间禁止重复点击
/// - 支持 [icon] 前缀图标（icon 类型时作为唯一内容）
/// - 支持通过 [style] 完全自定义按钮样式
class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    this.type = ActionButtonType.elevated,
    this.text,
    this.icon,
    this.iconSize,
    this.onPressed,
    this.disabled = false,
    this.loadingIndicator,
    this.loadingText,
    this.style,
    this.height = 45,
  });
  // 按钮默认高度 45
  final double height;

  /// 按钮类型，默认 [ActionButtonType.elevated]
  final ActionButtonType type;

  /// 按钮文字（[ActionButtonType.icon] 时忽略）
  final String? text;

  /// 图标
  /// - 非 icon 类型：显示在文字左侧
  /// - [ActionButtonType.icon] 类型：作为按钮唯一内容
  final Widget? icon;

  /// 图标尺寸（仅 [ActionButtonType.icon] 时生效，透传给 IconButton.iconSize）
  final double? iconSize;

  /// 点击回调
  ///
  /// - 传入同步函数 `() { ... }` → 无 loading，直接执行
  /// - 传入异步函数 `() async { await ... }` → 自动显示 loading，执行期间不可重复点击
  final FutureOr<void> Function()? onPressed;

  /// 是否禁用，默认 false
  final bool disabled;

  /// 自定义加载指示器（覆盖默认的 CircularProgressIndicator）
  final Widget? loadingIndicator;

  /// 加载中显示的文字（为 null 时保持原文字 [text]，icon 类型时忽略）
  final String? loadingText;

  /// 按钮样式（透传给底层按钮，覆盖默认样式）
  final ButtonStyle? style;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    if (_isLoading || widget.disabled || widget.onPressed == null) return;

    final result = widget.onPressed!();

    if (result is Future) {
      setState(() => _isLoading = true);
      try {
        await result;
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled || _isLoading;
    final onPressed = isDisabled ? null : _handleTap;
    final hasIcon = widget.icon != null && !_isLoading;
    final style =
        widget.style ??
        ButtonStyle(
          textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(height: 1.3, fontSize: 16, fontWeight: FontWeight.w600)),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 15, vertical: 5)),
        );

    final child = _ButtonChild(
      isLoading: _isLoading,
      icon: widget.icon,
      text: widget.text,
      loadingText: widget.loadingText,
      loadingIndicator: widget.loadingIndicator,
      foregroundColor: widget.style?.foregroundColor?.resolve({}) ?? Colors.white,
    );

    return SizedBox(
      height: widget.height,
      child: switch (widget.type) {
        ActionButtonType.elevated =>
          hasIcon
              ? ElevatedButton.icon(onPressed: onPressed, icon: widget.icon!, label: Text(widget.text ?? ''), style: style)
              : ElevatedButton(onPressed: onPressed, style: style, child: child),
        ActionButtonType.outlined =>
          hasIcon
              ? OutlinedButton.icon(onPressed: onPressed, icon: widget.icon!, label: Text(widget.text ?? ''), style: style)
              : OutlinedButton(onPressed: onPressed, style: style, child: child),
        ActionButtonType.text =>
          hasIcon
              ? TextButton.icon(onPressed: onPressed, icon: widget.icon!, label: Text(widget.text ?? ''), style: style)
              : TextButton(onPressed: onPressed, style: style, child: child),
        ActionButtonType.filled =>
          hasIcon
              ? FilledButton.icon(onPressed: onPressed, icon: widget.icon!, label: Text(widget.text ?? ''), style: style)
              : FilledButton(onPressed: onPressed, style: style, child: child),
        ActionButtonType.toned =>
          hasIcon
              ? FilledButton.tonalIcon(onPressed: onPressed, icon: widget.icon!, label: Text(widget.text ?? ''), style: style)
              : FilledButton.tonal(onPressed: onPressed, style: style, child: child),
        ActionButtonType.icon => IconButton(
          onPressed: onPressed,
          icon: _isLoading
              ? SizedBox(
                  width: widget.iconSize ?? 24,
                  height: widget.iconSize ?? 24,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(widget.style?.foregroundColor?.resolve({}) ?? Colors.white)),
                )
              : widget.icon!,
          iconSize: widget.iconSize ?? 24,
          style: style,
        ),
      },
    );
  }
}

/// 按钮内容组件
///
/// 根据加载状态、图标、文字组合按钮内部显示内容。
class _ButtonChild extends StatelessWidget {
  final bool isLoading;
  final Widget? icon;
  final String? text;
  final String? loadingText;
  final Widget? loadingIndicator;
  final Color foregroundColor;

  const _ButtonChild({required this.isLoading, required this.icon, required this.text, required this.loadingText, required this.loadingIndicator, required this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingIndicator ?? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(foregroundColor))),
          if ((loadingText ?? text) != null) ...[const SizedBox(width: 8), Text(loadingText ?? text ?? '')],
        ],
      );
    }
    if (icon != null && text != null) {
      return Row(mainAxisSize: MainAxisSize.min, children: [icon!, const SizedBox(width: 8), Text(text!)]);
    }
    if (icon != null) return icon!;
    return Text(text ?? '');
  }
}
