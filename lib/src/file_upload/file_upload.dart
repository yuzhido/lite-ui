import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'controller.dart';
import 'model/enum.dart';
import 'model/file_info.dart';
import 'model/upload_config.dart';
import 'widgets/card_show_file.dart';
import 'widgets/file_action_sheet.dart';
import 'widgets/list_show_file.dart';
import 'widgets/picker_sheet.dart';
import 'service/upload_controller.dart';
import 'widgets/upload_action_area.dart';

class FileUpload extends StatefulWidget {
  /// 选择器操作类型
  /// - [PickFile.file]：直接选择文件
  /// - [PickFile.gallery]：直接选择相册
  /// - [PickFile.camera]：直接拍照
  /// - [PickFile.imageOrCamera]：弹窗选择相册或拍照
  /// - [PickFile.all]：弹窗选择文件/相册/拍照
  final PickFile pickFile;

  /// 是否支持多选，默认为 true；设为 false 时只能单选
  final bool multiple;

  /// 上传文件数量限制，默认 -1 表示不限制；设置为正整数时最多允许上传的文件数。
  ///
  /// 达到上限后上传按钮自动隐藏，删除文件后可继续添加。
  final int limit;

  /// 允许的文件扩展名列表（如 ['pdf', 'docx']），仅在 [PickFile.file] 时生效
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

  /// 上传进度回调
  ///
  /// 参数依次为：文件 id、文件本地路径、进度值 0.0~1.0
  final void Function(String id, String path, double progress)? onProgress;

  final Widget? icon;

  /// 外层容器圆角半径，默认 7
  final double borderRadius;

  /// 文件卡片内部圆角半径，默认 5
  ///
  /// 控制文件预览内容（图片/文件图标）的圆角，与外层容器 [borderRadius] 独立。
  final double fileRadius;

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

  /// 上传按钮区域的装饰样式，可自定义背景色、边框、圆角、阴影等
  ///
  /// 为空时使用默认装饰，传入后将完全覆盖默认的 [BoxDecoration]。
  final BoxDecoration? actionDecoration;

  /// 上传按钮区域的提示文字样式
  ///
  /// 为空时使用默认样式，传入后覆盖卡片模式和列表模式的文字样式。
  final TextStyle? actionTitleStyle;

  /// 使用方式，默认 [UseType.normal]
  ///
  /// - [UseType.normal]：普通模式，不限制文件数量和选择方式
  /// - [UseType.avatar]：头像模式，内部自动覆盖 limit=1、multiple=false、pickFile=imageOrCamera，
  ///   开发者无需传入这些参数
  final UseType useType;

  /// 初始文件列表（编辑模式回显）
  ///
  /// 传入已存在的文件列表，组件初始化时直接显示。
  /// 推荐使用 [FileInfo.existing] 构造函数，通过 [url] 设置网络地址。
  final List<FileInfo>? fileList;

  /// 显示文件名称和大小
  ///
  /// 默认显示
  final bool showFileName;

  const FileUpload({
    super.key,
    this.showFileName = true,
    this.pickFile = PickFile.all,
    this.multiple = true,
    this.limit = -1,
    this.allowedExtensions,
    this.title = '点击上传',
    this.onFileChanged,
    this.previewSize,
    this.columns,
    this.spacing = 10,
    this.alignment = WrapAlignment.start,
    this.uploadConfig,
    this.onProgress,
    this.icon,
    this.borderRadius = 7,
    this.fileRadius = 7,
    this.showType = ShowType.card,
    this.itemBuilder,
    this.uploadButtonBuilder,
    this.actionDecoration,
    this.actionTitleStyle,
    this.useType = UseType.normal,
    this.fileList,
  }) : assert(previewSize == null || columns == null, 'previewSize 和 columns 不能同时设置，二者互斥'),
       assert(limit == -1 || limit > 0, 'limit 必须为 -1 或正整数'),
       assert(
         useType != UseType.avatar || pickFile == PickFile.gallery || pickFile == PickFile.camera || pickFile == PickFile.imageOrCamera,
         '头像模式下 pickFile 仅支持 PickFile.gallery / PickFile.camera / PickFile.imageOrCamera',
       );

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

  /// 记录上一次已加载的 fileList 引用，用于检测外部数据变化
  List<FileInfo>? _loadedFileList;

