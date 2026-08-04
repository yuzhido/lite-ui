import 'package:flutter/material.dart';
import '../../widgets/keyword_highlight.dart';

import '../models/index.dart';
import '../utils/index.dart';
import 'tree_item.dart';

/// 纯展示型树形列表组件
///
/// 负责树节点的递归渲染、展开/折叠交互、懒加载子节点及空状态显示。
/// 不包含搜索框、选中逻辑等业务功能，可独立嵌入任意布局使用。
///
/// 使用示例：
/// ```dart
/// TreeList<String, dynamic>(
///   nodes: myTreeNodes,
///   selectedIds: {'node_1', 'node_2'},
///   multiple: true,
///   onNodeTap: (node) => print('点击: ${node.label}'),
/// )
/// ```
class TreeList<V extends Object, D> extends StatefulWidget {
  /// 树形数据源（根节点列表）
  final List<TreeNode<V, D>> nodes;

  /// 当前选中的节点 ID 集合
  final Set<V> selectedIds;

  /// 是否多选模式（影响三态选择器与 badge 显示）
  final bool multiple;

  /// 空状态提示文字
  final String emptyText;

  /// 懒加载子节点回调
  /// 当节点 isLeaf=false 且 children 为空时，展开会触发此回调
  final TreeNodeLoadChild<V, D>? onLoadChildren;

  /// 懒加载完成后的通知回调
  /// 用于让父组件同步原始数据（如更新非克隆树）
  final void Function(V nodeId, List<TreeNode<V, D>> children)? onChildrenLoaded;

  /// 节点点击回调
  final TreeNodeSelect<V, D>? onNodeTap;

  /// 当前搜索关键字，用于高亮匹配文本
  final String keyword;

  /// 关键字高亮样式配置
  final KeywordHighlightStyle? highlightStyle;

  /// 是否允许选中父节点
  final bool parentSelectable;

  /// 父节点圆圈点击回调（仅多选 + parentSelectable 时有效）
  final void Function(TreeNode<V, D> node)? onParentIndicatorTap;

  const TreeList({
    super.key,
    required this.nodes,
    this.selectedIds = const {},
    this.multiple = false,
    this.emptyText = '暂无数据',
    this.onLoadChildren,
    this.onNodeTap,
    this.onChildrenLoaded,
    this.keyword = '',
    this.highlightStyle,
    this.parentSelectable = false,
    this.onParentIndicatorTap,
  });

  @override
  State<TreeList<V, D>> createState() => _TreeListState<V, D>();
}

class _TreeListState<V extends Object, D> extends State<TreeList<V, D>> {
  late List<TreeNode<V, D>> _nodes;

  @override
  void initState() {
    super.initState();
    _nodes = widget.nodes;
  }

  @override
  void didUpdateWidget(covariant TreeList<V, D> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.nodes, oldWidget.nodes)) {
      _nodes = widget.nodes;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_nodes.isEmpty) {
      return Center(
        child: Text(widget.emptyText, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _nodes.length,
      itemBuilder: (context, index) {
        return TreeItem<V, D>(
          node: _nodes[index],
          selectedIds: widget.selectedIds,
          multiple: widget.multiple,
          parentSelectable: widget.parentSelectable,
          canLazyLoad: widget.onLoadChildren != null,
          keyword: widget.keyword,
          highlightStyle: widget.highlightStyle,
          onToggleExpand: _toggleNodeExpansion,
          onNodeTap: widget.onNodeTap,
          onParentIndicatorTap: widget.onParentIndicatorTap,
        );
      },
    );
  }

  // ── 展开/折叠（含懒加载） ──

  void _toggleNodeExpansion(V nodeId) async {
    final node = TreeUtils.findNode(_nodes, nodeId);
    if (node == null) return;

    // 懒加载
    if (!node.isLeaf && node.children.isEmpty && widget.onLoadChildren != null) {
      setState(() {
        node.isLoading = true;
        node.isExpanded = true;
      });
      try {
        final children = await widget.onLoadChildren!(node);
        TreeUtils.setNodeChildren(_nodes, nodeId, children);
        widget.onChildrenLoaded?.call(nodeId, children);
      } catch (_) {
      } finally {
        setState(() {
          node.isLoading = false;
        });
      }
      return;
    }

    setState(() {
      TreeUtils.toggleNodeInTree(_nodes, nodeId);
    });
  }
}
