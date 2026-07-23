import 'package:flutter/material.dart';

import '../model/enum.dart';
import '../model/file_info.dart';

/// 列表模式文件项的操作按钮组
///
/// 根据文件状态自动渲染不同按钮：
/// - 上传中：显示取消按钮
/// - 上传失败：显示重试按钮 + 删除按钮
/// - 其他状态：显示删除按钮
class ListActionBtn extends StatelessWidget {
  /// 文件信息（用于判断上传状态）
  final FileInfo fileInfo;

  /// 删除回调
  final VoidCallback? onRemove;

  /// 取消上传回调（上传中时调用，未提供则走 onRemove）
  final VoidCallback? onCancel;

  /// 重试上传回调（上传失败时调用）
  final VoidCallback? onRetry;

  const ListActionBtn({super.key, required this.fileInfo, this.onRemove, this.onCancel, this.onRetry});

  bool get _isUploading => fileInfo.status == UploadStatus.uploading;
  bool get _isFailed => fileInfo.status == UploadStatus.failed;

  @override
  Widget build(BuildContext context) {
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
              onTap: onRetry,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(6)),
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
            decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
            child: Icon(Icons.delete_forever_rounded, color: const Color(0xFFEF4444), size: 16),
          ),
        ),
      ],
    );
  }
}
