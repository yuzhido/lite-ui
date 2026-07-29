import 'package:flutter/material.dart';

import '../../../models/select_item.dart';
import '../../../widgets/empty_state.dart';
import 'check_list_item.dart';

/// SelectModal 内容列表组件
///
/// 负责展示 Loading / 空状态 / 数据列表三种状态的内容区域。
///
/// 泛型参数：
/// - [V] 选项 value 的类型
/// - [D] 选项 data 的类型（可选原始数据）
class SelectModalContentList<V, D> extends StatelessWidget {
  /// 是否正在加载
  final bool isLoading;

  /// 当前显示的数据列表
  final List<SelectItem<V, D>> displayItems;

  /// 是否为远程模式（影响空状态提示）
  final bool isRemote;

  /// 搜索是否执行过（仅 remote 模式，控制空状态提示）
  final bool hasSearched;

  /// 空状态提示文字（仅 isRemote=true 时有效）
  final String emptyText;

  /// 当前选中项的 value 集合
  final Set<V> selectedValues;

  /// 是否为多选模式
  final bool multiple;

  /// 列表项点击回调
  final void Function(SelectItem<V, D> item) onItemTap;

  const SelectModalContentList({
    required this.isLoading,
    required this.displayItems,
    required this.selectedValues,
    required this.onItemTap,
    this.isRemote = false,
    this.hasSearched = false,
    this.emptyText = '暂无数据',
    this.multiple = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && displayItems.isEmpty) {
      return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    if (displayItems.isEmpty) {
      if (isRemote) {
        return EmptyState(message: hasSearched ? emptyText : '请输入关键字搜索', icon: hasSearched ? Icons.search_off : Icons.search);
      }
      return const EmptyState(message: '无匹配数据');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        final item = displayItems[index];
        return SelectModalCheckListItem(
          label: item.label,
          subtitle: item.subtitle,
          icon: item.icon,
          iconData: item.iconData,
          iconColor: item.iconColor,
          iconSize: item.iconSize,
          isChecked: selectedValues.contains(item.value),
          isDisabled: item.disabled,
          multiple: multiple,
          onTap: () => onItemTap(item),
        );
      },
    );
  }
}
