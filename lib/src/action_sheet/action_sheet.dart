import 'package:flutter/material.dart';
import 'package:lite_ui/src/models/index.dart';
import 'package:lite_ui/src/widgets/choose_default_ui.dart';

import 'models/index.dart';
import 'ui/action_sheet_content.dart';

/// 底部弹窗显示数据操作
///
/// 支持三种使用方式：
/// 1. 自带默认触发器 UI：直接构造 ActionSheet，点击显示标题+描述的列表项弹出 Sheet
/// 2. 自定义触发器：传入 [child] 作为触发器，点击 child 弹出 Sheet
/// 3. 编程式调用：使用 [ActionSheet.show] 静态方法
///
/// 支持多种内容类型：
/// - [ActionSheetType.local]：本地固定数据（标题+描述+操作项列表）
/// - [ActionSheetType.custom]：自定义 Widget 内容
///
/// 该组件只负责弹窗壳子（showModalBottomSheet），
/// 不同模式内容渲染委托给对应的子组件。
class ActionSheet extends StatelessWidget {
  /// 自定义触发器 Widget（可选）
  ///
  /// 传入后点击该 child 弹出 Sheet；不传则渲染默认触发器 UI。
  final Widget? child;

  /// 内容类型，默认为 [ActionSheetType.local]
  final ActionSheetType type;

  /// 主标题
  final String? title;

  /// 副标题/描述
  final String? description;

  /// 操作项列表（local 模式）
  final List<SelectItem<dynamic, dynamic>>? items;

  /// 分组数据（优先于 items，仅 local 模式支持）
  final List<ActionSheetSection<dynamic, dynamic>>? sections;

  /// 自定义内容 Widget（custom 模式）
  final Widget? customChild;

  /// 取消按钮文字，默认为「取消」
  final String cancelLabel;

  /// 是否显示禁用项标签，默认 false
  final bool showDisabledBadge;

  /// 自定义最大高度（覆盖默认的 75%）
  final double? maxHeight;

  /// 选中回调
  final OnSelectChange<dynamic, dynamic>? onSelect;

  const ActionSheet({
    super.key,
    this.child,
    this.type = ActionSheetType.local,
    this.title,
    this.description,
    this.items,
    this.sections,
    this.customChild,
    this.cancelLabel = '取消',
    this.showDisabledBadge = false,
    this.maxHeight,
    this.onSelect,
  });

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

  void _showSheet(BuildContext context) {
    ActionSheet.show(
      context: context,
      type: type,
      title: title,
      description: description,
      items: items,
      sections: sections,
      customChild: customChild,
      cancelLabel: cancelLabel,
      showDisabledBadge: showDisabledBadge,
      maxHeight: maxHeight,
      onSelect: onSelect,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return GestureDetector(onTap: () => _showSheet(context), child: child);
    }
    // 默认触发器 UI：标题 + 描述 + 右箭头
    return GestureDetector(onTap: () => _showSheet(context), child: ChooseDefaultUi());
  }
}
