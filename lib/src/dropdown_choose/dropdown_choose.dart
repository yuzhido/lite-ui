import 'package:flutter/material.dart';
import 'package:lite_ui/src/models/enum.dart';
import 'package:lite_ui/src/models/select_item.dart';
import 'package:lite_ui/src/models/callbacks.dart';
import 'package:lite_ui/src/select_modal/select_modal.dart';
import 'package:lite_ui/src/theme/index.dart';

import '../wrapper_container/index.dart';

class DropdownChoose<V, D> extends StatefulWidget {
  /// 表单标签
  final String formLabel;

  /// 当前选中的值（受控模式）
  final V? value;

  /// 操作项列表
  final List<SelectItem<V, D>>? items;

  /// 占位提示文字
  final String? hintText;

  /// 是否必填
  final bool required;

  /// 选中回调
  final OnSelectChange<V, D>? onSelect;

  // 保存函数
  final Function(String)? onSaved;

  // 校验函数
  final String? Function(String?)? validator;

  /// 自动验证模式
  final AutovalidateMode autovalidateMode;

  /// 表单布局方式
  final FormLayout formLayout;
  const DropdownChoose({
    super.key,
    required this.formLabel,
    this.value,
    this.items,
    this.hintText,
    this.required = false,
    this.onSelect,
    this.onSaved,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.formLayout = FormLayout.row,
  });

  @override
  State<DropdownChoose<V, D>> createState() => _DropdownChooseState<V, D>();
}

class _DropdownChooseState<V, D> extends State<DropdownChoose<V, D>> {
  final _formFieldKey = GlobalKey<FormFieldState<String>>();

  /// 从 items 中匹配 value 对应的 label
  String? _matchLabel() {
    if (widget.value == null) return null;
    if (widget.items != null) {
      for (final item in widget.items!) {
        if (item.value == widget.value) return item.label;
      }
    }
    return null;
  }

  // 默认验证规则
  String? defaultValid(String? value) {
    if (widget.required != true) return null;
    if (widget.validator != null) {
      return widget.validator!(widget.value?.toString());
    }
    if (widget.value == null) {
      return '${widget.formLabel}是必填项不能为空';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _formFieldKey,
      validator: widget.required ? defaultValid : null,
      autovalidateMode: widget.autovalidateMode,
      initialValue: widget.value?.toString() ?? '',
      onSaved: (value) {
        widget.onSaved?.call(widget.value?.toString() ?? '');
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            if (widget.formLayout == FormLayout.column)
              SizedBox(
                child: Row(
                  spacing: 5,
                  children: [
                    Text(widget.formLabel),
                    if (state.hasError) Text('${state.errorText}', style: TextStyle(color: LiteUITheme.of(context).errorColor)),
                  ],
                ),
              ),
            WrapperContainer(
              formLayout: widget.formLayout,
              errorText: state.errorText,
              required: widget.required,
              formLabel: widget.formLabel,
              valueText: _matchLabel(),
              hintText: widget.hintText,
              onTap: () {
                SelectModal.show<V, D>(
                  context: context,
                  items: widget.items,
                  onSelect: (value, data) {
                    widget.onSelect?.call(value, data);
                    // 同步选中值到 FormField
                    _formFieldKey.currentState?.didChange(value?.toString() ?? '');
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
