import '../models/input_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputContent extends StatefulWidget {
  // 校验函数
  final String? Function(String?)? validator;
  // 是否必填
  final bool required;
  final bool isInputPassword;
  // label 标签
  final String? label;
  // formLabel 标签
  final String? formLabel;
  // layout 布局传递formLabel时生效
  final FormLayout formLayout;
  // 输入框控制器
  final TextEditingController? controller;
  // 保存函数
  final Function(String)? onSaved;
  // 输入框内容变化时的回调
  final Function(String)? onChange;
  // 输入框内容边距
  final EdgeInsetsGeometry? contentPadding;
  // 输入框填充颜色
  final Color? fillColor;
  // 输入框提示文字颜色
  final Color? hintTextColor;
  // 输入框提示文字大小
  final double? hintFontSize;
  // 输入框指针高度
  final double cursorHeight;
  // 是否显示浮动 label 标题
  final bool? showFloatingLabel;
  // 输入文字内容样式
  final TextStyle? contentStyle;
  // 浮动标签样式
  final TextStyle? labelStyle;
  //  提示文字样式
  final TextStyle? hintStyle;
  // 表单 label 文字样式
  final TextStyle? formLabelStyle;
  // 表单标题边距
  final EdgeInsetsGeometry? formLabelPadding;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final double fontSize;
  final FontWeight? fontWeight;
  final String? hintText;
  // 输入框圆角
  final double inputRadius;
  // 边框颜色
  final Color borderColor;
  // 聚焦边框颜色（不传则使用主题色）
  final Color? focusBorderColor;
  // 校验失败的提示颜色
  final Color errorColor;
  // 前置图标
  final Icon? prefixIcon;
  // 后置图标
  final Icon? suffixIcon;

  const InputContent({
    super.key,
    this.validator,
    this.required = false,
    this.isInputPassword = false,
    this.formLayout = FormLayout.column,
    this.label,
    this.formLabel,
    this.controller,
    this.onSaved,
    this.keyboardType,
    this.inputFormatters,
    this.fontSize = 18,
    this.fontWeight,
    this.hintText,
    this.inputRadius = 5,
    this.borderColor = const Color(0xFFE2E8F0),
    this.focusBorderColor,
    this.errorColor = const Color(0xFFEF4444),
    this.contentPadding,
    this.fillColor,
    this.hintTextColor,
    this.hintFontSize,
    this.cursorHeight = 20,
    this.showFloatingLabel = true,
    this.contentStyle,
    this.labelStyle,
    this.formLabelStyle,
    this.formLabelPadding,
    this.hintStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.onChange,
  });
  @override
  State<InputContent> createState() => _TextInputState();
}

class _TextInputState extends State<InputContent> {
  final FocusNode _focusNode = FocusNode();

