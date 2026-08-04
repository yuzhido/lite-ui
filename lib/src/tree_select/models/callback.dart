// ── 类型定义 ──

import 'tree_node.dart';

/// 单选节点点击回调
typedef TreeNodeSelect<V extends Object, D> = void Function(TreeNode<V, D> node);

/// 多选选中状态变化回调
typedef TreeNodeConfirm<V extends Object, D> = void Function(List<TreeNode<V, D>> selectedNodes);

/// 懒加载节点回调
///
/// [parent] 为 null 时表示加载根节点（treeData 未提供或为空时自动触发），
/// 否则表示加载该父节点的子节点。
typedef TreeNodeLoadChild<V extends Object, D> = Future<List<TreeNode<V, D>>> Function(TreeNode<V, D>? parent);
