import 'package:flutter/material.dart';

/// 上传按钮区域 UI
///
/// 支持两种布局模式：
/// - 正方形卡片（默认）：用于 [ShowType.card] 模式
/// - 通栏行（[fullWidth]=true）：用于 [ShowType.textInfo] 和 [ShowType.custom] 模式
class UploadArea extends StatelessWidget {
  final VoidCallback? onTap;

  /// 正方形模式下区域尺寸，默认 120
  final double size;

  /// 可选的背景图片，传入后作为卡片背景展示
  final ImageProvider? backgroundImage;

  /// 图标组件，默认 [Icon(Icons.add)]
  final Widget? icon;

  /// 提示文字
  final String title;

  /// 圆角半径，默认 8
  final double borderRadius;

  /// 是否为通栏行模式（列表/自定义模式使用）
  final bool fullWidth;

  /// 自定义上传按钮构建器，提供后完全替代默认 UI
  final Widget Function(VoidCallback onTap)? uploadButtonBuilder;

  const UploadArea({super.key, this.onTap, this.size = 120, this.backgroundImage, this.icon, required this.title, required this.borderRadius, this.fullWidth = false, this.uploadButtonBuilder});

  @override
  Widget build(BuildContext context) {
    if (uploadButtonBuilder != null && onTap != null) {
      return uploadButtonBuilder!(onTap!);
    }
    return fullWidth ? _buildFullWidth(context) : _buildSquare(context);
  }

  /// 通栏行模式（列表/自定义）
  Widget _buildFullWidth(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final borderColor = primaryColor.withValues(alpha: 0.35);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon ?? Icon(Icons.add, color: primaryColor.withValues(alpha: 0.55), size: 22),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primaryColor.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }

  /// 正方形卡片模式（默认）
  Widget _buildSquare(BuildContext context) {
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
