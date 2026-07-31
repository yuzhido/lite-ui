import 'select_item.dart';

/// 单选回调：返回选中的 value, item 和 data
typedef OnSelectChange<V, D> = void Function(V value, SelectItem<V, D> item, D? data);

/// 多选确认回调：返回所有选中项的 values、datas 和完整 items
///
/// [items] 包含完整的 label/value/data，用于父组件直接缓存以显示 label。
typedef OnMultiSelectConfirm<V, D> = void Function(List<V> values, List<SelectItem<V, D>> items, List<D?> datas);

/// 远程搜索回调：根据关键字异步返回数据列表
typedef RemoteSearchCallback<V, D> = Future<List<SelectItem<V, D>>> Function(String keyword);
