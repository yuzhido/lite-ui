import 'dart:async';

import 'package:flutter/material.dart';

import 'action_sheet_widgets.dart';
import 'model.dart';

/// ActionSheet 远程搜索选择器
///
/// 支持远程异步搜索，支持单选/多选模式。
/// - 单选模式：点击项即选中并关闭弹窗
/// - 多选模式：点击项切换选中状态，底部显示已选数量 + 确定按钮
///
/// 泛型参数：
/// - [V] 选项 value 的类型
/// - [D] 选项 data 的类型（可选原始数据）
class ActionSheetRemote<V, D> extends StatefulWidget {
  /// 主标题
  final String? title;

  /// 副标题/描述
  final String? description;

  /// 远程搜索回调：根据关键字返回数据列表
  final RemoteSearchCallback<V, D> onSearch;

  /// 初始数据（首次打开时显示，或空搜索时显示）
  final List<SelectItem<V, D>>? initialItems;

  /// 是否为多选模式，默认 false（单选）
  final bool multiple;

  /// 初始选中项的 value 集合
  final Set<V>? selectedValues;

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

  const ActionSheetRemote({
    super.key,
    this.title,
    this.description,
    required this.onSearch,
    this.initialItems,
    this.multiple = false,
    this.selectedValues,
    this.onSelect,
    this.onConfirm,
    this.searchHint = '搜索',
    this.cancelLabel = '取消',
    this.confirmLabel = '确定',
    this.emptyText = '暂无数据',
  });

  @override
  State<ActionSheetRemote<V, D>> createState() => _ActionSheetRemoteState<V, D>();
}

class _ActionSheetRemoteState<V, D> extends State<ActionSheetRemote<V, D>> {
  final TextEditingController _searchController = TextEditingController();

  /// 当前搜索结果
  List<SelectItem<V, D>> _results = [];

  /// 当前选中项的 value 集合
  Set<V> _selectedValues = {};

  /// 是否正在加载
  bool _isLoading = false;

  /// 搜索是否执行过（控制空状态提示）
  bool _hasSearched = false;

  /// 防抖定时器
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.selectedValues != null) {
      _selectedValues = Set.from(widget.selectedValues!);
    }
    // 首次加载初始数据
    _loadInitial();
  }

  /// 首次加载：优先使用 initialItems，否则执行空关键字搜索
  Future<void> _loadInitial() async {
    if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
      setState(() {
        _results = widget.initialItems!;
      });
    } else {
      await _performSearch('');
    }
  }

  /// 执行远程搜索
  Future<void> _performSearch(String keyword) async {
    setState(() => _isLoading = true);
    try {
      final results = await widget.onSearch(keyword);
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

  /// 搜索框内容变化处理
  void _onSearchChanged(String value) {
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
      // 单选：直接回调并关闭
      widget.onSelect?.call(item.value, item.data);
      Navigator.of(context).pop(item.value);
    }
  }

  /// 处理多选确认
  void _handleConfirm() {
    final selectedItems =
        _results.where((item) => _selectedValues.contains(item.value)).toList();
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
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽手柄
          const ActionSheetDragHandle(),

          // 头部：标题 + 描述 + 关闭按钮
          ActionSheetHeader(
              title: widget.title,
              description: widget.description,
              itemCount: _results.length,
              onClose: () => Navigator.of(context).pop()),

          // 搜索输入框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ActionSheetSearchField(
              hint: widget.searchHint,
              keyword: _searchController.text,
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: _onClearSearch,
            ),
          ),

          // 可滚动列表区域
          Expanded(child: _buildContent(theme)),

          // 多选模式底部栏
          if (widget.multiple)
            ActionSheetBottomBar(
              selectedCount: _selectedValues.length,
              cancelLabel: widget.cancelLabel,
              confirmLabel: widget.confirmLabel,
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: _handleConfirm,
            ),
        ],
      ),
    );
  }

  /// 构建内容区域（Loading / 空状态 / 数据列表）
  Widget _buildContent(ThemeData theme) {
    // Loading 状态
    if (_isLoading) {
      return const SizedBox(
          height: 120, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    // 空状态
    if (_results.isEmpty) {
      return ActionSheetEmptyState(
        message: _hasSearched ? widget.emptyText : '请输入关键字搜索',
        icon: _hasSearched ? Icons.search_off : Icons.search,
      );
    }

    // 数据列表
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        final isSelected = _selectedValues.contains(item.value);
        return ActionSheetCheckListItem(
          label: item.label,
          subtitle: item.subtitle,
          isChecked: isSelected,
          isDisabled: item.disabled,
          multiple: widget.multiple,
          onTap: () => _handleItemTap(item),
        );
      },
    );
  }
}
