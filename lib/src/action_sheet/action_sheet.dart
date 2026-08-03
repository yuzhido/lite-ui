import 'package:flutter/material.dart';
import 'package:lite_ui/src/models/index.dart';
import 'package:lite_ui/src/theme/index.dart';

import '../wrapper_container/index.dart';
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
class ActionSheet<V, D> extends StatefulWidget {
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
  final List<SheetSection<V, D>>? sections;

  /// 取消按钮文字，默认为「取消」
  final String cancelLabel;

  /// 是否显示禁用项标签，默认 false
  final bool showDisabledBadge;

  /// 是否显示选中状态标记，默认 true
  final bool showCheckMark;

  /// 自定义最大高度（覆盖默认的 75%）
  final double? maxHeight;

  /// 占位提示文字（未选中时显示）
  final String? hintText;

  /// 是否必填
  ///
  /// 默认值：false
  final bool required;

  // 保存函数
  final Function(String)? onSaved;

  /// 选中回调
  final OnSelectChange<V, D>? onSelect;

  // 校验函数
  final String? Function(String?)? validator;

  /// 自动验证模式
  ///
  /// 默认为 [AutovalidateMode.disabled]，仅在调用 Form.validate() 时触发验证
  final AutovalidateMode autovalidateMode;

  /// 表单布局方式
  final FormLayout formLayout;

  /// 前置图标
  final Widget? prefixIcon;

  /// 直接显示默认图标数据
  final IconData? prefixIconData;

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
    this.showCheckMark = true,
    this.maxHeight,
    this.hintText,
    this.onSelect,
    this.required = false,
    this.onSaved,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.formLayout = FormLayout.row,
    this.prefixIcon,
    this.prefixIconData,
  });

  /// 显示一个从底部向上弹出的 ActionSheet
  ///
  /// [title] 主标题
  /// [description] 副标题/描述
  /// [items] 操作项列表
  /// [sections] 分组数据（优先于 items）
  /// [cancelLabel] 取消按钮文字，默认为「取消」
  /// [showDisabledBadge] 是否显示禁用项标签，默认 false
  /// [showCheckMark] 是否显示选中状态标记，默认 true
  /// [maxHeight] 自定义最大高度（覆盖默认的 75%）
  /// [isDismissible] 点击遮罩是否可关闭，默认 true
  /// [barrierColor] 遮罩颜色
  static Future<V?> show<V, D>({
    required BuildContext context,
    String? title,
    String? description,
    List<SelectItem<V, D>>? items,
    List<SheetSection<V, D>>? sections,
    String cancelLabel = '取消',
    bool showDisabledBadge = false,
    bool showCheckMark = true,
    V? selectedValue,
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
          showCheckMark: showCheckMark,
          selectedValue: selectedValue,
          maxHeight: maxHeight,
          onSelect: (value, item, data) {
            onSelect?.call(value, item, data);
            Navigator.of(ctx).pop(value);
          },
          cancelLabel: cancelLabel,
        );
      },
    );
  }

  @override
  State<ActionSheet<V, D>> createState() => _ActionSheetState<V, D>();
}

class _ActionSheetState<V, D> extends State<ActionSheet<V, D>> {
  final _formFieldKey = GlobalKey<FormFieldState<String>>();

  /// 内部选中值（统一由组件内部管理，widget.value 仅作为初始值和外部同步参考）
  V? _internalValue;

  /// 内部选中的完整 SelectItem（用于 WrapperContainer 的 selectItems 显示）
  SelectItem<V, D>? _selectItem;

  /// 获取当前生效的选中值
  V? get _effectiveValue => _internalValue;

  /// 从 items 或 sections 中根据 value 查找对应的 SelectItem
  SelectItem<V, D>? _findItem(V? value) {
    if (value == null) return null;
    if (widget.sections != null) {
      for (final section in widget.sections!) {
        for (final item in section.items) {
          if (item.value == value) return item;
        }
      }
    }
    if (widget.items != null) {
      for (final item in widget.items!) {
        if (item.value == value) return item;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _internalValue = widget.value;
    _selectItem = _findItem(widget.value);
  }

  @override
  void didUpdateWidget(covariant ActionSheet<V, D> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _internalValue = widget.value;
      _selectItem = _findItem(widget.value);
    }
  }

  void _showSheet(BuildContext context) {
    ActionSheet.show<V, D>(
      context: context,
      title: widget.title,
      description: widget.description,
      items: widget.items,
      sections: widget.sections,
      cancelLabel: widget.cancelLabel,
      showDisabledBadge: widget.showDisabledBadge,
      showCheckMark: widget.showCheckMark,
      selectedValue: _effectiveValue,
      maxHeight: widget.maxHeight,
      onSelect: (value, item, data) {
        widget.onSelect?.call(value, item, data);
        setState(() {
          _internalValue = value;
          _selectItem = item;
        });
        // 同步选中值到 FormField
        _formFieldKey.currentState?.didChange(value?.toString() ?? '');
      },
    );
  }

  /// 从 items 或 sections 中匹配 value 对应的 label
  String? _matchLabel() {
    final effectiveVal = _effectiveValue;
    if (effectiveVal == null) return null;
    // 优先从 sections 匹配
    if (widget.sections != null) {
      for (final section in widget.sections!) {
        for (final item in section.items) {
          if (item.value == effectiveVal) return item.label;
        }
      }
    }
    // 从 items 匹配
    if (widget.items != null) {
      for (final item in widget.items!) {
        if (item.value == effectiveVal) return item.label;
      }
    }
    return null;
  }

  // 默认验证规则
  String? defaultValid(String? value) {
    if (widget.required != true) return null;
    // 优先使用自定义 validator
    if (widget.validator != null) {
      return widget.validator!(_effectiveValue?.toString());
    }
    // 直接检查当前生效值是否有值（和 InputText 读 controller.text 同理）
    if (_effectiveValue == null) {
      if (widget.formLabel != null) return '${widget.formLabel}是必选项不能为空';
      return '这个字段是必选项';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _formFieldKey,
      validator: widget.required ? defaultValid : null,
      autovalidateMode: widget.autovalidateMode,
      initialValue: _effectiveValue?.toString() ?? '',
      onSaved: (value) {
        widget.onSaved?.call(_effectiveValue?.toString() ?? '');
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
                    Text('${widget.formLabel}'),
                    if (state.hasError) Text('${state.errorText}', style: TextStyle(color: LiteUITheme.of(context).errorColor)),
                  ],
                ),
              ),
            WrapperContainer(
              selectItems: _selectItem != null ? [_selectItem!] : [],
              formLayout: widget.formLayout,
              errorText: state.errorText,
              required: widget.required,
              prefixIcon: widget.prefixIcon,
              prefixIconData: widget.prefixIconData,
              formLabel: widget.formLabel,
              valueText: _matchLabel(),
              hintText: widget.hintText,
              onTap: () => _showSheet(context),
              onClear: () {
                setState(() {
                  _internalValue = null;
                  _selectItem = null;
                });
                _formFieldKey.currentState?.didChange('');
              },
            ),
          ],
        );
      },
    );
  }
}
