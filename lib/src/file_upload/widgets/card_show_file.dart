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
/// 网络文件且未知大小时，自动通过 HTTP HEAD 请求获取文件大小。
class CardShowFile extends StatefulWidget {
  const CardShowFile({
    super.key,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.grey,
    required this.borderRadius,
    required this.fileInfo,
    this.fileRadius = 5,
    this.onRemove,
    this.onTap,
    this.size = 120,
    this.showSuccessBadge = true,
    this.showDeleteBtn = true,
    this.isAvatar = false,
    this.onRetry,
    required this.showType,
    required this.showFileName,
  });

  /// 文件信息
  final FileInfo fileInfo;

  /// 删除回调
  final VoidCallback? onRemove;

  /// 卡片点击回调（点击卡片触发，如弹出操作 Sheet）
  final VoidCallback? onTap;

  /// 预览卡片尺寸（宽高一致的正方形），默认 100
  final double size;

  /// 外层容器圆角半径（用于 ClipRRect 裁剪）
  final double borderRadius;

  /// 文件卡片内容圆角半径（用于 ShowImage / ShowFile 内部圆角）
  final double fileRadius;

  /// 是否显示上传成功的对勾徽标，默认 true
  final bool showSuccessBadge;

  /// 是否显示右上角删除按钮，默认 true
  final bool showDeleteBtn;

  /// 重试上传回调（上传失败时调用）
  final VoidCallback? onRetry;

  /// 是否为头像模式
  ///
  /// 头像模式下上传状态（待上传 / 上传中）居中显示在容器中央，
  /// 而非贴底部。
  final bool isAvatar;

  /// 预览文件卡片背景颜色
  ///
  /// 默认白色
  final Color backgroundColor;

  /// 预览文件卡片边框颜色
  ///
  /// 默认灰色
  final Color borderColor;

  /// 显示类型
  final ShowType showType;

  /// 显示文件名称和大小
  ///
  /// 默认显示
  final bool showFileName;

  @override
  State<CardShowFile> createState() => _CardShowFileState();
}

class _CardShowFileState extends State<CardShowFile> {
  bool get _isUploading => widget.fileInfo.status == UploadStatus.uploading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          children: [
            // 内容层：图片/文件，接收点击
            Container(
              width: widget.size,
              height: widget.size,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(color: widget.borderColor, width: 1),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onTap,
                      behavior: HitTestBehavior.opaque,
                      child: widget.fileInfo.isImage
                          ? ShowImage(fileInfo: widget.fileInfo, size: widget.size, borderRadius: widget.fileRadius, borderColor: widget.borderColor)
                          : ShowFile(
                              fileInfo: widget.fileInfo,
                              size: widget.size,
                              borderRadius: widget.fileRadius,
                              borderColor: widget.borderColor,
                              showType: widget.showType,
                              showFileName: widget.showFileName,
                            ),
                    ),
                  ),
                  if (widget.showType == ShowType.card && widget.fileInfo.isImage && widget.showFileName == true)
                    Text(
                      widget.fileInfo.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      strutStyle: StrutStyle(leading: 0, forceStrutHeight: true),
                      style: TextStyle(fontSize: 12, height: 1, fontWeight: FontWeight.w600, color: Color(0xFF666666)),
                    ),
                ],
              ),
            ),

            // 上传中时显示背景渐变动画进度条
            if (_isUploading)
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: widget.fileInfo.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.primary.withValues(alpha: 0.60), theme.colorScheme.primary.withValues(alpha: 0.25)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ),
            // 底部细进度条
            if (_isUploading && widget.isAvatar != true)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: widget.fileInfo.progress,
                  minHeight: 3,
                  backgroundColor: Colors.black26,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            // 状态层：上传状态浮动覆盖
            FileStatus(
              status: widget.fileInfo.status,
              progress: widget.fileInfo.progress,
              showSuccessBadge: widget.showSuccessBadge,
              isAvatar: widget.isAvatar,
              onRetry: widget.onRetry,
            ),
            // 删除按钮
            if (widget.showDeleteBtn && !_isUploading) CardDeleteBtn(onRemove: widget.onRemove),
          ],
        ),
      ),
    );
  }
}
