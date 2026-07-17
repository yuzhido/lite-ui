import 'package:flutter/material.dart';

import 'model/enum.dart';
import 'model/file_info.dart';
import 'model/upload_config.dart';
import 'widgets/card_show_file.dart';
import 'widgets/list_show_file.dart';
import 'service/upload_controller.dart';
import 'widgets/upload_action_area.dart';

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

  /// 上传文件数量限制，默认 -1 表示不限制；设置为正整数时最多允许上传的文件数。
  ///
  /// 达到上限后上传按钮自动隐藏，删除文件后可继续添加。
  final int limit;

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

  /// 文件列表展示类型
  /// - [ShowType.card]：卡片模式（默认），正方形网格布局
  /// - [ShowType.textInfo]：列表模式，横向行展示文件信息
  /// - [ShowType.custom]：自定义模式，需传入 [itemBuilder]
  final ShowType showType;

  /// 自定义文件项构建器
  ///
  /// 仅在 [showType] 为 [ShowType.custom] 时生效。
  /// 参数依次为：文件信息、索引、删除回调。
  final Widget Function(FileInfo fileInfo, int index, VoidCallback onRemove)? itemBuilder;

  /// 自定义上传按钮构建器
  ///
  /// 传入后将覆盖默认上传按钮样式，所有模式均可使用。
  /// 参数为点击上传的回调函数。
  final Widget Function(VoidCallback onTap)? uploadButtonBuilder;

  const FileUpload({
    super.key,
    this.pickerAction = PickerAction.all,
    this.multiple = true,
    this.limit = -1,
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
    this.borderRadius = 7,
    this.showType = ShowType.card,
    this.itemBuilder,
    this.uploadButtonBuilder,
  }) : assert(previewSize == null || columns == null, 'previewSize 和 columns 不能同时设置，二者互斥'),
       assert(limit == -1 || limit > 0, 'limit 必须为 -1 或正整数');

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
  UploadController? _controller;

  /// 获取当前文件列表
  List<FileInfo> get files => List.unmodifiable(_files);

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

  // ==================== 上传自动触发 ====================

  /// 自动上传（[UploadMode.auto] 和 [UploadMode.custom] 模式下生效）
  void _autoUpload(List<FileInfo> files) {
    if (widget.uploadConfig == null || widget.uploadConfig!.mode == UploadMode.manual) return;
    _ensureController();
    for (final file in files) {
      _controller!.startUpload(file.path);
    }
  }

  // ==================== 上传控制 - 公开方法 ====================

  /// 获取当前正在上传的文件数量
  int get activeUploadCount => _controller?.activeUploadCount ?? 0;

  UploadController _ensureController() {
    _controller ??= UploadController(
      config: widget.uploadConfig!,
      getFile: (path) => _files.firstWhere((f) => f.path == path),
      onFileStatusChanged: _onUploadFileStatusChanged,
      onFileProgress: _onUploadFileProgress,
    );
    return _controller!;
  }

  /// 开始上传指定文件（[UploadMode.manual] 和 [UploadMode.custom] 模式下使用）
  ///
  /// 如果文件正在上传或没有上传配置则忽略。
  /// 可通过 [GlobalKey<FileUploadState>] 在外部调用：
  /// ```dart
  /// key.currentState?.startUpload(file.path);
  /// ```
  Future<void> startUpload(String path) async {
    if (widget.uploadConfig == null) return;
    await _ensureController().startUpload(path);
  }

  /// 开始上传所有待上传（pending）的文件
  ///
  /// 按 [UploadConfig.maxConcurrent] 并发上限逐批上传。
  Future<void> startAllUpload() async {
    if (widget.uploadConfig == null) return;

    final pendingPaths = _files.where((f) => f.status == UploadStatus.pending).map((f) => f.path);
    await _ensureController().startAllUpload(pendingPaths);
  }

  /// 取消指定文件的上传
  ///
  /// 将文件状态恢复为 [UploadStatus.pending]，可再次上传。
  void cancelUpload(String path) {
    if (_controller != null) {
      _controller!.cancelUpload(path);
    } else {
      updateFileStatus(path, UploadStatus.pending);
    }
  }

  // ==================== 控制器回调 ====================

  void _onUploadFileStatusChanged(String path, UploadStatus status, {UploadResult? result}) {
    setState(() {
      final index = _files.indexWhere((f) => f.path == path);
      if (index == -1) return;
      _files[index] = _files[index].copyWith(status: status, responseBody: result?.responseBody);
    });

    FileAction? action;
    switch (status) {
      case UploadStatus.uploading:
        action = FileAction.uploading;
      case UploadStatus.success:
        action = FileAction.success;
      case UploadStatus.failed:
        action = FileAction.failed;
      default:
        break;
    }
    if (action != null) {
      final file = _files.firstWhere((f) => f.path == path, orElse: () => _files.first);
      widget.onFileChanged?.call([file], action);
    }
  }

  void _onUploadFileProgress(String path, double progress) {
    setState(() {
      final index = _files.indexWhere((f) => f.path == path);
      if (index != -1) {
        _files[index] = _files[index].copyWith(progress: progress);
      }
    });
    widget.onProgress?.call(path, progress);
    final file = _files.firstWhere((f) => f.path == path, orElse: () => _files.first);
    widget.onFileChanged?.call([file], FileAction.progress);
  }

  // ==================== 已选文件处理 ====================

  void _onFilesPicked(List<FileInfo> files) {
    setState(() => _files.addAll(files));
    widget.onFileChanged?.call(files, FileAction.add);
    _autoUpload(files);
  }

  // ==================== UI 构建 ====================

  /// 构建组件 UI
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        /// 卡片模式（默认）
        if (widget.showType == ShowType.card) {
          final useColumns = widget.columns != null;
          final cardSize = useColumns ? (constraints.maxWidth - (widget.columns! - 1) * widget.spacing) / widget.columns! : (widget.previewSize ?? 120);

          return SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: useColumns ? WrapAlignment.start : widget.alignment,
              spacing: widget.spacing,
              runSpacing: widget.spacing,
              children: [
                ..._files.map((f) => CardShowFile(key: ValueKey(f.path), fileInfo: f, borderRadius: widget.borderRadius, size: cardSize, onRemove: () => _removeFile(f))),
                if (widget.limit == -1 || _files.length < widget.limit)
                  UploadActionArea(
                    icon: widget.icon,
                    borderRadius: widget.borderRadius,
                    title: widget.title,
                    size: cardSize,
                    showType: widget.showType,
                    uploadButtonBuilder: widget.uploadButtonBuilder,
                    pickerAction: widget.pickerAction,
                    multiple: widget.multiple,
                    allowedExtensions: widget.allowedExtensions,
                    limit: widget.limit,
                    currentFileCount: _files.length,
                    onPicked: _onFilesPicked,
                  ),
              ],
            ),
          );
        } else if (widget.showType == ShowType.textInfo) {
          /// 列表模式
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._files.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: index < _files.length - 1 ? 8 : 0),
                  child: ListShowFile(
                    key: ValueKey(file.path),
                    fileInfo: file,
                    borderRadius: widget.borderRadius,
                    onRemove: () => _removeFile(file),
                    onCancel: () => cancelUpload(file.path),
                  ),
                );
              }),
              if (_files.isNotEmpty) const SizedBox(height: 8),
              if (widget.limit == -1 || _files.length < widget.limit)
                UploadActionArea(
                  icon: widget.icon,
                  borderRadius: widget.borderRadius,
                  title: widget.title,
                  size: 120,
                  showType: widget.showType,
                  uploadButtonBuilder: widget.uploadButtonBuilder,
                  pickerAction: widget.pickerAction,
                  multiple: widget.multiple,
                  allowedExtensions: widget.allowedExtensions,
                  limit: widget.limit,
                  currentFileCount: _files.length,
                  onPicked: _onFilesPicked,
                ),
            ],
          );
        } else if (widget.showType == ShowType.custom && widget.itemBuilder == null) {
          /// 自定义模式没提供 itemBuilder
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('custom 模式需要提供 itemBuilder', style: TextStyle(color: Colors.red)),
            ),
          );
        } else if (widget.showType == ShowType.custom && widget.itemBuilder != null) {
          /// 自定义模式
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._files.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: index < _files.length - 1 ? 8 : 0),
                  child: widget.itemBuilder!(file, index, () => _removeFile(file)),
                );
              }),
              if (_files.isNotEmpty) const SizedBox(height: 8),
              if (widget.limit == -1 || _files.length < widget.limit)
                UploadActionArea(
                  icon: widget.icon,
                  borderRadius: widget.borderRadius,
                  title: widget.title,
                  size: 120,
                  showType: widget.showType,
                  uploadButtonBuilder: widget.uploadButtonBuilder,
                  pickerAction: widget.pickerAction,
                  multiple: widget.multiple,
                  allowedExtensions: widget.allowedExtensions,
                  limit: widget.limit,
                  currentFileCount: _files.length,
                  onPicked: _onFilesPicked,
                ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
