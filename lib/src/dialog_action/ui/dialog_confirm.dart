import 'package:flutter/material.dart';

import 'package:lite_ui/src/models/dialog_action.dart';
import 'dialog_widgets.dart';

/// Confirm 确认弹窗
///
/// 包含：标题 + 内容 + 取消/确认双按钮
/// 用于 [DialogActionType.confirm] 模式
class DialogConfirm extends StatelessWidget {
  /// 主标题
  final String? title;

  /// 内容文本
  final String? content;

  /// 自定义图标 Widget
  final Widget? icon;

  /// 预设图标类型
  final DialogPresetIcon? presetIcon;

  /// 取消按钮文字
  final String cancelLabel;

  /// 确认按钮文字
  final String confirmLabel;

  /// 确认按钮样式
  final DialogButtonStyle confirmStyle;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 确认回调
  final VoidCallback? onConfirm;

  const DialogConfirm({
    this.title,
    this.content,
    this.icon,
    this.presetIcon,
    this.cancelLabel = '取消',
    this.confirmLabel = '确定',
    this.confirmStyle = DialogButtonStyle.primary,
    this.onCancel,
    this.onConfirm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DialogTitleSection(title: title, content: content, icon: icon, presetIcon: presetIcon),
        DialogButtonBar(
          buttons: [
            DialogActionButton(label: cancelLabel, value: 'cancel', style: DialogButtonStyle.normal),
            DialogActionButton(label: confirmLabel, value: 'confirm', style: confirmStyle),
          ],
          onPressed: (value) {
            if (value == 'cancel') return onCancel;
            return onConfirm;
          },
        ),
      ],
    );
  }
}
