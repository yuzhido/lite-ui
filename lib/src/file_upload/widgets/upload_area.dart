import 'package:flutter/material.dart';

class UploadArea extends StatelessWidget {
  const UploadArea({super.key, this.onTap, this.size = 120});

  final VoidCallback? onTap;

  /// 上传区域尺寸，默认 100，应与 [FilePreview] 的 size 保持一致
  final double size;

  /// 上传按钮区域 UI
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: const Alignment(0, 0),
        child: const Text('点击上传'),
      ),
    );
  }
}
