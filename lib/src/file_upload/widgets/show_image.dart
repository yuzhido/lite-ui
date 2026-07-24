import 'dart:io';
import 'package:flutter/material.dart';

import '../model/file_info.dart';

/// 图片文件卡片内容
///
/// 图片文件展示缩略图，支持网络图片回显（当 [FileInfo.isNetwork] 为 true 时使用 [Image.network]）。
/// 加载中展示 [LoadingStatus]，加载失败展示错误占位符。
class ShowImage extends StatelessWidget {
  const ShowImage({super.key, required this.fileInfo, required this.size, required this.borderRadius, required this.borderColor});

  /// 文件信息
  final FileInfo fileInfo;

  /// 卡片尺寸（宽高一致的正方形）
  final double size;

  /// 圆角半径
  final double borderRadius;

  /// 边框颜色
  final Color borderColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(borderRadius)),
      clipBehavior: Clip.antiAlias,
      child: fileInfo.isNetwork
          ? Image.network(
              fileInfo.url!,
              width: size,
              fit: BoxFit.fitWidth,
              cacheWidth: (size * 2).toInt(),
              cacheHeight: (size * 2).toInt(),
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                // 图片已加载（同步或异步首帧渲染完成）→ 直接显示
                if (wasSynchronouslyLoaded || frame != null) {
                  return child;
                }
                // 第一帧且图片尚未加载 → 显示加载动画（填补 loadingBuilder 接管前的空白）
                return LoadingStatus(size: size, borderRadius: borderRadius, progress: 0);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                final expected = loadingProgress.expectedTotalBytes ?? 1;
                final loaded = loadingProgress.cumulativeBytesLoaded;
                final progress = (loaded / expected).clamp(0.0, 1.0);
                return LoadingStatus(size: size, borderRadius: borderRadius, progress: progress);
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('[ShowImage] 网络图片加载失败: id=${fileInfo.id}, url=${fileInfo.url}, error=$error');
                return _ImageErrorPlaceholder(name: fileInfo.name, size: size, borderRadius: borderRadius);
              },
            )
          : Image.file(
              File(fileInfo.path!),
              width: size,
              fit: BoxFit.fitWidth,
              cacheWidth: (size * 2).toInt(),
              cacheHeight: (size * 2).toInt(),
              errorBuilder: (context, error, stackTrace) {
                debugPrint('[ShowImage] 本地图片加载失败: id=${fileInfo.id}, path=${fileInfo.path}, error=$error');
                return _ImageErrorPlaceholder(name: fileInfo.name, size: size, borderRadius: borderRadius);
              },
            ),
    );
  }
}

/// 图片加载失败占位符
class _ImageErrorPlaceholder extends StatelessWidget {
  final String name;
  final double size;
  final double borderRadius;

  const _ImageErrorPlaceholder({required this.name, required this.size, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(borderRadius)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.grey.shade500, size: size * 0.35),
          SizedBox(height: size * 0.06),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.1),
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

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
