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
