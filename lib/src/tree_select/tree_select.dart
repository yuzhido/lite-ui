import 'package:flutter/material.dart';
import 'package:lite_ui/src/models/enum.dart';
import 'package:lite_ui/src/models/select_item.dart';
import 'package:lite_ui/src/widgets/keyword_highlight.dart';
import 'package:lite_ui/src/wrapper_container/index.dart';

import 'models/index.dart';
import 'utils/index.dart';
import 'ui/tree_select_content.dart';

/// 树形选择表单组件
///
/// 提供默认的表单字段 UI（标签 + 值展示 + 清除图标），
/// 点击后弹出底部树形选择面板，对齐 [DropdownChoose] 的使用模式。
///
/// 支持单选和多选模式，集成 FormField 实现表单校验与保存。
///
/// ```dart
/// TreeSelect<String>(
///   formLabel: '部门',
///   treeData: treeData,
///   multiple: false,
///   onSelect: (node) => print(node.label),
/// )
/// ```
class TreeSelect<T extends Object> extends StatefulWidget {
  /// 表单标签
  final String formLabel;

  /// 表单副标题
  final String? subTitle;

  /// 占位提示文字
  final String? hintText;

  /// 是否必填
  final bool required;

  /// 是否为多选模式，默认 false（单选）
  final bool multiple;

  /// 树形数据源
  final List<TreeNode<T>> treeData;

  /// 初始/外部选中的节点ID集合
  final Set<T> selectedIds;

  /// 是否允许选中父节点，默认 false
  final bool parentSelectable;

  /// 是否显示搜索框，默认 true
  final bool showSearch;

  /// 搜索框提示文字
  final String searchHint;

  /// 空状态提示文字
  final String emptyText;

  /// 懒加载子节点回调
  final TreeNodeLoadChildrenCallback<T>? onLoadChildren;

  /// 关键字高亮样式配置
  final KeywordHighlightStyle? highlightStyle;

  /// 弹窗主标题
  final String? title;

  /// 取消按钮文字
  final String cancelLabel;

  /// 确定按钮文字
  final String confirmLabel;

  /// 搜索按钮背景色
  final Color? searchButtonColor;

  /// 搜索按钮文字/图标颜色
  final Color? searchButtonTextColor;

  /// 确认按钮背景色
  final Color? confirmButtonColor;

  /// 确认按钮文字/图标颜色
  final Color? confirmButtonTextColor;

  /// 取消按钮文字/边框颜色
  final Color? cancelButtonColor;

  // ── 表单相关 ──

  /// 校验函数
  ///
  /// 返回 null 表示验证通过，返回字符串表示验证失败的提示文字。
  final String? Function(String?)? validator;

  /// 自动验证模式
  final AutovalidateMode autovalidateMode;

  /// 保存函数
  final Function(String)? onSaved;

  /// 表单布局方式
  final FormLayout formLayout;

  /// 前置图标
  final Widget? prefixIcon;

  /// 直接显示默认图标数据
  final IconData? prefixIconData;

  /// 值显示模式，默认 [DisplayMode.text]
  final DisplayMode displayMode;

  /// compact 模式下最多显示的 tag 数
  final int? maxShowTags;

  /// 自定义值显示 Widget 构建器
  ///
  /// 传入后优先使用此构建器，忽略 [displayMode] 的默认逻辑。
  /// 参数为当前选中的节点列表。
  final Widget Function(List<TreeNode<T>> nodes)? valueBuilder;

  // ── 回调 ──

  /// 选中回调（单选模式下点击项时触发，弹窗自动关闭）
  final TreeNodeTapCallback<T>? onSelect;

  /// 多选确认回调（多选模式下点击「确定」时触发）
  final TreeNodeSelectCallback<T>? onConfirm;

  /// 点击清除图标回调
  final VoidCallback? onClear;

