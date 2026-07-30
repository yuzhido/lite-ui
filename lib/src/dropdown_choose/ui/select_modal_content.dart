import 'package:flutter/material.dart';

import '../../models/callbacks.dart';
import '../../models/select_item.dart';
import '../../widgets/input_search.dart';
import '../../widgets/drag_indicator.dart';
import '../../widgets/top_title_info.dart';
import '../../widgets/bottom_action_bar.dart';
import '../models/index.dart';

import 'widgets/select_modal_content_list.dart';
import 'widgets/selected_items_dialog.dart';

/// SelectModal 统一内容组件
///
/// 直接接收 [items] 数据列表，内部处理本地过滤和状态管理。
/// 支持可选的 [onRemoteSearch] 远程搜索回调。
///
/// 泛型参数：
/// - [V] 选项 value 的类型
/// - [D] 选项 data 的类型（可选原始数据）
class SelectModalContent<V, D> extends StatefulWidget {
  /// 主标题
  final String? title;

  /// 副标题/描述
  final String? subTitle;

  /// 组件模式（filterable 本地过滤 / remote 远程搜索）
  final SelectModalType type;

  /// 选项列表数据（直接传递，组件内部根据搜索关键字本地过滤）
  ///
  /// 本地过滤模式下必传；远程搜索模式可不传，通过 [onRemoteSearch] 获取数据。
  final List<SelectItem<V, D>>? items;

  /// 远程搜索回调（remote 模式下必填），搜索时调用远程接口而非本地过滤
  final Future<List<SelectItem<V, D>>> Function(String keyword)? onRemoteSearch;

  /// 是否为多选模式，默认 false（单选）
  final bool multiple;

  /// 初始选中项的 value 集合
  final Set<V>? selectedValues;

  /// 已选中项的完整数据（用于「查看已选」弹窗回显 label）
  ///
  /// 与 [selectedValues] 同时传递时，长度必须相等。
  /// 若只传 [selectedValues]（只有 ID），查看已选时降级显示 value.toString()。
  final List<SelectItem<V, D>>? selectedItems;

  /// 选中回调（单选/多选模式下点击项时均触发，返回当前点击项的 value 和 data）
  ///
  /// 单选模式：触发后弹窗自动关闭
  /// 多选模式：仅切换勾选状态，不关闭弹窗（最终确认由 [onConfirm] 处理）
  final OnSelectChange<V, D>? onSelect;

  /// 多选确认回调（多选模式下点击「确定」时触发，返回 values 和 datas）
  final OnMultiSelectConfirm<V, D>? onConfirm;

  /// 多选最大可选数量，不传则无限制
  ///
  /// 达到上限后列表项点击不再新增选中，但不影响取消选中。
  final int? maxCount;

  /// 搜索框提示文字
  final String? searchHint;

  /// 取消按钮文字
  final String cancelLabel;

  /// 确定按钮文字
  final String confirmLabel;

  /// 空状态提示文字
  final String emptyText;

  /// 是否显示新增按钮，默认 false
  final bool showAdd;

  /// 新增按钮文字，默认 '新增'
  final String addLabel;

  /// 新增按钮点击回调（异步，传入当前搜索关键字，完成后自动刷新列表）
  final Future<void> Function(String keyword)? onAdd;

  const SelectModalContent({
    super.key,
    this.title,
    this.subTitle,
    this.type = SelectModalType.filterable,
    this.items,
    this.onRemoteSearch,
    this.multiple = false,
    this.selectedValues,
    this.selectedItems,
    this.onSelect,
    this.onConfirm,
    this.maxCount,
    this.searchHint,
    this.cancelLabel = '取消',
    this.confirmLabel = '确定',
    this.emptyText = '暂无数据',
    this.showAdd = false,
    this.addLabel = '新增',
    this.onAdd,
  }) : assert((items != null) ^ (onRemoteSearch != null), 'items 和 onRemoteSearch 必须且只能传递一个：传 items 为本地数据模式，传 onRemoteSearch 为远程搜索模式'),
       assert(onConfirm == null || multiple, '单选模式不支持 onConfirm，onConfirm 仅在多选模式下有效'),
       assert(maxCount == null || (maxCount > 0 && multiple), 'maxCount 必须大于 0 且仅在多选模式下有效'),
       assert(selectedValues == null || selectedItems == null || selectedValues.length == selectedItems.length, 'selectedValues 与 selectedItems 同时传递时，长度必须相等');

  @override
  State<SelectModalContent<V, D>> createState() => _SelectModalContentState<V, D>();
}

class _SelectModalContentState<V, D> extends State<SelectModalContent<V, D>> {
  final TextEditingController _searchController = TextEditingController();

  /// 当前搜索关键字
  String _keyword = '';

  /// 当前显示的数据列表
  List<SelectItem<V, D>> _results = [];

  /// 当前选中项的 value 集合
  Set<V> _selectedValues = {};

  /// 已选中项的完整数据缓存（value → SelectItem）
  ///
  /// 数据来源：
  /// 1. [selectedItems] 传入时直接填充
  /// 2. 用户点击选中列表项时自动缓存
  ///
  /// 用于「查看已选」弹窗获取 label，若无完整数据则降级显示 value.toString()
  final Map<V, SelectItem<V, D>> _selectedItemMap = {};

  /// 是否正在加载
  bool _isLoading = false;

  /// 搜索是否执行过（仅远程搜索模式，控制空状态提示）
  bool _hasSearched = false;

  /// 是否为远程搜索模式
  bool get _isRemote => widget.type == SelectModalType.remote;

