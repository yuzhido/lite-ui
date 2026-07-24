import 'package:flutter/material.dart';

import '../model/enum.dart';

/// 文件操作底部弹窗（Apple 风格）
///
/// 点击已上传成功的文件卡片时弹出，提供「替换」「删除」两个操作选项。
/// 返回用户选择的 [ActionFileSheet]，取消返回 `null`。
class FileActionSheet {
  /// 显示文件操作弹窗
  ///
  /// [fileName] 当前文件名（展示给用户确认操作对象）
  /// [hasFailed] 文件是否上传失败，为 true 时额外显示「重新上传」选项
  static Future<ActionFileSheet?> show({required BuildContext context, required String fileName, bool hasFailed = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showModalBottomSheet<ActionFileSheet>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) =>
          _FileActionSheetBody(fileName: fileName, isDark: isDark, hasFailed: hasFailed, onSelected: (action) => Navigator.pop(ctx, action), onCancel: () => Navigator.pop(ctx)),
    );
  }
}

/// 文件操作弹窗内容体
class _FileActionSheetBody extends StatelessWidget {
  final String fileName;
  final bool isDark;
  final bool hasFailed;
  final ValueChanged<ActionFileSheet> onSelected;
  final VoidCallback onCancel;

  const _FileActionSheetBody({required this.fileName, required this.isDark, required this.hasFailed, required this.onSelected, required this.onCancel});

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
