import 'package:flutter/material.dart';

/// 判断是否为图片文件
bool isImageFile(String? fileName) {
  if (fileName == null) return false;
  const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'];
  final lower = fileName.toLowerCase();
  return imageExtensions.any((ext) => lower.endsWith(ext));
}

/// 格式化文件大小
String fileSizeFormat(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

/// 根据文件扩展名返回对应图标
IconData getFileIcon(String extension) {
  switch (extension.toLowerCase()) {
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

/// 获取文件类型颜色
Color getFileColor(String extension) {
  const extMap = {
    'jpg': Color(0xFFD97706),
    'jpeg': Color(0xFFD97706),
    'png': Color(0xFFD97706),
    'gif': Color(0xFFD97706),
    'bmp': Color(0xFFD97706),
    'webp': Color(0xFFD97706),
    'svg': Color(0xFFD97706),
    'pdf': Color(0xFFDC2626),
    'doc': Color(0xFF2563EB),
    'docx': Color(0xFF2563EB),
    'xls': Color(0xFF059669),
    'xlsx': Color(0xFF059669),
    'ppt': Color(0xFFEA580C),
    'pptx': Color(0xFFEA580C),
    'zip': Color(0xFF7C3AED),
    'rar': Color(0xFF7C3AED),
    'mp4': Color(0xFFDB2777),
    'mov': Color(0xFFDB2777),
    'mp3': Color(0xFF0891B2),
    'wav': Color(0xFF0891B2),
  };
  return extMap[extension.toLowerCase()] ?? const Color(0xFF6B7280);
}
