import 'package:flutter/material.dart';

import 'model.dart';
import 'tree_cascade.dart';
import 'tree_vertical.dart';

/// 树形选择器
///
/// 提供 [show] 静态方法，以 BottomSheet 弹窗形式展示树形选择器。
/// 支持两种布局模式：
/// - [TreeLayout.vertical]：竖向缩进布局（递归缩进，支持懒加载、搜索）
/// - [TreeLayout.cascade]：横向级联布局（多列并排，逐级选择）
///
/// 使用示例：
/// ```dart
/// TreeSelect.show<String, dynamic>(
///   context: context,
///   title: '选择部门',
///   layout: TreeLayout.vertical,
///   items: [
///     TreeSelectItem(label: '技术部', value: 'tech', children: [
///       TreeSelectItem(label: '前端组', value: 'frontend'),
///       TreeSelectItem(label: '后端组', value: 'backend'),
///     ]),
///   ],
///   onSelect: (value, data) => print('选中: $value'),
/// );
/// ```
class TreeSelect {
  TreeSelect._();

  /// 以 BottomSheet 形式展示树形选择器
  ///
  /// 泛型参数：
  /// - [V] 选项 value 的类型
  /// - [D] 选项 data 的类型（可选原始数据）
  ///
  /// 参数说明：
  /// - [context] 构建上下文
  /// - [layout] 布局模式，默认 [TreeLayout.vertical]
  /// - [title] 弹窗标题
  /// - [subtitle] 弹窗副标题
  /// - [items] 本地树形数据
  /// - [multiple] 是否多选，默认 false
  /// - [selectedValues] 初始选中值集合
  /// - [checkStrictly] 父子联动开关（仅 vertical），默认 true
  /// - [cascadeLevels] 级联列标题（仅 cascade），如 ["省","市","区"]
  /// - [onLoadChildren] 懒加载回调
  /// - [onSearch] 远程搜索回调（仅 vertical）
  /// - [onSelect] 单选回调
  /// - [onConfirm] 多选确认回调
  /// - [searchHint] 搜索提示（仅 vertical）
  /// - [cancelLabel] 取消按钮文字
  /// - [confirmLabel] 确定按钮文字
  /// - [emptyText] 空状态文字
  static Future<V?> show<V, D>({
    required BuildContext context,
    TreeLayout layout = TreeLayout.vertical,
    String? title,
    String? subtitle,
    List<TreeSelectItem<V, D>>? items,
    bool multiple = false,
    Set<V>? selectedValues,
    bool checkStrictly = true,
    List<String>? cascadeLevels,
    TreeLazyLoadCallback<V, D>? onLoadChildren,
    TreeSearchCallback<V, D>? onSearch,
    TreeOnSelectChange<V, D>? onSelect,
    TreeOnMultiSelectConfirm<V, D>? onConfirm,
    String searchHint = '搜索',
    String cancelLabel = '取消',
    String confirmLabel = '确定',
    String emptyText = '暂无数据',
  }) {
    return showModalBottomSheet<V>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _buildContent(
          layout: layout,
          title: title,
          subtitle: subtitle,
          items: items,
          multiple: multiple,
          selectedValues: selectedValues,
          checkStrictly: checkStrictly,
          cascadeLevels: cascadeLevels,
          onLoadChildren: onLoadChildren,
          onSearch: onSearch,
          onSelect: onSelect,
          onConfirm: onConfirm,
          searchHint: searchHint,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          emptyText: emptyText,
        );
      },
    );
  }

  static Widget _buildContent<V, D>({
    required TreeLayout layout,
    required String? title,
    required String? subtitle,
    required List<TreeSelectItem<V, D>>? items,
    required bool multiple,
    required Set<V>? selectedValues,
    required bool checkStrictly,
    required List<String>? cascadeLevels,
    required TreeLazyLoadCallback<V, D>? onLoadChildren,
    required TreeSearchCallback<V, D>? onSearch,
    required TreeOnSelectChange<V, D>? onSelect,
    required TreeOnMultiSelectConfirm<V, D>? onConfirm,
    required String searchHint,
    required String cancelLabel,
    required String confirmLabel,
    required String emptyText,
  }) {
    switch (layout) {
      case TreeLayout.vertical:
        return TreeVertical<V, D>(
          title: title,
          subtitle: subtitle,
          items: items,
          multiple: multiple,
          selectedValues: selectedValues,
          checkStrictly: checkStrictly,
          onLoadChildren: onLoadChildren,
          onSearch: onSearch,
          onSelect: onSelect,
          onConfirm: onConfirm,
          searchHint: searchHint,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          emptyText: emptyText,
        );

      case TreeLayout.cascade:
        return TreeCascade<V, D>(
          title: title,
          subtitle: subtitle,
          items: items ?? [],
          cascadeLevels: cascadeLevels,
          multiple: multiple,
          selectedValues: selectedValues,
          onSelect: onSelect,
          onConfirm: onConfirm,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          onLoadChildren: onLoadChildren,
        );
    }
  }
}
