import 'package:flutter/material.dart';

import '../model/enum.dart';
import '../model/file_info.dart';

import 'file_status.dart';
import 'card_delete_btn.dart';
import 'show_image.dart';
import 'show_file.dart';

/// 单个文件预览卡片
///
/// 图片文件展示缩略图，非图片文件展示文件类型图标。
/// 根据 [FileInfo.status] 叠加对应的上传状态指示层。
/// 支持网络图片回显（当 [FileInfo.isNetwork] 为 true 时使用 [Image.network]，加载 [FileInfo.url]）。
class CardShowFile extends StatelessWidget {
  /// 文件信息
  final FileInfo fileInfo;

  /// 删除回调
  final VoidCallback? onRemove;

  /// 卡片点击回调（点击卡片触发，如弹出操作 Sheet）
  final VoidCallback? onTap;

  /// 预览卡片尺寸（宽高一致的正方形），默认 100
  final double size;

  /// 圆角半径，默认 5
  final double borderRadius;

  /// 是否显示上传成功的对勾徽标，默认 true
  final bool showSuccessBadge;

  /// 是否显示右上角删除按钮，默认 true
  final bool showDeleteBtn;

  const CardShowFile({
    super.key,
    required this.borderRadius,
    required this.fileInfo,
    this.onRemove,
    this.onTap,
    this.size = 120,
    this.showSuccessBadge = true,
    this.showDeleteBtn = true,
  });

  /// 上传中时隐藏删除按钮
  bool get _isUploading => fileInfo.status == UploadStatus.uploading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.primary.withValues(alpha: 0.25);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: FileStatus(
              status: UploadStatus.success,
              size: size,
              progress: fileInfo.progress,
              showSuccessBadge: showSuccessBadge,
              child: Stack(
                children: [
                  // 显示图片的时候
                  if (fileInfo.isImage) ShowImage(fileInfo: fileInfo, size: size, borderRadius: borderRadius, borderColor: borderColor),
                  // 显示非图片的时候
                  if (fileInfo.isImage != true) ShowFile(fileInfo: fileInfo, size: size, borderRadius: borderRadius, borderColor: borderColor),
                  if (_isUploading)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: fileInfo.progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [theme.colorScheme.primary.withValues(alpha: 0.40), theme.colorScheme.primary.withValues(alpha: 0.12)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (showDeleteBtn && !_isUploading) CardDeleteBtn(onRemove: onRemove),
        ],
      ),
    );
  }
}
