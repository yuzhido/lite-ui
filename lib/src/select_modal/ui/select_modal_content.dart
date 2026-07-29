import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/callbacks.dart';
import '../../models/select_item.dart';
import '../../widgets/input_search.dart';
import '../../widgets/drag_indicator.dart';
import '../../widgets/top_title_info.dart';
import '../../widgets/bottom_action_bar.dart';

import 'widgets/select_modal_content_list.dart';
import 'widgets/selected_items_dialog.dart';

/// 数据提供策略：根据搜索关键字异步返回数据列表
///
/// - filterable 模式：本地过滤静态数据 + 可选合并动态数据
/// - remote 模式：调用远程搜索接口
typedef SelectModalDataProvider<V, D> = Future<List<SelectItem<V, D>>> Function(String keyword);

/// SelectModal 统一内容组件
///
/// 通过 [dataProvider] 注入数据获取策略，统一处理单选/多选、搜索、回显等逻辑。
///
/// 泛型参数：
/// - [V] 选项 value 的类型
/// - [D] 选项 data 的类型（可选原始数据）
class SelectModalContent<V, D> extends StatefulWidget {
  /// 主标题
  final String? title;

  /// 标题前缀（如 "请选择"），拼在 title 前面
  final String? prefixTitle;

  /// 副标题/描述
  final String? description;

  /// 数据提供策略回调
  final SelectModalDataProvider<V, D> dataProvider;

  /// 是否为远程模式（影响初始加载和空状态提示）
  final bool isRemote;

  /// 远程模式初始数据（仅 isRemote=true 时有效）
  final List<SelectItem<V, D>>? initialItems;

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

  /// 空状态提示文字（仅 isRemote=true 时有效）
  final String emptyText;

  const SelectModalContent({
    super.key,
    this.title,
    this.prefixTitle,
    this.description,
    required this.dataProvider,
    this.isRemote = false,
    this.initialItems,
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

  /// 搜索是否执行过（仅 remote 模式，控制空状态提示）
  bool _hasSearched = false;

  /// 防抖定时器
  Timer? _debounceTimer;

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
    // remote 模式：首次加载初始数据
    if (widget.isRemote) {
      _loadInitial();
    } else {
      // filterable 模式：初始加载空关键字数据（即全部数据）
      _performSearch('');
    }
  }

  /// 远程模式首次加载
  Future<void> _loadInitial() async {
    if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
      setState(() => _results = widget.initialItems!);
    } else {
      await _performSearch('');
    }
  }

  /// 执行数据加载（调用 dataProvider）
  Future<void> _performSearch(String keyword) async {
    setState(() => _isLoading = true);
    try {
      final results = await widget.dataProvider(keyword);
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
    final displayItems = _displayItems;
    final titleText = widget.prefixTitle != null ? '${widget.prefixTitle}${widget.title ?? ''}' : (widget.title ?? '');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DragIndicator(),
          TopTitleInfo(title: titleText, subTitle: widget.description, itemCount: displayItems.length),
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
              displayItems: displayItems,
              isRemote: widget.isRemote,
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
