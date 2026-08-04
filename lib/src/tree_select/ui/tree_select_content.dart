import 'package:flutter/material.dart';
import '../../widgets/drag_indicator.dart';
import '../../widgets/input_search.dart';
import '../../widgets/top_title_info.dart';
import '../../widgets/keyword_highlight.dart';

import '../models/index.dart';
import '../utils/index.dart';
import '../../widgets/bottom_action_bar.dart';
import 'look_chosen_tree.dart';
import 'tree_list.dart';

/// 树形选择器弹窗内容组件
///
/// 底部弹出的选择面板，内置搜索过滤与树形列表展示。
/// 支持单选（选中即关闭）和多选（底部确认按钮）。
///
/// 推荐使用 [TreeSelectHelper.show] 便捷方法，
/// 或通过 [TreeSelect] 表单组件集成使用。
class TreeModalContent<V extends Object, D> extends StatefulWidget {
  /// 树形数据源
  ///
  /// 可为空，为空时弹窗打开后自动通过 [onLoadChildren](parent == null) 加载根节点。
  final List<TreeNode<V, D>> treeData;

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
  final Set<V> selectedIds;

  /// 是否允许选中父节点
  final bool parentSelectable;

  /// 选中回调（单选）
  final TreeNodeSelect<V, D>? onSelect;

  /// 确认回调（多选）
  final TreeNodeConfirm<V, D>? onConfirm;

  /// 懒加载节点回调
  ///
  /// parent 为 null 时加载根节点，否则加载该父节点的子节点。
  final TreeNodeLoadChild<V, D>? onLoadChildren;

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

  /// 懒加载数据缓存回调
  ///
  /// 弹窗内完成懒加载（根节点或子节点）后，将最新完整树数据
  /// 同步到父级缓存，避免下次打开弹窗重复加载。
  final void Function(List<TreeNode<V, D>> data)? onLazyDataLoaded;

  const TreeModalContent({
    super.key,
    this.treeData = const [],
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
    this.onLazyDataLoaded,
  });

  @override
  State<TreeModalContent<V, D>> createState() => _TreeModalContentState<V, D>();
}

class _TreeModalContentState<V extends Object, D> extends State<TreeModalContent<V, D>> {
  late TextEditingController _searchController;

  Set<V> _selectedIds = {};
  List<TreeNode<V, D>> _filteredData = [];

  /// 内部维护的原始树数据（支持根节点懒加载后更新）
  List<TreeNode<V, D>> _treeData = [];

  /// 是否正在加载根节点
  bool _isLoadingRoot = false;

  /// 当前选中的节点列表
  List<TreeNode<V, D>> get _selectedNodes => TreeUtils.getSelectedNodes(_filteredData, _selectedIds);

  /// 当前过滤后数据的节点总数（含所有嵌套子节点）
  int get _totalCount => _filteredData.fold(0, (sum, node) => sum + 1 + TreeUtils.countDescendants(node));

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedIds = Set.from(widget.selectedIds);
    _treeData = widget.treeData;

    if (_treeData.isEmpty && widget.onLoadChildren != null) {
      // 纯懒加载模式：自动加载根节点
      _filteredData = [];
      _isLoadingRoot = true;
      _loadRootNodes();
    } else {
      _applyFilter('');
      // 展开所有选中节点的祖先路径
      TreeUtils.expandSelectedNodeAncestors(_filteredData, _selectedIds);
    }
  }

  /// 加载根节点（treeData 为空时自动触发）
  void _loadRootNodes() async {
    try {
      final roots = await widget.onLoadChildren!(null);
      if (!mounted) return;
      setState(() {
        _treeData = roots;
        _isLoadingRoot = false;
        _applyFilter('');
        TreeUtils.expandSelectedNodeAncestors(_filteredData, _selectedIds);
      });
      // 同步到父级缓存
      widget.onLazyDataLoaded?.call(List.of(_treeData));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingRoot = false);
    }
  }

  @override
  void didUpdateWidget(covariant TreeModalContent<V, D> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // treeData 变化时：同步内部数据 + 重新克隆 + 应用当前搜索词
    if (!identical(widget.treeData, oldWidget.treeData)) {
      _treeData = widget.treeData;
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
      _filteredData = TreeUtils.cloneTree(_treeData);
    } else {
      _filteredData = TreeUtils.filterTree(TreeUtils.cloneTree(_treeData), keyword.toLowerCase());
    }
    setState(() {});
  }

  // ── 选择逻辑 ──

  void _selectNode(TreeNode<V, D> node) {
    if (!widget.multiple) {
      _onNodeTap(node); // 单选：选中并关闭
      return;
    }
    // 多选：联动选中/取消所有后代
    setState(() {
      _toggleSelectWithChildren(node);
    });
  }

  void _toggleSelectWithChildren(TreeNode<V, D> node) {
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
  void _onParentIndicatorTap(TreeNode<V, D> node) {
    setState(() {
      if (widget.parentSelectable) {
        // 仅选中/取消父节点自身，不联动子节点，不展开
        if (_selectedIds.contains(node.value)) {
          _selectedIds.remove(node.value);
        } else {
          _selectedIds.add(node.value);
        }
      } else {
        // 默认模式：联动子节点
        _toggleSelectWithChildren(node);
      }
    });
  }


  void _onNodeTap(TreeNode<V, D> node) {
    Navigator.of(context).pop(node);
    widget.onSelect?.call(node);
  }

  void _onConfirm() {
    final selectedNodes = _selectedNodes;
    widget.onConfirm?.call(selectedNodes);
    Navigator.of(context).pop(selectedNodes);
  }

  // ── 查看已选项 ──

  /// 构建已选项剪枝树：仅保留选中节点及其祖先路径（基于完整原始数据）
  List<TreeNode<V, D>> _buildSelectedTree() {
    List<TreeNode<V, D>>? prune(List<TreeNode<V, D>> nodes) {
      final result = <TreeNode<V, D>>[];
      for (final node in nodes) {
        final children = prune(node.children);
        final keep = _selectedIds.contains(node.value) || (children != null && children.isNotEmpty);
        if (keep) {
          result.add(TreeNode<V, D>(value: node.value, label: node.label, parentId: node.parentId, children: children ?? const [], data: node.data));
        }
      }
      return result.isEmpty ? null : result;
    }

    return prune(_treeData) ?? [];
  }

  void _handleViewSelected() {
    final selectedTree = _buildSelectedTree();
    if (selectedTree.isEmpty) return;
    LookChosenTree.show<V, D>(
      context: context,
      tree: selectedTree,
      selectedIds: _selectedIds,
      onRemove: (removedIds) {
        setState(() {
          _selectedIds.removeAll(removedIds);
        });
      },
    );
  }

  // ── 懒加载同步 ──

  void _onChildrenLoaded(V nodeId, List<TreeNode<V, D>> children) {
    TreeUtils.setNodeChildren(_treeData, nodeId, children);
    // 同步到父级缓存
    widget.onLazyDataLoaded?.call(List.of(_treeData));
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

          // 树形列表（根节点加载中显示 loading）
          Expanded(
            child: _isLoadingRoot
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : TreeList<V, D>(
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
              onViewSelected: _handleViewSelected,
              confirmButtonColor: widget.confirmButtonColor,
              confirmButtonTextColor: widget.confirmButtonTextColor,
              cancelButtonColor: widget.cancelButtonColor,
            ),
        ],
      ),
    );
  }
}
