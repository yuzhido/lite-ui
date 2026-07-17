import 'package:flutter/material.dart';
import 'package:lite_ui/src/file_upload/model/file_info.dart';

import '../utils/file_utils.dart';

/// 文件类型图标
class FileType extends StatelessWidget {
  /// 文件信息
  final FileInfo fileInfo;
  const FileType({required this.fileInfo, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
      child: Icon(getFileIcon(fileInfo.extension), color: Colors.blue.shade400, size: 24),
    );
  }
}
