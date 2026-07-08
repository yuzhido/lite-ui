import 'select_item.dart';

/// 单选回调：返回选中的 value 和 data
typedef OnSelectChange<V, D> = void Function(V value, D? data);

/// 多选确认回调：返回所有选中项的 values 和 datas
typedef OnMultiSelectConfirm<V, D> = void Function(List<V> values, List<D?> datas);

/// 远程搜索回调：根据关键字异步返回数据列表
typedef RemoteSearchCallback<V, D> = Future<List<SelectItem<V, D>>> Function(String keyword);

/// 动态数据生成回调：根据当前过滤关键字返回额外数据（与静态 items 合并显示）
typedef DynamicItemsCallback<V, D> = Future<List<SelectItem<V, D>>> Function(String keyword);
