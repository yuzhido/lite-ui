import 'package:flutter/material.dart';

/// 上传按钮区域 UI
///
/// 支持可选背景图片，默认展示 "+" 图标。
/// 视觉风格与 [FilePreview] 卡片保持一致。
class UploadArea extends StatelessWidget {
  final VoidCallback? onTap;

  /// 上传区域尺寸，默认 120，应与 [FilePreview] 的 size 保持一致
  final double size;

  /// 可选的背景图片，传入后作为卡片背景展示
  final ImageProvider? backgroundImage;

  /// 图标组件，默认 [Icon(Icons.add)]，可自定义图标、大小、颜色等
  final Widget? icon;

  /// 提示文字，默认"点击上传"
  final String title;

  /// 圆角半径，默认 5
  final double borderRadius;

  const UploadArea({super.key, this.onTap, this.size = 120, this.backgroundImage, this.icon, required this.title, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final borderColor = primaryColor.withValues(alpha: 0.35);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: 1),
          image: backgroundImage != null ? DecorationImage(image: backgroundImage!, fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.white, BlendMode.lighten)) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon ?? Icon(Icons.add, color: primaryColor.withValues(alpha: 0.55), size: size * 0.2),
            Text(
              title,
              style: TextStyle(fontSize: size * 0.1, fontWeight: FontWeight.w500, color: primaryColor.withValues(alpha: 0.55)),
            ),
          ],
        ),
      ),
    );
  }
}
