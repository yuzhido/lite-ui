import 'package:flutter/material.dart';

import '../model/enum.dart';

/// 文件上传状态覆盖层
///
/// 根据 [UploadStatus] 在预览卡片上叠加不同样式的状态指示：
/// - pending：底部半透明条显示「待上传」
/// - uploading：底部标签条显示进度百分比
/// - success：左上角绿色对勾徽标
/// - failed：全遮罩 + 红色错误图标 + 「上传失败」
class FileStatus extends StatelessWidget {
  const FileStatus({super.key, required this.status, this.progress = 0.0, this.showSuccessBadge = true, this.isAvatar = false, this.onRetry});

  /// 当前上传状态
  final UploadStatus status;

  /// 上传进度 0.0 ~ 1.0（仅 [UploadStatus.uploading] 时有效）
  final double progress;

  /// 是否显示上传成功的对勾徽标，默认 true
  ///
  /// 头像模式下设为 false，避免小尺寸卡片上显示突兀
  final bool showSuccessBadge;

  /// 是否为头像模式
  ///
  /// 头像模式下 pending / uploading 状态居中显示在容器中央，
  /// 而非贴底部。
  final bool isAvatar;

  /// 上传失败时点击回调（用于重试）
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final pct = '${(progress * 100).toInt()}%';

    /// 待上传：底部半透明标签（头像模式居中显示）
    if (status == UploadStatus.pending) {
      if (isAvatar) {
        return Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(color: Colors.black38),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hourglass_empty, color: Colors.white70, size: 14),
                  SizedBox(width: 4),
                  Text('待上传', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
        );
      }
      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
          decoration: const BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_empty, color: Colors.white70, size: 12),
              SizedBox(width: 3),
              Text('待上传', style: TextStyle(color: Colors.white, fontSize: 11)),
            ],
          ),
        ),
      );
    }

    /// 上传中：底部标签条 + 进度百分比（头像模式居中显示）
    if (status == UploadStatus.uploading) {
      if (isAvatar) {
        return Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(color: Colors.black38),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
                  const SizedBox(width: 6),
                  Text(
                    pct,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
          decoration: const BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
              const SizedBox(width: 4),
              Expanded(
                child: Text('$pct 上传中...', style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ],
          ),
        ),
      );
    }

    /// 上传成功：左上角绿色实心对勾徽标
    if (status == UploadStatus.success && showSuccessBadge) {
      return Positioned(
        top: 2,
        left: 2,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 3, offset: const Offset(0, 1))],
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 14),
        ),
      );
    }

    /// 上传失败：遮罩 + 错误图标（点击穿透到卡片层触发操作 Sheet）
    if (status == UploadStatus.failed) {
      return Positioned.fill(
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
                  SizedBox(height: 4),
                  Text('上传失败', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
