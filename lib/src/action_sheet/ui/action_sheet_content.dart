import 'package:flutter/material.dart';
import 'package:lite_ui/src/models/index.dart';

import 'widgets/list_view.dart';

/// ActionSheetContent 本地固定数据组件
///
/// 包含：标题 + 描述 + 可滚动操作项列表 + 取消按钮
/// 用于 [ActionSheetType.local] 模式，可直接独立使用或嵌入弹窗。
///
/// 支持两种数据模式：
/// - [items]：普通列表模式
/// - [sections]：分组模式（优先于 items）
///
/// 泛型参数：
/// - [V] 选项 value 的类型
/// - [D] 选项 data 的类型（可选原始数据）
class ActionSheetContent<V, D> extends StatelessWidget {
  /// 主标题
  final String? title;

  /// 描述文本
  final String? description;

  /// 操作项列表（普通模式）
  final List<SelectItem<V, D>>? items;

  /// 分组数据（优先于 items）
  final List<ActionSheetSection<V, D>>? sections;

  /// 操作项点击回调，返回选中的 value 和 data
  final OnSelectChange<V, D>? onSelect;

  /// 取消按钮文字，默认为「取消」
  final String cancelLabel;

  /// 是否显示禁用项标签
  final bool showDisabledBadge;

  /// 最大高度（覆盖默认的 75% 屏幕高度）
  final double? maxHeight;

  const ActionSheetContent({
    super.key,
    this.title,
    this.description,
    this.items,
    this.sections,
    this.onSelect,
    this.cancelLabel = '取消',
    this.showDisabledBadge = false,
    this.maxHeight,
  });

  bool get _hasHeader => title != null || description != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? screenHeight * 0.75;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: effectiveMaxHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 内容卡片
              Flexible(
                child: Container(
                  decoration: BoxDecoration(color: theme.canvasColor, borderRadius: BorderRadius.circular(14)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题 + 描述（固定）
                      if (_hasHeader)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (title != null)
                                Text(
                                  title!,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              if (title != null && description != null) const SizedBox(height: 6),
                              if (description != null)
                                Text(
                                  description!,
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.55), height: 1.4),
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),
                      // 操作项列表
                      Flexible(
                        child: SingleChildScrollView(
                          child: ActionSheetListView<V, D>(sections: sections, items: items, onSelect: onSelect, showDisabledBadge: showDisabledBadge),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 取消按钮（固定）
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: theme.canvasColor, borderRadius: BorderRadius.circular(14)),
                clipBehavior: Clip.antiAlias,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text(cancelLabel, style: theme.textTheme.titleMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
