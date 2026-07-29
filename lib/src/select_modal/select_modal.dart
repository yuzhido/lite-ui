import 'package:flutter/material.dart';

import '../models/select_item.dart';
import '../models/callbacks.dart';
import 'models/index.dart';
import 'ui/select_modal_content.dart';

/// SelectModal 底部弹窗选择器
///
/// 支持多种内容类型：
/// - [SelectModalType.filterable]：可过滤选择器（本地过滤+动态数据合并）
/// - [SelectModalType.remote]：远程搜索选择器（异步搜索）
///
/// 该组件只负责弹窗壳子（showModalBottomSheet），
/// 内容渲染委托给 [SelectModalContent]，通过 [SelectModalDataProvider] 注入数据获取策略。
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
    // 根据模式构建数据提供策略
    final SelectModalDataProvider<V, D> dataProvider;
    final bool isRemote;
    final String? prefixTitle;

    switch (type) {
      case SelectModalType.filterable:
        isRemote = false;
        prefixTitle = '请选择';
        dataProvider = _buildFilterableProvider(items ?? [], dynamicItems);

      case SelectModalType.remote:
        if (onSearch == null) {
          throw ArgumentError('onSearch is required for SelectModalType.remote');
        }
        isRemote = true;
        prefixTitle = null;
        dataProvider = onSearch;
    }

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
              prefixTitle: prefixTitle,
              description: description,
              dataProvider: dataProvider,
              isRemote: isRemote,
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
            ),
          ),
        );
      },
    );
  }

  /// 构建 filterable 模式的数据提供策略
  ///
  /// 本地过滤静态 items，可选合并 dynamicItems 回调返回的动态数据。
  static SelectModalDataProvider<V, D> _buildFilterableProvider<V, D>(List<SelectItem<V, D>> items, DynamicItemsCallback<V, D>? dynamicItems) {
    return (String keyword) async {
      // 1. 本地过滤静态数据
      final filtered = keyword.isEmpty
          ? items
          : items.where((item) {
              final kw = keyword.toLowerCase();
              return item.label.toLowerCase().contains(kw) || (item.subtitle?.toLowerCase().contains(kw) ?? false);
            }).toList();

      // 2. 合并动态数据（去重）
      if (dynamicItems != null) {
        final dynamic = await dynamicItems(keyword);
        final staticValues = filtered.map((e) => e.value).toSet();
        final uniqueDynamic = dynamic.where((item) => !staticValues.contains(item.value)).toList();
        return [...filtered, ...uniqueDynamic];
      }

      return filtered;
    };
  }
}
