/// 备选数据项
///
/// 泛型参数说明：
/// - [T] value 的类型，用于后端提交等场景。作为选中状态追踪的标识，
///   若 T 是自定义对象，必须 override `==` 和 `hashCode`。
/// - [V] data 的类型，用于携带后端返回的完整原始数据对象，可选。
class SelectItem<T, V> {
  /// 显示文本
  final String label;

  /// 实际值，用于后端提交
  final T value;

  /// 可选的原始数据，选中时一并返回
  final V? data;

  /// 副标题/描述
  final String? subtitle;

  /// 是否禁用（不可选），默认 false
  final bool disabled;

  const SelectItem({
    required this.label,
    required this.value,
    this.subtitle,
    this.data,
    this.disabled = false,
  });
}

/// 单选回调：返回选中的 value 和 data
typedef OnSelectChange<T, V> = void Function(T value, V? data);

/// 多选确认回调：返回所有选中项的 values 和 datas
typedef OnMultiSelectConfirm<T, V> = void Function(List<T> values, List<V?> datas);

/// 远程搜索回调：根据关键字异步返回数据列表
typedef RemoteSearchCallback<T, V> = Future<List<SelectItem<T, V>>> Function(String keyword);

/// 动态数据生成回调：根据当前过滤关键字返回额外数据（与静态 items 合并显示）
typedef DynamicItemsCallback<T, V> = Future<List<SelectItem<T, V>>> Function(String keyword);

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
