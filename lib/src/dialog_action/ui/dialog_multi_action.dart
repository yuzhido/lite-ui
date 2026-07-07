import 'package:flutter/material.dart';

import '../model.dart';
import 'dialog_widgets.dart';

/// MultiAction 多操作弹窗
///
/// 包含：标题 + 内容 + 多按钮纵向排列
/// 用于 [DialogActionType.multiAction] 模式
class DialogMultiAction<V> extends StatelessWidget {
  /// 主标题
  final String? title;

  /// 内容文本
  final String? content;

  /// 自定义图标 Widget
  final Widget? icon;

  /// 预设图标类型
  final DialogPresetIcon? presetIcon;

  /// 操作按钮列表
  final List<DialogActionButton<V>> actions;

  /// 按钮点击回调
  final DialogActionCallback<V>? onAction;

  const DialogMultiAction({this.title, this.content, this.icon, this.presetIcon, required this.actions, this.onAction, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DialogTitleSection(title: title, content: content, icon: icon, presetIcon: presetIcon),
        DialogButtonBar(
          buttons: actions,
          isVertical: true,
          onPressed: (value) {
            return () => onAction?.call(value as V);
          },
        ),
      ],
    );
  }
}
