import 'package:flutter/material.dart';
import 'package:lite_ui/src/models/enum.dart';
import 'package:lite_ui/src/models/select_item.dart';
import 'package:lite_ui/src/models/callbacks.dart';
import 'package:lite_ui/src/dropdown_choose/models/index.dart';
import 'package:lite_ui/src/dropdown_choose/ui/select_modal_content.dart';
import 'package:lite_ui/src/theme/index.dart';

import '../wrapper_container/index.dart';

class DropdownChoose<V, D> extends StatefulWidget {
  /// 表单标签
  final String formLabel;

  /// 当前选中的值（单选模式）
  final V? value;

  /// 当前选中的值集合（多选模式）
  final Set<V>? selectedValues;

  /// 操作项列表
  final List<SelectItem<V, D>>? items;

  /// 前置图标
  final Widget? prefixIcon;

  /// 已选中项的完整数据（用于「查看已选」弹窗回显 label）
  ///
  /// 适用于编辑场景：当后端返回完整数据时传入，确保查看已选时能显示 label。
  /// 与 selectedValues 同时传递时，长度必须相等。
  final List<SelectItem<V, D>>? selectedItems;

  /// 占位提示文字
  final String? hintText;

  /// 是否必填
  final bool required;

  /// 是否为多选模式，默认 false（单选）
  final bool multiple;

  /// 选择器模式，默认 [SelectModalType.filterable]（本地过滤）
  ///
  /// - [SelectModalType.filterable]：本地过滤选择器（直接传 items，组件内部过滤）
  /// - [SelectModalType.remote]：远程搜索选择器（传 onRemoteSearch 异步搜索）
  final SelectModalType type;

  /// 远程搜索回调（remote 模式下必填），搜索时调用远程接口而非本地过滤
  final RemoteSearchCallback<V, D>? onRemoteSearch;

  /// 选中回调（单选/多选模式下点击项时均触发）
  ///
  /// 单选模式：触发后弹窗自动关闭
  /// 多选模式：仅切换勾选状态，不关闭弹窗（最终确认由 [onConfirm] 处理）
  final OnSelectChange<V, D>? onSelect;

  /// 多选确认回调（多选模式下使用）
  final OnMultiSelectConfirm<V, D>? onConfirm;

  /// 多选最大可选数量，不传则无限制
  ///
  /// 达到上限后列表项点击不再新增选中，但不影响取消选中。
  final int? maxCount;

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

  /// 是否显示新增按钮（搜索无结果时），默认 false
  final bool showAdd;

  /// 新增按钮文字，默认 '新增'
  final String addLabel;

  /// 新增按钮点击回调（异步，传入当前搜索关键字，完成后自动刷新列表）
  final Future<void> Function(String keyword)? onAdd;

  /// 远程搜索模式下，当已选值的 label 被解析出来时触发
  ///
  /// 适用于只传 selectedValues（无 selectedItems）的场景：
  /// 弹窗打开后通过远程搜索获取数据，匹配到已选值的 label 后通过此回调通知父组件，
  /// 父组件可据此更新 selectedItems 使表单字段显示正确的 label 而非 ID。
  ///
  /// 参数为 value → label 的映射，仅包含本次新解析到的项。
  final void Function(Map<V, String> resolvedLabels)? onLabelsResolved;

  /// 强制刷新，不使用缓存
  ///
  /// 默认为 null（启用缓存）；设为 true 时每次打开弹窗都重新获取远程数据，
  /// 不使用已有的缓存数据，也不会将本次结果写入缓存。
  final bool? forceRefresh;

