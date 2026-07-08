import 'package:flutter/material.dart';
import 'package:lite_ui/src/models/index.dart';

import 'ui/action_sheet_content.dart';

/// 底部弹窗显示数据操作
///
/// 支持多种内容类型：
/// - [ActionSheetType.local]：本地固定数据（标题+描述+操作项列表）
/// - [ActionSheetType.custom]：自定义 Widget 内容
///
/// 该组件只负责弹窗壳子（showModalBottomSheet），
/// 不同模式内容渲染委托给对应的子组件。
///
/// 泛型参数：
/// - [V] 选项 value 的类型
/// - [D] 选项 data 的类型（可选原始数据）
class ActionSheet {
  /// 显示一个从底部向上弹出的 ActionSheet
  ///
  /// [type] 内容类型，默认为 [ActionSheetType.local]
  /// [title] 主标题
  /// [description] 副标题/描述
  /// [items] 操作项列表（local 模式）
  /// [sections] 分组数据（优先于 items，仅 local 模式支持）
  /// [customChild] 自定义内容 Widget（custom 模式）
  /// [cancelLabel] 取消按钮文字，默认为「取消」
  /// [showDisabledBadge] 是否显示禁用项标签，默认 false
  /// [maxHeight] 自定义最大高度（覆盖默认的 75%）
  static Future<V?> show<V, D>({
    required BuildContext context,
    ActionSheetType type = ActionSheetType.local,
    String? title,
    String? description,
    List<SelectItem<V, D>>? items,
    List<ActionSheetSection<V, D>>? sections,
    Widget? customChild,
    String cancelLabel = '取消',
    bool showDisabledBadge = false,
    double? maxHeight,
    OnSelectChange<V, D>? onSelect,
  }) {
    return showModalBottomSheet<V>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        switch (type) {
          case ActionSheetType.local:
            return ActionSheetContent<V, D>(
              title: title,
              description: description,
              sections: sections,
              items: items,
              showDisabledBadge: showDisabledBadge,
              maxHeight: maxHeight,
              onSelect: (value, data) {
                onSelect?.call(value, data);
                Navigator.of(ctx).pop(value);
              },
              cancelLabel: cancelLabel,
            );

          case ActionSheetType.custom:
            final screenHeight = MediaQuery.of(ctx).size.height;
            final effectiveMaxHeight = maxHeight ?? screenHeight * 0.75;
            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: effectiveMaxHeight),
                child: customChild ?? const SizedBox.shrink(),
              ),
            );
        }
      },
    );
  }
}
