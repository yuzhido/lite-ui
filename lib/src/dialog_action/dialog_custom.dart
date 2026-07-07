import 'package:flutter/material.dart';

/// Custom 自定义内容弹窗
///
/// 仅壳子，内容由外部传入
/// 用于 [DialogActionType.custom] 模式
class DialogCustom extends StatelessWidget {
  /// 自定义内容 Widget
  final Widget child;

  const DialogCustom({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
