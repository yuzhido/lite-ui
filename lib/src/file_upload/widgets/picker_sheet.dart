import 'package:flutter/material.dart';

import '../model/enum.dart';

/// 底部选择弹窗 — Apple 风格，根据 [PickFile] 展示对应的文件选择操作选项
class PickerSheet {
  /// 显示底部选择弹窗，返回用户选择的 [PickFile]，取消返回 `null`
  static Future<PickFile?> show({required BuildContext context, required PickFile pickFile}) {
    final options = _buildOptions(pickFile);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showModalBottomSheet<PickFile>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _AppleSheetBody(options: options, isDark: isDark, onSelected: (action) => Navigator.pop(ctx, action), onCancel: () => Navigator.pop(ctx)),
    );
  }

  /// 根据 [PickFile] 构建弹窗选项列表
  static List<_SheetOption> _buildOptions(PickFile pickFile) {
    switch (pickFile) {
      case PickFile.all:
        return [
          const _SheetOption(label: '选择文件', icon: Icons.folder_open, action: PickFile.file),
          const _SheetOption(label: '从相册选择', icon: Icons.photo_library, action: PickFile.gallery),
          const _SheetOption(label: '拍照', icon: Icons.camera_alt, action: PickFile.camera),
        ];
      case PickFile.imageOrCamera:
        return [
          const _SheetOption(label: '从相册选择', icon: Icons.photo_library, action: PickFile.gallery),
          const _SheetOption(label: '拍照', icon: Icons.camera_alt, action: PickFile.camera),
        ];
      default:
        return [];
    }
  }
}

/// Apple 风格弹窗内容
class _AppleSheetBody extends StatelessWidget {
  final List<_SheetOption> options;
  final bool isDark;
  final ValueChanged<PickFile> onSelected;
  final VoidCallback onCancel;

  const _AppleSheetBody({required this.options, required this.isDark, required this.onSelected, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final dividerColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA);
    final subtitleColor = isDark ? const Color(0xFF98989D) : const Color(0xFF8E8E93);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 选项卡片
            Container(
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // // 顶部拖拽指示条
                  // Container(
                  //   margin: const EdgeInsets.only(top: 8, bottom: 12),
                  //   width: 36,
                  //   height: 5,
                  //   decoration: BoxDecoration(color: isDark ? const Color(0xFF636366) : const Color(0xFFD1D1D6), borderRadius: BorderRadius.circular(2.5)),
                  // ),
                  for (int i = 0; i < options.length; i++) ...[
                    if (i > 0) Divider(height: 0.5, thickness: 0.5, color: dividerColor, indent: 56),
                    _AppleOptionTile(option: options[i], subtitleColor: subtitleColor, onTap: () => onSelected(options[i].action)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            // 取消按钮
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
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
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

/// 单个选项行
class _AppleOptionTile extends StatelessWidget {
  final _SheetOption option;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _AppleOptionTile({required this.option, required this.subtitleColor, required this.onTap});

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
                decoration: BoxDecoration(color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(8)),
                child: Icon(option.icon, size: 20, color: isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF)),
              ),
              const SizedBox(width: 14),
              // 文字
              Expanded(
                child: Text(
                  option.label,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                ),
              ),
              // 箭头
              Icon(Icons.chevron_right, size: 20, color: subtitleColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// 弹窗选项数据
class _SheetOption {
  final String label;
  final IconData icon;
  final PickFile action;

  const _SheetOption({required this.label, required this.icon, required this.action});
}
