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

  /// 当前选中的值（单选模式）
  final V? value;

  /// 当前选中的值集合（多选模式）
  final Set<V>? values;

  /// 操作项列表
  final List<SelectItem<V, D>>? items;

  /// 已选中项的完整数据（用于弹窗回显，确保之前选中的项在列表中可见）
  ///
  /// 适用于编辑场景：当 items 为空或不包含已选值时（如 remote 模式），
  /// 传入此参数可确保已选项在弹窗中显示并标记为选中。
  final List<SelectItem<V, D>>? selectedItems;

  /// 占位提示文字
  final String? hintText;

  /// 是否必填
  final bool required;

  /// 是否为多选模式，默认 false（单选）
  final bool multiple;

  /// 单选回调（单选模式下使用）
  final OnSelectChange<V, D>? onSelect;

  /// 多选确认回调（多选模式下使用）
  final OnMultiSelectConfirm<V, D>? onConfirm;

  // 保存函数
  final Function(String)? onSaved;

  // 校验函数
  final String? Function(String?)? validator;

  /// 自动验证模式
  final AutovalidateMode autovalidateMode;

  /// 表单布局方式
  final FormLayout formLayout;

  /// 值显示模式，默认 [DisplayMode.text]
  ///
  /// - [DisplayMode.text]：单行文本，顿号分隔
  /// - [DisplayMode.tags]：每个值显示为 tag，横向滚动
  /// - [DisplayMode.compact]：显示前 N 个 tag，剩余以 "+M" 显示
  final DisplayMode displayMode;

  /// compact 模式下最多显示的 tag 数，默认 3
  final int maxShowTags;

  /// 自定义值显示 Widget 构建器
  ///
  /// 传入后优先使用此构建器，忽略 [displayMode] 的默认逻辑。
  /// [labels] 为当前所有选中值的 label 列表。
  final Widget Function(List<String> labels)? valueBuilder;

  const DropdownChoose({
    super.key,
    required this.formLabel,
    this.value,
    this.values,
    this.items,
    this.selectedItems,
    this.hintText,
    this.required = false,
    this.multiple = false,
    this.displayMode = DisplayMode.text,
    this.maxShowTags = 3,
    this.valueBuilder,
    this.onSelect,
    this.onConfirm,
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

  /// 获取所有选中值的 labels
  List<String> _getAllLabels() {
    final allItems = <SelectItem<V, D>>[...?widget.items, ...?widget.selectedItems];
    if (widget.multiple) {
      if (widget.values == null || widget.values!.isEmpty) return [];
      final labels = <String>[];
      for (final v in widget.values!) {
        for (final item in allItems) {
          if (item.value == v) {
            labels.add(item.label);
            break;
          }
        }
      }
      return labels;
    } else {
      if (widget.value == null) return [];
      for (final item in allItems) {
        if (item.value == widget.value) return [item.label];
      }
      return [];
    }
  }

  // 默认验证规则
  String? defaultValid(String? value) {
    if (widget.required != true) return null;
    if (widget.validator != null) {
      if (widget.multiple) {
        return widget.validator!((widget.values?.isEmpty ?? true) ? null : widget.values!.join(','));
      }
      return widget.validator!(widget.value?.toString());
    }
    if (widget.multiple) {
      if (widget.values == null || widget.values!.isEmpty) {
        return '${widget.formLabel}是必填项不能为空';
      }
    } else {
      if (widget.value == null) {
        return '${widget.formLabel}是必填项不能为空';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _formFieldKey,
      validator: widget.required ? defaultValid : null,
      autovalidateMode: widget.autovalidateMode,
      initialValue: widget.multiple ? (widget.values?.join(',') ?? '') : (widget.value?.toString() ?? ''),
      onSaved: (value) {
        if (widget.multiple) {
          widget.onSaved?.call(widget.values?.join(',') ?? '');
        } else {
          widget.onSaved?.call(widget.value?.toString() ?? '');
        }
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
              valueLabels: _getAllLabels(),
              displayMode: widget.displayMode,
              maxShowTags: widget.maxShowTags,
              valueBuilder: widget.valueBuilder,
              hintText: widget.hintText,
              onTap: () {
                SelectModal.show<V, D>(
                  context: context,
                  title: widget.formLabel,
                  items: widget.items,
                  multiple: widget.multiple,
                  selectedValues: widget.multiple ? widget.values : (widget.value != null ? {widget.value as V} : null),
                  selectedItems: widget.selectedItems,
                  onSelect: (value, data) {
                    widget.onSelect?.call(value, data);
                    _formFieldKey.currentState?.didChange(value?.toString() ?? '');
                  },
                  onConfirm: (values, datas) {
                    widget.onConfirm?.call(values, datas);
                    _formFieldKey.currentState?.didChange(values.join(','));
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
