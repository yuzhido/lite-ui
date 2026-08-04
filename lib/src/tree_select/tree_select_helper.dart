import 'package:flutter/material.dart';
import '../widgets/keyword_highlight.dart';

import 'models/index.dart';
import 'ui/tree_select_content.dart';

/// 树形选择器便捷方法
///
/// 提供统一的 [show] 静态方法，支持单选和多选模式，
/// 一行代码弹出底部树形选择面板。
class TreeSelectHelper {
  TreeSelectHelper._();

  /// 显示树形选择器弹窗
  ///
  /// 单选模式（[multiple] = false）：选中节点后自动关闭，返回该节点，取消返回 null。
  /// 多选模式（[multiple] = true）：通过 [onConfirm] 回调返回选中节点列表。
  ///
  /// [selectedIds] 预选中的节点ID集合。
  /// [treeData] 可不传（或传空列表），此时弹窗打开后自动通过
  /// [onLoadChildren]（parent == null）加载根节点。
  static Future<TreeNode<V, D>?> show<V extends Object, D>({
    required BuildContext context,
    List<TreeNode<V, D>> treeData = const [],
    String title = '请选择',
    String? subTitle,
    String searchHint = '搜索...',
    String emptyText = '暂无数据',
    bool showSearch = true,
    bool multiple = false,
    bool parentSelectable = false,
    Set<V> selectedIds = const {},
    TreeNodeSelect<V, D>? onSelect,
    TreeNodeConfirm<V, D>? onConfirm,
    TreeNodeLoadChild<V, D>? onLoadChildren,
    String cancelLabel = '取消',
    String confirmLabel = '确定',
    KeywordHighlightStyle? highlightStyle,
    Color? searchButtonColor,
    Color? searchButtonTextColor,
    Color? confirmButtonColor,
    Color? confirmButtonTextColor,
    Color? cancelButtonColor,
  }) {
    assert(onConfirm == null || multiple, '单选模式不支持 onConfirm，onConfirm 仅在多选模式下有效');
    assert(treeData.isNotEmpty || onLoadChildren != null, 'treeData 与 onLoadChildren 至少提供一个：无初始数据时需通过 onLoadChildren(parent == null) 加载根节点');
    return showModalBottomSheet<TreeNode<V, D>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final screenHeight = MediaQuery.of(ctx).size.height;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.75, minHeight: screenHeight * 0.5),
            child: TreeModalContent<V, D>(
              treeData: treeData,
              title: title,
              subTitle: subTitle,
              searchHint: searchHint,
              emptyText: emptyText,
              showSearch: showSearch,
              multiple: multiple,
              parentSelectable: parentSelectable,
              selectedIds: selectedIds,
              onSelect: onSelect,
              onConfirm: onConfirm,
              onLoadChildren: onLoadChildren,
              cancelLabel: cancelLabel,
              confirmLabel: confirmLabel,
              highlightStyle: highlightStyle,
              searchButtonColor: searchButtonColor,
              searchButtonTextColor: searchButtonTextColor,
              confirmButtonColor: confirmButtonColor,
              confirmButtonTextColor: confirmButtonTextColor,
              cancelButtonColor: cancelButtonColor,
            ),
          ),
        );
      },
    );
  }
}
