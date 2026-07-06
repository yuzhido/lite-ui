import 'dart:async';

import 'package:flutter/material.dart';

import 'model.dart';
import 'tree_widgets.dart';

/// 竖向缩进树形选择器
///
/// 支持本地树形数据、懒加载、本地/远程搜索、单选/多选模式。
/// 多选模式支持父子联动（全选/半选/未选）。
class TreeVertical<V, D> extends StatefulWidget {
  /// 标题
  final String? title;

  /// 副标题
  final String? subtitle;

  /// 本地树形数据
  final List<TreeSelectItem<V, D>>? items;

  /// 是否多选模式
  final bool multiple;

  /// 初始选中值集合
  final Set<V>? selectedValues;

  /// 父子联动开关，默认 true
  ///
  /// 为 true 时，选中父节点会自动全选子节点，子节点全选时父节点也自动选中。
  /// 为 false 时，父子选中状态独立。
  final bool checkStrictly;

  /// 懒加载子节点回调
  final TreeLazyLoadCallback<V, D>? onLoadChildren;

  /// 远程搜索回调（与本地搜索互斥，优先使用远程）
  final TreeSearchCallback<V, D>? onSearch;

  /// 单选回调
  final TreeOnSelectChange<V, D>? onSelect;

  /// 多选确认回调
  final TreeOnMultiSelectConfirm<V, D>? onConfirm;

  /// 搜索提示文字
  final String searchHint;

  /// 取消按钮文字
  final String cancelLabel;

  /// 确定按钮文字
  final String confirmLabel;

  /// 空状态文字
  final String emptyText;

  const TreeVertical({
    super.key,
    this.title,
    this.subtitle,
    this.items,
    this.multiple = false,
    this.selectedValues,
    this.checkStrictly = true,
    this.onLoadChildren,
    this.onSearch,
    this.onSelect,
    this.onConfirm,
    this.searchHint = '搜索',
    this.cancelLabel = '取消',
    this.confirmLabel = '确定',
    this.emptyText = '暂无数据',
  });

  @override
  State<TreeVertical<V, D>> createState() => _TreeVerticalState<V, D>();
}

class _TreeVerticalState<V, D> extends State<TreeVertical<V, D>> {
  final TextEditingController _searchController = TextEditingController();

  /// 搜索关键字
  String _keyword = '';

  /// 选中值集合
  Set<V> _selectedValues = {};

  /// 远程搜索结果
  List<TreeSearchResult<V, D>> _searchResults = [];

  /// 是否正在搜索
  bool _isSearching = false;

  /// 是否已执行过搜索
  bool _hasSearched = false;

  /// 展开的节点 value 集合
  final Set<V> _expandedValues = {};

  /// 正在懒加载的节点 value 集合
  final Set<V> _loadingValues = {};

  /// 动态加载的子节点缓存：parent.value -> children
  final Map<V, List<TreeSelectItem<V, D>>> _childrenCache = {};

  /// 防抖计时器
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

