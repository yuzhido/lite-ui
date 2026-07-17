import 'package:flutter/material.dart';

import '../model/enum.dart';
import '../model/file_info.dart';
import '../utils/file_utils.dart';

/// 文件状态信息行
///
/// 根据 [FileInfo.status] 自动渲染不同内容：
/// - 上传中：进度条(左) + 已上传/总大小(右)
/// - 其他状态：状态圆点 + 文件大小 · 状态文本
class ProgressStatus extends StatelessWidget {
  /// 文件信息
  final FileInfo fileInfo;

  /// 状态主题色（由外部传入以统一视觉风格）
  final Color statusColor;

  const ProgressStatus({super.key, required this.fileInfo, required this.statusColor});

  bool get _isUploading => fileInfo.status == UploadStatus.uploading;

  double get _progress => fileInfo.progress.clamp(0.0, 1.0);

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uploaded = (fileInfo.size * _progress).toInt();

    /// 上传中：进度条(左) + 已上传/总大小(右)
    if (_isUploading) {
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
            '${fileSizeFormat(uploaded)} / ${fileInfo.formatSize}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF6366F1)),
          ),
        ],
      );
    }

    /// 非上传状态：状态点 + 文件大小 · 状态文本
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
}
