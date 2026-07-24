import 'package:flutter/material.dart';
import 'package:lite_ui/src/file_upload/model/enum.dart';

import '../model/file_info.dart';
import '../utils/file_utils.dart';

/// 非图片文件卡片内容
///
/// 展示文件类型图标。
/// 卡片模式下（[showType] == [ShowType.card]），底部叠加半透明遮罩显示文件名和大小。
/// 网络文件且未知大小时，自动通过 HTTP HEAD 请求获取文件大小，加载中显示 loading 动画。
class ShowFile extends StatefulWidget {
  const ShowFile({
    super.key,
    required this.fileInfo,
    required this.size,
    required this.borderRadius,
    required this.borderColor,
    required this.showType,
    required this.showFileName,
  });

  /// 文件信息
  final FileInfo fileInfo;

  /// 卡片尺寸（宽高一致的正方形）
  final double size;

  /// 圆角半径
  final double borderRadius;

  /// 边框颜色
  final Color borderColor;

  /// 显示类型
  final ShowType showType;

  /// 是否显示文件名，默认 true
  final bool showFileName;

  @override
  State<ShowFile> createState() => _ShowFileState();
}

class _ShowFileState extends State<ShowFile> {
  /// 远程获取到的文件大小（字节），仅网络文件且本地 size 为 0 时使用
  int? _remoteSize;

  /// 是否正在发起远程大小请求（防止重复请求）
  bool _fetching = false;

  /// 是否已完成远程获取（成功或失败均置 true）
  bool _fetchDone = false;

  @override
  void initState() {
    super.initState();
    _tryFetchRemoteSize();
  }

  @override
  void didUpdateWidget(covariant ShowFile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // url 或 size 变化时重新获取远程大小
    if (oldWidget.fileInfo.url != widget.fileInfo.url || oldWidget.fileInfo.size != widget.fileInfo.size) {
      _fetchDone = false;
      _remoteSize = null;
      _tryFetchRemoteSize();
    }
  }

  /// 网络文件且未知大小时，通过 HTTP HEAD 请求获取文件大小
  void _tryFetchRemoteSize() {
    if (widget.fileInfo.isNetwork && widget.fileInfo.size == 0 && widget.fileInfo.fileSizeInfo == null && !_fetching && !_fetchDone) {
      _fetching = true;
      fetchRemoteFileSize(widget.fileInfo.url!).then((size) {
        if (mounted) {
          setState(() {
            _remoteSize = size;
            _fetching = false;
            _fetchDone = true;
            debugPrint('[ShowFile] HEAD 获取文件大小: url=${widget.fileInfo.url}, size=$size');
          });
        }
      });
    }
  }

  /// 获取当前应显示的文件大小文本
  String get _displaySize {
    if (widget.fileInfo.fileSizeInfo != null && widget.fileInfo.fileSizeInfo!.isNotEmpty) return widget.fileInfo.fileSizeInfo!;
    if (!widget.fileInfo.isNetwork) return widget.fileInfo.formatSize;
    if (_remoteSize != null) return fileSizeFormat(_remoteSize!);
    if (!_fetchDone) return '';
    return '未知大小';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(color: getFileColor(widget.fileInfo.extension).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(getFileIcon(widget.fileInfo.extension), color: getFileColor(widget.fileInfo.extension), size: widget.size * 0.45),
        ),
        // 如果显示类型是卡片,非图片显示的时候显示文件信息（文件名 + 文件大小，底部半透明遮罩）
        if (widget.showType == ShowType.card && widget.showFileName)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
              ),
              child: Column(
                spacing: 2,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _displaySize,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9, color: Colors.white, height: 1),
                  ),
                  Text(
                    widget.fileInfo.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white, height: 1),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
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
      return Icons.upload_file_rounded;
  }
}
