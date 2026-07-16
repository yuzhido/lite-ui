import 'dart:io';

import 'package:flutter/material.dart';

import '../model/file_info.dart';

/// 单个文件预览卡片
///
/// 图片文件展示缩略图，非图片文件展示文件类型图标。
class FilePreview extends StatelessWidget {
  const FilePreview({super.key, required this.fileInfo, this.onRemove, this.size = 120});

  /// 文件信息
  final FileInfo fileInfo;

  /// 删除回调
  final VoidCallback? onRemove;

  /// 预览卡片尺寸（宽高一致的正方形），默认 100
  final double size;

  @override
  Widget build(BuildContext context) {
    return fileInfo.isImage ? _buildImagePreview() : _buildFilePreview();
  }

  /// 图片文件：缩略图预览
  Widget _buildImagePreview() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(fileInfo.path),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildFileIcon(),
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  /// 非图片文件：图标 + 名称 + 大小，统一正方形卡片
  Widget _buildFilePreview() {
    final insets = size * 0.08;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.all(insets),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFileIcon(),
                SizedBox(height: insets),
                Text(
                  fileInfo.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  fileInfo.formatSize,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  /// 文件类型图标
  Widget _buildFileIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
      child: Icon(_getFileIcon(), color: Colors.blue.shade400, size: 24),
    );
  }

  /// 根据文件扩展名返回对应图标
  IconData _getFileIcon() {
    switch (fileInfo.extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return Icons.folder_zip;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
        return Icons.audio_file;
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// 右上角删除按钮
  Widget _buildRemoveButton() {
    return Positioned(
      top: 2,
      right: 2,
      child: GestureDetector(
        onTap: onRemove,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
          child: const Icon(Icons.close, color: Colors.white, size: 14),
        ),
      ),
    );
  }
}
