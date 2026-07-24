import 'package:flutter/material.dart';

import '../model/enum.dart';
import '../model/file_info.dart';
import '../utils/file_utils.dart';

import 'show_file.dart';
import 'show_image.dart';
import 'list_action_btn.dart';

/// 列表模式下的单个文件项（行级进度条方案）
///
/// 横向排列：文件类型图标 + 文件名/大小/状态 + 操作按钮
/// 整行容器作为进度载体：背景色填充 + 底部进度条始终可见。
/// 网络文件且未知大小时，自动通过 HTTP HEAD 请求获取。
class ListShowFile extends StatefulWidget {
  const ListShowFile({
    super.key,
    required this.fileInfo,
    required this.fileRadius,
    this.onRemove,
    this.onCancel,
    this.onRetry,
    required this.borderRadius,
    this.previewSize = 40,
    required this.showType,
    required this.showFileName,
  });

  /// 文件信息
  final FileInfo fileInfo;

  /// 删除回调
  final VoidCallback? onRemove;

  /// 取消上传回调
  final VoidCallback? onCancel;

  /// 重试上传回调（上传失败时调用）
  final VoidCallback? onRetry;

  /// 圆角半径
  final double borderRadius;

  /// 文件图标圆角半径，默认传进来的是 5
  final double fileRadius;

  /// 文件图标/缩略图尺寸，默认 40
  final double previewSize;

  /// 显示类型
  final ShowType showType;

  /// 是否显示文件名，默认 true
  final bool showFileName;

  @override
  State<ListShowFile> createState() => _ListShowFileState();
}

class _ListShowFileState extends State<ListShowFile> {
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
  void didUpdateWidget(covariant ListShowFile oldWidget) {
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
            debugPrint('[ListShowFile] HEAD 获取文件大小: url=${widget.fileInfo.url}, size=$size');
          });
        }
      });
    }
  }

  /// 获取当前应显示的文件大小文本
  ///
  /// 优先级：
  /// 1. fileInfo 自带的格式化大小（fileSizeInfo）
  /// 2. 本地文件：直接使用 fileInfo.size 格式化
  /// 3. 网络文件：优先用远程 HTTP 获取的大小
  /// 4. 正在获取中：返回空字符串
  /// 5. 获取失败：返回「未知大小」
  String get _displaySize {
    // 优先使用 fileInfo 自带的格式化大小
    if (widget.fileInfo.fileSizeInfo != null && widget.fileInfo.fileSizeInfo!.isNotEmpty) return widget.fileInfo.fileSizeInfo!;
    // 本地文件：使用 fileInfo.size
    if (!widget.fileInfo.isNetwork) return widget.fileInfo.formatSize;
    // 网络文件：优先用远程获取的大小
    if (_remoteSize != null) return fileSizeFormat(_remoteSize!);
    // 正在获取中：不显示
    if (!_fetchDone) return '';
    // 获取失败：显示未知
    return '未知大小';
  }

  bool get _isUploading => widget.fileInfo.status == UploadStatus.uploading;
  bool get _isSuccess => widget.fileInfo.status == UploadStatus.success;
  bool get _isFailed => widget.fileInfo.status == UploadStatus.failed;

  /// 进度值 0.0 ~ 1.0
  double get _progress => widget.fileInfo.progress.clamp(0.0, 1.0);

  /// 获取状态主题色
  Color _getStatusColor() {
    if (_isSuccess) return const Color(0xFF10B981);
    if (_isFailed) return const Color(0xFFEF4444);
    if (_isUploading) return const Color(0xFF6366F1);
    return const Color(0xFF9CA3AF); // pending
  }

  /// 获取背景填充颜色（仅上传中/失败时显示）
  Color? _getBgColor() {
    if (_isFailed) return const Color(0xFFEF4444).withValues(alpha: 0.08);
    if (_isUploading) return const Color(0xFF6366F1).withValues(alpha: 0.12);
    return null; // pending/success 不显示背景
  }

  /// 获取边框颜色（所有状态均显示，样式不同）
  Color _getBorderColor(BuildContext context) {
    if (_isFailed) return const Color(0xFFEF4444).withValues(alpha: 0.2);
    if (_isUploading) return const Color(0xFF6366F1).withValues(alpha: 0.25);
    if (_isSuccess) return const Color(0xFF11CB3F).withValues(alpha: 0.25);
    return Theme.of(context).dividerColor.withValues(alpha: 0.3);
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();
    final bgColor = _getBgColor();
    final borderColor = _getBorderColor(context);
    final statusText = switch (widget.fileInfo.status) {
      UploadStatus.pending => '待上传',
      UploadStatus.uploading => '上传中',
      UploadStatus.success => '上传成功',
      UploadStatus.failed => '上传失败',
    };
    final uploaded = (widget.fileInfo.size * _progress).toInt();
    final displaySize = _displaySize;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Stack(
          children: [
            // 进度背景填充层（上传中/失败时显示）— 置于底层，避免遮挡内容层按钮点击
            if (bgColor != null)
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _isSuccess ? 1.0 : _progress,
                  child: Container(color: bgColor),
                ),
              ),
            // 内容层（保持原有 padding）
            Padding(
              padding: EdgeInsetsGeometry.all(7),
              child: Row(
                spacing: 12,
                children: [
                  // 文件类型图标
                  widget.fileInfo.isImage
                      ? ShowImage(fileInfo: widget.fileInfo, size: widget.previewSize, borderRadius: widget.fileRadius, borderColor: borderColor)
                      : ShowFile(
                          fileInfo: widget.fileInfo,

                          size: widget.previewSize,
                          borderRadius: widget.fileRadius,
                          borderColor: borderColor,
                          showType: widget.showType,
                          showFileName: widget.showFileName,
                        ),
                  // 文件信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 第一行：文件名 + 进度百分比（上传中时显示）
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.fileInfo.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_isUploading)
                              Text(
                                '${(_progress * 100).toInt()}%',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // 第二行：上传中显示进度条+已上传/总大小，其他状态显示状态点+文件大小·状态文本
                        if (_isUploading)
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: _progress,
                                    minHeight: 6,
                                    backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.12),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${fileSizeFormat(uploaded)} / $displaySize',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF6366F1)),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  displaySize.isNotEmpty ? '$statusText · $displaySize' : statusText,
                                  style: theme.textTheme.bodySmall?.copyWith(color: statusColor.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // 右侧操作区
                  ListActionBtn(fileInfo: widget.fileInfo, onRemove: widget.onRemove, onCancel: widget.onCancel, onRetry: widget.onRetry),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