  // ─── 搜索相关 ───

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _keyword = value;
        if (widget.onSearch != null) {
          _doRemoteSearch(value);
        }
      });
    });
  }

  Future<void> _doRemoteSearch(String keyword) async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _searchResults = [];
    });
    try {
      final results = await widget.onSearch!(keyword);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _onSearchClear() {
    _searchController.clear();
    _onSearchChanged('');
  }

  // ─── 展开/收起 ───

  void _toggleExpand(TreeSelectItem<V, D> item) {
    if (_expandedValues.contains(item.value)) {
      setState(() => _expandedValues.remove(item.value));
    } else {
      setState(() => _expandedValues.add(item.value));
      // 懒加载
      if (widget.onLoadChildren != null &&
          !_childrenCache.containsKey(item.value) &&
          (item.children == null || item.children!.isEmpty)) {
        _doLazyLoad(item);
      }
    }
  }

  Future<void> _doLazyLoad(TreeSelectItem<V, D> parent) async {
    setState(() => _loadingValues.add(parent.value));
    try {
      final children = await widget.onLoadChildren!(parent);
      if (mounted) {
        setState(() {
          _childrenCache[parent.value] = children;
          _loadingValues.remove(parent.value);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingValues.remove(parent.value));
      }
    }
  }

  // ─── 选中逻辑 ───

  /// 获取节点的有效子节点（优先缓存，否则用原始 children）
  List<TreeSelectItem<V, D>> _getChildren(TreeSelectItem<V, D> item) {
    return _childrenCache[item.value] ?? item.children ?? [];
  }

  /// 收集节点及其所有后代 value
  List<V> _collectAllValues(TreeSelectItem<V, D> item) {
    final result = <V>[item.value];
    for (final child in _getChildren(item)) {
      result.addAll(_collectAllValues(child));
    }
    return result;
  }

  void _handleItemTap(TreeSelectItem<V, D> item) {
    if (item.disabled) return;

    if (widget.multiple) {
      _handleMultiSelect(item);
    } else {
      // 单选：直接回调并关闭
      widget.onSelect?.call(item.value, item.data);
      Navigator.of(context).pop(item.value);
    }
  }

  void _handleMultiSelect(TreeSelectItem<V, D> item) {
    setState(() {
      final isSelected = _selectedValues.contains(item.value);
      if (widget.checkStrictly) {
        // 父子联动
        final allValues = _collectAllValues(item);
        if (isSelected) {
          _selectedValues.removeAll(allValues);
        } else {
          _selectedValues.addAll(allValues);
        }
        // 向上更新祖先状态
        _updateAncestors(widget.items ?? []);
      } else {
        // 父子独立
        if (isSelected) {
          _selectedValues.remove(item.value);
        } else {
          _selectedValues.add(item.value);
        }
      }
    });
  }

  /// 向上更新祖先节点的选中状态（联动模式下）
  void _updateAncestors(List<TreeSelectItem<V, D>> items) {
    for (final item in items) {
      final children = _getChildren(item);
      if (children.isNotEmpty) {
        _updateAncestors(children);
        final childValues = children.map((c) => c.value).toList();
        final allChildrenSelected = childValues.every((v) => _selectedValues.contains(v));
        final anyChildSelected = childValues.any((v) => _selectedValues.contains(v));
        if (allChildrenSelected) {
          _selectedValues.add(item.value);
        } else if (!anyChildSelected) {
          _selectedValues.remove(item.value);
        }
        // 部分选中时不加入 selectedValues，由 _isPartial 判断
      }
    }
  }

  /// 判断节点是否部分选中（联动模式）
  bool _isPartial(TreeSelectItem<V, D> item) {
    if (!widget.multiple || !widget.checkStrictly) return false;
    if (_selectedValues.contains(item.value)) return false;
    final children = _getChildren(item);
    if (children.isEmpty) return false;
    // 有任一后代选中即为 partial
    return _hasAnyDescendantSelected(children);
  }

  bool _hasAnyDescendantSelected(List<TreeSelectItem<V, D>> items) {
    for (final item in items) {
      if (_selectedValues.contains(item.value)) return true;
      if (_hasAnyDescendantSelected(_getChildren(item))) return true;
    }
    return false;
  }

  void _handleConfirm() {
    final selectedItems = <TreeSelectItem<V, D>>[];
    _collectSelectedItems(widget.items ?? [], selectedItems);
    final values = selectedItems.map((i) => i.value).toList();
    final datas = selectedItems.map((i) => i.data).toList();
    widget.onConfirm?.call(values, datas);
    Navigator.of(context).pop();
  }

  void _collectSelectedItems(
      List<TreeSelectItem<V, D>> items, List<TreeSelectItem<V, D>> result) {
    for (final item in items) {
      if (_selectedValues.contains(item.value) && item.effectiveIsLeaf) {
        result.add(item);
      }
      _collectSelectedItems(_getChildren(item), result);
    }
  }

  // ─── 构建 UI ───

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: BoxDecoration(
              color: theme.canvasColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TreeSheetDragHandle(),
                TreeSheetHeader(
                  title: widget.title,
                  subtitle: widget.subtitle,
                  onClose: () => Navigator.of(context).pop(),
                ),
                TreeSheetSearchField(
                  hint: widget.searchHint,
                  keyword: _keyword,
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onClear: _onSearchClear,
                ),
                Flexible(child: _buildContent(theme)),
              ],
            ),
          ),
          if (widget.multiple)
            TreeSheetBottomBar(
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

  Widget _buildContent(ThemeData theme) {
    // 远程搜索模式
    if (widget.onSearch != null) {
      return _buildSearchContent(theme);
    }
    // 本地数据模式
    final items = widget.items ?? [];
    if (items.isEmpty) {
      return const SizedBox(
        height: 120,
        child: TreeEmptyState(message: '暂无数据'),
      );
    }
    final filteredItems = _keyword.isEmpty ? items : _filterLocal(items);
    if (filteredItems.isEmpty) {
      return SizedBox(
        height: 120,
        child: TreeEmptyState(
          message: _keyword.isEmpty ? widget.emptyText : '未找到匹配的数据',
          icon: Icons.search_off,
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      shrinkWrap: true,
      children: _buildTreeNodes(filteredItems, 0),
    );
  }

  Widget _buildSearchContent(ThemeData theme) {
    if (_isSearching) {
      return const SizedBox(
        height: 120,
        child: TreeLoadingState(message: '搜索中...'),
      );
    }
    if (_keyword.isEmpty && !_hasSearched) {
      return const SizedBox(
        height: 120,
        child: TreeEmptyState(
          message: '请输入关键字搜索',
          icon: Icons.search,
        ),
      );
    }
    if (_searchResults.isEmpty) {
      return SizedBox(
        height: 120,
        child: TreeEmptyState(
          message: _hasSearched ? '未找到匹配的数据' : '请输入关键字搜索',
          icon: Icons.search_off,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      shrinkWrap: true,
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final isSelected = _selectedValues.contains(result.item.value);
        return _SearchResultTile(
          label: result.item.label,
          path: result.path,
          keyword: _keyword,
          isChecked: isSelected,
          multiple: widget.multiple,
          onTap: () => _handleSearchResultTap(result),
        );
      },
    );
  }

  void _handleSearchResultTap(TreeSearchResult<V, D> result) {
    if (result.item.disabled) return;
    if (widget.multiple) {
      setState(() {
        if (_selectedValues.contains(result.item.value)) {
          _selectedValues.remove(result.item.value);
        } else {
          _selectedValues.add(result.item.value);
        }
      });
    } else {
      widget.onSelect?.call(result.item.value, result.item.data);
      Navigator.of(context).pop(result.item.value);
    }
  }

  /// 本地过滤：递归过滤，如果子节点匹配则保留父节点
  List<TreeSelectItem<V, D>> _filterLocal(List<TreeSelectItem<V, D>> items) {
    final result = <TreeSelectItem<V, D>>[];
    for (final item in items) {
      final matchesSelf = item.label.toLowerCase().contains(_keyword.toLowerCase());
      final children = _getChildren(item);
      final filteredChildren = _filterLocal(children);
      if (matchesSelf || filteredChildren.isNotEmpty) {
        result.add(TreeSelectItem<V, D>(
          label: item.label,
          value: item.value,
          data: item.data,
          subtitle: item.subtitle,
          children: matchesSelf ? children : filteredChildren,
          isLeaf: item.isLeaf,
          disabled: item.disabled,
        ));
        // 自动展开匹配的节点
        if (filteredChildren.isNotEmpty) {
          _expandedValues.add(item.value);
        }
      }
    }
    return result;
  }

  /// 递归构建树节点列表
  List<Widget> _buildTreeNodes(List<TreeSelectItem<V, D>> items, int depth) {
    final widgets = <Widget>[];
    for (final item in items) {
      final isExpanded = _expandedValues.contains(item.value);
      final isLoading = _loadingValues.contains(item.value);
      final children = _getChildren(item);
      final isLeaf = item.effectiveIsLeaf && !isLoading;

      widgets.add(TreeNodeTile(
        depth: depth,
        label: item.label,
        subtitle: item.subtitle,
        isLeaf: isLeaf,
        isExpanded: isExpanded,
        isChecked: _selectedValues.contains(item.value),
        isPartial: _isPartial(item),
        isDisabled: item.disabled,
        multiple: widget.multiple,
        onTap: () => _handleItemTap(item),
        onToggleExpand: isLeaf ? null : () => _toggleExpand(item),
        trailing: (!isLeaf && !isExpanded)
            ? Text(
                '${children.length} 项',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              )
            : null,
      ));

      // 展开时显示子节点
      if (isExpanded) {
        if (isLoading) {
          widgets.add(TreeNodeInlineLoading(depth: depth + 1));
        } else if (children.isNotEmpty) {
          widgets.addAll(_buildTreeNodes(children, depth + 1));
        }
      }
    }
    return widgets;
  }
}

/// 搜索结果行（带面包屑路径）
class _SearchResultTile extends StatelessWidget {
  final String label;
  final List<String> path;
  final String keyword;
  final bool isChecked;
  final bool multiple;
  final VoidCallback? onTap;

  const _SearchResultTile({
    required this.label,
    required this.path,
    required this.keyword,
    required this.isChecked,
    required this.multiple,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              if (multiple) ...[
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isChecked ? primary : Colors.transparent,
                    border: Border.all(
                      color: isChecked ? primary : Colors.grey.shade400,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHighlightedLabel(theme),
                    if (path.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: path
                            .expand((p) => [
                                  Text(p,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500])),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    child: Icon(Icons.chevron_right,
                                        size: 14, color: Colors.grey),
                                  ),
                                ])
                            .toList()
                          ..add(Text(label,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey[500]))),
                      ),
                    ],
                  ],
                ),
              ),
              if (!multiple && isChecked)
                Icon(Icons.check_circle, color: primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedLabel(ThemeData theme) {
    if (keyword.isEmpty) {
      return Text(label,
          style: const TextStyle(fontSize: 15, color: Colors.black87));
    }
    final lowerLabel = label.toLowerCase();
    final lowerKw = keyword.toLowerCase();
    final idx = lowerLabel.indexOf(lowerKw);
    if (idx < 0) {
      return Text(label,
          style: const TextStyle(fontSize: 15, color: Colors.black87));
    }
    return Text.rich(TextSpan(children: [
      TextSpan(
          text: label.substring(0, idx),
          style: const TextStyle(fontSize: 15, color: Colors.black87)),
      TextSpan(
        text: label.substring(idx, idx + keyword.length),
        style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            backgroundColor: Color(0xFFFFF3CD),
            fontWeight: FontWeight.w600),
      ),
      TextSpan(
          text: label.substring(idx + keyword.length),
          style: const TextStyle(fontSize: 15, color: Colors.black87)),
    ]));
  }
}
