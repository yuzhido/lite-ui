// ── 类型定义 ──

import 'tree_node.dart';

/// 单选节点点击回调
typedef TreeNodeSelect<V extends Object, D> = void Function(TreeNode<V, D> node);

/// 多选选中状态变化回调
typedef TreeNodeConfirm<V extends Object, D> = void Function(List<TreeNode<V, D>> selectedNodes);

/// 懒加载子节点回调
typedef TreeNodeLoadChild<V extends Object, D> = Future<List<TreeNode<V, D>>> Function(TreeNode<V, D> parent);
