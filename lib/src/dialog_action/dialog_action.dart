import 'package:flutter/material.dart';
import 'package:lite_ui/src/dialog_action/models/index.dart';

import 'ui/dialog_alert.dart';
import 'ui/dialog_input.dart';
import 'ui/dialog_custom.dart';
import 'ui/dialog_confirm.dart';
import 'ui/dialog_multi_action.dart';

/// 居中弹窗组件
///
/// 支持多种弹窗类型：
/// - [DialogType.alert]：提示弹窗（标题+内容+确认按钮）
/// - [DialogType.confirm]：确认弹窗（标题+内容+取消/确认双按钮）
/// - [DialogType.input]：输入弹窗（标题+输入框+取消/确认按钮）
/// - [DialogType.multiAction]：多操作弹窗（标题+内容+多按钮纵向排列）
/// - [DialogType.custom]：自定义内容弹窗（仅壳子，内容由外部传入）
///
/// 该组件只负责弹窗壳子（showDialog），
/// 不同类型内容渲染委托给对应的子组件。
///
/// 泛型参数：
/// - [V] 按钮 value 的类型
class DialogAction {
  /// 显示一个居中弹窗
  ///
  /// [type] 弹窗类型，默认为 [DialogType.alert]
  /// [title] 主标题
  /// [content] 内容文本
  /// [icon] 自定义图标 Widget（显示在标题上方，优先级高于 [presetIcon]）
  /// [presetIcon] 预设图标类型（success/warning/error/info）
  ///
  /// --- alert 模式参数 ---
  /// [confirmLabel] 确认按钮文字
  ///
  /// --- confirm 模式参数 ---
  /// [cancelLabel] 取消按钮文字
  /// [confirmStyle] 确认按钮样式
  ///
  /// --- input 模式参数 ---
  /// [hintText] 输入框提示文字
  /// [initialValue] 输入框初始值
  /// [maxLength] 最大输入长度
  /// [onInputConfirm] 输入确认回调（返回输入文本）
  ///
  /// --- multiAction 模式参数 ---
  /// [actions] 操作按钮列表
  /// [onAction] 操作按钮点击回调
  ///
  /// --- custom 模式参数 ---
  /// [customChild] 自定义内容 Widget
  ///
  /// --- 通用参数 ---
  /// [barrierDismissible] 点击遮罩是否可关闭，默认 true
  /// [barrierColor] 遮罩颜色
  static Future<V?> show<V>({
    required BuildContext context,
    DialogType type = DialogType.alert,
    String? title,
    String? content,

    // icon 相关
    Widget? icon,
    DialogPresetIcon? presetIcon,

    // 按钮文字（传值覆盖默认）
    String? confirmLabel,
    String? cancelLabel,
    DialogButtonStyle confirmStyle = DialogButtonStyle.primary,

    // confirm 专属
    VoidCallback? onCancel,
    VoidCallback? onConfirm,

    // input 专属
    String? hintText,
    String? initialValue,
    int? maxLength,
    DialogInputCallback? onInputConfirm,

    // multiAction 专属
    List<DialogActionButton<V>>? actions,
    DialogActionCallback<V>? onAction,

    // custom 专属
    Widget? customChild,

    // 通用
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    // 根据 type 解析默认值
    final defaults = _resolveDefaults(type, title, content, confirmLabel, cancelLabel, hintText);

    return showDialog<V>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Theme.of(ctx).canvasColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
            child: _buildContent<V>(
              type: type,
              title: defaults.title,
              content: defaults.content,
              icon: icon,
              presetIcon: presetIcon,
              confirmLabel: defaults.confirmLabel,
              cancelLabel: defaults.cancelLabel,
              confirmStyle: confirmStyle,
              onCancel: onCancel,
              onConfirm: onConfirm,
              hintText: defaults.hintText,
              initialValue: initialValue,
              maxLength: maxLength,
              onInputConfirm: onInputConfirm,
              actions: actions,
              onAction: onAction,
              customChild: customChild,
              ctx: ctx,
            ),
          ),
        );
      },
    );
  }

  /// 根据 type 解析默认值，用户传值优先覆盖
  static DialogDefaults _resolveDefaults(DialogType type, String? title, String? content, String? confirmLabel, String? cancelLabel, String? hintText) {
    switch (type) {
      case DialogType.alert:
        return DialogDefaults(title: title ?? '提示', content: content, confirmLabel: confirmLabel ?? '确定', cancelLabel: cancelLabel ?? '取消', hintText: hintText ?? '请输入');
      case DialogType.confirm:
        return DialogDefaults(
          title: title ?? '确认操作',
          content: content ?? '确定要执行此操作吗？',
          confirmLabel: confirmLabel ?? '确定',
          cancelLabel: cancelLabel ?? '取消',
          hintText: hintText ?? '请输入',
        );
      case DialogType.input:
        return DialogDefaults(title: title ?? '请输入', content: content, confirmLabel: confirmLabel ?? '确定', cancelLabel: cancelLabel ?? '取消', hintText: hintText ?? '请输入');
      case DialogType.multiAction:
        return DialogDefaults(title: title ?? '选择操作', content: content, confirmLabel: confirmLabel ?? '确定', cancelLabel: cancelLabel ?? '取消', hintText: hintText ?? '请输入');
      case DialogType.custom:
        return DialogDefaults(title: title, content: content, confirmLabel: confirmLabel ?? '确定', cancelLabel: cancelLabel ?? '取消', hintText: hintText ?? '请输入');
    }
  }

  /// 根据 type 渲染对应的内容组件
  static Widget _buildContent<V>({
    required DialogType type,
    required String? title,
    required String? content,
    required Widget? icon,
    required DialogPresetIcon? presetIcon,
    required String confirmLabel,
    required String cancelLabel,
    required DialogButtonStyle confirmStyle,
    required VoidCallback? onCancel,
    required VoidCallback? onConfirm,
    required String hintText,
    required String? initialValue,
    required int? maxLength,
    required DialogInputCallback? onInputConfirm,
    required List<DialogActionButton<V>>? actions,
    required DialogActionCallback<V>? onAction,
    required Widget? customChild,
    required BuildContext ctx,
  }) {
    switch (type) {
      case DialogType.alert:
        return DialogAlert(
          title: title,
          content: content,
          icon: icon,
          presetIcon: presetIcon,
          confirmLabel: confirmLabel,
          onConfirm: () {
            onConfirm?.call();
            Navigator.of(ctx).pop();
          },
        );

      case DialogType.confirm:
        return DialogConfirm(
          title: title,
          content: content,
          icon: icon,
          presetIcon: presetIcon,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          confirmStyle: confirmStyle,
          onCancel: () {
            onCancel?.call();
            Navigator.of(ctx).pop();
          },
          onConfirm: () {
            onConfirm?.call();
            Navigator.of(ctx).pop(true);
          },
        );

      case DialogType.input:
        return DialogInput(
          title: title,
          content: content,
          icon: icon,
          presetIcon: presetIcon,
          hintText: hintText,
          initialValue: initialValue,
          maxLength: maxLength,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          onCancel: () {
            onCancel?.call();
            Navigator.of(ctx).pop();
          },
          onConfirm: (text) {
            onInputConfirm?.call(text);
            Navigator.of(ctx).pop(text);
          },
        );

      case DialogType.multiAction:
        return DialogMultiAction<V>(
          title: title,
          content: content,
          icon: icon,
          presetIcon: presetIcon,
          actions: actions ?? [],
          onAction: (value) {
            onAction?.call(value);
            Navigator.of(ctx).pop(value);
          },
        );

      case DialogType.custom:
        return DialogCustom(child: customChild ?? const SizedBox.shrink());
    }
  }
}
