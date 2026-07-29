import 'dart:async';
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
/// 支持可选的 [onSearch] 远程搜索回调。
///
/// 泛型参数：
/// - [V] 选项 value 的类型
/// - [D] 选项 data 的类型（可选原始数据）
class SelectModalContent<V, D> extends StatefulWidget {
  /// 主标题
  final String? title;

  /// 副标题/描述
  final String? description;

  /// 组件模式（filterable 本地过滤 / remote 远程搜索）
  final SelectModalType type;

  /// 选项列表数据（直接传递，组件内部根据搜索关键字本地过滤）
  final List<SelectItem<V, D>> items;

  /// 远程搜索回调（remote 模式下必填），搜索时调用远程接口而非本地过滤
  final Future<List<SelectItem<V, D>>> Function(String keyword)? onSearch;

  /// 是否为多选模式，默认 false（单选）
  final bool multiple;

  /// 初始选中项的 value 集合
  final Set<V>? selectedValues;

  /// 已选中项的完整数据（确保回显时这些项一定出现在列表中，不受搜索过滤影响）
  final List<SelectItem<V, D>>? selectedItems;

  /// 单选回调（单选模式下点击项时触发，返回 value 和 data）
  final OnSelectChange<V, D>? onSelect;

  /// 多选确认回调（多选模式下点击「确定」时触发，返回 values 和 datas）
  final OnMultiSelectConfirm<V, D>? onConfirm;

  /// 搜索框提示文字
  final String searchHint;

  /// 取消按钮文字
  final String cancelLabel;

  /// 确定按钮文字
  final String confirmLabel;

  /// 空状态提示文字
  final String emptyText;

  const SelectModalContent({
    super.key,
    this.title,
    this.description,
    this.type = SelectModalType.filterable,
    required this.items,
    this.onSearch,
    this.multiple = false,
    this.selectedValues,
    this.selectedItems,
    this.onSelect,
    this.onConfirm,
    this.searchHint = '搜索',
    this.cancelLabel = '取消',
    this.confirmLabel = '确定',
    this.emptyText = '暂无数据',
  });

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

  /// 是否正在加载
  bool _isLoading = false;

  /// 搜索是否执行过（仅远程搜索模式，控制空状态提示）
  bool _hasSearched = false;

  /// 防抖定时器
  Timer? _debounceTimer;

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
      }
    }
    // 首次加载：有 items 直接显示，否则远程模式调 onSearch
    if (widget.items.isNotEmpty) {
      _results = widget.items;
    } else if (_isRemote) {
      _performSearch('');
    }
  }

  /// 执行数据加载
  ///
  /// 远程模式：调用 onSearch 回调
  /// 本地模式：直接对 widget.items 做关键字过滤
  Future<void> _performSearch(String keyword) async {
    if (_isRemote) {
      setState(() => _isLoading = true);
      try {
        final results = await widget.onSearch!(keyword);
        if (mounted) {
          setState(() {
            _results = results;
            _isLoading = false;
            _hasSearched = true;
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
      final kw = keyword.toLowerCase();
      setState(() {
        _results = kw.isEmpty
            ? widget.items
            : widget.items.where((item) {
                return item.label.toLowerCase().contains(kw) || (item.subtitle?.toLowerCase().contains(kw) ?? false);
              }).toList();
      });
    }
  }

  /// 获取合并后的显示列表（selectedItems 前置 + 去重）
  List<SelectItem<V, D>> get _displayItems {
    if (widget.selectedItems == null || widget.selectedItems!.isEmpty) {
      return _results;
    }
    final selectedValueSet = widget.selectedItems!.map((e) => e.value).toSet();
    final uniqueResults = _results.where((e) => !selectedValueSet.contains(e.value)).toList();
    return [...widget.selectedItems!, ...uniqueResults];
  }

  /// 获取已选项数据（value + label）
  List<SelectedItemLabel> get _selectedItemsData {
    return _displayItems.where((item) => _selectedValues.contains(item.value)).map((e) => SelectedItemLabel(value: e.value.toString(), label: e.label)).toList();
  }

  /// 移除某项选中
  void _handleRemove(String value) {
    setState(() => _selectedValues.remove(value));
  }

  /// 查看已选项弹窗
  void _handleViewSelected() {
    SelectedItemsDialog.show(context: context, items: _selectedItemsData, onRemove: _handleRemove);
  }

  /// 搜索框内容变化处理
  void _onSearchChanged(String value) {
    setState(() => _keyword = value);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(value);
    });
  }

  /// 清除搜索
  void _onClearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  /// 处理列表项点击
  void _handleItemTap(SelectItem<V, D> item) {
    if (item.disabled) return;

    if (widget.multiple) {
      setState(() {
        if (_selectedValues.contains(item.value)) {
          _selectedValues.remove(item.value);
        } else {
          _selectedValues.add(item.value);
        }
      });
    } else {
      widget.onSelect?.call(item.value, item.data);
      Navigator.of(context).pop(item.value);
    }
  }

  /// 处理多选确认
  void _handleConfirm() {
    final selectedItems = _displayItems.where((item) => _selectedValues.contains(item.value)).toList();
    final values = selectedItems.map((e) => e.value).toList();
    final datas = selectedItems.map((e) => e.data).toList();
    widget.onConfirm?.call(values, datas);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
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
          TopTitleInfo(title: '${widget.title}', subTitle: widget.description, itemCount: _displayItems.length),
          InputSearch(
            //
            searchHint: widget.searchHint,
            searchController: _searchController,
            applyFilter: _onSearchChanged,
            onClear: _onClearSearch,
            keyword: _keyword,
          ),
          Expanded(
            child: SelectModalContentList<V, D>(
              isLoading: _isLoading,
              displayItems: _displayItems,
              isRemote: _isRemote,
              hasSearched: _hasSearched,
              emptyText: widget.emptyText,
              selectedValues: _selectedValues,
              multiple: widget.multiple,
              onItemTap: _handleItemTap,
            ),
          ),
          if (widget.multiple)
            BottomActionBar(
              selectedCount: _selectedValues.length,
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
