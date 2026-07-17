import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'controller.dart';
import 'model/enum.dart';
import 'model/file_info.dart';
import 'model/upload_config.dart';
import 'widgets/file_preview.dart';
import 'widgets/upload_area.dart';
import 'widgets/picker_sheet.dart';
import 'service/upload_service.dart';

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
  /// [action] 变更动作（add / remove / uploading / progress / success / failed）
  final Function(List<FileInfo> files, FileAction action)? onFileChanged;

  /// 文件预览卡片尺寸（宽高一致的正方形），默认 120
  ///
  /// 仅在未设置 [columns] 时生效；设置 [columns] 后卡片宽度由列数自动计算。
  /// 与 [columns] 互斥，不能同时设置。
  final double? previewSize;

  /// 每行显示的卡片列数，设置后卡片宽度自适应填满容器
  ///
  /// 与 [previewSize] 互斥，不能同时设置。
  final int? columns;

  /// 卡片之间的间距（水平 + 垂直），默认 8
  ///
  /// 仅在设置 [columns] 时生效。
  final double spacing;

  /// 每行文件的对齐方式，默认左对齐（仅固定尺寸模式生效）
  final WrapAlignment alignment;

  /// 上传配置，提供后启用上传能力
  ///
  /// 支持三种模式：
  /// - [UploadMode.auto]：选择文件后自动上传
  /// - [UploadMode.manual]：手动触发上传
  /// - [UploadMode.custom]：自定义上传函数
  final UploadConfig? uploadConfig;

  /// 上传进度回调，参数为文件路径和 0.0~1.0 的进度
  final void Function(String path, double progress)? onProgress;

  final Widget? icon;

  /// 圆角半径，默认 5
  final double borderRadius;

  /// 标题
  final String title;

  const FileUpload({
    super.key,
    this.pickerAction = PickerAction.all,
    this.multiple = true,
    this.allowedExtensions,
    this.title = '点击上传',
    this.onFileChanged,
    this.previewSize,
    this.columns = 3,
    this.spacing = 10,
    this.alignment = WrapAlignment.start,
    this.uploadConfig,
    this.onProgress,
    this.icon,
    this.borderRadius = 10,
  }) : assert(previewSize == null || columns == null, 'previewSize 和 columns 不能同时设置，二者互斥');

  @override
  State<FileUpload> createState() => FileUploadState();
}

/// [FileUpload] 的状态管理类
///
/// 通过 [GlobalKey<FileUploadState>] 可在外部调用上传相关方法：
/// - [startUpload] / [startAllUpload]：手动触发上传
/// - [cancelUpload]：取消上传
/// - [updateFileStatus]：手动更新文件状态
class FileUploadState extends State<FileUpload> {
  final List<FileInfo> _files = [];
  bool _isPicking = false;

  /// 当前活跃的上传任务数
  int _activeUploadCount = 0;

  /// 用于取消上传的标志
  final Map<String, bool> _cancelFlags = {};

  /// 获取当前文件列表
  List<FileInfo> get files => List.unmodifiable(_files);

  // ==================== 文件选择操作 ====================

  /// 使用 [PickFileController.pickFiles] 选择文件
  Future<void> _pickFiles() async {
    final files = await PickFileController.pickFiles(multiple: widget.multiple, allowedExtensions: widget.allowedExtensions);
    if (files.isNotEmpty) {
      setState(() => _files.addAll(files));
      widget.onFileChanged?.call(files, FileAction.add);
      _autoUpload(files);
    }
  }

  /// 使用 [PickFileController.pickImage] 选择图片
  Future<void> _pickImage(ImageSource source) async {
    final files = await PickFileController.pickImage(source, multiple: widget.multiple);
    if (files.isNotEmpty) {
      setState(() => _files.addAll(files));
      widget.onFileChanged?.call(files, FileAction.add);
      _autoUpload(files);
    }
  }

  /// 删除单个文件
  void _removeFile(FileInfo file) {
    // 上传中的文件不让删除
    if (file.status == UploadStatus.uploading) return;
    setState(() => _files.remove(file));
    widget.onFileChanged?.call([file], FileAction.remove);
  }

  // ==================== 文件状态管理 ====================

  /// 更新指定文件的上传状态
  ///
  /// 通过 [path] 匹配文件，更新其 [status] 并触发重建。
  void updateFileStatus(String path, UploadStatus status) {
    setState(() {
      final index = _files.indexWhere((f) => f.path == path);
      if (index != -1) {
        _files[index] = _files[index].copyWith(status: status);
      }
    });
  }

  /// 更新指定文件的进度值
  void _updateFileProgress(String path, double progress) {
    setState(() {
      final index = _files.indexWhere((f) => f.path == path);
      if (index != -1) {
        _files[index] = _files[index].copyWith(progress: progress);
      }
    });
    widget.onProgress?.call(path, progress);
    widget.onFileChanged?.call([_files.firstWhere((f) => f.path == path, orElse: () => _files.first)], FileAction.progress);
  }

  // ==================== 上传自动触发 ====================

  /// 自动上传（[UploadMode.auto] 和 [UploadMode.custom] 模式下生效）
  void _autoUpload(List<FileInfo> files) {
    if (widget.uploadConfig == null || widget.uploadConfig!.mode == UploadMode.manual) return;
    for (final file in files) {
      startUpload(file.path);
    }
  }

  // ==================== 上传控制 - 公开方法 ====================

  /// 获取当前正在上传的文件数量
  int get activeUploadCount => _activeUploadCount;

