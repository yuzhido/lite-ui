import 'package:flutter/material.dart';

/// 右上角删除按钮
class CardDeleteBtn extends StatelessWidget {
  final VoidCallback? onRemove;
  const CardDeleteBtn({this.onRemove, super.key});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: GestureDetector(
        onTap: onRemove,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
          child: const Icon(Icons.close, color: Colors.white, size: 14),
        ),
      ),
    );
  }
}
