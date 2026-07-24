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
      child: InkWell(
        onTap: onRemove,
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 3, offset: const Offset(0, 1))],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
          ),
        ),
      ),
    );
  }
}
