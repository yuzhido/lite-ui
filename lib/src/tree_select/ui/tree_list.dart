import 'package:flutter/material.dart';

import '../model.dart';
import '../tree_utils.dart';

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

  const TreeList({
    super.key,
    required this.nodes,
    this.selectedIds = const {},
    this.multiple = false,
    this.emptyText = '暂无数据',
    this.onLoadChildren,
    this.onNodeTap,
    this.onChildrenLoaded,
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
    final isHalfSelected = widget.multiple && TreeUtils.isNodeHalfSelected(node, widget.selectedIds);
    final isFullySelected = widget.multiple && TreeUtils.isNodeFullySelected(node, widget.selectedIds);
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
              Expanded(
                child: InkWell(
                  onTap: () => widget.onNodeTap?.call(node),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            node.label,
                            style: TextStyle(
                              fontSize: 15,
                              color: isSelected || isFullySelected ? const Color(0xFF007AFF) : const Color(0xFF1A1A1A),
                              fontWeight: isSelected || isFullySelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),

                        // 子节点数量 badge
                        if (canExpand && hasChildren) ...[const SizedBox(width: 8), _buildChildCountBadge(node)],

                        // 选择指示器（放在最后，避免 badge 文字变化时挤动圆圈）
                        if (widget.multiple) ...[const SizedBox(width: 8), _buildSelectIndicator(isFullySelected, isHalfSelected)],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 子节点
        if (node.isExpanded && hasChildren) ...node.children.map((child) => _buildTreeNode(child, level: level + 1)),
      ],
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
