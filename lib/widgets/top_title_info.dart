import 'package:flutter/material.dart';

/// 顶部标题信息组件
///
/// 包含标题、副标题、计数和关闭按钮。
class TopTitleInfo extends StatelessWidget {
  /// 标题
  final String title;

  /// 副标题
  final String? subTitle;

  /// 数量计数，为 null 时不显示
  final int? itemCount;

  /// 关闭按钮点击回调，为 null 时不显示关闭按钮
  final VoidCallback? onClose;

  /// 是否显示关闭按钮，默认 true
  final bool showCloseButton;

  const TopTitleInfo({required this.title, this.subTitle, this.itemCount, this.onClose, this.showCloseButton = true, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧标题区域
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                ),
                if (subTitle != null)
                  Text(
                    subTitle ?? '--',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF999999)),
                  ),
              ],
            ),
          ),
          // 计数
          if (itemCount != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text('共 $itemCount 项', style: TextStyle(fontSize: 16, color: theme.hintColor)),
            ),
          // 关闭按钮
          if (showCloseButton)
            InkWell(
              onTap: onClose ?? () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.topRight,
                child: Icon(Icons.close_rounded, size: 24, color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }
}
