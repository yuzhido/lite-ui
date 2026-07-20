import 'dart:io';
import 'package:flutter/material.dart';

import '../model/file_info.dart';
import '../utils/file_utils.dart';

/// 文件类型图标/缩略图
///
/// - 图片文件：显示缩略图，加载失败时回退为文件类型图标
/// - 非图片文件：根据扩展名显示对应颜色的类型图标
///
/// 支持网络图片回显（当 [FileInfo.isNetwork] 为 true 时使用 [Image.network]，加载 [FileInfo.url]）。
/// 颜色和图标均由 [getFileColor] / [getFileIcon] 统一管理。
class FileType extends StatelessWidget {
  /// 文件信息
  final FileInfo fileInfo;

  /// 图标区域尺寸，默认 40
  final double size;

  const FileType({super.key, required this.fileInfo, this.size = 40});

  /// 构建加载占位符（浅色背景 + 小环形动画）
  Widget _buildLoadingPlaceholder(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF424242)),
        ),
      ),
    );
  }

  /// 构建错误占位符（浅色背景 + 文件类型图标）
  Widget _buildErrorPlaceholder(double size, Color color, IconData icon) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = getFileColor(fileInfo.extension);
    final icon = getFileIcon(fileInfo.extension);

    if (fileInfo.isImage) {
      final imageWidget = fileInfo.isNetwork
          ? Image.network(
              fileInfo.url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              cacheWidth: (size * 2).toInt(),
              cacheHeight: (size * 2).toInt(),
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) return child;
                return _buildLoadingPlaceholder(size, color);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildLoadingPlaceholder(size, color);
              },
              errorBuilder: (_, _, _) => _buildErrorPlaceholder(size, color, icon),
            )
          : Image.file(
              File(fileInfo.path!),
              width: size,
              height: size,
              fit: BoxFit.cover,
              cacheWidth: (size * 2).toInt(),
              cacheHeight: (size * 2).toInt(),
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) return child;
                return _buildLoadingPlaceholder(size, color);
              },
              errorBuilder: (_, _, _) => _buildErrorPlaceholder(size, color, icon),
            );
      return ClipRRect(borderRadius: BorderRadius.circular(8), child: imageWidget);
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
