import 'package:flutter/material.dart';

import '../models/select_item.dart';
import '../models/callbacks.dart';
import 'models/index.dart';
import 'ui/select_modal_filterable.dart';
import 'ui/select_modal_remote.dart';

/// SelectModal 底部弹窗选择器
///
/// 支持多种内容类型：
/// - [SelectModalType.filterable]：可过滤选择器（本地过滤+动态数据合并）
/// - [SelectModalType.remote]：远程搜索选择器（异步搜索）
///
/// 该组件只负责弹窗壳子（showModalBottomSheet），
/// 不同模式内容渲染委托给对应的子组件。
///
/// 泛型参数：
/// - [V] 选项 value 的类型
/// - [D] 选项 data 的类型（可选原始数据）
class SelectModal {
  /// 显示一个从底部向上弹出的选择器
  ///
  /// [type] 内容类型，默认为 [SelectModalType.filterable]
  /// [title] 主标题
  /// [description] 副标题/描述
  /// [items] 选项列表（filterable 模式）
  /// [multiple] 是否多选模式，默认 false（单选）
  /// [selectedValues] 初始选中项的 value 集合
  /// [selectedItems] 已选中项的完整数据（确保回显时这些项一定出现在列表中）
  /// [onSelect] 单选回调（返回 value 和 data）
  /// [onConfirm] 多选确认回调（返回 values 和 datas）
  /// [searchHint] 搜索框提示文字
  /// [cancelLabel] 取消按钮文字
  /// [confirmLabel] 确定按钮文字
  ///
  /// --- filterable 专属参数 ---
  /// [dynamicItems] 异步动态数据回调
  ///
  /// --- remote 专属参数 ---
  /// [onSearch] 远程搜索回调（必填）
  /// [initialItems] 初始数据
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

    // filterable 专属
    DynamicItemsCallback<V, D>? dynamicItems,

    // remote 专属
    RemoteSearchCallback<V, D>? onSearch,
    List<SelectItem<V, D>>? initialItems,
    String emptyText = '暂无数据',
  }) {
    return showModalBottomSheet<V>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final screenHeight = MediaQuery.of(ctx).size.height;

        // 高度限制在 60%~75%
        final constraints = BoxConstraints(minHeight: screenHeight * 0.60, maxHeight: screenHeight * 0.75);

        return SafeArea(
          child: ConstrainedBox(
            constraints: constraints,
            child: _buildContent<V, D>(
              type: type,
              title: title,
              description: description,
              items: items,
              multiple: multiple,
              selectedValues: selectedValues,
              selectedItems: selectedItems,
              onSelect: onSelect,
              onConfirm: onConfirm,
              searchHint: searchHint,
              cancelLabel: cancelLabel,
              confirmLabel: confirmLabel,
              dynamicItems: dynamicItems,
              onSearch: onSearch,
              initialItems: initialItems,
              emptyText: emptyText,
            ),
          ),
        );
      },
    );
  }

  /// 根据 type 渲染不同的内容组件
  static Widget _buildContent<V, D>({
    required SelectModalType type,
    required String? title,
    required String? description,
    required List<SelectItem<V, D>>? items,
    required bool multiple,
    required Set<V>? selectedValues,
    required List<SelectItem<V, D>>? selectedItems,
    required OnSelectChange<V, D>? onSelect,
    required OnMultiSelectConfirm<V, D>? onConfirm,
    required String searchHint,
    required String cancelLabel,
    required String confirmLabel,
    required DynamicItemsCallback<V, D>? dynamicItems,
    required RemoteSearchCallback<V, D>? onSearch,
    required List<SelectItem<V, D>>? initialItems,
    required String emptyText,
  }) {
    switch (type) {
      case SelectModalType.filterable:
        // filterable 模式：未传数据时使用空列表
        final filterableItems = items ?? [];

        return SelectModalFilterable<V, D>(
          title: title,
          description: description,
          items: filterableItems,
          dynamicItems: dynamicItems,
          multiple: multiple,
          selectedValues: selectedValues,
          selectedItems: selectedItems,
          onSelect: onSelect,
          onConfirm: onConfirm,
          searchHint: searchHint,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
        );

      case SelectModalType.remote:
        // remote 模式：onSearch 必填
        if (onSearch == null) {
          throw ArgumentError('onSearch is required for SelectModalType.remote');
        }

        return SelectModalRemote<V, D>(
          title: title,
          description: description,
          onSearch: onSearch,
          initialItems: initialItems,
          multiple: multiple,
          selectedValues: selectedValues,
          selectedItems: selectedItems,
          onSelect: onSelect,
          onConfirm: onConfirm,
          searchHint: searchHint,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          emptyText: emptyText,
        );
    }
  }
}
