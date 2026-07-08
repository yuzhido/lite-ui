import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 数字输入类型枚举
enum InputNumberType {
  /// 仅允许输入整数
  integer,

  /// 允许输入小数（默认）
  decimal,
}

/// 数字输入组件 - 左侧减号、中间输入框、右侧加号
///
/// 支持配置最小值、最大值、步长，通过 [type] 控制整数或小数输入
///
/// - [InputNumberType.decimal]（默认）：允许输入小数，可通过 [decimalPlaces] 控制小数位数
/// - [InputNumberType.integer]：仅允许输入整数
class InputNumber extends StatefulWidget {
  /// 当前值
  final num value;

  /// 值变化回调
  final ValueChanged<num>? onChanged;

  /// 最小值，默认为 0
  final num minValue;

  /// 最大值，默认为 9999
  final num maxValue;

  /// 每次加减的步长，默认为 1
  final num step;

  /// 输入类型，默认为 [InputNumberType.decimal]（小数）
  final InputNumberType type;

  /// 小数位数，仅在 [type] 为 [InputNumberType.decimal] 时有效，默认为 2
  final int decimalPlaces;

  /// 输入框宽度，默认 80
  final double inputWidth;

  /// 按钮大小，默认 36
  final double buttonSize;

  /// 是否禁用
  final bool disabled;

  const InputNumber({
    super.key,
    required this.value,
    this.onChanged,
    this.minValue = 0,
    this.maxValue = 9999,
    this.step = 1,
    this.type = InputNumberType.decimal,
    this.decimalPlaces = 2,
    this.inputWidth = 50,
    this.buttonSize = 36,
    this.disabled = false,
  });

  @override
  State<InputNumber> createState() => _InputNumberState();
}

class _InputNumberState extends State<InputNumber> {
  late TextEditingController _controller;

  /// 长按定时器
  Timer? _repeatTimer;
  bool _isPressingMinus = false;
  bool _isPressingPlus = false;

  /// 圆角半径，外框与按钮统一
  double get _borderRadius => 4.0;

  /// 格式化数值显示
  String _formatValue(num value) {
    if (widget.type == InputNumberType.decimal) {
      return value.toStringAsFixed(widget.decimalPlaces);
    }
    return value.toInt().toString();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant InputNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = _formatValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _repeatTimer?.cancel();
    super.dispose();
  }

  void _decrease() {
    if (widget.disabled) return;
    final newValue = widget.value - widget.step;
    if (newValue >= widget.minValue) {
      widget.onChanged?.call(newValue);
    }
  }

  void _increase() {
    if (widget.disabled) return;
    final newValue = widget.value + widget.step;
    if (newValue <= widget.maxValue) {
      widget.onChanged?.call(newValue);
    }
  }

  /// 处理按下事件：长按连续触发
  void _onPressStart(VoidCallback action, bool isMinus) {
    action();
    if (isMinus) {
      _isPressingMinus = true;
    } else {
      _isPressingPlus = true;
    }
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (isMinus ? _isPressingMinus : _isPressingPlus) {
        action();
      } else {
        _repeatTimer?.cancel();
      }
    });
  }

  void _onPressEnd(bool isMinus) {
    if (isMinus) {
      _isPressingMinus = false;
    } else {
      _isPressingPlus = false;
    }
    _repeatTimer?.cancel();
  }

  void _onSubmitted(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) {
      _controller.text = _formatValue(widget.value);
      return;
    }
    final clamped = parsed.clamp(widget.minValue.toDouble(), widget.maxValue.toDouble());
    _controller.text = _formatValue(clamped);
    widget.onChanged?.call(clamped);
  }

  bool get _canDecrease => !widget.disabled && widget.value > widget.minValue;
  bool get _canIncrease => !widget.disabled && widget.value < widget.maxValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surfaceContainer;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final outlineColor = theme.colorScheme.outline;
    final bool allowDecimal = widget.type == InputNumberType.decimal;

    return Opacity(
      opacity: widget.disabled ? 0.5 : 1.0,
      child: Container(
        height: widget.buttonSize,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(color: outlineColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 减号按钮
            _PressIconButton(
              icon: Icons.remove,
              size: widget.buttonSize,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(_borderRadius), bottomLeft: Radius.circular(_borderRadius)),
              enabled: _canDecrease,
              primaryColor: primaryColor,
              onSurfaceColor: onSurfaceColor,
              onTapDown: () => _onPressStart(_decrease, true),
              onTapUp: () => _onPressEnd(true),
            ),
            // 中间输入框
            SizedBox(
              width: widget.inputWidth,
              child: TextField(
                controller: _controller,
                enabled: !widget.disabled,
                textAlign: TextAlign.center,
                keyboardType: allowDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
                inputFormatters: [
                  allowDecimal ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,${widget.decimalPlaces}}')) : FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.maxValue.toString().length + (allowDecimal ? widget.decimalPlaces + 1 : 0)),
                ],
                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurfaceColor),
                onSubmitted: _onSubmitted,
              ),
            ),
            // 加号按钮
            _PressIconButton(
              icon: Icons.add,
              size: widget.buttonSize,
              borderRadius: BorderRadius.only(topRight: Radius.circular(_borderRadius), bottomRight: Radius.circular(_borderRadius)),
              enabled: _canIncrease,
              primaryColor: primaryColor,
              onSurfaceColor: onSurfaceColor,
              onTapDown: () => _onPressStart(_increase, false),
              onTapUp: () => _onPressEnd(false),
            ),
          ],
        ),
      ),
    );
  }
}

/// 带独立缩放动画的按钮，每个按钮各自管理自己的动画
class _PressIconButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final BorderRadius borderRadius;
  final bool enabled;
  final Color primaryColor;
  final Color onSurfaceColor;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;

  const _PressIconButton({
    required this.icon,
    required this.size,
    required this.borderRadius,
    required this.enabled,
    required this.primaryColor,
    required this.onSurfaceColor,
    required this.onTapDown,
    required this.onTapUp,
  });

  @override
  State<_PressIconButton> createState() => _PressIconButtonState();
}

class _PressIconButtonState extends State<_PressIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.82).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _animatePress() {
    _animController.forward().then((_) => _animController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled
          ? (_) {
              _animatePress();
              widget.onTapDown();
            }
          : null,
      onTapUp: widget.enabled ? (_) => widget.onTapUp() : null,
      onTapCancel: () => widget.onTapUp(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(color: widget.enabled ? widget.primaryColor.withValues(alpha: 0.08) : Colors.transparent, borderRadius: widget.borderRadius),
          child: Icon(widget.icon, size: 20, color: widget.enabled ? widget.primaryColor : widget.onSurfaceColor.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
