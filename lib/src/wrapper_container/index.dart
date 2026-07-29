import 'package:flutter/material.dart';
import 'package:lite_ui/src/models/enum.dart';
import 'package:lite_ui/src/theme/index.dart';
import 'package:lite_ui/src/widgets/border_builder.dart';
import 'package:lite_ui/src/widgets/prefix_icon_label.dart';
import 'package:lite_ui/src/widgets/suffix_icon_label.dart';

/// 包装容器
///
/// 用于包装其他组件，提供表单标签 + 值显示 + 后缀图标的统一布局
class WrapperContainer extends StatelessWidget {
  /// 点击回调
  final VoidCallback? onTap;

  /// 表单标签（左侧）
  final String? formLabel;

  /// 选中的值文本（中间显示，有值时高亮色）
  final String? valueText;

  /// 自定义值显示 Widget（优先级高于 valueText）
  final Widget? valueWidget;

  /// 占位提示文字（无值时显示）
  final String? hintText;

  /// 错误提示文字（有值时显示）
  final String? errorText;

  /// 是否必填
  final bool? required;

  /// 表单布局方式
  final FormLayout? formLayout;

  const WrapperContainer({super.key, this.onTap, this.formLabel, this.valueText, this.valueWidget, this.hintText, this.errorText, this.required, this.formLayout});

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final errorColor = LiteUITheme.of(context).errorColor;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: InputDecorator(
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
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: buildInputOutlineBorder(type: BorderType.border, context: context, hasError: hasError, errorColor: hasError ? errorColor : null),
          enabledBorder: buildInputOutlineBorder(type: BorderType.border, context: context, hasError: hasError, errorColor: hasError ? errorColor : null),
        ),
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              PrefixIconLabel(required: required ?? false, label: formLabel ?? '表单标签'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: (valueWidget != null)
                      ? valueWidget!
                      : (valueText != null)
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            valueText ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, color: LiteUITheme.of(context).textColor),
                          ),
                        )
                      : (errorText != null)
                      ? Text(errorText ?? '', style: TextStyle(fontSize: 16, color: LiteUITheme.of(context).errorColor))
                      : Text(hintText ?? '请选择$formLabel', style: TextStyle(fontSize: 16, color: LiteUITheme.of(context).hintColor)),
                ),
              ),
              SuffixIconLabel(),
            ],
          ),
        ),
      ),
    );
  }
}
