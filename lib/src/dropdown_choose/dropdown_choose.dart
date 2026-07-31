import 'package:flutter/material.dart';
import 'package:lite_ui/src/models/enum.dart';
import 'package:lite_ui/src/theme/index.dart';
import 'package:lite_ui/src/models/callbacks.dart';
import 'package:lite_ui/src/models/select_item.dart';
import 'package:lite_ui/src/dropdown_choose/models/index.dart';
import 'package:lite_ui/src/dropdown_choose/ui/modal_content.dart';

import '../wrapper_container/index.dart';

class DropdownChoose<V, D> extends StatefulWidget {
  const DropdownChoose({
    super.key,
    required this.formLabel,
    this.items,
    this.selectedItems,
    this.hintText,
    this.required = false,
    this.multiple = false,
    this.type = SelectType.filter,
    this.onRemoteSearch,
    this.displayMode = DisplayMode.text,
    this.maxShowTags,
    this.valueBuilder,
    this.showAdd = false,
    this.addLabel = '新增',
    this.onAdd,
    this.onLabelsResolved,
    this.onSelect,
    this.onConfirm,
    this.maxCount,
    this.forceRefresh,
    this.onClear,
    this.onSaved,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.formLayout = FormLayout.row,
    this.prefixIcon,
    this.subTitle,
  }) : assert(type == SelectType.remote ? items == null : items != null, '本地过滤模式(type: filterable)必须传递 items，远程搜索模式(type: remote)不能传递 items'),
       assert(type == SelectType.remote ? onRemoteSearch != null : onRemoteSearch == null, '远程搜索模式(type: remote)必须传递 onRemoteSearch，本地过滤模式(type: filterable)不能传递 onRemoteSearch'),
       assert(onConfirm == null || multiple, '单选模式不支持 onConfirm，onConfirm 仅在多选模式下有效'),
       assert(maxCount == null || (maxCount > 0 && multiple), 'maxCount 必须大于 0 且仅在多选模式下有效'),
       assert(maxShowTags == null || displayMode == DisplayMode.compact, 'maxShowTags 仅在 displayMode 为 compact 时有效'),
       assert(displayMode != DisplayMode.compact || multiple, 'compact 模式仅支持多选'),
       assert(selectedItems == null || maxCount == null || selectedItems.length <= maxCount, 'selectedItems 数量不能超过 maxCount'),
       assert(selectedItems == null || multiple || selectedItems.length <= 1, '单选模式 selectedItems 最多只能有 1 项');

  /// 表单标签
  final String formLabel;

  /// 表单副标题
  final String? subTitle;

  /// 操作项列表
  final List<SelectItem<V, D>>? items;

  /// 前置图标
  final Widget? prefixIcon;

  /// 已选中项的完整数据（单选/多选统一使用）
  ///
  /// - 单选模式：最多 1 项
  /// - 多选模式：任意数量
  ///
  /// 若只有 value 无完整数据，可自行构造：
  /// `ids.map((id) => SelectItem(value: id, label: '$id')).toList()`
  final List<SelectItem<V, D>>? selectedItems;

  /// 占位提示文字
  final String? hintText;

  /// 是否必填
  final bool required;

  /// 是否为多选模式，默认 false（单选）
  final bool multiple;

  /// 选择器模式，默认 [SelectType.filter]（本地过滤）
  ///
  /// - [SelectType.filter]：本地过滤选择器（直接传 items，组件内部过滤）
  /// - [SelectType.remote]：远程搜索选择器（传 onRemoteSearch 异步搜索）
  final SelectType type;

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

  /// ## 校验函数
  ///
  /// 返回 null 表示验证通过，返回字符串表示验证失败的提示文字。
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

  /// compact 模式下最多显示的 tag 数，仅在 displayMode 为 compact 时有效
  final int? maxShowTags;

  /// 自定义值显示 Widget 构建器
  ///
  /// 传入后优先使用此构建器，忽略 [displayMode] 的默认逻辑。
  /// 传入后忽略 [displayMode] 的默认逻辑，[items] 为当前所有选中值的 label 列表。
  final Widget Function(List<SelectItem<V, D>> items)? valueBuilder;

  /// 是否显示新增按钮（搜索无结果时），默认 false
  final bool showAdd;

  /// 新增按钮文字，默认 '新增'
  final String addLabel;

  /// 新增按钮点击回调（异步，传入当前搜索关键字，完成后自动刷新列表）
  final OnAddCallback? onAdd;

  /// 远程搜索模式下，当已选值的 label 被解析出来时触发
  ///
  /// 适用于 selectedItems 中 label 为降级值（如 ID）的场景：
  /// 弹窗打开后通过远程搜索获取数据，匹配到已选值的真实 label 后通过此回调通知父组件，
  /// 父组件可据此更新 selectedItems 使表单字段显示正确的 label。
  ///
  /// 参数为 value → label 的映射，仅包含本次新解析到的项。
  final void Function(Map<V, String> resolvedLabels)? onLabelsResolved;

