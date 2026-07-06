import 'package:flutter/material.dart';

import 'model.dart';
import 'tree_widgets.dart';

/// 横向级联树形选择器
///
/// 多列并排显示，逐级选择。支持单选和多选模式。
/// 每选中一级，驱动下一列数据展示。
class TreeCascade<V, D> extends StatefulWidget {
  /// 标题
  final String? title;

  /// 副标题
  final String? subtitle;

  /// 本地树形数据
  final List<TreeSelectItem<V, D>> items;

  /// 级联列标题，如 ["省份", "城市", "区县"]
  final List<String>? cascadeLevels;

  /// 是否多选模式
  final bool multiple;

  /// 初始选中值集合
  final Set<V>? selectedValues;

  /// 单选回调
  final TreeOnSelectChange<V, D>? onSelect;

  /// 多选确认回调
  final TreeOnMultiSelectConfirm<V, D>? onConfirm;

  /// 取消按钮文字
  final String cancelLabel;

  /// 确定按钮文字
  final String confirmLabel;

  /// 懒加载子节点回调（支持异步级联）
  final TreeLazyLoadCallback<V, D>? onLoadChildren;

  const TreeCascade({
    super.key,
    this.title,
    this.subtitle,
    required this.items,
    this.cascadeLevels,
    this.multiple = false,
    this.selectedValues,
    this.onSelect,
    this.onConfirm,
    this.cancelLabel = '取消',
    this.confirmLabel = '确定',
    this.onLoadChildren,
  });

  @override
  State<TreeCascade<V, D>> createState() => _TreeCascadeState<V, D>();
}

class _TreeCascadeState<V, D> extends State<TreeCascade<V, D>> {
  /// 选中值集合
  Set<V> _selectedValues = {};

  /// 每级当前选中的节点（驱动下一级数据）
  /// 索引对应列，值为该列选中的节点
  final List<TreeSelectItem<V, D>?> _levelSelections = [];

  /// 每级显示的数据列表
  final List<List<TreeSelectItem<V, D>>> _levelData = [];

  /// 当前活跃的 tab 索引
  int _activeTab = 0;

  /// 正在加载的层级
  final Set<int> _loadingLevels = {};

  @override
  void initState() {
    super.initState();
    if (widget.selectedValues != null) {
      _selectedValues = Set.from(widget.selectedValues!);
    }
    // 初始化第一列数据
    _levelData.add(widget.items);
    _levelSelections.add(null);
  }

  /// 获取列标题
  String _getLevelTitle(int index) {
    if (widget.cascadeLevels != null && index < widget.cascadeLevels!.length) {
      return widget.cascadeLevels![index];
    }
    return '第${index + 1}级';
  }

