import 'package:flutter/material.dart';
import '../../widgets/drag_indicator.dart';
import '../../widgets/input_search.dart';
import '../../widgets/top_title_info.dart';

import '../model.dart';
import '../tree_utils.dart';
import 'bottom_action.dart';
import 'tree_list.dart';

/// 树形选择器弹窗组件
///
/// 底部弹出的选择面板，内置搜索过滤与树形列表展示。
/// 支持单选（选中即关闭）和多选（底部确认按钮）。
///
/// 推荐使用 [TreeSelectHelper.show] / [TreeSelectHelper.showMultiple] 便捷方法。
class TreeSelect<T extends Object> extends StatefulWidget {
  /// 树形数据源
  final List<TreeNode<T>> treeData;

  /// 配置参数
  final TreeSelectConfig<T> config;

  const TreeSelect({super.key, required this.treeData, required this.config});

  @override
  State<TreeSelect<T>> createState() => _TreeSelectState<T>();
}

class _TreeSelectState<T extends Object> extends State<TreeSelect<T>> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late TextEditingController _searchController;

  Set<T> _selectedIds = {};
  List<TreeNode<T>> _filteredData = [];

  /// 当前选中的节点列表
  List<TreeNode<T>> get _selectedNodes => TreeUtils.getSelectedNodes(_filteredData, _selectedIds);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic);
    _animationController.forward();

    _searchController = TextEditingController();
    _selectedIds = Set.from(widget.config.selectedIds);
    _applyFilter('');

    // 展开所有选中节点的祖先路径
    TreeUtils.expandSelectedNodeAncestors(_filteredData, _selectedIds);
    setState(() {}); // 触发重建以应用展开状态
  }

  @override
  void didUpdateWidget(covariant TreeSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // treeData 变化时：重新克隆 + 应用当前搜索词
    if (!identical(widget.treeData, oldWidget.treeData)) {
      final keyword = _searchController.text;
      if (keyword.isEmpty) {
        _filteredData = TreeUtils.cloneTree(widget.treeData);
      } else {
        _filteredData = TreeUtils.filterTree(TreeUtils.cloneTree(widget.treeData), keyword.toLowerCase());
      }
    }

    // selectedIds 变化时：同步内部选中状态并重新计算展开状态
    if (widget.config.selectedIds != oldWidget.config.selectedIds) {
      _selectedIds = Set.from(widget.config.selectedIds);
      TreeUtils.expandSelectedNodeAncestors(_filteredData, _selectedIds);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── 搜索过滤 ──

  void _applyFilter(String keyword) {
    if (keyword.isEmpty) {
      _filteredData = TreeUtils.cloneTree(widget.treeData);
    } else {
      _filteredData = TreeUtils.filterTree(TreeUtils.cloneTree(widget.treeData), keyword.toLowerCase());
    }
    setState(() {});
  }

  // ── 选择逻辑 ──

  void _selectNode(TreeNode<T> node) {
    if (!widget.config.multiple) {
      _onNodeTap(node); // 单选：选中并关闭
      return;
    }
    // 多选：联动选中/取消所有后代
    setState(() {
      _toggleSelectWithChildren(node);
    });
  }

  void _toggleSelectWithChildren(TreeNode<T> node) {
    final isCurrentlySelected = TreeUtils.isNodeFullySelected(node, _selectedIds);
    if (isCurrentlySelected) {
      TreeUtils.removeNodeAndDescendants(node, _selectedIds);
      if (!widget.config.parentSelectable) {
        TreeUtils.autoDeselectParentChain(_filteredData, node, _selectedIds);
      }
    } else {
      TreeUtils.addNodeAndDescendants(node, _selectedIds);
      if (!widget.config.parentSelectable) {
        TreeUtils.autoSelectParentChain(_filteredData, node, _selectedIds);
      }
    }
  }

  /// 多选模式下，点击父节点圆圈的独立处理
  ///
  /// - parentSelectable=false（默认）：联动选中/取消所有子节点
  /// - parentSelectable=true：仅选中/取消父节点自身
  void _onParentIndicatorTap(TreeNode<T> node) {
    setState(() {
      if (widget.config.parentSelectable) {
        // 仅选中/取消父节点自身，不联动子节点，不展开
        if (_selectedIds.contains(node.id)) {
          _selectedIds.remove(node.id);
        } else {
          _selectedIds.add(node.id);
        }
      } else {
        // 默认模式：联动子节点
        _toggleSelectWithChildren(node);
      }
    });
  }

  /// 多选 + parentSelectable 模式下，点击父节点文本但子节点未加载时，先懒加载再全选
  void _onParentExpandForSelect(TreeNode<T> node) async {
    final clonedNode = TreeUtils.findNode(_filteredData, node.id);
    if (clonedNode == null || clonedNode.isChildrenLoaded) return;

    // 触发懒加载（展开 + loading）
    setState(() {
      clonedNode.isLoading = true;
      clonedNode.isExpanded = true;
    });
    try {
      final children = await widget.config.onLoadChildren!(clonedNode);
      setState(() {
        TreeUtils.setNodeChildren(_filteredData, node.id, children);
        clonedNode.isLoading = false;
        // 同步到原始数据
        TreeUtils.setNodeChildren(widget.treeData, node.id, children);
        // 加载完成后自动全选（不向上联动父节点）
        TreeUtils.addNodeAndDescendants(clonedNode, _selectedIds);
      });
    } catch (_) {
      setState(() {
        clonedNode.isLoading = false;
      });
    }
  }

  void _onNodeTap(TreeNode<T> node) {
    widget.config.onSelect?.call(node);
    Navigator.of(context).pop(node);
  }

  void _onConfirm() {
    final selectedNodes = _selectedNodes;
    widget.config.onConfirm?.call(selectedNodes);
    Navigator.of(context).pop(selectedNodes);
  }

  // ── 懒加载同步 ──

  void _onChildrenLoaded(T nodeId, List<TreeNode<T>> children) {
    TreeUtils.setNodeChildren(widget.treeData, nodeId, children);
  }

  // ── 构建 UI ──

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(_slideAnimation),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部拖拽指示条
            DragIndicator(),
            // 标题栏
            TopTitleInfo(title: widget.config.title),

            // 搜索框
            if (widget.config.showSearch) InputSearch(searchHint: widget.config.searchHint, applyFilter: _applyFilter, searchController: _searchController),

            // 树形列表
            Expanded(
              child: TreeList<T>(
                nodes: _filteredData,
                selectedIds: _selectedIds,
                multiple: widget.config.multiple,
                emptyText: widget.config.emptyText,
                onLoadChildren: widget.config.onLoadChildren,
                onChildrenLoaded: widget.config.onLoadChildren != null ? _onChildrenLoaded : null,
                onNodeTap: _selectNode,
                keyword: _searchController.text,
                highlightStyle: widget.config.highlightStyle,
                parentSelectable: widget.config.parentSelectable,
                onParentIndicatorTap: widget.config.multiple ? _onParentIndicatorTap : null,
                onParentExpandForSelect: widget.config.multiple && widget.config.parentSelectable ? _onParentExpandForSelect : null,
              ),
            ),

            // 底部按钮（仅多选模式显示）
            if (widget.config.multiple) BottomAction(config: widget.config, onConfirm: _onConfirm),
          ],
        ),
      ),
    );
  }
}
