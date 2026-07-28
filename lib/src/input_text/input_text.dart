import 'package:flutter/material.dart';

import '../widgets/prefix_icon_label.dart';
import '../widgets/suffix_clear_icon.dart';

/// 输入框
/// 输入框组件
class InputText extends StatefulWidget {
  const InputText({
    super.key,
    this.formLabel,
    this.hintText,
    this.labelSpacing = 2,
    this.maxLines,
    this.minLines,
    this.labelWidth,
    this.prefixIcon,
    this.prefixIconData,
    this.prefixIconColor,
    this.suffixIcon,
    this.suffixIconData,
    this.required = false,
    this.controller,
    this.isInputPassword = false,
    this.onSaved,
    this.validator,
    this.onChange,
    this.autoValidate = AutovalidateMode.disabled,
  });

  /// 表单标签名称
  ///
  /// ⚠️ 与 [hintText] 互斥，优先使用 [formLabel]
  final String? formLabel;

  /// 标签宽度
  final double? labelWidth;

  /// 输入框最大行数
  final int? maxLines;

  /// 输入框最小行数
  final int? minLines;

  /// 输入框与 formLabel 的间隔
  /// 默认值为 0
  final double labelSpacing;

  /// 提示文本
  final String? hintText;

  final Widget? prefixIcon;
  final IconData? prefixIconData;
  final Color? prefixIconColor;
  final Widget? suffixIcon;
  final IconData? suffixIconData;

  /// 输入内容是否必填
  ///
  /// 默认值为 false
  final bool required;

  /// 输入框控制器
  final TextEditingController? controller;

  /// 是否是输入密码
  ///
  /// 默认值为 false
  final bool isInputPassword;

  // 保存函数
  final Function(String)? onSaved;

  // 校验函数
  final String? Function(String?)? validator;

  // 输入框内容变化时的回调
  final Function(String)? onChange;

  /// 自动验证模式
  ///
  /// 默认为 [AutovalidateMode.disabled]，仅在调用 Form.validate() 时触发验证
  final AutovalidateMode autoValidate;

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  final FocusNode _focusNode = FocusNode();

  late TextEditingController controller;
  // 是否显示密码
  bool isShowPassword = false;

  @override
  void initState() {
    controller = widget.controller ?? TextEditingController();
    if (widget.isInputPassword) {
      isShowPassword = true;
    }
    super.initState();
  }

  @override
  void dispose() {
    // 只有内部创建的 controller 才需要 dispose，外部传入的由外部管理
    if (widget.controller == null) {
      controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  // 默认验证规则
  String? defaultValid(String? value) {
    if (widget.required && widget.validator != null) {
      return widget.validator!(controller.text);
    }
    if (widget.required != true) return null;
    if (controller.text.isEmpty) {
      if (widget.formLabel != null) return '${widget.formLabel}是必填项不能为空';
      return '这个字段是必填项';
    }
    return null;
  }

  // 输入内容变化
  void onInputChange(String val) {
    widget.onChange?.call(val);
    if (widget.isInputPassword) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      validator: widget.required ? defaultValid : null,
      autovalidateMode: widget.autoValidate,
      onSaved: (value) {
        widget.onSaved?.call(controller.text);
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: widget.labelSpacing,
          children: [
            SizedBox(
              child: Row(
                children: [
                  Text('${widget.formLabel}'),
                  if (state.hasError) Text('${state.errorText}', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            TextFormField(
              controller: controller,
              focusNode: _focusNode,
              onTapUpOutside: (event) => _focusNode.unfocus(),
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              onChanged: onInputChange,
              expands: false,
              decoration: InputDecoration(
                
                // 前置图标
                prefixIcon: PrefixIconLabel(
                  label: '${widget.formLabel}',
                  labelWidth: widget.labelWidth,
                  prefixIcon: widget.prefixIcon,
                  prefixIconData: widget.prefixIconData,
                  prefixIconColor: widget.prefixIconColor,
                  required: widget.required,
                ),
                prefixIconConstraints: BoxConstraints(minWidth: 20, minHeight: 20),
                // 后置图标
                suffixIcon: SuffixClearIcon(),
                suffixIconConstraints: BoxConstraints(minWidth: 20, minHeight: 20),
                contentPadding: EdgeInsets.all(0),
                // 添加边框
                border: OutlineInputBorder(),
                hintText: widget.hintText ?? (widget.formLabel != null ? '请输入${widget.formLabel}' : '请输入'),
              ),
            ),
          ],
        );
      },
    );
  }
}