  /// 标记初始文件同步通知是否已发送，避免重复触发父组件 setState 导致无限 rebuild
  bool _initialSyncNotified = false;

  @override
  void initState() {
    super.initState();
    _syncInitialFiles();
  }

  @override
  void didUpdateWidget(covariant FileUpload oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部 fileList 引用变化时（如异步数据返回），同步更新内部列表
    // 仅当 fileList 内容实际发生变化时才同步，避免因父组件 rebuild 导致的无效触发
    if (!identical(widget.fileList, _loadedFileList) && _isFileListChanged(widget.fileList, _loadedFileList)) {
      _syncInitialFiles();
    }
  }

  /// 比较两个 fileList 内容是否真正发生变化
  ///
  /// 优先使用 url 比较（编辑模式下 url 是稳定标识），
  /// 其次比较 id、name、size 等属性，避免因父组件 rebuild 创建新对象导致的无效触发。
  bool _isFileListChanged(List<FileInfo>? newList, List<FileInfo>? oldList) {
    if (newList == null && oldList == null) return false;
    if (newList == null || oldList == null) return true;
    if (newList.length != oldList.length) return true;
    // 基于 url + name + size 生成稳定签名进行比较
    String sig(FileInfo f) => '${f.url ?? ''}|${f.name}|${f.size}';
    final newSigs = newList.map(sig).toSet();
    final oldSigs = oldList.map(sig).toSet();
    return !newSigs.containsAll(oldSigs);
  }