  const TreeSelect({
    super.key,
    required this.formLabel,
    required this.treeData,
    this.subTitle,
    this.hintText,
    this.required = false,
    this.multiple = false,
    this.selectedIds = const {},
    this.parentSelectable = false,
    this.showSearch = true,
    this.searchHint = '搜索...',
    this.emptyText = '暂无数据',
    this.onLoadChildren,
    this.highlightStyle,
    this.title,
    this.cancelLabel = '取消',
    this.confirmLabel = '确定',
    this.searchButtonColor,
    this.searchButtonTextColor,
    this.confirmButtonColor,
    this.confirmButtonTextColor,
    this.cancelButtonColor,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onSaved,
    this.formLayout = FormLayout.row,
    this.prefixIcon,
    this.displayMode = DisplayMode.text,
    this.maxShowTags,
    this.valueBuilder,
    this.onSelect,
    this.onConfirm,
    this.onClear,
    this.prefixIconData,
  }) : assert(onConfirm == null || multiple, '单选模式不支持 onConfirm，onConfirm 仅在多选模式下有效'),
       assert(maxShowTags == null || displayMode == DisplayMode.compact, 'maxShowTags 仅在 displayMode 为 compact 时有效'),
       assert(displayMode != DisplayMode.compact || multiple, 'compact 模式仅支持多选');

  @override
  State<TreeSelect<T>> createState() => _TreeSelectFieldState<T>();
}

class _TreeSelectFieldState<T extends Object> extends State<TreeSelect<T>> {
  final _formFieldKey = GlobalKey<FormFieldState<String>>();

  /// 单选模式下缓存的选中节点
  TreeNode<T>? _selectedNode;

  /// 多选模式下缓存的选中节点列表
  List<TreeNode<T>> _selectedNodes = [];

  /// 弹窗是否展开
  bool _isExpanded = false;

  /// 是否已内部清除（点击后缀 clear 图标后置为 true）
  bool _cleared = false;

  @override
  void initState() {
    super.initState();
    _syncFromExternalIds();
  }

