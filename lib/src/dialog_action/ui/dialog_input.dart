import 'package:flutter/material.dart';

import '../model.dart';
import 'dialog_widgets.dart';

/// Input 输入弹窗
///
/// 包含：标题 + 输入框 + 取消/确认按钮
/// 用于 [DialogActionType.input] 模式
class DialogInput extends StatefulWidget {
  /// 主标题
  final String? title;

  /// 内容文本（显示在输入框上方）
  final String? content;

  /// 自定义图标 Widget
  final Widget? icon;

  /// 预设图标类型
  final DialogPresetIcon? presetIcon;

  /// 输入框提示文本
  final String? hintText;

  /// 初始值
  final String? initialValue;

  /// 最大长度
  final int? maxLength;

  /// 取消按钮文字
  final String cancelLabel;

  /// 确认按钮文字
  final String confirmLabel;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 确认回调（返回输入文本）
  final DialogInputCallback? onConfirm;

  const DialogInput({
    this.title,
    this.content,
    this.icon,
    this.presetIcon,
    this.hintText = '请输入',
    this.initialValue,
    this.maxLength,
    this.cancelLabel = '取消',
    this.confirmLabel = '确定',
    this.onCancel,
    this.onConfirm,
    super.key,
  });

  @override
  State<DialogInput> createState() => _DialogInputState();
}

class _DialogInputState extends State<DialogInput> {
  late TextEditingController _controller;
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _currentText = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DialogTitleSection(title: widget.title, content: widget.content, icon: widget.icon, presetIcon: widget.presetIcon),
        DialogInputField(
          controller: _controller,
          hintText: widget.hintText,
          maxLength: widget.maxLength,
          onChanged: (text) {
            setState(() {
              _currentText = text;
            });
          },
        ),
        DialogButtonBar(
          buttons: [
            DialogActionButton(label: widget.cancelLabel, value: 'cancel', style: DialogButtonStyle.normal),
            DialogActionButton(label: widget.confirmLabel, value: 'confirm', style: DialogButtonStyle.primary, disabled: _currentText.isEmpty),
          ],
          onPressed: (value) {
            if (value == 'cancel') return widget.onCancel;
            return () => widget.onConfirm?.call(_currentText);
          },
        ),
      ],
    );
  }
}
