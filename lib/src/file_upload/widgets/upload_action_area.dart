import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controller.dart';
import '../model/enum.dart';
import '../model/file_info.dart';

import 'picker_sheet.dart';

/// 上传操作区域
///
/// 默认模式下点击触发文件选择（根据 [pickFile] 自动选择文件/相册/拍照），
/// 选择完成后通过 [onPicked] 回调返回。
///
/// 自定义模式下（[uploadButtonBuilder]）使用外部传入的 [onTap] 完全控制行为。
class UploadActionArea extends StatefulWidget {
  /// 正方形模式下区域尺寸，默认 120
  final double size;

  /// 文件圆角半径
  final double? fileRadius;

  /// 预览图尺寸
  final double? previewSize;

  /// 可选的背景图片，传入后作为卡片背景展示
  final ImageProvider? backgroundImage;

  /// 图标组件，默认 [Icon(Icons.add)]
  final Widget? icon;

  /// 提示文字
  final String title;

  /// 提示文字样式，为空时使用默认样式
  final TextStyle? titleStyle;

  /// 圆角半径，默认 8
  final double borderRadius;

  /// 上传区域的装饰样式，可自定义背景色、边框、圆角、阴影等
  ///
  /// 为空时使用默认装饰（主题色浅背景 + 主题色边框 + [borderRadius] 圆角）。
  /// 传入后将完全覆盖默认的 [BoxDecoration]（包括背景色、边框、圆角、渐变、阴影等）。
  final BoxDecoration? decoration;

  /// 展示类型，决定布局样式
  final ShowType showType;

  // ==================== 选择器配置 ====================

  /// 选择器操作类型
  final PickFile pickFile;

  /// 是否支持多选
  final bool multiple;

  /// 允许的文件扩展名列表（如 ['pdf', 'docx']）
  final List<String>? allowedExtensions;

  /// 上传文件数量限制，-1 表示不限制
  final int limit;

  /// 当前文件数量（用于判断是否已达上限）
  final int currentFileCount;

  /// 文件选择完成回调，参数为本次选中的文件列表
  final void Function(List<FileInfo> files)? onPicked;

  // ==================== 自定义模式 ====================

  /// 自定义点击回调（仅 [uploadButtonBuilder] 模式下使用）
  final VoidCallback? onTap;

  /// 自定义上传按钮构建器，提供后完全替代默认 UI
  final Widget Function(VoidCallback onTap)? uploadButtonBuilder;

  const UploadActionArea({
    super.key,
    this.size = 120,
    this.fileRadius,
    this.backgroundImage,
    this.icon,
    required this.title,
    this.previewSize,
    this.titleStyle,
    required this.borderRadius,
    this.decoration,
    required this.showType,
    required this.pickFile,
    this.multiple = true,
    this.allowedExtensions,
    this.limit = -1,
    this.currentFileCount = 0,
    this.onPicked,
    this.onTap,
    this.uploadButtonBuilder,
  });

  @override
  State<UploadActionArea> createState() => _UploadActionAreaState();
}

class _UploadActionAreaState extends State<UploadActionArea> {
  bool _isPicking = false;

  // ==================== 文件选择操作 ====================

  Future<void> _onTapUpload() async {
    if (_isPicking) return;
    // 已达上传数量上限
    if (widget.limit > 0 && widget.currentFileCount >= widget.limit) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已达到上传数量上限')));
      }
      return;
    }
    _isPicking = true;
    try {
      switch (widget.pickFile) {
        case PickFile.file:
          await _pickFiles();
        case PickFile.gallery:
          await _pickImage(ImageSource.gallery);
        case PickFile.camera:
          await _pickImage(ImageSource.camera);
        case PickFile.all:
        case PickFile.imageOrCamera:
          final action = await PickerSheet.show(context: context, pickFile: widget.pickFile);
          if (action != null) {
            await _handlePickerAction(action);
          }
      }
    } finally {
      _isPicking = false;
    }
  }

  Future<void> _handlePickerAction(PickFile action) async {
    switch (action) {
      case PickFile.file:
        await _pickFiles();
      case PickFile.gallery:
        await _pickImage(ImageSource.gallery);
      case PickFile.camera:
        await _pickImage(ImageSource.camera);
      case PickFile.all:
      case PickFile.imageOrCamera:
        break;
    }
  }

  Future<void> _pickFiles() async {
    final remaining = widget.limit > 0 ? widget.limit - widget.currentFileCount : null;
    final files = await PickFileController.pickFiles(multiple: widget.multiple, allowedExtensions: widget.allowedExtensions, remaining: remaining);
    if (files.isNotEmpty) {
      widget.onPicked?.call(files);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final remaining = widget.limit > 0 ? widget.limit - widget.currentFileCount : null;
    final files = await PickFileController.pickImage(source, multiple: widget.multiple, remaining: remaining);
    if (files.isNotEmpty) {
      widget.onPicked?.call(files);
    }
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final defaultBorderColor = primaryColor.withValues(alpha: 0.35);

    if (widget.uploadButtonBuilder != null && widget.onTap != null) {
      return widget.uploadButtonBuilder!(widget.onTap!);
    } else if (widget.showType == ShowType.card) {
      /// 正方形卡片模式（默认）
      return GestureDetector(
        onTap: _onTapUpload,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration:
              widget.decoration ??
              BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(color: defaultBorderColor, width: 1),
                image: widget.backgroundImage != null
                    ? DecorationImage(image: widget.backgroundImage!, fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.white, BlendMode.lighten))
                    : null,
              ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon ?? Icon(Icons.add, color: primaryColor.withValues(alpha: 0.55), size: widget.size * 0.2),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: widget.titleStyle ?? TextStyle(fontSize: widget.size * 0.1, fontWeight: FontWeight.w500, color: primaryColor.withValues(alpha: 0.55)),
              ),
            ],
          ),
        ),
      );
    } else {
      /// 通栏行模式（列表/自定义）
      return GestureDetector(
        onTap: _onTapUpload,
        child: Container(
          decoration:
              widget.decoration ??
              BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor.withValues(alpha: 0.04), primaryColor.withValues(alpha: 0.08)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(color: defaultBorderColor, width: 1),
              ),
          child: Padding(
            padding: EdgeInsets.all(7),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(widget.fileRadius ?? 8),
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.transparent)),
                    child: Container(
                      width: widget.previewSize,
                      height: widget.previewSize,
                      decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(widget.fileRadius ?? 8)),
                      child: widget.icon ?? Icon(Icons.cloud_upload_outlined, color: primaryColor.withValues(alpha: 0.7), size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: widget.titleStyle ?? TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primaryColor.withValues(alpha: 0.8)),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                  child: Icon(Icons.arrow_forward_ios_rounded, color: primaryColor.withValues(alpha: 0.4), size: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
