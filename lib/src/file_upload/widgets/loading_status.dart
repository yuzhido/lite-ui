import 'package:flutter/material.dart';

/// 构建加载占位符（灰色背景 + 环形动画）
class LoadingStatus extends StatelessWidget {
  final double size;
  final double progress;
  final double borderRadius;
  final Color? color;
  final Color? bgColor;
  const LoadingStatus({super.key, this.size = 0, this.progress = 0, this.borderRadius = 0, this.color, this.bgColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(borderRadius)),
      child: Center(
        child: SizedBox(
          width: size * 0.3,
          height: size * 0.3,
          child: CircularProgressIndicator(strokeWidth: 2.5, value: progress > 0 ? progress : null, color: color, backgroundColor: bgColor),
        ),
      ),
    );
  }
}
