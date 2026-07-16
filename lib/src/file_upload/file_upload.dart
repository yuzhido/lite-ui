import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'file_picker_controller.dart';
import 'model/enum.dart';
import 'model/file_info.dart';
import 'widgets/file_preview.dart';
import 'widgets/picker_sheet.dart';
import 'widgets/upload_area.dart';

class FileUpload extends StatefulWidget {
  /// 选择器操作类型
  /// - [PickerAction.file]：直接选择文件
  /// - [PickerAction.gallery]：直接选择相册
  /// - [PickerAction.camera]：直接拍照
  /// - [PickerAction.imageOrCamera]：弹窗选择相册或拍照
  /// - [PickerAction.all]：弹窗选择文件/相册/拍照
  final PickerAction pickerAction;

  /// 是否支持多选，默认为 true；设为 false 时只能单选
  final bool multiple;

  /// 允许的文件扩展名列表（如 ['pdf', 'docx']），仅在 [PickerAction.file] 时生效
  final List<String>? allowedExtensions;

  /// 文件变更回调，选择/删除文件后触发
  ///
  /// [action] 变更动作（add / remove）
  /// [files] 本次变更涉及的文件列表
  final Function(List<FileInfo> files, FileAction action)? onFileChanged;

  /// 文件预览卡片尺寸（宽高一致的正方形），默认 120
  final double previewSize;

  /// 每行文件的对齐方式，默认左对齐
  final WrapAlignment alignment;

  const FileUpload({
    super.key,
    this.pickerAction = PickerAction.all,
    this.multiple = true,
    this.allowedExtensions,
    this.onFileChanged,
    this.previewSize = 120,
    this.alignment = WrapAlignment.start,
  });

  @override
  State<FileUpload> createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {
  final List<FileInfo> _files = [];
  bool _isPicking = false;

  // ==================== 文件选择操作 ====================

  /// 使用 [FilePickerController.pickFiles] 选择文件
  Future<void> _pickFiles() async {
    final files = await FilePickerController.pickFiles(multiple: widget.multiple, allowedExtensions: widget.allowedExtensions);
    if (files.isNotEmpty) {
      setState(() => _files.addAll(files));
      widget.onFileChanged?.call(files, FileAction.add);
    }
  }

  /// 使用 [FilePickerController.pickImage] 选择图片
  Future<void> _pickImage(ImageSource source) async {
    final files = await FilePickerController.pickImage(source, multiple: widget.multiple);
    if (files.isNotEmpty) {
      setState(() => _files.addAll(files));
      widget.onFileChanged?.call(files, FileAction.add);
    }
  }

  /// 删除单个文件
  void _removeFile(FileInfo file) {
    setState(() => _files.remove(file));
    widget.onFileChanged?.call([file], FileAction.remove);
  }

  /// 执行具体的 [PickerAction]（分发到对应的文件选择方法）
  Future<void> _handlePickerAction(PickerAction action) async {
    switch (action) {
      case PickerAction.file:
        await _pickFiles();
      case PickerAction.gallery:
        await _pickImage(ImageSource.gallery);
      case PickerAction.camera:
        await _pickImage(ImageSource.camera);
      case PickerAction.all:
      case PickerAction.imageOrCamera:
        break;
    }
  }

  // ==================== 点击上传入口 ====================

  /// 点击上传入口：直接选择或弹窗选择后执行
  Future<void> _onTapUpload() async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      switch (widget.pickerAction) {
        case PickerAction.file:
          await _pickFiles();
        case PickerAction.gallery:
          await _pickImage(ImageSource.gallery);
        case PickerAction.camera:
          await _pickImage(ImageSource.camera);
        case PickerAction.all:
        case PickerAction.imageOrCamera:
          final action = await PickerSheet.show(context: context, pickerAction: widget.pickerAction);
          if (action != null) {
            await _handlePickerAction(action);
          }
      }
    } finally {
      _isPicking = false;
    }
  }

  /// 构建组件 UI
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: widget.alignment,
        spacing: 8,
        runSpacing: 8,
        children: [
          // 文件预览列表
          ..._files.map((f) => FilePreview(key: ValueKey(f.path), fileInfo: f, size: widget.previewSize, onRemove: () => _removeFile(f))),
          // 上传按钮区域
          UploadArea(size: widget.previewSize, onTap: _onTapUpload),
        ],
      ),
    );
  }
}
