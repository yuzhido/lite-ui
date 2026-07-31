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
class ModalContentList<V, D> extends StatelessWidget {
  /// 是否正在加载
  final bool isLoading;

  /// 当前显示的数据列表
  final List<SelectItem<V, D>> displayItems;

  /// 是否为远程模式（影响空状态提示）
  final bool remote;

  /// 搜索是否执行过（仅 remote 模式，控制空状态提示）
  final bool hasSearched;

  /// 空状态提示文字（仅 remote=true 时有效）
  final String emptyText;

  /// 当前选中项的 value 集合
  final Set<V> selectedValues;

  /// 是否为多选模式
  final bool multiple;

  /// 列表项点击回调
  final void Function(SelectItem<V, D> item) onItemTap;

  /// 是否显示新增按钮
  final bool showAdd;

  /// 新增按钮文字
  final String addLabel;

  /// 新增按钮点击回调
  final VoidCallback? onAdd;

  const ModalContentList({
    required this.isLoading,
    required this.displayItems,
    required this.selectedValues,
    required this.onItemTap,
    this.remote = false,
    this.hasSearched = false,
    this.emptyText = '暂无数据',
    this.multiple = false,
    this.showAdd = false,
    this.addLabel = '新增',
    this.onAdd,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    if (displayItems.isEmpty) {
      if (remote) {
        return EmptyState(
          message: hasSearched ? emptyText : '请输入关键字搜索',
          icon: hasSearched ? Icons.search_off : Icons.search,
          showAdd: hasSearched && showAdd,
          addLabel: addLabel,
          onAdd: onAdd,
        );
      }
      return EmptyState(message: '无匹配数据', showAdd: showAdd, addLabel: addLabel, onAdd: onAdd);
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
