import 'package:flutter/material.dart';
import 'package:lite_ui/src/models/dialog_action.dart';

import 'dialog_widgets.dart';

/// Alert 提示弹窗
///
/// 包含：标题 + 内容 + 单个确认按钮
/// 用于 [DialogActionType.alert] 模式
class DialogAlert extends StatelessWidget {
  /// 主标题
  final String? title;

  /// 内容文本
  final String? content;

  /// 自定义图标 Widget
  final Widget? icon;

  /// 预设图标类型
  final DialogPresetIcon? presetIcon;

  /// 确认按钮文字
  final String confirmLabel;

  /// 确认按钮点击回调
  final VoidCallback? onConfirm;

  const DialogAlert({this.title, this.content, this.icon, this.presetIcon, this.confirmLabel = '确定', this.onConfirm, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DialogTitleSection(title: title, content: content, icon: icon, presetIcon: presetIcon),
        DialogButtonBar(
          buttons: [DialogActionButton(label: confirmLabel, value: 'confirm', style: DialogButtonStyle.primary)],
          onPressed: (_) => onConfirm,
        ),
      ],
    );
  }
}
