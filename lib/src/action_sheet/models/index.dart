import '../../models/select_item.dart';

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
