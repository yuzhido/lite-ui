import 'package:flutter/material.dart';
import 'package:lite_ui/src/models/index.dart';

import '../wrapper_container/index.dart';
import 'models/index.dart';
import 'ui/action_sheet_content.dart';

/// 底部弹窗显示数据操作
///
/// 支持两种使用方式：
/// 1. 自带默认触发器 UI：构造 ActionSheet，点击显示表单标签项弹出 Sheet
/// 2. 自定义触发器：传入 [child] 作为触发器，点击 child 弹出 Sheet
/// 3. 编程式调用：使用 [ActionSheet.show] 静态方法
///
/// 内容包含：标题 + 描述 + 可滚动操作项列表 + 取消按钮。
/// 该组件只负责弹窗壳子（showModalBottomSheet），
/// 内容渲染委托给 [ActionSheetContent]。
///
/// 受控模式：传入 [value]，组件自动从 [items]/[sections] 中匹配
/// 对应的 label 显示在触发器上，配合 [onSelect] 回调 setState 即可。
class ActionSheet<V, D> extends StatelessWidget {
  /// 自定义触发器 Widget（可选）
  ///
  /// 传入后点击该 child 弹出 Sheet；不传则渲染默认触发器 UI。
  final Widget? child;

  /// 表单标签（默认触发器模式使用）
  final String? formLabel;

  /// 当前选中的值（受控模式）
  ///
  /// 传入后自动从 [items] 或 [sections] 中匹配对应项的 label 显示。
  final V? value;

  /// 主标题
  final String? title;

  /// 副标题/描述
  final String? description;

  /// 操作项列表
  final List<SelectItem<V, D>>? items;

  /// 分组数据（优先于 items）
  final List<ActionSheetSection<V, D>>? sections;

  /// 取消按钮文字，默认为「取消」
  final String cancelLabel;

  /// 是否显示禁用项标签，默认 false
  final bool showDisabledBadge;

  /// 自定义最大高度（覆盖默认的 75%）
  final double? maxHeight;

  /// 占位提示文字（未选中时显示）
  final String? hintText;

  /// 选中回调
  final OnSelectChange<V, D>? onSelect;

  const ActionSheet({
    super.key,
    this.child,
    this.formLabel,
    this.value,
    this.title,
    this.description,
    this.items,
    this.sections,
    this.cancelLabel = '取消',
    this.showDisabledBadge = false,
    this.maxHeight,
    this.hintText,
    this.onSelect,
  });

  /// 显示一个从底部向上弹出的 ActionSheet
  ///
  /// [title] 主标题
  /// [description] 副标题/描述
  /// [items] 操作项列表
  /// [sections] 分组数据（优先于 items）
  /// [cancelLabel] 取消按钮文字，默认为「取消」
  /// [showDisabledBadge] 是否显示禁用项标签，默认 false
  /// [maxHeight] 自定义最大高度（覆盖默认的 75%）
  /// [isDismissible] 点击遮罩是否可关闭，默认 true
  /// [barrierColor] 遮罩颜色
  static Future<V?> show<V, D>({
    required BuildContext context,
    String? title,
    String? description,
    List<SelectItem<V, D>>? items,
    List<ActionSheetSection<V, D>>? sections,
    String cancelLabel = '取消',
    bool showDisabledBadge = false,
    double? maxHeight,
    OnSelectChange<V, D>? onSelect,
    bool isDismissible = true,
    Color? barrierColor,
  }) {
    return showModalBottomSheet<V>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      barrierColor: barrierColor,
      builder: (ctx) {
        return ActionSheetContent<V, D>(
          title: title,
          description: description,
          sections: sections,
          items: items,
          showDisabledBadge: showDisabledBadge,
          maxHeight: maxHeight,
          onSelect: (value, data) {
            onSelect?.call(value, data);
            Navigator.of(ctx).pop(value);
          },
          cancelLabel: cancelLabel,
        );
      },
    );
  }

  void _showSheet(BuildContext context) {
    ActionSheet.show<V, D>(
      context: context,
      title: title,
      description: description,
      items: items,
      sections: sections,
      cancelLabel: cancelLabel,
      showDisabledBadge: showDisabledBadge,
      maxHeight: maxHeight,
      onSelect: onSelect,
    );
  }

  /// 从 items 或 sections 中匹配 value 对应的 label
  String? _matchLabel() {
    if (value == null) return null;
    // 优先从 sections 匹配
    if (sections != null) {
      for (final section in sections!) {
        for (final item in section.items) {
          if (item.value == value) return item.label;
        }
      }
    }
    // 从 items 匹配
    if (items != null) {
      for (final item in items!) {
        if (item.value == value) return item.label;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSheet(context),
      child: child ?? WrapperContainer(
        formLabel: formLabel,
        valueText: _matchLabel(),
        hintText: hintText,
      ),
    );
  }
}