  @override
  void initState() {
    super.initState();
    if (widget.selectedValues != null) {
      _selectedValues = Set.from(widget.selectedValues!);
    }
    if (widget.selectedItems != null) {
      for (final item in widget.selectedItems!) {
        _selectedValues.add(item.value);
        _selectedItemMap[item.value] = item;
      }
    }
    // 首次加载：有 items 直接显示，否则远程模式调 onRemoteSearch
    if (widget.items?.isNotEmpty ?? false) {
      _results = widget.items!;
    } else if (_isRemote) {
      _performSearch('');
    }
  }

  /// 执行数据加载
  ///
  /// 远程模式：调用 onRemoteSearch 回调
  /// 本地模式：直接对 widget.items 做关键字过滤
  Future<void> _performSearch(String keyword) async {
    if (_isRemote) {
      setState(() => _isLoading = true);
      try {
        final results = await widget.onRemoteSearch!(keyword);
        if (mounted) {
          setState(() {
            _results = results;
            _isLoading = false;
            _hasSearched = true;
            _syncSelectedItemMap();
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _results = [];
            _isLoading = false;
            _hasSearched = true;
          });
        }
      }
    } else {
      // 本地过滤
      final source = widget.items ?? <SelectItem<V, D>>[];
      final kw = keyword.toLowerCase();
      setState(() {
        _results = kw.isEmpty
            ? source
            : source.where((item) {
                return item.label.toLowerCase().contains(kw) || (item.subtitle?.toLowerCase().contains(kw) ?? false);
              }).toList();
        _syncSelectedItemMap();
      });
    }
  }

  /// 将搜索结果中匹配已选项的完整数据补充到 [_selectedItemMap]
  void _syncSelectedItemMap() {
    for (final item in _results) {
      if (_selectedValues.contains(item.value) && !_selectedItemMap.containsKey(item.value)) {
        _selectedItemMap[item.value] = item;
      }
    }
  }

  /// 根据 value 获取已选项的完整数据
  ///
  /// 优先从 [_selectedItemMap] 获取，找不到则降级构造一个 label 为 value.toString() 的 SelectItem
  SelectItem<V, D> _getSelectedItem(V value) {
    final cached = _selectedItemMap[value];
    if (cached != null) return cached;
    return SelectItem<V, D>(value: value, label: value.toString());
  }

  /// 获取已选项的标签信息（用于「查看已选」弹窗）
  List<SelectedItemLabel<V>> _getSelectedLabels() {
    return _selectedValues.map((v) {
      final item = _getSelectedItem(v);
      return SelectedItemLabel<V>(value: v, label: item.label);
    }).toList();
  }

  /// 查看已选项弹窗
  void _handleViewSelected() {
    SelectedItemsDialog.show(
      context: context,
      items: _getSelectedLabels(),
      onRemove: (V value) {
        setState(() => _selectedValues.remove(value));
      },
    );
  }

  /// 搜索按钮点击处理
  void _onSearch(String keyword) {
    setState(() => _keyword = keyword);
    _performSearch(keyword);
  }

  /// 清除搜索
  void _onClearSearch() {
    setState(() => _keyword = '');
    _performSearch('');
  }

  /// 处理新增按钮点击，传入当前关键字，完成后自动刷新列表
  Future<void> _handleAdd() async {
    if (widget.onAdd == null) return;
    await widget.onAdd!(_keyword);
    if (mounted) {
      _performSearch(_keyword);
    }
  }

  /// 处理列表项点击
  void _handleItemTap(SelectItem<V, D> item) {
    if (item.disabled) return;

    // 单选多选：触发选中回调
    widget.onSelect?.call(item.value, item.data);
    if (widget.multiple) {
      // 多选：切换勾选状态
      final isSelected = _selectedValues.contains(item.value);
      if (!isSelected && widget.maxCount != null && _selectedValues.length >= widget.maxCount!) {
        return; // 达到上限，不再新增选中
      }
      setState(() {
        if (isSelected) {
          _selectedValues.remove(item.value);
        } else {
          _selectedValues.add(item.value);
          // 缓存完整数据，用于「查看已选」弹窗回显
          _selectedItemMap[item.value] = item;
        }
      });
    } else {
      // 单选：立即关闭弹窗
      Navigator.of(context).pop(item.value);
    }
  }

  /// 处理多选确认
  void _handleConfirm() {
    final selectedItems = _selectedValues.map(_getSelectedItem).toList();
    final values = selectedItems.map((e) => e.value).toList();
    final datas = selectedItems.map((e) => e.data).toList();
    widget.onConfirm?.call(values, datas);

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DragIndicator(),
          TopTitleInfo(title: '${widget.title}', subTitle: '这是副标题${widget.subTitle ?? ''}', itemCount: _results.length),
          InputSearch(searchHint: widget.searchHint, searchController: _searchController, onSearch: _onSearch, onClear: _onClearSearch, keyword: _keyword, isLoading: _isLoading),
          Expanded(
            child: SelectModalContentList<V, D>(
              isLoading: _isLoading,
              displayItems: _results,
              isRemote: _isRemote,
              hasSearched: _hasSearched,
              emptyText: widget.emptyText,
              selectedValues: _selectedValues,
              multiple: widget.multiple,
              onItemTap: _handleItemTap,
              showAdd: widget.showAdd,
              addLabel: widget.addLabel,
              onAdd: widget.onAdd != null ? _handleAdd : null,
            ),
          ),
          if (widget.multiple)
            BottomActionBar(
              selectedCount: _selectedValues.length,
              maxCount: widget.maxCount,
              onViewSelected: _handleViewSelected,
              cancelLabel: widget.cancelLabel,
              confirmLabel: widget.confirmLabel,
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: _handleConfirm,
            ),
        ],
      ),
    );
  }
}
