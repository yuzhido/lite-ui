import 'package:flutter/material.dart';
import '../../widgets/keyword_highlight.dart';

import '../models/index.dart';
import '../utils/index.dart';
import 'select_indicator.dart';

/// 纯展示型树节点组件
///
/// 负责单个树节点及其子树的 UI 渲染（含层级连接线），
/// 不持有任何业务状态，展开/选中/懒加载等交互全部通过回调交由外部处理。
///
/// 由 [TreeList] 递归使用，一般不直接调用。
class TreeItem<V extends Object, D> extends StatelessWidget {
  /// 当前节点
  final TreeNode<V, D> node;

  /// 节点层级（决定缩进与连接线位置）
  final int level;

  /// 当前选中的节点 ID 集合
  final Set<V> selectedIds;

  /// 是否多选模式（影响三态选择器与 badge 显示）
  final bool multiple;

  /// 是否允许选中父节点
  final bool parentSelectable;

  /// 是否具备懒加载能力（影响可展开判断）
  final bool canLazyLoad;

  /// 当前搜索关键字，用于高亮匹配文本
  final String keyword;

  /// 关键字高亮样式配置
  final KeywordHighlightStyle? highlightStyle;

  /// 展开/折叠回调（箭头或父节点行点击时触发）
  final ValueChanged<V> onToggleExpand;

  /// 节点点击回调
  final TreeNodeSelect<V, D>? onNodeTap;

  /// 父节点圆圈点击回调（仅多选 + parentSelectable 时有效）
  final void Function(TreeNode<V, D> node)? onParentIndicatorTap;

  /// 父节点文本点击时需要展开（懒加载场景），由外部处理加载后再选中
  final void Function(TreeNode<V, D> node)? onParentExpandForSelect;

  const TreeItem({
    super.key,
    required this.node,
    this.level = 0,
    this.selectedIds = const {},
    this.multiple = false,
    this.parentSelectable = false,
    this.canLazyLoad = false,
    this.keyword = '',
    this.highlightStyle,
    required this.onToggleExpand,
    this.onNodeTap,
    this.onParentIndicatorTap,
    this.onParentExpandForSelect,
  });

  @override
  Widget build(BuildContext context) {
    final hasChildren = node.children.isNotEmpty;
    final canExpand = !node.isLeaf && (hasChildren || canLazyLoad);
    final isSelected = selectedIds.contains(node.id);
    final isHalfSelected = multiple && !parentSelectable && TreeUtils.isNodeHalfSelected(node, selectedIds);
    final isFullySelected = multiple && (parentSelectable ? isSelected : TreeUtils.isNodeFullySelected(node, selectedIds));
    final indent = level * 24.0;
    final isSelectedVisual = isSelected || isFullySelected;
    // 多选 + parentSelectable + 非叶子节点：拆分文本区和圆圈区
    final splitIndicator = multiple && canExpand && !node.isLeaf;

    // —— 子节点数量 badge ——
    final total = TreeUtils.countDescendants(node);
    final selectedCount = TreeUtils.countSelectedDescendants(node, selectedIds);
    final badgeText = multiple && selectedCount > 0 ? '$selectedCount/$total' : '$total';
    final badge = Container(
      constraints: const BoxConstraints(minWidth: 32),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: selectedCount > 0 ? const Color(0xFF007AFF).withValues(alpha: 0.1) : Colors.grey.shade100, borderRadius: BorderRadius.circular(999)),
      child: Text(
        badgeText,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: selectedCount > 0 ? const Color(0xFF007AFF) : Colors.grey.shade600, fontWeight: FontWeight.w500),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // —— 节点行 ——
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: EdgeInsets.only(left: 8 + indent, right: 8, top: 6, bottom: 6),
          decoration: BoxDecoration(color: isSelectedVisual ? const Color(0xFF007AFF).withValues(alpha: 0.08) : null, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              // 左侧展开/折叠箭头区
              if (canExpand)
                GestureDetector(
                  onTap: () => onToggleExpand(node.id),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.all(0),
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
                const SizedBox(width: 5),

              // 右侧文本 + 选择器区
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (!parentSelectable && canExpand) {
                      // parentSelectable=false + 父节点 → 展开/折叠
                      onToggleExpand(node.id);
                    } else if (parentSelectable && multiple && canExpand && !node.isLeaf && !node.isChildrenLoaded) {
                      // parentSelectable=true + 多选 + 父节点未加载 → 通知外部懒加载后再选中
                      onParentExpandForSelect?.call(node);
                    } else {
                      // 正常选中逻辑
                      onNodeTap?.call(node);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: buildHighlightedText(
                            text: node.label,
                            keyword: keyword,
                            style: TextStyle(
                              fontSize: 15,
                              color: isSelectedVisual ? const Color(0xFF007AFF) : const Color(0xFF1A1A1A),
                              fontWeight: isSelectedVisual ? FontWeight.w600 : FontWeight.normal,
                            ),
                            highlightStyle: highlightStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // 子节点数量 badge
                        if (canExpand && hasChildren) ...[const SizedBox(width: 8), badge],

                        // 选择指示器
                        if (multiple) ...[
                          const SizedBox(width: 8),
                          if (splitIndicator)
                            GestureDetector(
                              onTap: () => onParentIndicatorTap?.call(node),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: SelectIndicator(selected: isFullySelected, halfSelected: isHalfSelected),
                              ),
                            )
                          else
                            SelectIndicator(selected: isFullySelected, halfSelected: isHalfSelected),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 子节点（展开时逐子项绘制实线直角引导线：垂直线 + 横向连接线）
        if (node.isExpanded && hasChildren)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < node.children.length; i++)
                Stack(
                  children: [
                    // 垂直实线：非末项贯穿整个子项区块（含其展开的孙节点），末项只画到行中心（└ 效果）
                    Positioned(
                      left: indent + 30,
                      top: 0,
                      bottom: i < node.children.length - 1 ? 0 : null,
                      height: i < node.children.length - 1 ? null : 24,
                      child: Container(width: 1, color: Colors.grey.shade300),
                    ),
                    // 横向连接线：从垂直线连到子项展开箭头的中心（行中心高度 22px，箭头中心位于 indent+54）
                    Positioned(
                      left: indent + 30,
                      top: 24,
                      width: 18,
                      height: 1,
                      child: Container(color: Colors.grey.shade300),
                    ),
                    TreeItem<V, D>(
                      node: node.children[i],
                      level: level + 1,
                      selectedIds: selectedIds,
                      multiple: multiple,
                      parentSelectable: parentSelectable,
                      canLazyLoad: canLazyLoad,
                      keyword: keyword,
                      highlightStyle: highlightStyle,
                      onToggleExpand: onToggleExpand,
                      onNodeTap: onNodeTap,
                      onParentIndicatorTap: onParentIndicatorTap,
                      onParentExpandForSelect: onParentExpandForSelect,
                    ),
                  ],
                ),
            ],
          ),
      ],
    );
  }
}
