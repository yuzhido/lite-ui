import 'package:flutter/material.dart';

/// 底部弹窗操作项
class ActionSheetItem {
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? textColor;

  /// 选项唯一标识。未指定时组件内部以 label 作为标识。
  final String? value;

  const ActionSheetItem({
    required this.label,
    this.subtitle,
    this.onTap,
    this.textColor,
    this.value,
  });
}

/// 获取选项的唯一标识，优先使用 value，否则使用 label
String itemValue(ActionSheetItem item) => item.value ?? item.label;

/// 远程搜索回调：根据关键字异步返回数据列表
typedef RemoteSearchCallback = Future<List<ActionSheetItem>> Function(String keyword);

/// 动态数据生成回调：根据当前过滤关键字返回额外数据
typedef DynamicItemsCallback = Future<List<ActionSheetItem>> Function(String keyword);

/// ActionSheet 内容类型
enum ActionSheetType {
  /// 本地固定数据模式：显示标题 + 描述 + 操作项列表
  local,

  /// 远程获取数据
  remote,

  /// 可过滤
  filterable,

  /// 自定义 Widget 模式：显示用户传入的任意 Widget
  custom,
}
