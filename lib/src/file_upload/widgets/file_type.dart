import 'dart:io';
import 'package:flutter/material.dart';

import '../model/file_info.dart';
import '../utils/file_utils.dart';

/// 文件类型图标/缩略图
///
/// - 图片文件：显示缩略图，加载失败时回退为文件类型图标
/// - 非图片文件：根据扩展名显示对应颜色的类型图标
///
/// 颜色和图标均由 [getFileColor] / [getFileIcon] 统一管理。
class FileType extends StatelessWidget {
  /// 文件信息
  final FileInfo fileInfo;

  /// 图标区域尺寸，默认 40
  final double size;

  const FileType({super.key, required this.fileInfo, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final color = getFileColor(fileInfo.extension);
    final icon = getFileIcon(fileInfo.extension);

    if (fileInfo.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(fileInfo.path),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: size * 0.5),
          ),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
