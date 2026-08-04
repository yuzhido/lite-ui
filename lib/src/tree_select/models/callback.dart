// ── 类型定义 ──

import 'tree_node.dart';

/// 节点点击回调
///
/// [isSelected] 表示当前操作是选中还是取消选中：
/// - 单选模式：始终为 true（点击即选中）
/// - 多选模式：true = 选中，false = 取消选中
typedef TreeNodeSelect<V extends Object, D> = void Function(V value, TreeNode<V, D> node, bool isSelected);

/// 多选选中状态变化回调
typedef TreeNodeConfirm<V extends Object, D> = void Function(List<V> value, List<TreeNode<V, D>> selectedNodes, List<D?> data);

/// 懒加载节点回调
///
/// [parent] 为 null 时表示加载根节点（treeData 未提供或为空时自动触发），
/// 否则表示加载该父节点的子节点。
typedef TreeNodeLoadChild<V extends Object, D> = Future<List<TreeNode<V, D>>> Function(TreeNode<V, D>? parent);
