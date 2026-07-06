import 'package:flutter/material.dart';

import 'model.dart';

/// ActionSheet 本地固定数据组件
///
/// 包含：标题 + 描述 + 可滚动操作项列表 + 取消按钮
/// 用于 [ActionSheetType.local] 模式，可直接独立使用或嵌入弹窗。
class ActionSheetLocal extends StatelessWidget {
  /// 主标题
  final String? title;

  /// 描述文本
  final String? description;

  /// 操作项列表
  final List<ActionSheetItem>? items;

  /// 操作项点击回调，返回点击的索引
  final ValueChanged<int>? onSelect;

  /// 取消按钮文字，默认为「取消」
  final String cancelLabel;

  const ActionSheetLocal({super.key, this.title, this.description, this.items, this.onSelect, this.cancelLabel = '取消'});

  bool get _hasHeader => title != null || description != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 内容卡片
        Flexible(
          child: Container(
            decoration: BoxDecoration(color: theme.canvasColor, borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: _buildContent(theme),
          ),
        ),

        const SizedBox(height: 8),

        // 取消按钮（固定）
        _buildCancelButton(context, theme),
      ],
    );
  }

  /// 内容区域：标题 + 描述 + 可滚动操作项列表
  Widget _buildContent(ThemeData theme) {
    return Column(
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
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.55), height: 1.4),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        // 操作项（可滚动）
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: (items ?? []).asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (index > 0 || _hasHeader) Divider(height: 0.5, thickness: 0.5),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => onSelect?.call(index),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item.label, style: theme.textTheme.titleMedium?.copyWith(color: item.textColor ?? theme.colorScheme.primary)),
                            if (item.subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.subtitle!,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), height: 1.3),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建取消按钮
  Widget _buildCancelButton(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: theme.canvasColor, borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
        child: Text(cancelLabel, style: theme.textTheme.titleMedium),
      ),
    );
  }
}
