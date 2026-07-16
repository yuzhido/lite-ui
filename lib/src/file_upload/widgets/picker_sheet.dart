import 'package:flutter/material.dart';

import '../model/enum.dart';

/// 底部选择弹窗 — 根据 [PickerAction] 展示对应的文件选择操作选项
class PickerSheet {
  /// 显示底部选择弹窗，返回用户选择的 [PickerAction]，取消返回 `null`
  static Future<PickerAction?> show({required BuildContext context, required PickerAction pickerAction}) {
    final options = _buildOptions(pickerAction);

    return showModalBottomSheet<PickerAction>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (opt) => ListTile(
                  leading: Icon(opt.icon, color: Theme.of(context).colorScheme.primary),
                  title: Text(opt.label),
                  onTap: () => Navigator.pop(ctx, opt.action),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  /// 根据 [PickerAction] 构建弹窗选项列表
  static List<_SheetOption> _buildOptions(PickerAction pickerAction) {
    switch (pickerAction) {
      case PickerAction.all:
        return [
          const _SheetOption(label: '选择文件', icon: Icons.folder_open, action: PickerAction.file),
          const _SheetOption(label: '从相册选择', icon: Icons.photo_library, action: PickerAction.gallery),
          const _SheetOption(label: '拍照', icon: Icons.camera_alt, action: PickerAction.camera),
        ];
      case PickerAction.imageOrCamera:
        return [
          const _SheetOption(label: '从相册选择', icon: Icons.photo_library, action: PickerAction.gallery),
          const _SheetOption(label: '拍照', icon: Icons.camera_alt, action: PickerAction.camera),
        ];
      default:
        return [];
    }
  }
}

/// 弹窗选项数据
class _SheetOption {
  final String label;
  final IconData icon;
  final PickerAction action;

  const _SheetOption({required this.label, required this.icon, required this.action});
}
