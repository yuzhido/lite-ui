import 'dart:io';
import 'package:flutter/material.dart';

import '../model/enum.dart';
import '../model/file_info.dart';

import 'file_type.dart';
import 'file_status.dart';
import 'card_delete_btn.dart';
import '../utils/file_utils.dart';

/// 图片加载环形指示器颜色（深色，提高可见性）
const Color _kImageLoadingColor = Color(0xFF424242); // Material Grey[800]

/// 图片加载背景色
const Color _kImageLoadingBgColor = Color(0xFFE0E0E0); // Material Grey[300]

/// 单个文件预览卡片
///
/// 图片文件展示缩略图，非图片文件展示文件类型图标。
/// 根据 [FileInfo.status] 叠加对应的上传状态指示层。
/// 支持网络图片回显（当 [FileInfo.isNetwork] 为 true 时使用 [Image.network]，加载 [FileInfo.url]）。
class CardShowFile extends StatelessWidget {
  /// 文件信息
  final FileInfo fileInfo;

  /// 删除回调
  final VoidCallback? onRemove;

  /// 重试上传回调（上传失败时点击失败遮罩触发）
  final VoidCallback? onRetry;

  /// 预览卡片尺寸（宽高一致的正方形），默认 100
  final double size;

  /// 圆角半径，默认 5
  final double borderRadius;

  const CardShowFile({super.key, required this.borderRadius, required this.fileInfo, this.onRemove, this.onRetry, this.size = 120});

  /// 上传中时隐藏删除按钮
  bool get _isUploading => fileInfo.status == UploadStatus.uploading;

  /// 构建加载占位符（灰色背景 + 环形动画）
  Widget _buildLoadingPlaceholder(double size, double borderRadius, double progress) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(borderRadius)),
      child: Center(
        child: SizedBox(
          width: size * 0.3,
          height: size * 0.3,
          child: CircularProgressIndicator(strokeWidth: 2.5, value: progress > 0 ? progress : null, color: _kImageLoadingColor, backgroundColor: _kImageLoadingBgColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.primary.withValues(alpha: 0.25);

    // 构建卡片内容
    Widget cardContent = fileInfo.isImage
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: fileInfo.isNetwork
                ? Image.network(
                    fileInfo.url!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    cacheWidth: (size * 2).toInt(),
                    cacheHeight: (size * 2).toInt(),
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      // 图片已加载（同步或异步首帧渲染完成）→ 直接显示
                      if (wasSynchronouslyLoaded || frame != null) {
                        return child;
                      }
                      // 第一帧且图片尚未加载 → 显示加载动画（填补 loadingBuilder 接管前的空白）
                      return _buildLoadingPlaceholder(size, borderRadius, 0);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      final expected = loadingProgress.expectedTotalBytes ?? 1;
                      final loaded = loadingProgress.cumulativeBytesLoaded;
                      final progress = (loaded / expected).clamp(0.0, 1.0);
                      return _buildLoadingPlaceholder(size, borderRadius, progress);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('[CardShowFile] 本地图片加载失败: id=${fileInfo.id}, path=${fileInfo.url}, error=$error');
                      final color = getFileColor(fileInfo.extension);
                      final icon = getFileIcon(fileInfo.extension);
                      return Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(borderRadius)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: color, size: size * 0.4),
                            SizedBox(height: size * 0.06),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: size * 0.1),
                              child: Text(
                                fileInfo.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Image.file(
                    File(fileInfo.path!),
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    cacheWidth: (size * 2).toInt(),
                    cacheHeight: (size * 2).toInt(),
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('[CardShowFile] 本地图片加载失败: id=${fileInfo.id}, path=${fileInfo.path}, error=$error');
                      return SizedBox(
                        width: size,
                        height: size,
                        child: Center(
                          child: FileType(fileInfo: fileInfo, size: size * 0.5),
                        ),
                      );
                    },
                  ),
          )
        : Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: 1),
            ),
            padding: EdgeInsets.all(size * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FileType(fileInfo: fileInfo),
                SizedBox(height: size * 0.08),
                Text(fileInfo.name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                Text(fileInfo.formatSize, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          );

    // 上传中：在卡片内容上方叠加进度填充动画
    final displayContent = _isUploading
        ? Stack(
            children: [
              cardContent,
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: fileInfo.progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary.withValues(alpha: 0.40), theme.colorScheme.primary.withValues(alpha: 0.12)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : cardContent;

    // 失败状态下整个卡片可点击触发重试
    final isFailed = fileInfo.status == UploadStatus.failed;
    final statusLayer = FileStatus(status: fileInfo.status, size: size, progress: fileInfo.progress, child: displayContent);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          if (isFailed && onRetry != null)
            Positioned.fill(
              child: GestureDetector(onTap: onRetry, behavior: HitTestBehavior.opaque, child: statusLayer),
            )
          else
            statusLayer,
          if (!_isUploading) CardDeleteBtn(onRemove: onRemove),
        ],
      ),
    );
  }
}
