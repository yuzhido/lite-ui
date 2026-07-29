import 'package:flutter/material.dart';

import '../models/select_item.dart';
import '../models/callbacks.dart';
import 'models/index.dart';
import 'ui/select_modal_content.dart';

/// SelectModal 底部弹窗选择器
///
/// 支持两种模式：
/// - [SelectModalType.filterable]：本地过滤选择器（直接传 items，组件内部过滤）
/// - [SelectModalType.remote]：远程搜索选择器（传 onSearch 异步搜索）
///
/// 该组件只负责弹窗壳子（showModalBottomSheet），
/// 内容渲染委托给 [SelectModalContent]。
///
/// 泛型参数：
/// - [V] 选项 value 的类型
/// - [D] 选项 data 的类型（可选原始数据）
class SelectModal {
  /// 显示一个从底部向上弹出的选择器
  ///
  /// [title] 主标题
  /// [description] 副标题/描述
  /// [items] 选项列表数据（直接传递给 SelectModalContent）
  /// [multiple] 是否多选模式，默认 false（单选）
  /// [selectedValues] 初始选中项的 value 集合
  /// [selectedItems] 已选中项的完整数据（确保回显时这些项一定出现在列表中）
  /// [onSelect] 单选回调（返回 value 和 data）
  /// [onConfirm] 多选确认回调（返回 values 和 datas）
  /// [searchHint] 搜索框提示文字
  /// [cancelLabel] 取消按钮文字
  /// [confirmLabel] 确定按钮文字
  ///
  /// --- remote 专属参数 ---
  /// [onSearch] 远程搜索回调（传入后启用远程搜索模式）
  /// [emptyText] 空状态提示文字
  static Future<V?> show<V, D>({
    required BuildContext context,
    SelectModalType type = SelectModalType.filterable,
    String? title,
    String? description,
    List<SelectItem<V, D>>? items,
    bool multiple = false,
    Set<V>? selectedValues,
    List<SelectItem<V, D>>? selectedItems,
    OnSelectChange<V, D>? onSelect,
    OnMultiSelectConfirm<V, D>? onConfirm,
    String searchHint = '搜索',
    String cancelLabel = '取消',
    String confirmLabel = '确定',

    // remote 专属
    RemoteSearchCallback<V, D>? onSearch,
    String emptyText = '暂无数据',
  }) {
    return showModalBottomSheet<V>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final screenHeight = MediaQuery.of(ctx).size.height;
        final constraints = BoxConstraints(minHeight: screenHeight * 0.60, maxHeight: screenHeight * 0.75);

        return SafeArea(
          child: ConstrainedBox(
            constraints: constraints,
            child: SelectModalContent<V, D>(
              title: title,
              description: description,
              type: type,
              items: items ?? [],
              onSearch: onSearch,
              multiple: multiple,
              selectedValues: selectedValues,
              selectedItems: selectedItems,
              onSelect: onSelect,
              onConfirm: onConfirm,
              searchHint: searchHint,
              cancelLabel: cancelLabel,
              confirmLabel: confirmLabel,
              emptyText: emptyText,
            ),
          ),
        );
      },
    );
  }
}
