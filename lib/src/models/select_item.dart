import 'package:flutter/material.dart';

/// 备选数据项
///
/// 泛型参数说明：
/// - [V] value 的类型，用于后端提交等场景。作为选中状态追踪的标识，
///   若 V 是自定义对象，必须 override `==` 和 `hashCode`。
/// - [D] data 的类型，用于携带后端返回的完整原始数据对象，可选。
class SelectItem<V, D> {
  /// 显示文本
  final String label;

  /// 实际值，用于后端提交
  final V value;

  /// 可选的原始数据，选中时一并返回
  final D? data;

  /// 副标题/描述
  final String? subtitle;

  /// 是否禁用（不可选），默认 false
  final bool disabled;

  /// 禁用状态标签（如"不可用"），仅在 [disabled] 为 true 且 [showDisabledBadge] 为 true 时显示
  final String? disabledLabel;

  /// 图标 Widget（优先级最高，与 [iconData] 互斥）
  final Widget? icon;

  /// 图标数据（与 [icon] 互斥）
  final IconData? iconData;

  /// 图标颜色（仅 [iconData] 有效）
  final Color? iconColor;

  /// 图标大小，默认 24
  final double iconSize;

  const SelectItem({
    required this.label,
    required this.value,
    this.subtitle,
    this.data,
    this.disabled = false,
    this.disabledLabel,
    this.icon,
    this.iconData,
    this.iconColor,
    this.iconSize = 24,
  });

  /// 构造带图标的项
  factory SelectItem.withIcon({
    required String label,
    required V value,
    required IconData iconData,
    Color? iconColor,
    String? subtitle,
    D? data,
    bool disabled = false,
    String? disabledLabel,
    double iconSize = 24,
  }) {
    return SelectItem(
      label: label,
      value: value,
      subtitle: subtitle,
      data: data,
      disabled: disabled,
      disabledLabel: disabledLabel,
      iconData: iconData,
      iconColor: iconColor,
      iconSize: iconSize,
    );
  }
}

/// ActionSheet 分组数据
///
/// 用于将操作项分组显示，每组可选带标题。
class SheetSection<V, D> {
  /// 分组标题
  final String? title;

  /// 该组的操作项列表
  final List<SelectItem<V, D>> items;

  const SheetSection({this.title, required this.items});
}
