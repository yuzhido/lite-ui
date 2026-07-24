/// 上传状态
enum UploadStatus {
  /// 待上传
  pending,

  /// 上传中
  uploading,

  /// 上传成功
  success,

  /// 上传失败
  failed,
}

/// 文件列表展示类型
enum ShowType {
  /// 卡片模式（默认）
  card,

  /// 文本列表模式
  textInfo,

  /// 自定义模式
  custom,
}

/// 文件来源
enum FileSource {
  /// 文件选择器
  file,

  /// 图片选择器（相册）
  image,

  /// 拍照
  camera,

  /// 图片或拍照
  imageOrCamera,

  /// 全部（文件/相册/拍照）
  all,

  /// 网络地址（仅回显用，不触发选择器）
  network,
}

/// 文件变更动作
enum FileAction {
  /// 默认加载（回显）
  defaultLoad,

  /// 添加文件
  add,

  /// 移除文件
  remove,

  /// 上传中
  uploading,

  /// 上传进度
  progress,

  /// 上传成功
  success,

  /// 上传失败
  failed,
}

/// 选择器操作
enum PickFile {
  /// 文件选择
  file,

  /// 相册选择
  gallery,

  /// 拍照
  camera,

  /// 所有
  all,

  /// 相机或者相册
  imageOrCamera,
}

/// 文件操作类型
enum ActionFileSheet {
  /// 重新上传
  retry,

  /// 替换文件
  replace,

  /// 删除文件
  delete,
}
