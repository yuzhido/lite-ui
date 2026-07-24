import 'dart:io';
import 'package:flutter/material.dart';

import '../model/enum.dart';
import '../model/file_info.dart';

/// 文件操作底部弹窗（Apple 风格）
///
/// 点击已上传成功的文件卡片时弹出，提供「预览图片」「替换」「删除」等操作选项。
/// 返回用户选择的 [ActionFileSheet]，取消返回 `null`。
class FileActionSheet {
  /// 显示文件操作弹窗
  ///
  /// [fileName] 当前文件名（展示给用户确认操作对象）
  /// [hasFailed] 文件是否上传失败，为 true 时额外显示「重新上传」选项
  /// [isImage] 是否为图片文件，为 true 时额外显示「预览图片」选项
  static Future<ActionFileSheet?> show({required BuildContext context, required String fileName, bool hasFailed = false, bool isImage = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showModalBottomSheet<ActionFileSheet>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _FileActionSheetBody(
        fileName: fileName,
        isDark: isDark,
        hasFailed: hasFailed,
        isImage: isImage,
        onSelected: (action) => Navigator.pop(ctx, action),
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  /// 显示图片全屏预览
  ///
  /// 支持双指缩放和拖动，点击关闭。
  static Future<void> showImagePreview({required BuildContext context, required FileInfo fileInfo}) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => _ImagePreviewPage(fileInfo: fileInfo),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}

/// 文件操作弹窗内容体
class _FileActionSheetBody extends StatelessWidget {
  final String fileName;
  final bool isDark;
  final bool hasFailed;
  final bool isImage;
  final ValueChanged<ActionFileSheet> onSelected;
  final VoidCallback onCancel;

  const _FileActionSheetBody({required this.fileName, required this.isDark, required this.hasFailed, required this.isImage, required this.onSelected, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final dividerColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 选项卡片
            Container(
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 文件名标题
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(color: cardColor),
                    child: Text(
                      fileName,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, height: 1, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF98989D) : const Color(0xFF696969)),
                    ),
                  ),

                  Divider(height: 0.5, thickness: 0.5, color: dividerColor),
                  if (isImage)
                    _ActionTile(
                      label: '预览图片',
                      icon: Icons.image_outlined,
                      iconColor: isDark ? const Color(0xFFBF5AF2) : const Color(0xFFAF52DE),
                      iconBgColor: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF5F0FF),
                      textColor: isDark ? const Color(0xFFBF5AF2) : const Color(0xFFAF52DE),
                      onTap: () => onSelected(ActionFileSheet.preview),
                    ),
                  if (isImage) Divider(height: 0.5, thickness: 0.5, color: dividerColor),
                  if (hasFailed)
                    _ActionTile(
                      label: '上传重试',
                      icon: Icons.refresh,
                      iconColor: isDark ? const Color(0xFF30D158) : const Color(0xFF34C759),
                      iconBgColor: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF0FDF4),
                      textColor: isDark ? const Color(0xFF30D158) : const Color(0xFF34C759),
                      onTap: () => onSelected(ActionFileSheet.retry),
                    ),
                  if (hasFailed) Divider(height: 0.5, thickness: 0.5, color: dividerColor),
                  _ActionTile(
                    label: '替换文件',
                    icon: Icons.swap_horiz,
                    iconColor: isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF),
                    iconBgColor: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF2F2F7),
                    textColor: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    onTap: () => onSelected(ActionFileSheet.replace),
                  ),
                  Divider(height: 0.5, thickness: 0.5, color: dividerColor),
                  _ActionTile(
                    label: '删除文件',
                    icon: Icons.delete_forever_outlined,
                    iconColor: const Color(0xFFEF4444),
                    iconBgColor: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFFEF2F2),
                    textColor: const Color(0xFFEF4444),
                    onTap: () => onSelected(ActionFileSheet.delete),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // 取消按钮
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onCancel,
                  splashColor: Colors.transparent,
                  highlightColor: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      '取消',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单个操作选项行
class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionTile({required this.label, required this.icon, required this.iconColor, required this.iconBgColor, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // 图标容器
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              // 文字
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: textColor),
                ),
              ),
              // 箭头
              Icon(Icons.chevron_right, size: 20, color: isDark ? const Color(0xFF98989D) : const Color(0xFF8E8E93)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 图片全屏预览页面
class _ImagePreviewPage extends StatelessWidget {
  final FileInfo fileInfo;

  const _ImagePreviewPage({required this.fileInfo});

  @override
  Widget build(BuildContext context) {
    final isNetwork = fileInfo.isNetwork;
    final imageProvider = isNetwork ? Image.network(fileInfo.url!, fit: BoxFit.contain).image : Image.file(File(fileInfo.path!), fit: BoxFit.contain).image;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 图片区域：支持双指缩放和拖动
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5.0,
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.contain,
                  errorBuilder: (_, error, stack) => const Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 64)),
                ),
              ),
            ),
            // 顶部关闭按钮
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
            // 底部文件名
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: const BoxDecoration(color: Color(0x80000000)),
                child: Text(
                  fileInfo.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
