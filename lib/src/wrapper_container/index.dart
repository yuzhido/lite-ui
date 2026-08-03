import 'package:flutter/material.dart';
import 'package:lite_ui/src/theme/index.dart';
import 'package:lite_ui/src/models/enum.dart';
import 'package:lite_ui/src/models/select_item.dart';
import 'package:lite_ui/src/widgets/border_builder.dart';
import 'package:lite_ui/src/widgets/prefix_icon_label.dart';
import 'package:lite_ui/src/widgets/suffix_icon_label.dart';

import 'show_content.dart';

/// 包装容器
///
/// 用于包装其他组件，提供表单标签 + 值显示 + 后缀图标的统一布局
class WrapperContainer<V, D> extends StatelessWidget {
  /// 点击回调
  final VoidCallback? onTap;

  /// 表单标签（左侧）
  final String? formLabel;

  /// 选中的值文本（中间显示，有值时高亮色）
  final String? valueText;

  /// 值显示模式，默认 [DisplayMode.text]
  final DisplayMode displayMode;

  /// compact 模式下最多显示的 tag 数，默认 3
  final int maxShowTags;

  /// 自定义值显示 Widget 构建器（优先级最高）
  ///
  /// 传入后忽略 [displayMode] 的默认逻辑，[items] 为当前所有选中值的 label 列表。
  final Widget Function(List<SelectItem<V, D>> items)? valueBuilder;

  /// 占位提示文字（无值时显示）
  final String? hintText;

  /// 错误提示文字（有值时显示）
  final String? errorText;

  /// 是否必填
  final bool? required;

  /// 表单布局方式
  final FormLayout? formLayout;

  /// 前置图标
  final Widget? prefixIcon;

  /// 直接传递图标数据
  final IconData? prefixIconData;

  /// 是否展开（弹窗打开状态），用于切换后缀图标
  final bool? isExpanded;

  /// 有值时点击清除回调（透传给 SuffixIconLabel）
  final VoidCallback? onClear;

  /// 选中的数据
  final List<SelectItem<V, D>> selectItems;

  const WrapperContainer({
    super.key,
    this.onTap,
    this.formLabel,
    this.valueText,
    this.displayMode = DisplayMode.text,
    this.maxShowTags = 3,
    this.valueBuilder,
    this.hintText,
    this.errorText,
    this.required,
    this.formLayout,
    this.prefixIcon,
    this.isExpanded,
    this.onClear,
    required this.selectItems,
    this.prefixIconData,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final errorColor = LiteUITheme.of(context).errorColor;
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(0),
        // 有错误时通过 label 显示错误文字，always 固定显示不触发浮动动画
        label: (formLayout == FormLayout.column)
            ? null
            : hasError
            ? Text(
                errorText!,
                style: TextStyle(fontSize: 16, color: errorColor, fontWeight: FontWeight.w500),
              )
            : null,
        floatingLabelBehavior: selectItems.isEmpty ? FloatingLabelBehavior.never : FloatingLabelBehavior.always,
        border: buildInputOutlineBorder(type: BorderType.border, context: context, hasError: hasError, errorColor: hasError ? errorColor : null, gapPadding: 0),
        enabledBorder: buildInputOutlineBorder(type: BorderType.border, context: context, hasError: hasError, errorColor: hasError ? errorColor : null, gapPadding: 0),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Row(
            spacing: 5,
            children: [
              if (prefixIcon != null || prefixIconData != null || formLabel != null)
                PrefixIconLabel(required: required ?? false, prefixIconData: prefixIconData, prefixIcon: prefixIcon, label: formLabel)
              else
                SizedBox(width: 5),
              Expanded(
                child: ShowContent(
                  selectItems: selectItems,
                  errorText: errorText,
                  valueText: valueText,
                  hintText: hintText,
                  formLabel: formLabel,
                  displayMode: displayMode,
                  maxShowTags: maxShowTags,
                  valueBuilder: valueBuilder,
                ),
              ),
              // 后缀图标区域独立于外层 GestureDetector，点击不会触发弹窗
              SuffixIconLabel(isExpanded: isExpanded ?? false, onClear: onClear, hasValue: selectItems.isNotEmpty == true),
            ],
          ),
        ),
      ),
    );
  }
}
