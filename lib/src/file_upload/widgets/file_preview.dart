import 'dart:io';
import 'package:flutter/material.dart';

import '../model/enum.dart';
import '../model/file_info.dart';

import 'delete_btn.dart';
import 'file_type.dart';
import 'file_status.dart';

/// 单个文件预览卡片
///
/// 图片文件展示缩略图，非图片文件展示文件类型图标。
/// 根据 [FileInfo.status] 叠加对应的上传状态指示层。
class FilePreview extends StatelessWidget {
  /// 文件信息
  final FileInfo fileInfo;

  /// 删除回调
  final VoidCallback? onRemove;

  /// 预览卡片尺寸（宽高一致的正方形），默认 100
  final double size;

  /// 圆角半径，默认 5
  final double borderRadius;

  const FilePreview({super.key, required this.borderRadius, required this.fileInfo, this.onRemove, this.size = 120});

  /// 上传中时隐藏删除按钮
  bool get _isUploading => fileInfo.status == UploadStatus.uploading;

  @override
  Widget build(BuildContext context) {
    if (fileInfo.isImage) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            FileStatus(
              status: fileInfo.status,
              size: size,
              progress: fileInfo.progress,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Image.file(
                  File(fileInfo.path),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => FileType(fileInfo: fileInfo),
                ),
              ),
            ),
            if (!_isUploading) DeleteBtn(onRemove: onRemove),
          ],
        ),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          FileStatus(
            status: fileInfo.status,
            size: size,
            progress: fileInfo.progress,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
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
            ),
          ),
          if (!_isUploading) DeleteBtn(onRemove: onRemove),
        ],
      ),
    );
  }
}
