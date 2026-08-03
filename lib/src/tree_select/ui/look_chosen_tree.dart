import 'package:flutter/material.dart';

import '../models/index.dart';

/// 已选项查看弹窗（居中 Dialog，树形层级版）
///
/// 展示当前已选中的树节点（剪枝树，保留数据层级），支持按节点移除。
/// 内部维护列表状态，移除后自动刷新，全部移除后自动关闭。
///
/// [tree] 为「选中剪枝树」：仅保留选中节点及其祖先路径，
/// 可由 [TreeModalContent] 根据原始树数据与 selectedIds 构建。
class LookChosenTree<V extends Object, D> extends StatefulWidget {
  /// 已选项剪枝树（保留层级的子树）
  final List<TreeNode<V, D>> tree;

  /// 当前选中的节点 ID 集合
  final Set<V> selectedIds;

  /// 移除节点时的回调（传入该节点及其已选后代的 ID 集合）
  final ValueChanged<Set<V>>? onRemove;

  const LookChosenTree({required this.tree, required this.selectedIds, this.onRemove, super.key});

  /// 显示已选项弹窗
  static void show<V extends Object, D>({required BuildContext context, required List<TreeNode<V, D>> tree, required Set<V> selectedIds, ValueChanged<Set<V>>? onRemove}) {
    showDialog(
      context: context,
      builder: (ctx) => LookChosenTree<V, D>(tree: tree, selectedIds: selectedIds, onRemove: onRemove),
    );
  }

  @override
  State<LookChosenTree<V, D>> createState() => _LookChosenTreeState<V, D>();
}

class _LookChosenTreeState<V extends Object, D> extends State<LookChosenTree<V, D>> {
  late List<TreeNode<V, D>> _tree;
  late Set<V> _selectedIds;

  @override
  void initState() {
    super.initState();
    _tree = List.from(widget.tree);
    _selectedIds = Set.from(widget.selectedIds);
  }

  /// 收集节点自身 + 全部后代 ID
  Set<V> _collectIds(TreeNode<V, D> node) {
    final ids = <V>{node.id};
    for (final child in node.children) {
      ids.addAll(_collectIds(child));
    }
    return ids;
  }

  void _handleRemove(TreeNode<V, D> node) {
    final removedIds = _collectIds(node).where(_selectedIds.contains).toSet();
    setState(() {
      _selectedIds.removeAll(removedIds);
      _removeNode(_tree, node.id);
    });
    widget.onRemove?.call(removedIds);

    // 全部移除后自动关闭
    if (_selectedIds.isEmpty) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  bool _removeNode(List<TreeNode<V, D>> nodes, V id) {
    for (var i = 0; i < nodes.length; i++) {
      if (nodes[i].id == id) {
        nodes.removeAt(i);
        return true;
      }
      if (_removeNode(nodes[i].children, id)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        clipBehavior: Clip.antiAlias,
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340, maxHeight: 480),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: primary),
                        const SizedBox(width: 5),
                        Text(
                          '已选 ${_selectedIds.length} 项',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                        child: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 树形列表
            Flexible(
              child: _selectedIds.isEmpty
                  ? Container(
                      height: 200,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                            child: Icon(Icons.inbox_outlined, size: 30, color: Colors.grey.shade400),
                          ),
                          const SizedBox(height: 12),
                          Text('暂无已选项', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [for (final node in _tree) _ChosenTreeItem<V, D>(node: node, level: 0, primary: primary, selectedIds: _selectedIds, onRemove: _handleRemove)],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 已选项树节点行（含子树递归渲染）
///
/// 纯 UI 组件：缩进 + 实线直角引导线表达层级，每行带移除按钮。
/// 仅作为路径的祖先节点（自身未选中）以灰色弱化样式展示，
/// 与真正选中的节点（蓝色勾选样式）区分，避免歧义。
class _ChosenTreeItem<V extends Object, D> extends StatelessWidget {
  final TreeNode<V, D> node;
  final int level;
  final Color primary;
  final Set<V> selectedIds;
  final ValueChanged<TreeNode<V, D>> onRemove;

  const _ChosenTreeItem({required this.node, required this.level, required this.primary, required this.selectedIds, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final indent = level * 20.0;
    final hasChildren = node.children.isNotEmpty;
    final selectedDescCount = _countSelected(node);
    final isSelected = selectedIds.contains(node.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 8),
          padding: EdgeInsets.only(left: 8 + indent, right: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
              children: [
                // 真正选中的节点：蓝色勾选样式；仅作为路径的祖先节点：灰色文件夹弱化样式
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(color: primary.withValues(alpha: 0.10), shape: BoxShape.circle),
                    child: Icon(Icons.check_rounded, color: primary, size: 12),
                  )
                else
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: Icon(Icons.folder_outlined, color: Colors.grey.shade400, size: 12),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isSelected ? const Color(0xFF333333) : Colors.grey.shade500,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                if (hasChildren) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: primary.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      '$selectedDescCount 项',
                      style: TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
                if (isSelected)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onRemove(node),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.delete_forever_outlined, size: 20, color: Colors.red.shade500),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // 子节点：逐子项绘制实线直角引导线（垂直线 + 横向连接线）
        if (hasChildren)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < node.children.length; i++)
                Stack(
                  children: [
                    // 垂直实线：非末项贯穿子项区块，末项只画到行中心（└ 效果）
                    Positioned(
                      left: indent + 17,
                      top: 0,
                      bottom: i < node.children.length - 1 ? 0 : null,
                      height: i < node.children.length - 1 ? null : 30,
                      child: Container(width: 1, color: Colors.grey.shade300),
                    ),
                    // 横向连接线
                    Positioned(
                      left: indent + 17,
                      top: 30,
                      width: 12,
                      height: 1,
                      child: Container(color: Colors.grey.shade300),
                    ),
                    _ChosenTreeItem<V, D>(node: node.children[i], level: level + 1, primary: primary, selectedIds: selectedIds, onRemove: onRemove),
                  ],
                ),
            ],
          ),
      ],
    );
  }

  int _countSelected(TreeNode<V, D> node) {
    var count = 0;
    for (final child in node.children) {
      count += 1 + _countSelected(child);
    }
    return count;
  }
}
