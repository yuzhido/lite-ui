import 'dart:async';
import 'package:flutter/material.dart';
import 'action_sheet_widgets.dart';
import 'model.dart';

/// ActionSheet 可过滤选择器
///
/// 支持本地过滤 + 动态数据合并，支持单选/多选模式。
/// - 单选模式：点击项即选中并关闭弹窗
/// - 多选模式：点击项切换选中状态，底部显示已选数量 + 确定按钮
class ActionSheetFilterable extends StatefulWidget {
  /// 主标题
  final String? title;

  /// 副标题/描述
  final String? description;

  /// 静态数据源
  final List<ActionSheetItem> items;

  /// 异步动态数据回调（根据过滤关键字返回额外数据，与静态 items 合并显示）
  final DynamicItemsCallback? dynamicItems;

  /// 是否为多选模式，默认 false（单选）
  final bool multiple;

  /// 初始选中项的 value 集合
  final Set<String>? selectedValues;

  /// 单选回调（单选模式下点击项时触发）
  final ValueChanged<ActionSheetItem>? onSelect;

  /// 多选确认回调（多选模式下点击「确定」时触发）
  final ValueChanged<List<ActionSheetItem>>? onConfirm;

  /// 搜索框提示文字
  final String searchHint;

  /// 取消按钮文字
  final String cancelLabel;

  /// 确定按钮文字
  final String confirmLabel;

  const ActionSheetFilterable({
    super.key,
    this.title,
    this.description,
    required this.items,
    this.dynamicItems,
    this.multiple = false,
    this.selectedValues,
    this.onSelect,
    this.onConfirm,
    this.searchHint = '搜索',
    this.cancelLabel = '取消',
    this.confirmLabel = '确定',
  });

  @override
  State<ActionSheetFilterable> createState() => _ActionSheetFilterableState();
}

class _ActionSheetFilterableState extends State<ActionSheetFilterable> {
  final TextEditingController _searchController = TextEditingController();

  /// 当前搜索关键字
  String _keyword = '';

  /// 当前选中项的 value 集合
  Set<String> _selectedValues = {};

  /// 动态数据回调返回的结果
  List<ActionSheetItem> _dynamicResults = [];

  /// 动态数据是否正在加载
  bool _isLoadingDynamic = false;

  /// 防抖定时器
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.selectedValues != null) {
      _selectedValues = Set.from(widget.selectedValues!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// 获取过滤后的显示列表
  List<ActionSheetItem> get _filteredItems {
    // 1. 静态数据本地过滤
    final filteredStatic = _keyword.isEmpty
        ? widget.items
        : widget.items.where((item) {
            final kw = _keyword.toLowerCase();
            return item.label.toLowerCase().contains(kw) || (item.subtitle?.toLowerCase().contains(kw) ?? false);
          }).toList();

    // 2. 合并动态数据（去重）
    if (_dynamicResults.isEmpty) return filteredStatic;
    final staticValues = filteredStatic.map(itemValue).toSet();
    final uniqueDynamic = _dynamicResults.where((item) => !staticValues.contains(itemValue(item))).toList();

    return [...filteredStatic, ...uniqueDynamic];
  }

  /// 搜索框内容变化处理
  void _onSearchChanged(String value) {
    setState(() => _keyword = value);

    // 防抖调用动态数据回调
    if (widget.dynamicItems != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
        setState(() => _isLoadingDynamic = true);
        try {
          final results = await widget.dynamicItems!(value);
          if (mounted) {
            setState(() {
              _dynamicResults = results;
              _isLoadingDynamic = false;
            });
          }
        } catch (_) {
          if (mounted) setState(() => _isLoadingDynamic = false);
        }
      });
    }
  }

  /// 清除搜索
  void _onClearSearch(String val) {
    _searchController.clear();
    _onSearchChanged('');
  }

  /// 处理列表项点击
  void _handleItemTap(ActionSheetItem item) {
    final val = itemValue(item);
    if (widget.multiple) {
      setState(() {
        if (_selectedValues.contains(val)) {
          _selectedValues.remove(val);
        } else {
          _selectedValues.add(val);
        }
      });
    } else {
      // 单选：直接回调并关闭
      widget.onSelect?.call(item);
      item.onTap?.call();
      Navigator.of(context).pop(item);
    }
  }

  /// 处理多选确认
  void _handleConfirm() {
    final selectedItems = _filteredItems.where((item) => _selectedValues.contains(itemValue(item))).toList();
    widget.onConfirm?.call(selectedItems);
    Navigator.of(context).pop(selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredItems = _filteredItems;

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
          ActionSheetHeader(title: widget.title, description: widget.description, itemCount: filteredItems.length, onClose: () => Navigator.of(context).pop()),

          // 搜索输入框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ActionSheetSearchField(
              hint: widget.searchHint,
              keyword: _keyword,
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: () => _onClearSearch(''),
            ),
          ),

          // 可滚动列表区域
          Expanded(
            child: _isLoadingDynamic && filteredItems.isEmpty
                ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                : filteredItems.isEmpty
                ? const ActionSheetEmptyState(message: '无匹配数据')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final isSelected = _selectedValues.contains(itemValue(item));
                      return ActionSheetCheckListItem(
                        item: item,
                        isSelected: isSelected,
                        multiple: widget.multiple,
                        onTap: () => _handleItemTap(item),
                      );
                    },
                  ),
          ),

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
}
