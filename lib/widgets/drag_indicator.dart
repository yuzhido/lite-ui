import 'package:flutter/material.dart';

/// 拖拽手柄指示器
///
/// 底部弹窗顶部的短横条，提示用户可拖拽关闭。
class DragIndicator extends StatelessWidget {
  /// 是否使用主题颜色，默认 true
  ///
  /// 为 true 时使用 `Theme.of(context).colorScheme.outlineVariant`
  /// 为 false 时使用固定的灰色 `Colors.grey.shade300`
  final bool useThemeColor;

  const DragIndicator({this.useThemeColor = true, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final handleColor = useThemeColor ? theme.colorScheme.outlineVariant : Colors.grey.shade300;

    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 0),
        width: 40,
        height: 4,
        decoration: BoxDecoration(color: handleColor, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}