  /// 显示一个从底部向上弹出的选择器弹窗
  ///
  /// [title] 主标题
  /// [subTitle] 副标题/描述
  /// [items] 选项列表数据（直接传递给 SelectModalContent）
  /// [multiple] 是否多选模式，默认 false（单选）
  /// [selectedValues] 初始选中项的 value 集合
  /// [selectedItems] 已选中项的完整数据（确保回显时这些项一定出现在列表中）
  /// [onSelect] 选中回调（单选/多选均触发，返回当前点击项的 value 和 data）
  /// [onConfirm] 多选确认回调（返回 values 和 datas）
  /// [searchHint] 搜索框提示文字
  /// [cancelLabel] 取消按钮文字
  /// [confirmLabel] 确定按钮文字
  ///
  /// --- remote 专属参数 ---
  /// [onRemoteSearch] 远程搜索回调（传入后启用远程搜索模式）
  /// [emptyText] 空状态提示文字
  ///
  /// --- 新增功能参数 ---
  /// [showAdd] 是否显示新增按钮（搜索无结果时），默认 false
  /// [addLabel] 新增按钮文字，默认 '新增'
  /// [onAdd] 新增按钮点击回调（异步，传入当前搜索关键字，完成后自动刷新列表）
  static Future<V?> show<V, D>({
    required BuildContext context,
    SelectModalType type = SelectModalType.filterable,
    String? title,
    String? subTitle,
    List<SelectItem<V, D>>? items,
    bool multiple = false,
    Set<V>? selectedValues,
    List<SelectItem<V, D>>? selectedItems,
    OnSelectChange<V, D>? onSelect,
    OnMultiSelectConfirm<V, D>? onConfirm,
    int? maxCount,
    String? searchHint,
    String cancelLabel = '取消',
    String confirmLabel = '确定',

    // remote 专属
    RemoteSearchCallback<V, D>? onRemoteSearch,
    String emptyText = '暂无数据',

    // 新增功能
    bool showAdd = false,
    String addLabel = '新增',
    Future<void> Function(String keyword)? onAdd,

    // label 解析回调
    void Function(Map<V, String> resolvedLabels)? onLabelsResolved,

    // 数据加载完成回调（用于外部缓存）
    void Function(List<SelectItem<V, D>> data)? onDataLoaded,

    // 强制刷新
    bool? forceRefresh,
  }) {
    assert(
      type == SelectModalType.remote ? onRemoteSearch != null : (items != null && onRemoteSearch == null),
      '远程搜索模式(type: remote)必须传递 onRemoteSearch，本地过滤模式(type: filterable)必须传递 items 且不能传递 onRemoteSearch',
    );
    assert(onConfirm == null || multiple, '单选模式不支持 onConfirm，onConfirm 仅在多选模式下有效');
    assert(maxCount == null || (maxCount > 0 && multiple), 'maxCount 必须大于 0 且仅在多选模式下有效');
    assert(selectedValues == null || selectedItems == null || selectedValues.length == selectedItems.length, 'selectedValues 与 selectedItems 同时传递时，长度必须相等');
    return showModalBottomSheet<V>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final screenHeight = MediaQuery.of(ctx).size.height;
        final constraints = BoxConstraints(minHeight: screenHeight * 0.60, maxHeight: screenHeight * 0.75);

        return SafeArea(
          child: ConstrainedBox(
            constraints: constraints,
            child: SelectModalContent<V, D>(
              title: title,
              subTitle: subTitle,
              type: type,
              items: items,
              onRemoteSearch: onRemoteSearch,
              multiple: multiple,
              selectedValues: selectedValues,
              selectedItems: selectedItems,
              onSelect: onSelect,
              onConfirm: onConfirm,
              maxCount: maxCount,
              searchHint: searchHint,
              cancelLabel: cancelLabel,
              confirmLabel: confirmLabel,
              emptyText: emptyText,
              showAdd: showAdd,
              addLabel: addLabel,
              onAdd: onAdd,
              onLabelsResolved: onLabelsResolved,
              onDataLoaded: onDataLoaded,
            ),
          ),
        );
      },
    );
  }

  const DropdownChoose({
    super.key,
    required this.formLabel,
    this.value,
    this.selectedValues,
    this.items,
    this.selectedItems,
    this.hintText,
    this.required = false,
    this.multiple = false,
    this.type = SelectModalType.filterable,
    this.onRemoteSearch,
    this.displayMode = DisplayMode.text,
    this.maxShowTags = 3,
    this.valueBuilder,
    this.showAdd = false,
    this.addLabel = '新增',
    this.onAdd,
    this.onLabelsResolved,
    this.onSelect,
    this.onConfirm,
    this.maxCount,
    this.forceRefresh,
    this.onSaved,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.formLayout = FormLayout.row,
    this.prefixIcon,
  }) : assert(type == SelectModalType.remote ? items == null : items != null, '本地过滤模式(type: filterable)必须传递 items，远程搜索模式(type: remote)不能传递 items'),
       assert(
         type == SelectModalType.remote ? onRemoteSearch != null : onRemoteSearch == null,
         '远程搜索模式(type: remote)必须传递 onRemoteSearch，本地过滤模式(type: filterable)不能传递 onRemoteSearch',
       ),
       assert(onConfirm == null || multiple, '单选模式不支持 onConfirm，onConfirm 仅在多选模式下有效'),
       assert(maxCount == null || (maxCount > 0 && multiple), 'maxCount 必须大于 0 且仅在多选模式下有效'),
       assert(selectedValues == null || selectedItems == null || selectedValues.length == selectedItems.length, 'selectedValues 与 selectedItems 同时传递时，长度必须相等');

  @override
  State<DropdownChoose<V, D>> createState() => _DropdownChooseState<V, D>();
}

class _DropdownChooseState<V, D> extends State<DropdownChoose<V, D>> {
  final _formFieldKey = GlobalKey<FormFieldState<String>>();

  /// 内部缓存的已选项完整数据（由 onConfirm 回调自动填充）
  ///
  /// 当用户未传递 selectedItems 时，通过 onConfirm 返回的 datas 自动构建，
  /// 使表单字段能正确显示 label 而非 ID。
  List<SelectItem<V, D>> _resolvedItems = [];