  /// 处理列中的项点击
  void _handleLevelItemTap(int level, TreeSelectItem<V, D> item) {
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
      // 单选模式
      setState(() {
        // 更新当前级选中
        while (_levelSelections.length > level) {
          _levelSelections.removeLast();
        }
        _levelSelections.add(item);

        // 清除后续列
        while (_levelData.length > level + 1) {
          _levelData.removeLast();
        }

        // 加载下一级
        final children = item.children ?? [];
        if (children.isNotEmpty) {
          _levelData.add(children);
          _levelSelections.add(null);
          _activeTab = level + 1;
        } else if (widget.onLoadChildren != null && !item.effectiveIsLeaf) {
          // 懒加载
          _levelData.add([]);
          _levelSelections.add(null);
          _activeTab = level + 1;
          _doLazyLoad(level + 1, item);
        } else {
          // 叶子节点，完成选择
          _selectedValues.clear();
          _selectedValues.add(item.value);
          widget.onSelect?.call(item.value, item.data);
          Navigator.of(context).pop(item.value);
          return;
        }
      });
    }
  }

  Future<void> _doLazyLoad(int level, TreeSelectItem<V, D> parent) async {
    setState(() => _loadingLevels.add(level));
    try {
      final children = await widget.onLoadChildren!(parent);
      if (mounted) {
        setState(() {
          if (level < _levelData.length) {
            _levelData[level] = children;
          }
          _loadingLevels.remove(level);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingLevels.remove(level));
      }
    }
  }

  /// 切换 tab
  void _switchTab(int index) {
    setState(() => _activeTab = index);
  }

  /// 获取面包屑路径
  List<String> _buildBreadcrumb() {
    final parts = <String>[];
    for (final sel in _levelSelections) {
      if (sel != null) parts.add(sel.label);
    }
    return parts;
  }

  void _handleConfirm() {
    final values = _selectedValues.toList();
    // 尝试找到对应的 data
    final datas = <D?>[];
    for (final v in values) {
      datas.add(_findData(v, widget.items));
    }
    widget.onConfirm?.call(values, datas);
    Navigator.of(context).pop();
  }

  D? _findData(V value, List<TreeSelectItem<V, D>> items) {
    for (final item in items) {
      if (item.value == value) return item.data;
      if (item.children != null) {
        final found = _findData(value, item.children!);
        if (found != null) return found;
      }
    }
    return null;
  }

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
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            decoration: BoxDecoration(
              color: theme.canvasColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
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
                // Tab 栏
                _buildTabBar(theme),
                // 内容列
                Flexible(child: _buildCascadeBody(theme)),
              ],
            ),
          ),
          // 底部栏
          _buildBottomBar(theme),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    final primary = theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: List.generate(_levelData.length, (index) {
          final isActive = index == _activeTab;
          final selected = index < _levelSelections.length
              ? _levelSelections[index]
              : null;
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchTab(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getLevelTitle(index),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        color: isActive ? primary : theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    if (selected != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        selected.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: primary.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCascadeBody(ThemeData theme) {
    // 显示当前活跃 tab 对应的列
    if (_activeTab >= _levelData.length) {
      return const SizedBox(height: 200);
    }

    final isLoading = _loadingLevels.contains(_activeTab);
    if (isLoading) {
      return const SizedBox(
        height: 200,
        child: TreeLoadingState(message: '加载中...'),
      );
    }

    final data = _levelData[_activeTab];
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: TreeEmptyState(message: '暂无数据'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final isSelected = _selectedValues.contains(item.value) ||
            (_activeTab < _levelSelections.length &&
                _levelSelections[_activeTab]?.value == item.value);

        return _CascadeItemTile(
          label: item.label,
          subtitle: item.subtitle,
          isSelected: isSelected,
          isDisabled: item.disabled,
          hasChildren: !item.effectiveIsLeaf,
          multiple: widget.multiple,
          onTap: () => _handleLevelItemTap(_activeTab, item),
        );
      },
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    final breadcrumb = _buildBreadcrumb();
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 面包屑路径
            if (breadcrumb.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: breadcrumb
                            .expand((p) => [
                                  Text(
                                    p,
                                    style: TextStyle(
                                        fontSize: 12, color: primary),
                                  ),
                                  if (p != breadcrumb.last)
                                    Icon(Icons.chevron_right,
                                        size: 14,
                                        color: Colors.grey[400]),
                                ])
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            // 按钮行
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.multiple)
                  Expanded(
                    child: Text(
                      _selectedValues.isNotEmpty
                          ? '已选 ${_selectedValues.length} 项'
                          : '请选择',
                      style:
                          TextStyle(fontSize: 13, color: theme.hintColor),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(widget.cancelLabel,
                      style: TextStyle(color: theme.hintColor)),
                ),
                const SizedBox(width: 16),
                if (widget.multiple)
                  ElevatedButton(
                    onPressed: _selectedValues.isNotEmpty
                        ? _handleConfirm
                        : null,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor:
                          theme.colorScheme.outlineVariant,
                    ),
                    child: Text(widget.confirmLabel),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 级联列表项
class _CascadeItemTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool isSelected;
  final bool isDisabled;
  final bool hasChildren;
  final bool multiple;
  final VoidCallback? onTap;

  const _CascadeItemTile({
    required this.label,
    required this.isSelected,
    required this.hasChildren,
    this.subtitle,
    this.isDisabled = false,
    this.multiple = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Material(
        color: isSelected
            ? primary.withValues(alpha: 0.08)
            : Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (multiple) ...[
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isSelected ? primary : Colors.transparent,
                      border: Border.all(
                        color:
                            isSelected ? primary : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected ? primary : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasChildren && !multiple)
                  Icon(Icons.chevron_right,
                      size: 20, color: Colors.grey[400]),
                if (isSelected && !multiple)
                  Icon(Icons.check, size: 20, color: primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