  /// 开始上传指定文件（[UploadMode.manual] 和 [UploadMode.custom] 模式下使用）
  ///
  /// 如果文件正在上传或没有上传配置则忽略。
  /// 可通过 [GlobalKey<FileUploadState>] 在外部调用：
  /// ```dart
  /// key.currentState?.startUpload(file.path);
  /// ```
  Future<void> startUpload(String path) async {
    if (widget.uploadConfig == null) return;

    final index = _files.indexWhere((f) => f.path == path);
    if (index == -1) return;
    if (_files[index].status == UploadStatus.uploading) return;

    // 并发控制：等待直到活跃数低于上限
    while (_activeUploadCount >= widget.uploadConfig!.maxConcurrent) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }

    await _executeUpload(index);
  }

  /// 开始上传所有待上传（pending）的文件
  ///
  /// 按 [UploadConfig.maxConcurrent] 并发上限逐批上传。
  Future<void> startAllUpload() async {
    if (widget.uploadConfig == null) return;

    final pendingPaths = _files.where((f) => f.status == UploadStatus.pending).map((f) => f.path).toList();

    // 逐个启动上传，内部通过 _activeUploadCount 控制并发
    final futures = pendingPaths.map((path) => startUpload(path));
    await Future.wait(futures);
  }

  /// 取消指定文件的上传
  ///
  /// 将文件状态恢复为 [UploadStatus.pending]，可再次上传。
  void cancelUpload(String path) {
    _cancelFlags[path] = true;
    updateFileStatus(path, UploadStatus.pending);
  }

  // ==================== 上传执行 ====================

  /// 执行实际上传，含重试逻辑
  Future<void> _executeUpload(int index) async {
    final path = _files[index].path;
    _cancelFlags.remove(path);

    // 更新状态为上传中
    updateFileStatus(path, UploadStatus.uploading);
    widget.onFileChanged?.call([_files[index]], FileAction.uploading);

    _activeUploadCount++;
    UploadResult? result;

    try {
      for (int attempt = 0; attempt <= widget.uploadConfig!.retryCount; attempt++) {
        // 检查是否被取消
        if (_cancelFlags[path] == true) return;

        if (attempt > 0) {
          // 重试前短暂延迟
          updateFileStatus(path, UploadStatus.uploading);
          await Future<void>.delayed(Duration(seconds: attempt));
        }

        // 执行上传
        result = widget.uploadConfig!.mode == UploadMode.custom && widget.uploadConfig!.customUpload != null ? await _customUpload(path, index) : await _builtinUpload(path, index);

        if (result.success) break;
      }

      // 处理结果
      if (_cancelFlags[path] == true) return;

      if (result != null && result.success) {
        // 业务校验：如果提供了 validateResult，检查服务端响应体
        final isValid = widget.uploadConfig!.validateResult == null || widget.uploadConfig!.validateResult!(result.responseBody);

        if (isValid) {
          setState(() {
            final i = _files.indexWhere((f) => f.path == path);
            if (i != -1) {
              _files[i] = _files[i].copyWith(status: UploadStatus.success, responseBody: result!.responseBody);
            }
          });
          widget.onFileChanged?.call([_files[index]], FileAction.success);
        } else {
          debugPrint('[FileUpload] 业务校验失败: path=$path, response=${result.responseBody}');
          updateFileStatus(path, UploadStatus.failed);
          widget.onFileChanged?.call([_files[index]], FileAction.failed);
        }
      } else {
        debugPrint('[FileUpload] 上传失败: path=$path, error=${result?.error}');
        updateFileStatus(path, UploadStatus.failed);
        widget.onFileChanged?.call([_files[index]], FileAction.failed);
      }
    } finally {
      _activeUploadCount--;
      _cancelFlags.remove(path);
    }
  }

  /// 自定义上传
  Future<UploadResult> _customUpload(String path, int index) async {
    try {
      final result = await widget.uploadConfig!.customUpload!(_files[index], (progress) {
        if (_cancelFlags[path] == true) return;
        _updateFileProgress(path, progress);
      });
      return result;
    } catch (e) {
      return UploadResult.failure(error: e.toString());
    }
  }

  /// 内置 HTTP 上传
  Future<UploadResult> _builtinUpload(String path, int index) async {
    if (widget.uploadConfig!.url == null) {
      return UploadResult.failure(error: '未配置上传地址（url）');
    }

    try {
      final result = await UploadService.upload(
        filePath: path,
        url: widget.uploadConfig!.url!,
        method: widget.uploadConfig!.method,
        headers: widget.uploadConfig!.headers,
        fields: widget.uploadConfig!.fields,
        fileField: widget.uploadConfig!.fileField,
        fileName: _files[index].name,
        onProgress: (progress) {
          if (_cancelFlags[path] == true) return;
          _updateFileProgress(path, progress);
        },
      );
      return result;
    } catch (e) {
      return UploadResult.failure(error: e.toString());
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

  // ==================== UI 构建 ====================

  /// 构建组件 UI
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useColumns = widget.columns != null;
        final cardSize = useColumns ? (constraints.maxWidth - (widget.columns! - 1) * widget.spacing) / widget.columns! : (widget.previewSize ?? 120);

        return SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: useColumns ? WrapAlignment.start : widget.alignment,
            spacing: widget.spacing,
            runSpacing: widget.spacing,
            children: [
              ..._files.map((f) => FilePreview(key: ValueKey(f.path), fileInfo: f, borderRadius: widget.borderRadius, size: cardSize, onRemove: () => _removeFile(f))),
              UploadArea(icon: widget.icon, borderRadius: widget.borderRadius, title: widget.title, size: cardSize, onTap: _onTapUpload),
            ],
          ),
        );
      },
    );
  }
}
