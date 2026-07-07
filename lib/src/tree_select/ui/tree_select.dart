import 'package:flutter/material.dart';
import 'package:lite_ui/widgets/drag_indicator.dart';
import 'package:lite_ui/widgets/input_search.dart';
import 'package:lite_ui/widgets/top_title_info.dart';

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

    // selectedIds 变化时：同步内部选中状态
    if (widget.config.selectedIds != oldWidget.config.selectedIds) {
      _selectedIds = Set.from(widget.config.selectedIds);
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
    if (widget.config.multiple) {
      setState(() {
        _toggleSelectWithChildren(node);
      });
    } else {
      _onNodeTap(node);
    }
  }

  void _toggleSelectWithChildren(TreeNode<T> node) {
    final isCurrentlySelected = TreeUtils.isNodeFullySelected(node, _selectedIds);
    if (isCurrentlySelected) {
      TreeUtils.removeNodeAndDescendants(node, _selectedIds);
    } else {
      TreeUtils.addNodeAndDescendants(node, _selectedIds);
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
