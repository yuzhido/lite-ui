import 'package:flutter/material.dart';
import '../../widgets/drag_indicator.dart';
import '../../widgets/input_search.dart';
import '../../widgets/top_title_info.dart';
import '../../widgets/keyword_highlight.dart';

import '../models/index.dart';
import '../utils/index.dart';
import '../../widgets/bottom_action_bar.dart';
import 'tree_list.dart';

/// 树形选择器弹窗内容组件
///
/// 底部弹出的选择面板，内置搜索过滤与树形列表展示。
/// 支持单选（选中即关闭）和多选（底部确认按钮）。
///
/// 推荐使用 [TreeSelectHelper.show] 便捷方法，
/// 或通过 [TreeSelect] 表单组件集成使用。
class TreeModalContent<T extends Object> extends StatefulWidget {
  /// 树形数据源
  final List<TreeNode<T>> treeData;

  /// 主标题
  final String title;

  /// 副标题
  final String? subTitle;

  /// 搜索框提示文字
  final String searchHint;

  /// 空状态提示
  final String emptyText;

  /// 是否显示搜索框
  final bool showSearch;

  /// 是否支持多选
  final bool multiple;

  /// 初始选中的节点ID列表
  final Set<T> selectedIds;

  /// 是否允许选中父节点
  final bool parentSelectable;

  /// 选中回调（单选）
  final TreeNodeTapCallback<T>? onSelect;

  /// 确认回调（多选）
  final TreeNodeSelectCallback<T>? onConfirm;

  /// 懒加载子节点回调
  final TreeNodeLoadChildrenCallback<T>? onLoadChildren;

  /// 取消按钮文字
  final String cancelLabel;

  /// 确定按钮文字
  final String confirmLabel;

  /// 关键字高亮样式配置
  final KeywordHighlightStyle? highlightStyle;

  /// 搜索按钮背景色
  final Color? searchButtonColor;

  /// 搜索按钮文字/图标颜色
  final Color? searchButtonTextColor;

  /// 确认按钮背景色
  final Color? confirmButtonColor;

  /// 确认按钮文字/图标颜色
  final Color? confirmButtonTextColor;

  /// 取消按钮文字/边框颜色
  final Color? cancelButtonColor;

  const TreeModalContent({
    super.key,
    required this.treeData,
    this.title = '请选择',
    this.subTitle,
    this.searchHint = '搜索...',
    this.emptyText = '暂无数据',
    this.showSearch = true,
    this.multiple = false,
    this.parentSelectable = false,
    this.selectedIds = const {},
    this.onSelect,
    this.onConfirm,
    this.onLoadChildren,
    this.cancelLabel = '取消',
    this.confirmLabel = '确定',
    this.highlightStyle,
    this.searchButtonColor,
    this.searchButtonTextColor,
    this.confirmButtonColor,
    this.confirmButtonTextColor,
    this.cancelButtonColor,
  });

  @override
  State<TreeModalContent<T>> createState() => _TreeModalContentState<T>();
}

class _TreeModalContentState<T extends Object> extends State<TreeModalContent<T>> {
  late TextEditingController _searchController;

  Set<T> _selectedIds = {};
  List<TreeNode<T>> _filteredData = [];

  /// 当前选中的节点列表
  List<TreeNode<T>> get _selectedNodes => TreeUtils.getSelectedNodes(_filteredData, _selectedIds);

  /// 当前过滤后数据的节点总数（含所有嵌套子节点）
  int get _totalCount => _filteredData.fold(0, (sum, node) => sum + 1 + TreeUtils.countDescendants(node));

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedIds = Set.from(widget.selectedIds);
    _applyFilter('');

    // 展开所有选中节点的祖先路径
    TreeUtils.expandSelectedNodeAncestors(_filteredData, _selectedIds);
    setState(() {}); // 触发重建以应用展开状态
  }

  @override
  void didUpdateWidget(covariant TreeModalContent<T> oldWidget) {
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
    if (widget.selectedIds != oldWidget.selectedIds) {
      _selectedIds = Set.from(widget.selectedIds);
      TreeUtils.expandSelectedNodeAncestors(_filteredData, _selectedIds);
      setState(() {});
    }
  }

  @override
  void dispose() {
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
    if (!widget.multiple) {
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
      if (!widget.parentSelectable) {
        TreeUtils.autoDeselectParentChain(_filteredData, node, _selectedIds);
      }
    } else {
      TreeUtils.addNodeAndDescendants(node, _selectedIds);
      if (!widget.parentSelectable) {
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
      if (widget.parentSelectable) {
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
      final children = await widget.onLoadChildren!(clonedNode);
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
    widget.onSelect?.call(node);
    Navigator.of(context).pop(node);
  }

  void _onConfirm() {
    final selectedNodes = _selectedNodes;
    widget.onConfirm?.call(selectedNodes);
    Navigator.of(context).pop(selectedNodes);
  }

  // ── 懒加载同步 ──

  void _onChildrenLoaded(T nodeId, List<TreeNode<T>> children) {
    TreeUtils.setNodeChildren(widget.treeData, nodeId, children);
  }

  // ── 构建 UI ──

  @override
  Widget build(BuildContext context) {
    return Container(
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
          TopTitleInfo(title: widget.title, subTitle: widget.subTitle ?? '', itemCount: _totalCount),

          // 搜索框
          if (widget.showSearch)
            InputSearch(
              searchHint: widget.searchHint,
              onSearch: _applyFilter,
              searchController: _searchController,
              searchButtonColor: widget.searchButtonColor,
              searchButtonTextColor: widget.searchButtonTextColor,
            ),

          // 树形列表
          Expanded(
            child: TreeList<T>(
              nodes: _filteredData,
              selectedIds: _selectedIds,
              multiple: widget.multiple,
              emptyText: widget.emptyText,
              onLoadChildren: widget.onLoadChildren,
              onChildrenLoaded: widget.onLoadChildren != null ? _onChildrenLoaded : null,
              onNodeTap: _selectNode,
              keyword: _searchController.text,
              highlightStyle: widget.highlightStyle,
              parentSelectable: widget.parentSelectable,
              onParentIndicatorTap: widget.multiple ? _onParentIndicatorTap : null,
              onParentExpandForSelect: widget.multiple && widget.parentSelectable ? _onParentExpandForSelect : null,
            ),
          ),

          // 底部按钮（仅多选模式显示）
          if (widget.multiple)
            BottomActionBar(
              selectedCount: _selectedIds.length,
              cancelLabel: widget.cancelLabel,
              confirmLabel: widget.confirmLabel,
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: _onConfirm,
              confirmButtonColor: widget.confirmButtonColor,
              confirmButtonTextColor: widget.confirmButtonTextColor,
              cancelButtonColor: widget.cancelButtonColor,
            ),
        ],
      ),
    );
  }
}
