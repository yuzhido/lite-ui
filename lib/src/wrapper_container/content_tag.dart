import 'package:flutter/material.dart';

/// 标签组件,用于显示内容标签样式
class ContentTag extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  const ContentTag({super.key, required this.label, required this.bgColor, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 13, color: textColor)),
    );
  }
}
