import 'package:flutter/material.dart';
import 'package:lite_ui/widgets/keyword_highlight.dart';

import 'model.dart';
import 'ui/tree_select.dart';

/// 树形选择器便捷方法
///
/// 提供 [show]（单选）和 [showMultiple]（多选）两个静态方法，
/// 一行代码弹出底部树形选择面板。
class TreeSelectHelper {
  TreeSelectHelper._();

  /// 显示树形选择器弹窗（单选模式）
  ///
  /// 选中节点后自动关闭并返回该节点，取消返回 null。
  ///
  /// [selectedId] 预选中的节点ID，传 null 表示无预选中。
  static Future<TreeNode<T>?> show<T extends Object>({
    required BuildContext context,
    required List<TreeNode<T>> treeData,
    String title = '请选择',
    String searchHint = '搜索...',
    String emptyText = '暂无数据',
    bool showSearch = true,
    bool parentSelectable = false,
    T? selectedId,
    TreeNodeTapCallback<T>? onSelect,
    TreeNodeLoadChildrenCallback<T>? onLoadChildren,
    String cancelLabel = '取消',
    String confirmLabel = '确定',
    KeywordHighlightStyle? highlightStyle,
  }) {
    return showModalBottomSheet<TreeNode<T>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final screenHeight = MediaQuery.of(ctx).size.height;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.75, minHeight: screenHeight * 0.5),
            child: TreeSelect<T>(
              treeData: treeData,
              config: TreeSelectConfig<T>(
                title: title,
                searchHint: searchHint,
                emptyText: emptyText,
                showSearch: showSearch,
                multiple: false,
                parentSelectable: parentSelectable,
                selectedIds: selectedId != null ? {selectedId} : const {},
                onSelect: onSelect,
                onLoadChildren: onLoadChildren,
                cancelLabel: cancelLabel,
                confirmLabel: confirmLabel,
                highlightStyle: highlightStyle,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 显示树形选择器弹窗（多选模式）
  ///
  /// 用户选择完成后点击"确定"关闭，返回选中的节点列表，取消返回 null。
  ///
  /// [selectedIds] 预选中的节点ID列表，内部自动转为 Set。
  /// 可直接传入后端返回的 ID 列表，无需手动转换。
  static Future<List<TreeNode<T>>?> showMultiple<T extends Object>({
    required BuildContext context,
    required List<TreeNode<T>> treeData,
    String title = '请选择',
    String searchHint = '搜索...',
    String emptyText = '暂无数据',
    bool showSearch = true,
    bool parentSelectable = false,
    List<T> selectedIds = const [],
    TreeNodeSelectCallback<T>? onConfirm,
    TreeNodeLoadChildrenCallback<T>? onLoadChildren,
    String cancelLabel = '取消',
    String confirmLabel = '确定',
    KeywordHighlightStyle? highlightStyle,
  }) {
    return showModalBottomSheet<List<TreeNode<T>>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final screenHeight = MediaQuery.of(ctx).size.height;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.75, minHeight: screenHeight * 0.5),
            child: TreeSelect<T>(
              treeData: treeData,
              config: TreeSelectConfig<T>(
                title: title,
                searchHint: searchHint,
                emptyText: emptyText,
                showSearch: showSearch,
                multiple: true,
                parentSelectable: parentSelectable,
                selectedIds: selectedIds.toSet(),
                onConfirm: onConfirm,
                onLoadChildren: onLoadChildren,
                cancelLabel: cancelLabel,
                confirmLabel: confirmLabel,
                highlightStyle: highlightStyle,
              ),
            ),
          ),
        );
      },
    );
  }
}