  /// 远程模式首次加载成功的初始数据缓存
  ///
  /// 首次打开弹窗加载成功且数据非空时缓存，后续打开直接使用，避免重复远程请求。
  /// 若首次加载失败或返回空数据，则不缓存，每次打开仍重新请求。
  List<SelectItem<V, D>>? _cachedRemoteItems;

  /// 弹窗是否展开
  bool _isExpanded = false;

  /// 获取有效的选中值集合（优先 selectedValues，其次从 selectedItems 提取）
  Set<V>? _effectiveSelectedValues() {
    if (widget.selectedValues != null && widget.selectedValues!.isNotEmpty) {
      return widget.selectedValues;
    }
    if (widget.selectedItems != null && widget.selectedItems!.isNotEmpty) {
      return widget.selectedItems!.map((e) => e.value).toSet();
    }
    return null;
  }

  List<String> _getAllLabels() {
    final allItems = <SelectItem<V, D>>[...?widget.items, ...?widget.selectedItems, ..._resolvedItems];
    final effectiveValues = _effectiveSelectedValues();
    if (widget.multiple) {
      if (effectiveValues == null || effectiveValues.isEmpty) return [];
      final labels = <String>[];
      for (final v in effectiveValues) {
        String? matched;
        for (final item in allItems) {
          if (item.value == v) {
            matched = item.label;
            break;
          }
        }
        // 未匹配到完整数据时，降级用 value.toString() 作为 label
        labels.add(matched ?? v.toString());
      }
      return labels;
    } else {
      if (widget.value == null) return [];
      for (final item in allItems) {
        if (item.value == widget.value) return [item.label];
      }
      // 未匹配到完整数据时，降级用 value.toString() 作为 label
      return [widget.value!.toString()];
    }
  }

  // 默认验证规则
  String? defaultValid(String? value) {
    if (widget.required != true) return null;
    final effectiveValues = _effectiveSelectedValues();
    if (widget.validator != null) {
      if (widget.multiple) {
        return widget.validator!((effectiveValues?.isEmpty ?? true) ? null : effectiveValues!.join(','));
      }
      return widget.validator!(widget.value?.toString());
    }
    if (widget.multiple) {
      if (effectiveValues == null || effectiveValues.isEmpty) {
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
      initialValue: widget.multiple ? (_effectiveSelectedValues()?.join(',') ?? '') : (widget.value?.toString() ?? ''),
      onSaved: (value) {
        if (widget.multiple) {
          widget.onSaved?.call(_effectiveSelectedValues()?.join(',') ?? '');
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
              prefixIcon: widget.prefixIcon,
              formLabel: widget.formLabel,
              valueLabels: _getAllLabels(),
              displayMode: widget.displayMode,
              maxShowTags: widget.maxShowTags,
              valueBuilder: widget.valueBuilder,
              hintText: widget.hintText,
              isExpanded: _isExpanded,
              selectedValue: !widget.multiple ? (_getAllLabels().isNotEmpty ? _getAllLabels().first : null) : null,
              selectedValues: widget.multiple ? (_getAllLabels().isNotEmpty ? _getAllLabels() : null) : null,
              onTap: () {
                setState(() => _isExpanded = true);
                DropdownChoose.show<V, D>(
                  context: context,
                  type: widget.type,
                  onRemoteSearch: widget.onRemoteSearch,
                  title: '请选择${widget.formLabel}',
                  // 远程模式：有缓存且非强制刷新则传缓存数据，否则传 null 触发请求
                  items: (widget.forceRefresh == true) ? null : (widget.items ?? _cachedRemoteItems),
                  multiple: widget.multiple,
                  selectedValues: widget.multiple ? _effectiveSelectedValues() : (widget.value != null ? {widget.value as V} : null),
                  selectedItems: widget.selectedItems,
                  showAdd: widget.showAdd,
                  addLabel: widget.addLabel,
                  onAdd: widget.onAdd,
                  onLabelsResolved: widget.onLabelsResolved,
                  onDataLoaded: (widget.forceRefresh == true)
                      ? null
                      : (data) {
                          // 仅缓存首次加载结果（之前未缓存过）
                          if (_cachedRemoteItems == null) {
                            setState(() => _cachedRemoteItems = data);
                          }
                        },
                  onSelect: (value, data) {
                    widget.onSelect?.call(value, data);
                    _formFieldKey.currentState?.didChange(value?.toString() ?? '');
                  },
                  onConfirm: widget.multiple
                      ? (values, datas, items) {
                          widget.onConfirm?.call(values, datas, items);
                          // 自动缓存已选项完整数据（含 label），使表单字段能正确显示
                          setState(() {
                            _resolvedItems = items;
                          });
                          _formFieldKey.currentState?.didChange(values.join(','));
                        }
                      : null,
                  maxCount: widget.maxCount,
                ).then((_) {
                  if (mounted) setState(() => _isExpanded = false);
                });
              },
            ),
          ],
        );
      },
    );
  }
}