  /// 将 external fileList 同步到内部 _files 列表
  void _syncInitialFiles() {
    final incoming = widget.fileList;
    if (incoming == null || incoming.isEmpty) {
      _loadedFileList = null;
      return;
    }
    // 移除上一轮加载的回显文件，保留用户手动添加的文件
    if (_loadedFileList != null) {
      _files.removeWhere((f) => _loadedFileList!.any((ini) => f.id == ini.id));
    }
    // 插入新的回显文件到列表头部
    _files.insertAll(0, incoming);
    _loadedFileList = incoming;
    if (!_initialSyncNotified) {
      _initialSyncNotified = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onFileChanged?.call(List.unmodifiable(_files), FileAction.defaultLoad);
      });
    }
  }

  /// 当前是否头像模式
  bool get _isAvatar => widget.useType == UseType.avatar;

  /// 实际生效的 limit（头像模式强制为 1）
  int get _effectiveLimit => _isAvatar ? 1 : widget.limit;

  /// 实际生效的 multiple（头像模式强制为 false）
  bool get _effectiveMultiple => _isAvatar ? false : widget.multiple;

  /// 实际生效的 pickFile（头像模式下，若用户未明确指定 gallery/camera，则默认 imageOrCamera）
  PickFile get _effectivePickFile {
    if (!_isAvatar) return widget.pickFile;
    // 头像模式：用户已明确指定 gallery 或 camera 时尊重选择，否则默认 imageOrCamera
    if (widget.pickFile == PickFile.gallery || widget.pickFile == PickFile.camera) {
      return widget.pickFile;
    }
    return PickFile.imageOrCamera;
  }

  /// 获取当前文件列表
  List<FileInfo> get files => List.unmodifiable(_files);

  /// 删除单个文件（基于 id 匹配）
  void _removeFile(FileInfo file) {
    // 上传中的文件不让删除
    if (file.status == UploadStatus.uploading) return;
    setState(() => _files.removeWhere((f) => f.id == file.id));
    widget.onFileChanged?.call([file], FileAction.remove);
  }

  // ==================== 文件状态管理 ====================

  /// 更新指定文件的上传状态
  ///
  /// 通过 [id] 匹配文件，更新其 [status] 并触发重建。
  void updateFileStatus(String id, UploadStatus status) {
    setState(() {
      final index = _files.indexWhere((f) => f.id == id);
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
      _controller!.startUpload(file.id);
    }
  }

  // ==================== 上传控制 - 公开方法 ====================

  /// 获取当前正在上传的文件数量
  int get activeUploadCount => _controller?.activeUploadCount ?? 0;

  UploadController _ensureController() {
    _controller ??= UploadController(
      config: widget.uploadConfig!,
      getFile: (id) => _files.firstWhere((f) => f.id == id),
      onFileStatusChanged: _onUploadFileStatusChanged,
      onFileProgress: _onUploadFileProgress,
    );
    return _controller!;
  }

  /// 开始上传指定文件（[UploadMode.manual] 和 [UploadMode.custom] 模式下使用）
  ///
  /// 通过文件 [id] 标识指定文件。如果文件正在上传或没有上传配置则忽略。
  /// 可通过 [GlobalKey<FileUploadState>] 在外部调用：
  /// ```dart
  /// key.currentState?.startUpload(fileId);
  /// ```
  Future<void> startUpload(String id) async {
    if (widget.uploadConfig == null) return;
    await _ensureController().startUpload(id);
  }

  /// 开始上传所有待上传（pending）的文件
  ///
  /// 按 [UploadConfig.maxConcurrent] 并发上限逐批上传。
  Future<void> startAllUpload() async {
    if (widget.uploadConfig == null) return;

    final pendingIds = _files.where((f) => f.status == UploadStatus.pending).map((f) => f.id);
    await _ensureController().startAllUpload(pendingIds);
  }

  /// 取消指定文件的上传
  ///
  /// 将文件状态恢复为 [UploadStatus.pending]，可再次上传。
  void cancelUpload(String id) {
    if (_controller != null) {
      _controller!.cancelUpload(id);
    } else {
      updateFileStatus(id, UploadStatus.pending);
    }
  }

  // ==================== 控制器回调 ====================

  void _onUploadFileStatusChanged(String id, UploadStatus status, {Map<String, dynamic>? data}) {
    setState(() {
      final index = _files.indexWhere((f) => f.id == id);
      if (index == -1) return;
      _files[index] = _files[index].copyWith(status: status, data: data);
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
      final file = _files.firstWhere((f) => f.id == id, orElse: () => _files.first);
      widget.onFileChanged?.call([file], action);
    }
  }

  void _onUploadFileProgress(String id, double progress) {
    setState(() {
      final index = _files.indexWhere((f) => f.id == id);
      if (index != -1) {
        _files[index] = _files[index].copyWith(progress: progress);
      }
    });
    final file = _files.firstWhere((f) => f.id == id, orElse: () => _files.first);
    widget.onProgress?.call(id, file.path ?? '', progress);
    widget.onFileChanged?.call([file], FileAction.progress);
  }

  // ==================== 已选文件处理 ====================

  void _onFilesPicked(List<FileInfo> files) {
    setState(() => _files.addAll(files));
    widget.onFileChanged?.call(files, FileAction.add);
    _autoUpload(files);
  }

  // ==================== 卡片点击操作 ====================

  /// 点击卡片 → 弹出操作 Sheet
  Future<void> _onCardTap(FileInfo file) async {
    final hasFailed = file.status == UploadStatus.failed;
    final action = await FileActionSheet.show(context: context, fileName: file.name, hasFailed: hasFailed, isImage: file.isImage);
    if (action == null || !mounted) return;
    switch (action) {
      case ActionFileSheet.preview:
        await FileActionSheet.showImagePreview(context: context, fileInfo: file);
      case ActionFileSheet.retry:
        startUpload(file.id);
      case ActionFileSheet.replace:
        await _replaceFile(file.id);
      case ActionFileSheet.delete:
        _removeFile(file);
    }
  }

  /// 原位替换指定文件
  ///
  /// 弹出文件选择器，选中新文件后替换到 [oldFileId] 所在位置，
  /// 保持列表顺序不变，并自动触发上传。
  Future<void> _replaceFile(String oldFileId) async {
    final index = _files.indexWhere((f) => f.id == oldFileId);
    if (index == -1) return;
    // 弹出文件选择器（复用 pickFile 配置）
    List<FileInfo> picked = [];
    switch (_effectivePickFile) {
      case PickFile.file:
        picked = await PickFileController.pickFiles(multiple: false, allowedExtensions: widget.allowedExtensions);
      case PickFile.gallery:
        picked = await PickFileController.pickImage(ImageSource.gallery, multiple: false);
      case PickFile.camera:
        picked = await PickFileController.pickImage(ImageSource.camera, multiple: false);
      case PickFile.all:
      case PickFile.imageOrCamera:
        // 替换场景固定走 imageOrCamera（替换通常是图片）
        final subAction = await PickerSheet.show(context: context, pickFile: _effectivePickFile);
        if (subAction == null) return;
        switch (subAction) {
          case PickFile.file:
            picked = await PickFileController.pickFiles(multiple: false, allowedExtensions: widget.allowedExtensions);
          case PickFile.gallery:
            picked = await PickFileController.pickImage(ImageSource.gallery, multiple: false);
          case PickFile.camera:
            picked = await PickFileController.pickImage(ImageSource.camera, multiple: false);
          case PickFile.all:
          case PickFile.imageOrCamera:
            return;
        }
    }
    if (picked.isEmpty) return;
    final newFile = picked.first;
    final oldFile = _files[index];
    setState(() {
      _files[index] = newFile;
    });
    // 通知外部：先移除旧文件，再添加新文件
    widget.onFileChanged?.call([oldFile], FileAction.remove);
    widget.onFileChanged?.call([newFile], FileAction.add);
    _autoUpload([newFile]);
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
                ..._files.map(
                  (f) => CardShowFile(
                    key: ValueKey(f.id),
                    showFileName: widget.showFileName,
                    fileInfo: f,
                    borderRadius: widget.borderRadius,
                    fileRadius: widget.fileRadius,
                    size: cardSize,
                    showSuccessBadge: !_isAvatar,
                    showDeleteBtn: !_isAvatar,
                    isAvatar: _isAvatar,
                    showType: widget.showType,
                    onRemove: () => _removeFile(f),
                    onTap: () => _onCardTap(f),
                    onRetry: widget.uploadConfig == null ? null : () => startUpload(f.id),
                  ),
                ),
                if (_effectiveLimit == -1 || _files.length < _effectiveLimit)
                  UploadActionArea(
                    icon: widget.icon,
                    borderRadius: widget.borderRadius,
                    decoration: widget.actionDecoration,
                    titleStyle: widget.actionTitleStyle,
                    title: widget.title,
                    size: cardSize,
                    showType: widget.showType,
                    uploadButtonBuilder: widget.uploadButtonBuilder,
                    pickFile: _effectivePickFile,
                    multiple: _effectiveMultiple,
                    allowedExtensions: widget.allowedExtensions,
                    limit: _effectiveLimit,
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
            spacing: 8,
            children: [
              ..._files.asMap().entries.map((entry) {
                final file = entry.value;
                return GestureDetector(
                  onTap: () => _onCardTap(file),
                  behavior: HitTestBehavior.opaque,
                  child: ListShowFile(
                    key: ValueKey(file.id),
                    fileInfo: file,
                    showFileName: widget.showFileName,
                    showType: widget.showType,
                    fileRadius: widget.fileRadius,
                    borderRadius: widget.borderRadius,
                    previewSize: widget.previewSize ?? 40,
                    onRemove: () => _removeFile(file),
                    onCancel: () => cancelUpload(file.id),
                    onRetry: widget.uploadConfig == null ? null : () => startUpload(file.id),
                  ),
                );
              }),
              if (_effectiveLimit == -1 || _files.length < _effectiveLimit)
                UploadActionArea(
                  icon: widget.icon,
                  borderRadius: widget.borderRadius,
                  decoration: widget.actionDecoration,
                  titleStyle: widget.actionTitleStyle,
                  title: widget.title,
                  fileRadius: widget.fileRadius,
                  previewSize: widget.previewSize ?? 40,
                  showType: widget.showType,
                  uploadButtonBuilder: widget.uploadButtonBuilder,
                  pickFile: _effectivePickFile,
                  multiple: _effectiveMultiple,
                  allowedExtensions: widget.allowedExtensions,
                  limit: _effectiveLimit,
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
                return widget.itemBuilder!(file, index, () => _removeFile(file));
              }),
              if (_files.isNotEmpty) const SizedBox(height: 8),
              if (_effectiveLimit == -1 || _files.length < _effectiveLimit)
                UploadActionArea(
                  icon: widget.icon,
                  borderRadius: widget.borderRadius,
                  decoration: widget.actionDecoration,
                  titleStyle: widget.actionTitleStyle,
                  title: widget.title,
                  showType: widget.showType,
                  uploadButtonBuilder: widget.uploadButtonBuilder,
                  pickFile: _effectivePickFile,
                  multiple: _effectiveMultiple,
                  allowedExtensions: widget.allowedExtensions,
                  limit: _effectiveLimit,
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