  @override
  void didUpdateWidget(covariant TreeSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final idsChanged = widget.selectedIds != oldWidget.selectedIds;
    final dataChanged = !identical(widget.treeData, oldWidget.treeData);

    if (idsChanged) {
      // 外部 selectedIds 真正变化时，以外部值为准同步内部状态
      _cleared = false;
      _syncFromExternalIds();
      final newValue = _getValidationValue();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _formFieldKey.currentState?.didChange(newValue);
      });
    } else if (dataChanged) {
      // 仅 treeData 变化时，基于当前内部选中状态重新查找节点
      _syncFromExternalIds();
    }
  }

  /// 从外部 selectedIds 同步内部选中节点
  void _syncFromExternalIds() {
    if (widget.selectedIds.isEmpty) {
      _selectedNode = null;
      _selectedNodes = [];
      return;
    }
    final nodes = TreeUtils.getSelectedNodes(widget.treeData, widget.selectedIds);
    if (widget.multiple) {
      _selectedNodes = nodes;
    } else {
      _selectedNode = nodes.isNotEmpty ? nodes.first : null;
    }
  }

  /// 获取用于校验/保存的值（基于内部最新状态）
  String _getValidationValue() {
    if (_cleared) return '';
    if (widget.multiple) {
      return _selectedNodes.map((e) => e.id.toString()).join(',');
    }
    return _selectedNode != null ? _selectedNode!.id.toString() : '';
  }

  /// 将选中节点转为 SelectItem 列表供 WrapperContainer 显示
  List<SelectItem<T, TreeNode<T>>> _toSelectItems() {
    if (_cleared) return [];
    if (widget.multiple) {
      return _selectedNodes.map((node) => SelectItem<T, TreeNode<T>>(value: node.id, label: node.label, data: node)).toList();
    }
    return _selectedNode != null ? [SelectItem<T, TreeNode<T>>(value: _selectedNode!.id, label: _selectedNode!.label, data: _selectedNode)] : [];
  }

  /// 弹窗打开时应使用的选中ID集合
  Set<T> _modalSelectedIds() {
    if (_cleared) return {};
    if (widget.multiple) {
      return _selectedNodes.map((e) => e.id).toSet();
    }
    return _selectedNode != null ? {_selectedNode!.id} : {};
  }

  // 默认验证规则
  String? defaultValid(String? value) {
    if (!widget.required) return null;
    if (_cleared) {
      if (widget.validator != null) return widget.validator?.call(null);
      return '${widget.formLabel}是必选项不能为空';
    }
    final validationValue = _getValidationValue();
    if (widget.validator != null) {
      return widget.validator!(validationValue.isEmpty ? null : validationValue);
    }
    if (validationValue.isEmpty) {
      return '${widget.formLabel}是必选项不能为空';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      key: _formFieldKey,
      validator: widget.required ? defaultValid : null,
      autovalidateMode: widget.autovalidateMode,
      initialValue: _getValidationValue(),
      onSaved: (value) {
        widget.onSaved?.call(_getValidationValue());
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
                    if (state.hasError) Text('${state.errorText}', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                ),
              ),
            WrapperContainer<T, TreeNode<T>>(
              selectItems: _toSelectItems(),
              formLayout: widget.formLayout,
              errorText: state.errorText,
              required: widget.required,
              prefixIcon: widget.prefixIcon,
              prefixIconData: widget.prefixIconData,
              formLabel: widget.formLabel,
              displayMode: widget.displayMode,
              maxShowTags: widget.maxShowTags ?? 1,
              valueBuilder: widget.valueBuilder != null ? (items) => widget.valueBuilder!(_selectedNodes) : null,
              hintText: widget.hintText,
              isExpanded: _isExpanded,
              onClear: () {
                setState(() {
                  _cleared = true;
                  _selectedNode = null;
                  _selectedNodes = [];
                });
                widget.onClear?.call();
              },
              onTap: () {
                setState(() => _isExpanded = true);
                _openModal().then((_) {
                  if (mounted) setState(() => _isExpanded = false);
                });
              },
            ),
          ],
        );
      },
    );
  }

  /// 打开树形选择弹窗
  Future<void> _openModal() async {
    final screenHeight = MediaQuery.of(context).size.height;

    if (widget.multiple) {
      // 多选模式
      final result = await showModalBottomSheet<List<TreeNode<T>>>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) {
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.75, minHeight: screenHeight * 0.5),
              child: TreeModalContent<T>(
                treeData: widget.treeData,
                title: widget.title ?? '请选择${widget.formLabel}',
                searchHint: widget.searchHint,
                emptyText: widget.emptyText,
                showSearch: widget.showSearch,
                multiple: true,
                parentSelectable: widget.parentSelectable,
                selectedIds: _modalSelectedIds(),
                onLoadChildren: widget.onLoadChildren,
                cancelLabel: widget.cancelLabel,
                confirmLabel: widget.confirmLabel,
                highlightStyle: widget.highlightStyle,
                searchButtonColor: widget.searchButtonColor,
                searchButtonTextColor: widget.searchButtonTextColor,
                confirmButtonColor: widget.confirmButtonColor,
                confirmButtonTextColor: widget.confirmButtonTextColor,
                cancelButtonColor: widget.cancelButtonColor,
                onConfirm: (nodes) {
                  _selectedNodes = nodes;
                  widget.onConfirm?.call(nodes);
                },
              ),
            ),
          );
        },
      );
      // 弹窗关闭后，有返回值说明用户点击了确定
      if (result != null && mounted) {
        setState(() => _cleared = false);
      }
    } else {
      // 单选模式
      final selectedNode = await showModalBottomSheet<TreeNode<T>>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) {
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.75, minHeight: screenHeight * 0.5),
              child: TreeModalContent<T>(
                treeData: widget.treeData,
                title: widget.title ?? '请选择${widget.formLabel}',
                searchHint: widget.searchHint,
                emptyText: widget.emptyText,
                showSearch: widget.showSearch,
                multiple: false,
                parentSelectable: widget.parentSelectable,
                selectedIds: _modalSelectedIds(),
                onLoadChildren: widget.onLoadChildren,
                cancelLabel: widget.cancelLabel,
                confirmLabel: widget.confirmLabel,
                highlightStyle: widget.highlightStyle,
                searchButtonColor: widget.searchButtonColor,
                searchButtonTextColor: widget.searchButtonTextColor,
                confirmButtonColor: widget.confirmButtonColor,
                confirmButtonTextColor: widget.confirmButtonTextColor,
                cancelButtonColor: widget.cancelButtonColor,
                onSelect: (node) {
                  widget.onSelect?.call(node);
                },
              ),
            ),
          );
        },
      );
      // 弹窗关闭后统一更新状态
      if (selectedNode != null && mounted) {
        setState(() {
          _selectedNode = selectedNode;
          _cleared = false;
        });
      }
    }
  }
}
