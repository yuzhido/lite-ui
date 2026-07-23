import 'package:flutter/material.dart';

import '../model/enum.dart';
import '../model/file_info.dart';

import 'show_file.dart';
import 'show_image.dart';
import 'list_action_btn.dart';
import 'progress_status.dart';

/// 列表模式下的单个文件项（行级进度条方案）
///
/// 横向排列：文件类型图标 + 文件名/大小/状态 + 操作按钮
/// 整行容器作为进度载体：背景色填充 + 底部进度条始终可见。
class ListShowFile extends StatelessWidget {
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

  const ListShowFile({super.key, required this.fileInfo, required this.fileRadius, this.onRemove, this.onCancel, this.onRetry, required this.borderRadius, this.previewSize = 40});

  bool get _isUploading => fileInfo.status == UploadStatus.uploading;
  bool get _isSuccess => fileInfo.status == UploadStatus.success;
  bool get _isFailed => fileInfo.status == UploadStatus.failed;

  /// 进度值 0.0 ~ 1.0
  double get _progress => fileInfo.progress.clamp(0.0, 1.0);

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
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
              padding: EdgeInsetsGeometry.all(10),
              child: Row(
                spacing: 12,
                children: [
                  // 文件类型图标
                  fileInfo.isImage
                      ? ShowImage(fileInfo: fileInfo, size: previewSize, borderRadius: fileRadius, borderColor: borderColor)
                      : ShowFile(fileInfo: fileInfo, size: previewSize, borderRadius: fileRadius, borderColor: borderColor),
                  // 文件信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 第一行：文件名 + 进度百分比（上传中时显示）
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                fileInfo.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
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
                        // 第二行文件上传进度或者上传状态文本
                        ProgressStatus(fileInfo: fileInfo, statusColor: statusColor),
                      ],
                    ),
                  ),
                  // 右侧操作区
                  ListActionBtn(fileInfo: fileInfo, onRemove: onRemove, onCancel: onCancel, onRetry: onRetry),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
