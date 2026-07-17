import 'dart:io';
import 'package:flutter/material.dart';

import '../model/enum.dart';
import '../model/file_info.dart';

import 'file_type.dart';
import 'file_status.dart';
import 'card_delete_btn.dart';

/// 单个文件预览卡片
///
/// 图片文件展示缩略图，非图片文件展示文件类型图标。
/// 根据 [FileInfo.status] 叠加对应的上传状态指示层。
class CardShowFile extends StatelessWidget {
  /// 文件信息
  final FileInfo fileInfo;

  /// 删除回调
  final VoidCallback? onRemove;

  /// 预览卡片尺寸（宽高一致的正方形），默认 100
  final double size;

  /// 圆角半径，默认 5
  final double borderRadius;

  const CardShowFile({super.key, required this.borderRadius, required this.fileInfo, this.onRemove, this.size = 120});

  /// 上传中时隐藏删除按钮
  bool get _isUploading => fileInfo.status == UploadStatus.uploading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.primary.withValues(alpha: 0.25);

    // 构建卡片内容
    Widget cardContent = fileInfo.isImage
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.file(
              File(fileInfo.path),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => FileType(fileInfo: fileInfo),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
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

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          FileStatus(status: fileInfo.status, size: size, progress: fileInfo.progress, child: displayContent),
          if (!_isUploading) CardDeleteBtn(onRemove: onRemove),
        ],
      ),
    );
  }
}
