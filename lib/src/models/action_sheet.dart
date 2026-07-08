import 'select_item.dart';

/// ActionSheet 内容类型
enum ActionSheetType {
  /// 本地固定数据模式：显示标题 + 描述 + 操作项列表
  local,

  /// 自定义 Widget 模式：显示用户传入的任意 Widget
  custom,
}

/// ActionSheet 分组数据
///
/// 用于将操作项分组显示，每组可选带标题。
class ActionSheetSection<V, D> {
  /// 分组标题
  final String? title;

  /// 该组的操作项列表
  final List<SelectItem<V, D>> items;

  const ActionSheetSection({this.title, required this.items});
}
