import 'package:flutter/material.dart';

/// EmptyData 风格组件的共享参数
///
/// 将 EmptyData 的多个属性聚合为一个对象，
/// 避免每个风格组件都需要传递 10+ 个参数。
class EmptyDataStyleParams {
  final String title;
  final String description;
  final Widget? icon;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final double? iconSize;
  final Color? iconBackgroundColor;
  final String? actionLabel;
  final Widget? actionWidget;
  final VoidCallback? onAction;

  const EmptyDataStyleParams({
    required this.title,
    required this.description,
    this.icon,
    required this.padding,
    this.titleStyle,
    this.descriptionStyle,
    this.iconSize,
    this.iconBackgroundColor,
    this.actionLabel,
    this.actionWidget,
    this.onAction,
  });
}
