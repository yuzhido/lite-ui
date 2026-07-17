import 'dart:io';
import 'package:flutter/material.dart';

import '../model/enum.dart';
import '../model/file_info.dart';
import '../utils/file_utils.dart';

/// 列表模式下的单个文件项（行级进度条方案）
///
/// 横向排列：文件类型图标 + 文件名/大小/状态 + 操作按钮
/// 整行容器作为进度载体：背景色填充 + 底部进度条始终可见。
class FileListPreview extends StatelessWidget {
  /// 文件信息
  final FileInfo fileInfo;

  /// 删除回调
  final VoidCallback? onRemove;

  /// 取消上传回调
  final VoidCallback? onCancel;

  /// 圆角半径，默认 8
  final double borderRadius;

  const FileListPreview({super.key, required this.fileInfo, this.onRemove, this.onCancel, this.borderRadius = 8});

  bool get _isUploading => fileInfo.status == UploadStatus.uploading;
  bool get _isSuccess => fileInfo.status == UploadStatus.success;
  bool get _isFailed => fileInfo.status == UploadStatus.failed;

  /// 进度值 0.0 ~ 1.0
  double get _progress => fileInfo.progress.clamp(0.0, 1.0);

  /// 获取文件类型图标
  IconData _getFileIcon() => getFileIcon(fileInfo.extension);

  /// 获取状态主题色
  Color _getStatusColor() {
    if (_isSuccess) return const Color(0xFF10B981);
    if (_isFailed) return const Color(0xFFEF4444);
    if (_isUploading) return const Color(0xFF6366F1);
    return const Color(0xFF9CA3AF); // pending
  }

  /// 获取状态文本
  String _getStatusText() {
    switch (fileInfo.status) {
      case UploadStatus.pending:
        return '待上传';
      case UploadStatus.uploading:
        return '上传中';
      case UploadStatus.success:
        return '上传成功';
      case UploadStatus.failed:
        return '上传失败';
    }
  }

  /// 获取背景填充颜色（仅上传中/失败时显示）
  Color? _getBgColor() {
    if (_isFailed) return const Color(0xFFEF4444).withValues(alpha: 0.06);
    if (_isUploading) return const Color(0xFF6366F1).withValues(alpha: 0.06);
    return null; // pending/success 不显示背景
  }

  /// 获取边框颜色（所有状态均显示，样式不同）
  Color _getBorderColor(BuildContext context) {
    if (_isFailed) return const Color(0xFFEF4444).withValues(alpha: 0.2);
    if (_isUploading) return const Color(0xFF6366F1).withValues(alpha: 0.25);
    if (_isSuccess) return const Color(0xFF10B981).withValues(alpha: 0.25);
    return Theme.of(context).dividerColor.withValues(alpha: 0.3);
  }

  /// 格式化已上传大小
  String _formatUploadedSize() {
    final uploaded = (fileInfo.size * _progress).toInt();
    return fileSizeFormat(uploaded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileColor = getFileColor(fileInfo.extension);
    final statusColor = _getStatusColor();
    final bgColor = _getBgColor();
    final borderColor = _getBorderColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: bgColor != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius - 1),
              child: Stack(
                children: [
                  // 背景填充层（仅上传中/失败）
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _isSuccess ? 1.0 : _progress,
                      child: Container(color: bgColor),
                    ),
                  ),
                  _buildContent(context, theme, fileColor, statusColor),
                ],
              ),
            )
          : _buildContent(context, theme, fileColor, statusColor),
    );
  }

  /// 构建内容行
  Widget _buildContent(BuildContext context, ThemeData theme, Color fileColor, Color statusColor) {
    return Row(
      children: [
        // 文件类型图标
        _buildIcon(fileColor),
        const SizedBox(width: 12),
        // 文件信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileInfo.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              const SizedBox(height: 4),
              _isUploading ? _buildUploadingRow(theme) : _buildStatusRow(theme, statusColor),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // 右侧操作区
        _buildActions(context),
      ],
    );
  }

  /// 上传中：进度条(左) + 已上传/总大小 百分比(右)
  Widget _buildUploadingRow(ThemeData theme) {
    return Row(
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
          '${_formatUploadedSize()} / ${fileInfo.formatSize}',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF6366F1)),
        ),
        const SizedBox(width: 4),
        Text(
          '${(_progress * 100).toInt()}%',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
        ),
      ],
    );
  }

  /// 非上传状态：状态点 + 文件大小 · 状态文本
  Widget _buildStatusRow(ThemeData theme, Color statusColor) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '${fileInfo.formatSize} · ${_getStatusText()}',
          style: theme.textTheme.bodySmall?.copyWith(color: statusColor.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildIcon(Color fileColor) {
    if (fileInfo.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(fileInfo.path), width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, _, _) => _buildDefaultIcon(fileColor)),
      );
    }
    return _buildDefaultIcon(fileColor);
  }

  Widget _buildDefaultIcon(Color fileColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: fileColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(_getFileIcon(), color: fileColor, size: 20),
    );
  }

  Widget _buildActions(BuildContext context) {
    // 上传中：取消按钮
    if (_isUploading) {
      return GestureDetector(
        onTap: onCancel ?? onRemove,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(6)),
          child: Icon(Icons.close, color: Colors.grey.shade500, size: 14),
        ),
      );
    }

    // 非上传状态：显示操作按钮
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 失败时显示重试按钮
        if (_isFailed)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
                child: Icon(Icons.refresh, color: const Color(0xFF6366F1), size: 16),
              ),
            ),
          ),
        // 删除按钮
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(6)),
            child: Icon(Icons.delete_outline, color: const Color(0xFFEF4444), size: 16),
          ),
        ),
      ],
    );
  }
}
