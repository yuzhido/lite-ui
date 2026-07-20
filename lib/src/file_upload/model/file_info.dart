import '../utils/snowflake_id.dart';
import 'enum.dart';

/// 文件信息模型
///
/// 统一管理文件的生命周期数据：
/// - [path] 仅表示本地文件路径（可为 null，编辑模式下后端已有文件时无需本地路径）
/// - [url] 表示上传成功后的网络访问地址（http 开头），或编辑模式回显地址
/// - [id] 唯一标识，用于前端操作（删除、匹配等），永远不为空
class FileInfo {
  /// 唯一标识ID（雪花算法生成，用于前端操作如删除等，永远不为空）
  final String id;

  /// 文件名
  final String name;

  /// 文件路径（仅本地路径，可为 null）
  ///
  /// - 本地文件：文件系统路径，如 `/data/xxx/image.jpg`
  /// - 编辑模式：后端已有文件时可为 null
  final String? path;

  /// 文件访问URL地址（上传成功后 http 开头的地址，或编辑模式回显）
  ///
  /// - 上传成功：服务端返回的访问地址，如 `https://example.com/files/xxx.jpg`
  /// - 编辑模式：已存在文件的网络地址
  final String? url;

  /// 文件大小（字节）
  final int size;

  /// 格式化后的文件大小信息（如：1.2MB、500KB等）
  ///
  /// 可选字段，若不传则使用 [formatSize] getter 自动计算
  final String? fileSizeInfo;

  /// 上传状态
  final UploadStatus status;

  /// 文件来源
  final FileSource source;

  /// 扩展数据（保存后端返回的响应数据，方便后续扩展）
  ///
  /// 上传成功后，服务端响应体自动写入此字段（替代原 responseBody）
  final Map<String, dynamic>? data;

  /// 上传进度 0.0 ~ 1.0（仅 [UploadStatus.uploading] 时有意义）
  final double progress;

  /// 文件创建时间
  final DateTime? createTime;

  /// 文件最后更新时间
  final DateTime? updateTime;

  FileInfo({
    String? id,
    required this.name,
    this.path,
    this.url,
    this.size = 0,
    this.fileSizeInfo,
    UploadStatus? status,
    FileSource? source,
    this.data,
    this.progress = 0.0,
    this.createTime,
    this.updateTime,
  }) : id = id ?? SnowflakeId.generate(),
       // url 有值且为 http 开头，说明是已上传成功的文件，自动设置 status=success、source=network
       status = (url != null && isUrl(url)) ? UploadStatus.success : (status ?? UploadStatus.pending),
       source = (url != null && isUrl(url)) ? FileSource.network : (source ?? FileSource.file);

  /// 判断给定字符串是否为网络 URL
  static bool isUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  /// 创建副本，支持局部字段更新
  FileInfo copyWith({
    String? id,
    String? name,
    String? path,
    String? url,
    int? size,
    String? fileSizeInfo,
    UploadStatus? status,
    FileSource? source,
    Map<String, dynamic>? data,
    double? progress,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return FileInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      url: url ?? this.url,
      size: size ?? this.size,
      fileSizeInfo: fileSizeInfo ?? this.fileSizeInfo,
      status: status ?? this.status,
      source: source ?? this.source,
      data: data ?? this.data,
      progress: progress ?? this.progress,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }

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

  /// 是否为网络文件（通过 url 判断）
  bool get isNetwork => url != null && url!.isNotEmpty;

  /// 格式化文件大小（基于 size 字节数自动计算）
  String get formatSize {
    if (fileSizeInfo != null && fileSizeInfo!.isNotEmpty) return fileSizeInfo!;
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(2)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  String toString() => 'FileInfo(id: $id, name: $name, size: $formatSize, status: $status)';
}
