import 'enum.dart';

/// 文件信息模型
class FileInfo {
  /// 文件名
  final String name;

  /// 文件本地路径
  final String path;

  /// 文件大小（字节）
  final int size;

  /// 上传状态
  final UploadStatus status;

  /// 文件来源
  final FileSource source;

  const FileInfo({
    required this.name,
    required this.path,
    this.size = 0,
    this.status = UploadStatus.pending,
    this.source = FileSource.file,
  });

  /// 获取文件扩展名
  String get extension {
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1);
  }

  /// 是否为图片文件
  bool get isImage {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'];
    return imageExtensions.contains(extension.toLowerCase());
  }

  /// 格式化文件大小
  String get formatSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(2)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  String toString() => 'FileInfo(name: $name, size: $formatSize, status: $status)';
}
