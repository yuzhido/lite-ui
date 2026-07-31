import 'package:flutter/material.dart';

import '../../../models/index.dart';
import '../../models/index.dart';
import 'sheet_item.dart';

/// ActionSheet 操作项列表视图
///
/// 统一处理分组模式和普通模式的渲染：
/// - 分组模式：每组包裹在 [if (_hasSections) ] 中，项之间无分割线
/// - 普通模式：扁平列表，项之间显示分割线
class ActionSheetListView<V, D> extends StatelessWidget {
  /// 分组数据（优先于 items）
  final List<ActionSheetSection<V, D>>? sections;

  /// 操作项列表（普通模式）
  final List<SelectItem<V, D>>? items;

  /// 操作项点击回调
  final OnSelectChange<V, D>? onSelect;

  /// 是否显示禁用项标签
  final bool showDisabledBadge;

  const ActionSheetListView({super.key, this.sections, this.items, this.onSelect, this.showDisabledBadge = false});

  bool get _hasSections => sections != null && sections!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_hasSections) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: sections!.map((section) {
          final itemList = section.items;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 分组标题
              if (section.title != null && section.title?.isNotEmpty == true)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(section.title ?? ''.toUpperCase(), style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93), letterSpacing: 0.5)),
                ),
              // 操作项列表
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: itemList.asMap().entries.map((entry) {
                    final isLast = entry.key == itemList.length - 1;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildItem(theme, entry.value),
                        if (!isLast) Divider(height: 0.5, thickness: 0.5, color: Theme.of(context).dividerColor.withValues(alpha: 0.1), indent: 16, endIndent: 0),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // 组间距
              const SizedBox(height: 10),
            ],
          );
        }).toList(),
      );
    }

    final itemList = items ?? [];
    if (itemList.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: theme.canvasColor, borderRadius: BorderRadius.circular(14)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: itemList.asMap().entries.map((entry) {
          final isLast = entry.key == itemList.length - 1;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildItem(theme, entry.value),
              if (!isLast) Divider(height: 0.5, thickness: 0.5, color: theme.dividerColor.withValues(alpha: 0.1), indent: 16, endIndent: 0),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 构建单个操作项
  Widget _buildItem(ThemeData theme, SelectItem<V, D> item) {
    return ActionSheetItem(
      label: item.label,
      subtitle: item.subtitle,
      icon: item.icon,
      iconData: item.iconData,
      iconColor: item.iconColor,
      iconSize: item.iconSize,
      isDisabled: item.disabled,
      disabledLabel: item.disabledLabel,
      showDisabledBadge: showDisabledBadge,
      onTap: () => onSelect?.call(item.value, item, item.data),
    );
  }
}
