import 'package:flutter/material.dart';

import 'models/index.dart';
import 'ui/card_style.dart';
import 'ui/default_style.dart';
import 'ui/compact_style.dart';
import 'ui/minimal_style.dart';

/// 空状态数据展示组件
///
/// 当列表、页面或模块没有数据时显示的占位组件。
/// 支持 8 种场景类型 × 4 种布局风格，可自由组合。
///
/// 最简用法：
/// ```dart
/// EmptyData()
/// ```
///
/// 指定风格和场景：
/// ```dart
/// EmptyData(
///   style: EmptyDataStyle.compact,
///   type: EmptyDataType.noPermission,
/// )
/// ```
class EmptyData extends StatefulWidget {
  /// 预设场景类型，默认为 [EmptyDataType.empty]
  final EmptyDataType type;

  /// 布局风格，默认为 [EmptyDataStyle.defaultStyle]
  final EmptyDataStyle style;

  /// 主标题，不传则根据 [type] 使用默认文案
  final String? title;

  /// 描述文字，不传则根据 [type] 使用默认文案
  final String? description;

  /// 自定义图标 Widget，不传则使用 [type] 对应的内置图标
  final Widget? icon;

  /// 图标背景圆形颜色，不传则使用 [type] 对应的默认颜色
  final Color? iconBackgroundColor;

  /// 图标尺寸（宽高），默认 88（defaultStyle），其他风格有各自默认值
  final double? iconSize;

  /// 操作按钮文字，传 null 不显示按钮
  final String? actionLabel;

  /// 操作按钮点击回调
  final VoidCallback? onAction;

  /// 自定义操作区域 Widget（优先级高于 [actionLabel]）
  final Widget? actionWidget;

  /// 自定义标题样式
  final TextStyle? titleStyle;

  /// 自定义描述样式
  final TextStyle? descriptionStyle;

  /// 组件内边距
  final EdgeInsetsGeometry padding;

  /// 是否启用入场动画，默认 true
  final bool animate;

  /// 动画时长，默认 400ms
  final Duration animationDuration;

  const EmptyData({
    super.key,
    this.type = EmptyDataType.empty,
    this.style = EmptyDataStyle.defaultStyle,
    this.title,
    this.description,
    this.icon,
    this.iconBackgroundColor,
    this.iconSize,
    this.actionLabel,
    this.onAction,
    this.actionWidget,
    this.titleStyle,
    this.descriptionStyle,
    this.padding = const EdgeInsets.all(32),
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  /// 获取指定类型的内置图标
  static IconData iconOf(EmptyDataType type) => emptyDataDefaults[type]!.icon;

  /// 获取指定类型的内置背景色
  static Color bgColorOf(EmptyDataType type) => emptyDataDefaults[type]!.bgColor;

  /// 获取指定类型的内置图标色
  static Color iconColorOf(EmptyDataType type) => emptyDataDefaults[type]!.iconColor;

  @override
  State<EmptyData> createState() => _EmptyDataState();
}

class _EmptyDataState extends State<EmptyData> with SingleTickerProviderStateMixin {
  late final AnimationController? _animController;
  late final Animation<double>? _fadeAnimation;
  late final Animation<Offset>? _slideAnimation;

  EmptyConfig get _config => emptyDataDefaults[widget.type]!;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      final controller = AnimationController(vsync: this, duration: widget.animationDuration);
      _animController = controller;
      _fadeAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
      _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
      controller.forward();
    } else {
      _animController = null;
      _fadeAnimation = null;
      _slideAnimation = null;
    }
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late Widget content;
    final params = EmptyDataStyleParams(
      title: widget.title ?? _config.title,
      description: widget.description ?? _config.description,
      icon: widget.icon,
      padding: widget.padding,
      titleStyle: widget.titleStyle,
      descriptionStyle: widget.descriptionStyle,
      iconSize: widget.iconSize,
      iconBackgroundColor: widget.iconBackgroundColor,
      actionLabel: widget.actionLabel,
      actionWidget: widget.actionWidget,
      onAction: widget.onAction,
    );
    if (widget.style == EmptyDataStyle.defaultStyle) {
      content = EmptyDataDefaultStyle(params: params, config: _config);
    } else if (widget.style == EmptyDataStyle.compact) {
      content = EmptyDataCompactStyle(params: params, config: _config);
    } else if (widget.style == EmptyDataStyle.card) {
      content = EmptyDataCardStyle(params: params, config: _config);
    } else if (widget.style == EmptyDataStyle.minimal) {
      content = EmptyDataMinimalStyle(params: params, config: _config);
    }

    if (_animController == null) return content;

    return FadeTransition(
      opacity: _fadeAnimation!,
      child: SlideTransition(position: _slideAnimation!, child: content),
    );
  }
}
