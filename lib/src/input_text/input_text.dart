import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/enum.dart';
import '../theme/index.dart';
import '../widgets/border_builder.dart';
import '../widgets/prefix_icon_label.dart';
import 'models/enum.dart';
import 'ui/clear_icon.dart';
import 'utils/input_format.dart';
import 'utils/valid_rules.dart';

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
    this.password = false,
    this.onSaved,
    this.validator,
    this.onChange,
    this.autoValidate = AutovalidateMode.disabled,
    this.formLayout = FormLayout.row,
    this.onSuffixIconTap,
    this.showFloatingLabel = true,
    this.labelStyle,
    this.errorColor,
    this.hintStyle,
    this.hintTextColor,
    this.hintFontSize,
    this.inputRadius,
    this.borderColor,
    this.focusBorderColor,
    this.label,
    this.inputType = InputType.text,
    this.validRuleType = ValidRuleType.custom,
    this.minLen,
    this.maxLen,
    this.validRules,
    this.keyboardType,
    this.inputFormatters,
  });
  // label 标签
  final String? label;
  // 边框颜色（不传则使用 LiteUITheme 默认值）
  final Color? borderColor;
  // 聚焦边框颜色（不传则使用 LiteUITheme 默认值，仍为 null 则使用系统主题色）
  final Color? focusBorderColor;
  // 输入框圆角（不传则使用 LiteUITheme 默认值）
  final double? inputRadius;
  // 输入框提示文字颜色
  final Color? hintTextColor;
  // 输入框提示文字大小
  final double? hintFontSize;
  //  提示文字样式
  final TextStyle? hintStyle;
  // 校验失败的提示颜色（不传则使用 LiteUITheme 默认值）
  final Color? errorColor;
  // 浮动标签样式
  final TextStyle? labelStyle;

  /// 是否显示浮动 label 标题
  ///
  /// 默认值为 true
  final bool? showFloatingLabel;

  /// 表单标签名称
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

  /// 输入内容是否必填（控制红色星号 * 显示）
  ///
  /// 默认值为 false
  final bool required;

  /// 输入类型
  ///
  /// 控制用户只能输入指定类型的内容，底层通过 [TextInputFormatter] 实时拦截非法字符。
  /// 默认值为 [InputType.text]
  final InputType inputType;

  /// 校验规则类型
  ///
  /// 默认值为 [ValidRuleType.none]，一个枚举值搞定常见校验
  final ValidRuleType validRuleType;

  /// 最小长度（配合 validRuleType 使用）
  final int? minLen;

  /// 最大长度（配合 validRuleType 使用）
  final int? maxLen;

  /// 自定义校验规则列表
  ///
  /// 仅当 [validRuleType] 为 [ValidRuleType.custom] 时生效
  final List<String? Function(String?)>? validRules;
  final TextEditingController? controller;

  /// 是否是输入密码
  ///
  /// 默认值为 false
  final bool password;

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

  /// 后置图标点击时的回调
  final Function(SuffixIconEvent)? onSuffixIconTap;

  /// 表单布局
  ///
  /// 默认值为 [FormLayout.row]
  final FormLayout formLayout;

  /// 键盘类型
  final TextInputType? keyboardType;

  /// 输入格式化器（用于限制输入内容，如只允许数字）
  final List<TextInputFormatter>? inputFormatters;

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
    if (widget.password) {
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

  // 组合校验：根据 validRuleType 枚举自动构建规则列表
  // 注意：必须读 controller.text（真实数据源），FormField 的 value 参数不会自动同步
  String? defaultValid(String? value) {
    final text = controller.text;
    final rules = <String? Function(String?)>[];

    // required: true 时添加必填校验
    if (widget.required) {
      rules.add((v) => ValidRules.required(v, message: widget.formLabel != null ? '${widget.formLabel}是必填项不能为空' : '这个字段是必填项'));
    }

    // 根据 validRuleType 添加格式校验（custom 类型只使用 validRules）
    final typeRules = ValidRules.buildRules(type: widget.validRuleType, formLabel: widget.formLabel, minLen: widget.minLen, maxLen: widget.maxLen, customRules: widget.validRules);
    rules.addAll(typeRules);

    // 自定义 validator 最后执行
    if (widget.validator != null) {
      rules.add(widget.validator!);
    }
    if (rules.isEmpty) return null;
    return ValidRules.compose(text, rules);
  }

  // 输入内容变化
  void onInputChange(String val) {
    widget.onChange?.call(val);
    if (widget.password) return;
  }

  // 后置图标区域点击事件
  void onSuffixAreaTap(SuffixIconEvent event) {
    widget.onSuffixIconTap?.call(event);
    if (event == SuffixIconEvent.clear) {
      controller.clear();
    } else if (event == SuffixIconEvent.showPassword) {
      setState(() => isShowPassword = !isShowPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    // required 或 validRuleType 非 custom 时都启用校验
    final hasValidation = widget.required || widget.validRuleType != ValidRuleType.custom;
    return FormField(
      validator: hasValidation ? defaultValid : null,
      autovalidateMode: widget.autoValidate,
      onSaved: (value) {
        widget.onSaved?.call(controller.text);
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: widget.labelSpacing,
          children: [
            if (widget.formLayout == FormLayout.column)
              SizedBox(
                child: Row(
                  spacing: 5,
                  children: [
                    Text('${widget.formLabel}'),
                    if (state.hasError) Text('${state.errorText}', style: TextStyle(color: LiteUITheme.of(context).errorColor)),
                  ],
                ),
              ),
            TextFormField(
              controller: controller,
              obscureText: widget.password ? isShowPassword : false,
              focusNode: _focusNode,
              onTapUpOutside: (event) => _focusNode.unfocus(),
              maxLines: widget.maxLines ?? 1,
              minLines: widget.minLines,
              onChanged: onInputChange,
              expands: false,
              keyboardType: widget.keyboardType,
              inputFormatters: [...InputFormat.getFormatters(widget.inputType), if (widget.inputFormatters != null) ...widget.inputFormatters!],
              decoration: InputDecoration(
                label: (widget.formLayout == FormLayout.column)
                    ? null
                    : state.hasError
                    ? Text('${state.errorText}')
                    : (widget.required && widget.label?.isNotEmpty == true)
                    ? Text('${widget.label}')
                    : null,
                // 关键:启用浮动标签行为
                floatingLabelBehavior: handleFloatingLabelBehavior(),
                // 自定义浮动标签样式
                labelStyle:
                    widget.labelStyle ??
                    TextStyle(
                      // 颜色
                      color: state.hasError ? (widget.errorColor ?? LiteUITheme.of(context).errorColor) : LiteUITheme.of(context).hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                hintText: state.hasError ? state.errorText : widget.hintText ?? '请输入${widget.formLabel ?? ''}',

                hintStyle:
                    widget.hintStyle ??
                    TextStyle(
                      color: state.hasError ? (widget.errorColor ?? LiteUITheme.of(context).errorColor) : widget.hintTextColor ?? Colors.grey,
                      fontSize: widget.hintFontSize,
                    ),
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
                suffixIcon: ClearIcon(
                  isShowPassword: isShowPassword,
                  password: widget.password,
                  onTap: onSuffixAreaTap,
                  hasValue: controller.text.isNotEmpty == true,
                  suffixIcon: widget.suffixIcon,
                  suffixIconData: widget.suffixIconData,
                ),
                suffixIconConstraints: BoxConstraints(minWidth: 20, minHeight: 20),
                contentPadding: EdgeInsets.all(0),
                // 添加边框
                border: buildInputOutlineBorder(
                  type: BorderType.border,
                  borderRadius: widget.inputRadius,
                  borderColor: widget.borderColor,
                  focusBorderColor: widget.focusBorderColor,
                  errorColor: widget.errorColor,
                  hasError: state.hasError,
                  context: context,
                ),
                enabledBorder: buildInputOutlineBorder(
                  type: BorderType.enabledBorder,
                  borderRadius: widget.inputRadius,
                  borderColor: widget.borderColor,
                  focusBorderColor: widget.focusBorderColor,
                  errorColor: widget.errorColor,
                  hasError: state.hasError,
                  context: context,
                ),
                focusedBorder: buildInputOutlineBorder(
                  type: BorderType.focusedBorder,
                  borderRadius: widget.inputRadius,
                  borderColor: widget.borderColor,
                  focusBorderColor: widget.focusBorderColor,
                  errorColor: widget.errorColor,
                  hasError: state.hasError,
                  context: context,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 构建是否显示浮动 label
  FloatingLabelBehavior? handleFloatingLabelBehavior() {
    if (widget.formLayout == FormLayout.column && widget.formLabel?.isNotEmpty == true) {
      return FloatingLabelBehavior.never;
    } else if (widget.formLayout == FormLayout.column && widget.formLabel?.isEmpty == true) {
      return FloatingLabelBehavior.always;
    }
    if (widget.showFloatingLabel == true) return FloatingLabelBehavior.always;
    return FloatingLabelBehavior.never;
  }
}
