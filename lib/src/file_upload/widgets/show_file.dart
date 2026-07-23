import 'package:flutter/material.dart';

import '../model/file_info.dart';
import '../utils/file_utils.dart';

/// 非图片文件卡片内容
///
/// 展示文件类型图标、文件名和文件大小。
class ShowFile extends StatelessWidget {
  /// 文件信息
  final FileInfo fileInfo;

  /// 卡片尺寸（宽高一致的正方形）
  final double size;

  /// 圆角半径
  final double borderRadius;

  /// 边框颜色
  final Color borderColor;

  const ShowFile({super.key, required this.fileInfo, required this.size, required this.borderRadius, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: getFileColor(fileInfo.extension).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(getFileIcon(fileInfo.extension), color: getFileColor(fileInfo.extension), size: size * 0.5),
          ),
          SizedBox(height: size * 0.08),
          Text(fileInfo.name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
          Text(fileInfo.formatSize, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
