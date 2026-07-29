import 'select_item.dart';

/// 单选回调：返回选中的 value 和 data
typedef OnSelectChange<V, D> = void Function(V value, D? data);

/// 多选确认回调：返回所有选中项的 values 和 datas
typedef OnMultiSelectConfirm<V, D> = void Function(List<V> values, List<D?> datas);

/// 远程搜索回调：根据关键字异步返回数据列表
typedef RemoteSearchCallback<V, D> = Future<List<SelectItem<V, D>>> Function(String keyword);