  /// 强制刷新，不使用缓存
  ///
  /// 默认为 null（启用缓存）；设为 true 时每次打开弹窗都重新获取远程数据，
  /// 不使用已有的缓存数据，也不会将本次结果写入缓存。
  final bool? forceRefresh;

  /// 点击清除图标回调（有值时后缀 close 图标点击触发）
  ///
  /// 通常用于清空当前选中值，外部可在此回调中调用 setState 将 value/selectedItems 置空。
  final VoidCallback? onClear;

  /// 显示一个从底部向上弹出的选择器弹窗
  ///
  /// [title] 主标题
  /// [subTitle] 副标题/描述
  /// [items] 选项列表数据（直接传递给 SelectModalContent）
  /// [multiple] 是否多选模式，默认 false（单选）
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
    SelectType type = SelectType.filter,
    String? title,
    String? subTitle,
    List<SelectItem<V, D>>? items,
    bool multiple = false,
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
    OnAddCallback? onAdd,

    // label 解析回调
    void Function(Map<V, String> resolvedLabels)? onLabelsResolved,

    // 数据加载完成回调（用于外部缓存）
    void Function(List<SelectItem<V, D>> data)? onDataLoaded,
    // 强制刷新
    bool? forceRefresh,
  }) {
    assert(
      type == SelectType.remote ? onRemoteSearch != null : (items != null && onRemoteSearch == null),
      '远程搜索模式(type: remote)必须传递 onRemoteSearch，本地过滤模式(type: filterable)必须传递 items 且不能传递 onRemoteSearch',
    );
    assert(onConfirm == null || multiple, '单选模式不支持 onConfirm，onConfirm 仅在多选模式下有效');
    assert(maxCount == null || (maxCount > 0 && multiple), 'maxCount 必须大于 0 且仅在多选模式下有效');
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
            child: ModalContent<V, D>(
              title: title,
              subTitle: subTitle,
              type: type,
              items: items,
              onRemoteSearch: onRemoteSearch,
              multiple: multiple,
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

  @override
  State<DropdownChoose<V, D>> createState() => _DropdownChooseState<V, D>();
}

class _DropdownChooseState<V, D> extends State<DropdownChoose<V, D>> {
  final _formFieldKey = GlobalKey<FormFieldState<String>>();

  /// 单选模式下缓存的选中项
  SelectItem<V, D>? chooseItem;

  /// 多选模式下缓存的选中项
  List<SelectItem<V, D>>? chooseItems = [];

  /// 远程模式首次加载成功的初始数据缓存
  ///
  /// 首次打开弹窗加载成功且数据非空时缓存，后续打开直接使用，避免重复远程请求。
  /// 若首次加载失败或返回空数据，则不缓存，每次打开仍重新请求。
  List<SelectItem<V, D>>? _cachedRemoteItems;

  /// 弹窗是否展开
  bool _isExpanded = false;

  /// 是否已内部清除（点击后缀 clear 图标后置为 true）
  ///
  /// 为 true 时组件显示为空，弹窗不回显任何选中项。
  /// 当外部 selectedItems 发生变化时自动重置。
  bool _cleared = false;

  @override
  void initState() {
    super.initState();
    // 从外部初始值初始化内部缓存，确保首次渲染即可回显
    if (widget.selectedItems != null && widget.selectedItems!.isNotEmpty) {
      if (widget.multiple) {
        chooseItems = widget.selectedItems;
      } else {
        chooseItem = widget.selectedItems!.first;
      }
    }
  }

  @override
  void didUpdateWidget(covariant DropdownChoose<V, D> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部 selectedItems 发生变化时，重置内部清除状态并同步 FormField
    if (widget.selectedItems != oldWidget.selectedItems) {
      _cleared = false;
      // 仅当外部值被清空时，才清除内部缓存的选中项，避免正常选中流程被误清
      final newEffectiveValues = _effectiveSelectedValues();
      if (newEffectiveValues == null || newEffectiveValues.isEmpty) {
        chooseItem = null;
        chooseItems = [];
      } else {
        // 外部值变化时同步内部缓存
        if (widget.multiple) {
          chooseItems = widget.selectedItems;
        } else {
          chooseItem = widget.selectedItems!.isNotEmpty ? widget.selectedItems!.first : null;
        }
      }
      // 外部值变化后同步 FormField 内部状态，触发重新验证
      final newValue = newEffectiveValues?.join(',') ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _formFieldKey.currentState?.didChange(newValue);
      });
    }
  }

  /// 获取有效的选中值集合（从 selectedItems 提取）
  Set<V>? _effectiveSelectedValues() {
    if (widget.selectedItems != null && widget.selectedItems!.isNotEmpty) {
      return widget.selectedItems!.map((e) => e.value).toSet();
    }
    return null;
  }

  /// 弹窗打开时应使用的选中项（感知内部清除状态）
  ///
  /// 优先使用外部 selectedItems，若未提供则使用内部缓存的 chooseItem/chooseItems，
  /// 确保未提供 onSelect/selectedItems 时弹窗仍能正确标记已选项。
  List<SelectItem<V, D>>? _modalSelectedItems() {
    if (_cleared) return null;
    if (widget.selectedItems != null) return widget.selectedItems;
    // 外部未提供 selectedItems 时，使用内部缓存的回显
    if (widget.multiple) {
      return (chooseItems != null && chooseItems!.isNotEmpty) ? chooseItems : null;
    }
    return chooseItem != null ? [chooseItem!] : null;
  }

  /// 获取用于校验/保存的值集合（基于内部最新状态）
  ///
  /// 直接使用 chooseItem/chooseItems，不依赖外部 selectedItems，
  /// 确保无论是否受控，校验和保存都基于最新选中状态。
  Set<V>? _getValidationValues() {
    if (_cleared) return null;
    if (widget.multiple) {
      if (chooseItems == null || chooseItems!.isEmpty) return null;
      return chooseItems!.map((e) => e.value).toSet();
    }
    if (chooseItem == null) return null;
    return {chooseItem!.value};
  }

  // 默认验证规则
  String? defaultValid(String? value) {
    if (widget.required != true) return null;
    // 感知内部清除状态：清除后视为空值，确保验证能正确触发失败
    if (_cleared) {
      if (widget.validator != null) return widget.validator?.call(null);
      return '${widget.formLabel}是必填项不能为空';
    }
    final validationValues = _getValidationValues();
    final validatorValue = (validationValues?.isEmpty ?? true) ? null : validationValues!.join(',');
    if (widget.validator != null) {
      return widget.validator!(validatorValue);
    }
    if (validationValues == null || validationValues.isEmpty) {
      return '${widget.formLabel}是必填项不能为空';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      key: _formFieldKey,
      validator: widget.required ? defaultValid : null,
      autovalidateMode: widget.autovalidateMode,
      initialValue: _getValidationValues()?.join(',') ?? '',
      onSaved: (value) {
        widget.onSaved?.call(_getValidationValues()?.join(',') ?? '');
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
            WrapperContainer<V, D>(
              selectItems: (widget.multiple == true)
                  ? chooseItems ?? []
                  : chooseItem != null
                  ? [chooseItem!]
                  : [],
              formLayout: widget.formLayout,
              errorText: state.errorText,
              required: widget.required,
              prefixIcon: widget.prefixIcon,
              formLabel: widget.formLabel,
              displayMode: widget.displayMode,
              maxShowTags: widget.maxShowTags ?? 1,
              valueBuilder: widget.valueBuilder,
              hintText: widget.hintText,
              isExpanded: _isExpanded,
              onClear: () {
                setState(() {
                  _cleared = true;
                  chooseItem = null;
                  chooseItems = [];
                });
                widget.onClear?.call();
                // 同步 FormField 内部值为空，使验证能正确触发失败
                // WidgetsBinding.instance.addPostFrameCallback((_) {
                //   if (mounted) _formFieldKey.currentState?.didChange('');
                // });
              },
              onTap: () {
                setState(() => _isExpanded = true);
                DropdownChoose.show<V, D>(
                  context: context,
                  type: widget.type,
                  subTitle: widget.subTitle,
                  onRemoteSearch: widget.onRemoteSearch,
                  title: '请选择${widget.formLabel}',
                  // 远程模式：有缓存且非强制刷新则传缓存数据，否则传 null 触发请求
                  items: (widget.forceRefresh == true) ? null : (widget.items ?? _cachedRemoteItems),
                  multiple: widget.multiple,
                  selectedItems: _modalSelectedItems(),
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
                  onSelect: (value, item, data) {
                    chooseItem = item;
                    setState(() => _cleared = false);
                    widget.onSelect?.call(value, item, data);
                    // 不再在此处调用 didChange，由 didUpdateWidget 统一处理
                  },

                  /// 这样写的目的是为了单选的时候提示不要传递 onConfirm
                  onConfirm: (widget.multiple == true)
                      ? (values, datas, items) {
                          chooseItems = datas;
                          setState(() => _cleared = false);
                          widget.onConfirm?.call(values, datas, items);
                          // 自动缓存已选项完整数据（含 label），使表单字段能正确显示
                          // setState(() {
                          //   _resolvedItems = items;
                          // });
                          // 不再在此处调用 didChange，由 didUpdateWidget 统一处理
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
