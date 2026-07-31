import 'package:flutter/material.dart';
import '../../widgets/keyword_highlight.dart';

import '../models/index.dart';
import '../utils/index.dart';

/// 纯展示型树形列表组件
///
/// 负责树节点的递归渲染、展开/折叠交互、懒加载子节点及空状态显示。
/// 不包含搜索框、选中逻辑等业务功能，可独立嵌入任意布局使用。
///
/// 使用示例：
/// ```dart
/// TreeList<String>(
///   nodes: myTreeNodes,
///   selectedIds: {'node_1', 'node_2'},
///   multiple: true,
///   onNodeTap: (node) => print('点击: ${node.label}'),
/// )
/// ```
class TreeList<T extends Object> extends StatefulWidget {
  /// 树形数据源（根节点列表）
  final List<TreeNode<T>> nodes;

  /// 当前选中的节点 ID 集合
  final Set<T> selectedIds;

  /// 是否多选模式（影响三态选择器与 badge 显示）
  final bool multiple;

  /// 空状态提示文字
  final String emptyText;

  /// 懒加载子节点回调
  /// 当节点 isLeaf=false 且 children 为空时，展开会触发此回调
  final TreeNodeLoadChildrenCallback<T>? onLoadChildren;

  /// 懒加载完成后的通知回调
  /// 用于让父组件同步原始数据（如更新非克隆树）
  final void Function(T nodeId, List<TreeNode<T>> children)? onChildrenLoaded;

  /// 节点点击回调
  final TreeNodeTapCallback<T>? onNodeTap;

  /// 当前搜索关键字，用于高亮匹配文本
  final String keyword;

  /// 关键字高亮样式配置
  final KeywordHighlightStyle? highlightStyle;

  /// 是否允许选中父节点
  final bool parentSelectable;

  /// 父节点圆圈点击回调（仅多选 + parentSelectable 时有效）
  final void Function(TreeNode<T> node)? onParentIndicatorTap;

  /// 父节点文本点击时需要展开（懒加载场景），由外部处理加载后再选中
  final void Function(TreeNode<T> node)? onParentExpandForSelect;

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
    this.onParentExpandForSelect,
  });

  @override
  State<TreeList<T>> createState() => _TreeListState<T>();
}

class _TreeListState<T extends Object> extends State<TreeList<T>> {
  late List<TreeNode<T>> _nodes;

  @override
  void initState() {
    super.initState();
    _nodes = widget.nodes;
  }

  @override
  void didUpdateWidget(covariant TreeList<T> oldWidget) {
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
        return _buildTreeNode(_nodes[index], level: 0);
      },
    );
  }

  // ── 展开/折叠（含懒加载） ──

  void _toggleNodeExpansion(T nodeId) async {
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

  // ── 节点渲染 ──

  Widget _buildTreeNode(TreeNode<T> node, {required int level}) {
    final hasChildren = node.children.isNotEmpty;
    final canExpand = !node.isLeaf && (hasChildren || widget.onLoadChildren != null);
    final isSelected = widget.selectedIds.contains(node.id);
    final isHalfSelected = widget.multiple && !widget.parentSelectable && TreeUtils.isNodeHalfSelected(node, widget.selectedIds);
    final isFullySelected = widget.multiple && (widget.parentSelectable ? isSelected : TreeUtils.isNodeFullySelected(node, widget.selectedIds));
    final indent = level * 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 16 + indent, right: 16, top: 10, bottom: 10),
          child: Row(
            children: [
              // —— 左侧展开/折叠箭头区 ——
              if (canExpand)
                GestureDetector(
                  onTap: () => _toggleNodeExpansion(node.id),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: node.isLoading
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade500)))
                        : AnimatedRotation(
                            turns: node.isExpanded ? 0.25 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(Icons.keyboard_arrow_right_rounded, size: 20, color: Colors.grey.shade600),
                          ),
                  ),
                )
              else
                const SizedBox(width: 28),

              const SizedBox(width: 4),

              // —— 右侧文本 + 选择器区 ——
              Expanded(child: _buildContentArea(node, canExpand, hasChildren, isSelected, isFullySelected, isHalfSelected)),
            ],
          ),
        ),

        // 子节点
        if (node.isExpanded && hasChildren) ...node.children.map((child) => _buildTreeNode(child, level: level + 1)),
      ],
    );
  }

  // ── 内容区域构建 ──

  Widget _buildContentArea(TreeNode<T> node, bool canExpand, bool hasChildren, bool isSelected, bool isFullySelected, bool isHalfSelected) {
    // 多选 + parentSelectable + 非叶子节点：拆分文本区和圆圈区
    final splitIndicator = widget.multiple && canExpand && !node.isLeaf;

    return InkWell(
      onTap: () {
        if (!widget.parentSelectable && canExpand) {
          // parentSelectable=false + 父节点 → 展开/折叠
          _toggleNodeExpansion(node.id);
        } else if (widget.parentSelectable && widget.multiple && canExpand && !node.isLeaf && !node.isChildrenLoaded) {
          // parentSelectable=true + 多选 + 父节点未加载 → 通知外部懒加载后再选中
          widget.onParentExpandForSelect?.call(node);
        } else {
          // 正常选中逻辑
          widget.onNodeTap?.call(node);
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: buildHighlightedText(
                text: node.label,
                keyword: widget.keyword,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected || isFullySelected ? const Color(0xFF007AFF) : const Color(0xFF1A1A1A),
                  fontWeight: isSelected || isFullySelected ? FontWeight.w600 : FontWeight.normal,
                ),
                highlightStyle: widget.highlightStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 子节点数量 badge
            if (canExpand && hasChildren) ...[const SizedBox(width: 8), _buildChildCountBadge(node)],

            // 选择指示器
            if (widget.multiple) ...[
              const SizedBox(width: 8),
              if (splitIndicator) _buildSplitIndicator(node, isFullySelected, isHalfSelected) else _buildSelectIndicator(isFullySelected, isHalfSelected),
            ],
          ],
        ),
      ),
    );
  }

  /// 拆分模式下的圆圈指示器（独立点击区域，不触发行点击）
  Widget _buildSplitIndicator(TreeNode<T> node, bool isFully, bool isHalf) {
    return GestureDetector(
      onTap: () => widget.onParentIndicatorTap?.call(node),
      behavior: HitTestBehavior.opaque,
      child: Padding(padding: const EdgeInsets.all(2), child: _buildSelectIndicator(isFully, isHalf)),
    );
  }

  Widget _buildSelectIndicator(bool isFully, bool isHalf) {
    if (isFully) {
      return const Icon(Icons.check_circle_rounded, size: 22, color: Color(0xFF007AFF));
    }
    if (isHalf) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.circle_outlined, size: 22, color: Colors.grey.shade400),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle),
          ),
        ],
      );
    }
    return Icon(Icons.circle_outlined, size: 22, color: Colors.grey.shade300);
  }

  Widget _buildChildCountBadge(TreeNode<T> node) {
    final total = TreeUtils.countDescendants(node);
    final selected = TreeUtils.countSelectedDescendants(node, widget.selectedIds);
    final text = widget.multiple && selected > 0 ? '$selected/$total' : '$total';
    return Container(
      constraints: const BoxConstraints(minWidth: 36),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: selected > 0 ? const Color(0xFF007AFF).withValues(alpha: 0.1) : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: selected > 0 ? const Color(0xFF007AFF) : Colors.grey.shade600, fontWeight: FontWeight.w500),
      ),
    );
  }
}