  late TextEditingController controller;
  bool isShowPassword = true;
  FormFieldState<String>? state;

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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onSaved: (value) {
        widget.onSaved?.call(controller.text);
      },
      builder: (FormFieldState<String> state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...buildColumnLabel(state),
            TextFormField(
              obscureText: widget.isInputPassword ? isShowPassword : false,
              controller: controller,
              focusNode: _focusNode,
              onChanged: onInputChange,
              keyboardType: widget.keyboardType,
              cursorHeight: widget.cursorHeight,
              inputFormatters: widget.inputFormatters,
              onTapUpOutside: (event) => _focusNode.unfocus(),
              style: widget.contentStyle ?? TextStyle(color: Color(0xff333333), fontWeight: FontWeight.w500),
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                labelText: buildRowLabel(state),
                // 关键:启用浮动标签行为
                floatingLabelBehavior: handleFloatingLabelBehavior(),
                // 自定义浮动标签样式
                labelStyle: handleLabelStyle(hasError: state.hasError),
                hintText: widget.hintText ?? '请输入${widget.formLabel ?? ''}',
                hintStyle: widget.hintStyle ?? TextStyle(color: state.hasError ? widget.errorColor : widget.hintTextColor ?? Colors.grey, fontSize: widget.hintFontSize),
                prefixIcon: buildPrefixIcon(),
                prefixIconConstraints: BoxConstraints(minWidth: 40, minHeight: 40),
                suffixIcon: TextInputSuffixIcon(
                  suffixIcon: widget.suffixIcon,
                  isShowPassword: isShowPassword,
                  isInputPassword: widget.isInputPassword,
                  onHandle: onHandleSuffixIconEvent,
                  inputContent: controller.text,
                ),
                border: buildBorder(BorderType.border, hasError: state.hasError),
                enabledBorder: buildBorder(BorderType.enabledBorder, hasError: state.hasError),
                focusedBorder: buildBorder(BorderType.focusedBorder, hasError: state.hasError),
                filled: true,
                fillColor: widget.fillColor ?? Colors.white,
                contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              ),
            ),
          ],
        );
      },
    );
  }

  // 构建是否必填的 Column 布局的 label
  List<Widget> buildColumnLabel(FormFieldState<String> state) {
    if (widget.formLayout == FormLayout.row) return [];
    if (widget.formLabel?.isNotEmpty == true) {
      return [
        Padding(
          padding: widget.formLabelPadding ?? EdgeInsetsGeometry.only(top: 5, bottom: 2, left: 5),
          child: Row(
            spacing: 5,
            children: [
              if (widget.required) Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
              Text(
                widget.formLabel ?? '表单标题',
                style: widget.formLabelStyle ?? TextStyle(color: widget.hintTextColor, fontWeight: FontWeight.w500, fontSize: widget.hintFontSize),
              ),
              if (state.hasError) Text('${state.errorText}', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ];
    }

    return [];
  }

  // 构建是否必填的 Row 布局的 label
  String? buildRowLabel(FormFieldState<String> state) {
    if (widget.formLayout == FormLayout.column) return null;
    if (state.hasError) {
      return '${state.errorText}';
    }
    if (widget.required && widget.label?.isNotEmpty == true) {
      return '${widget.label}';
    }
    return null;
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

  // 构建浮动标签样式
  TextStyle? handleLabelStyle({bool hasError = false}) {
    return widget.labelStyle ?? TextStyle(color: hasError ? widget.errorColor : Color(0xff666666), fontWeight: FontWeight.w500);
  }

  // 构建边框
  InputBorder? buildBorder(BorderType type, {bool hasError = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.inputRadius),
      borderSide: BorderSide(
        color: hasError
            ? widget.errorColor
            : type == BorderType.focusedBorder
            ? widget.focusBorderColor ?? Theme.of(context).colorScheme.primary
            : widget.borderColor,
        width: 1.5,
      ),
    );
  }

  // 点击后置图标的事件
  void onHandleSuffixIconEvent(SuffixIconEvent event) {
    // 切换显示密码
    if (event == SuffixIconEvent.showPassword) {
      setState(() => isShowPassword = !isShowPassword);
    } else if (event == SuffixIconEvent.clear) {
      controller.text = '';
    }
  }

  // 构建前置图标区域
  Widget? buildPrefixIcon() {
    if (widget.formLabel != null && widget.prefixIcon != null && widget.formLayout == FormLayout.column) {
      return widget.prefixIcon ?? SizedBox.shrink();
    } else if (widget.formLabel != null && widget.prefixIcon == null && widget.formLayout == FormLayout.column || widget.formLabel == null && widget.prefixIcon == null) {
      return null;
    }
    return Padding(
      padding: EdgeInsetsGeometry.only(left: 15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          if (widget.required && widget.formLabel != null && widget.formLayout == FormLayout.row) Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
          // 是否显示前置图标
          widget.prefixIcon ?? SizedBox.shrink(),
          if (widget.formLabel != null && widget.formLayout == FormLayout.row) ...[
            Text('${widget.formLabel}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(
              height: 18,
              child: Padding(
                padding: EdgeInsetsGeometry.only(left: 5),
                child: VerticalDivider(width: 1, thickness: 1, color: const Color(0xFF999999)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 输入框前置图标区域
class TextInputPrefixIcon extends StatelessWidget {
  final Icon? prefixIcon;
  final String? formLabel;
  final bool required;
  final FormLayout formLayout;

  const TextInputPrefixIcon({super.key, this.prefixIcon, this.formLabel, this.required = false, this.formLayout = FormLayout.row});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(left: 15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          if (required && formLabel != null && formLayout == FormLayout.row) Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
          // 是否显示前置图标
          prefixIcon ?? SizedBox.shrink(),
          if (formLabel != null && formLayout == FormLayout.row) ...[
            Text('$formLabel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(
              height: 18,
              child: Padding(
                padding: EdgeInsetsGeometry.only(left: 5),
                child: VerticalDivider(width: 1, thickness: 1, color: const Color(0xFF999999)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 输入框后置图标区域
class TextInputSuffixIcon extends StatelessWidget {
  final Icon? suffixIcon;
  final String? formLabel;
  final String? inputContent;
  final bool showClose;
  final bool isInputPassword;
  final Function(SuffixIconEvent event)? onHandle;
  final bool isShowPassword;

  const TextInputSuffixIcon({
    super.key,
    this.suffixIcon,
    this.formLabel,
    this.showClose = true,
    this.isInputPassword = false,
    this.inputContent,
    this.onHandle,
    this.isShowPassword = false,
  });
  @override
  Widget build(BuildContext context) {
    if (isInputPassword) {
      return GestureDetector(
        onTap: () => onHandle?.call(SuffixIconEvent.showPassword),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(isShowPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: const Color(0xFF94A3B8)),
        ),
      );
    } else if (suffixIcon != null) {
      return InkWell(
        // 点击后置图标
        onTap: () => onHandle?.call(SuffixIconEvent.onTap),
        child: suffixIcon!,
      );
    } else if (inputContent?.isNotEmpty == true) {
      return GestureDetector(
        onTap: () => onHandle?.call(SuffixIconEvent.clear),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
