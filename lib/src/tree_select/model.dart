/// 树形选择数据项
///
/// 泛型参数说明：
/// - [V] value 的类型，用于后端提交等场景。作为选中状态追踪的标识，
///   若 V 是自定义对象，必须 override `==` 和 `hashCode`。
/// - [D] data 的类型，用于携带后端返回的完整原始数据对象，可选。
class TreeSelectItem<V, D> {
  /// 显示文本
  final String label;

  /// 实际值，用于后端提交
  final V value;

  /// 可选的原始数据，选中时一并返回
  final D? data;

  /// 副标题/描述
  final String? subtitle;

  /// 子节点列表，为 null 或空表示叶子节点
  final List<TreeSelectItem<V, D>>? children;

  /// 是否为叶子节点
  ///
  /// 默认根据 [children] 是否为 null / 空自动判断。
  /// 懒加载场景下，节点暂无 children 但并非叶子时，需显式设为 false。
  final bool? isLeaf;

  /// 是否禁用（不可选），默认 false
  final bool disabled;

  const TreeSelectItem({
    required this.label,
    required this.value,
    this.data,
    this.subtitle,
    this.children,
    this.isLeaf,
    this.disabled = false,
  });

  /// 是否叶子节点（自动判断 + 手动覆盖）
  bool get effectiveIsLeaf {
    if (isLeaf != null) return isLeaf!;
    return children == null || children!.isEmpty;
  }
}

/// 树形搜索结果
///
/// 远程搜索返回的扁平结果，包含匹配项及其面包屑路径。
class TreeSearchResult<V, D> {
  /// 匹配到的树节点
  final TreeSelectItem<V, D> item;

  /// 面包屑路径（从根到该节点的 label 列表，不含自身）
  final List<String> path;

  const TreeSearchResult({
    required this.item,
    this.path = const [],
  });
}

// ─── 回调类型定义 ───

/// 单选回调：返回选中的 value 和 data
typedef TreeOnSelectChange<V, D> = void Function(V value, D? data);

/// 多选确认回调：返回所有选中项的 values 和 datas
typedef TreeOnMultiSelectConfirm<V, D> = void Function(
    List<V> values, List<D?> datas);

/// 懒加载回调：根据父节点异步加载子节点列表
typedef TreeLazyLoadCallback<V, D> = Future<List<TreeSelectItem<V, D>>> Function(
    TreeSelectItem<V, D> parent);

/// 远程搜索回调：根据关键字异步返回带路径的搜索结果
typedef TreeSearchCallback<V, D> = Future<List<TreeSearchResult<V, D>>> Function(
    String keyword);

// ─── 枚举 ───

/// 树形选择器布局模式
enum TreeLayout {
  /// 竖向缩进布局：递归缩进展示树形结构
  vertical,

  /// 横向级联布局：多列并排，逐级选择
  cascade,
}
