import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'model/enum.dart';
import 'model/file_info.dart';

/// 文件选择控制器
///
/// 封装 [file_picker] 和 [image_picker] 的文件选择操作，
/// 返回统一的 [FileInfo] 列表，与 UI 层完全解耦。
class PickFileController {
  /// 使用 [file_picker] 选择文件
  ///
  /// [multiple] 是否支持多选，默认为 true
  /// [allowedExtensions] 允许的文件扩展名列表，如 ['pdf', 'doc']，仅在 [PickerAction.file] 时生效
  static Future<List<FileInfo>> pickFiles({bool multiple = true, List<String>? allowedExtensions}) async {
    if (multiple) {
      // FileType.any 在部分 Android 设备上多选不生效，改用 FileType.custom
      // 以触发系统 DocumentsUI 的多选模式
      final type = allowedExtensions != null ? FileType.custom : FileType.any;
      final result = await FilePicker.pickFiles(type: type, allowedExtensions: allowedExtensions);
      if (result == null || result.files.isEmpty) return [];
      return result.files.map((f) => FileInfo(name: f.name, path: f.path ?? '', size: f.size, source: FileSource.file)).toList();
    } else {
      final file = await FilePicker.pickFile(allowedExtensions: allowedExtensions);
      if (file == null) return [];
      return [FileInfo(name: file.name, path: file.path ?? '', size: file.size, source: FileSource.file)];
    }
  }

  /// 使用 [image_picker] 选择图片
  ///
  /// [source] 为图片来源：[ImageSource.gallery]（相册）或 [ImageSource.camera]（拍照）
  /// [multiple] 是否支持多选（仅相册生效），默认为 true
  static Future<List<FileInfo>> pickImage(ImageSource source, {bool multiple = true}) async {
    final picker = ImagePicker();

    // 相册多选：使用 pickMultiImage
    if (multiple && source == ImageSource.gallery) {
      final xFiles = await picker.pickMultiImage();
      if (xFiles.isEmpty) return [];

      final files = <FileInfo>[];
      for (final xFile in xFiles) {
        final bytes = await xFile.length();
        files.add(FileInfo(name: xFile.name, path: xFile.path, size: bytes, source: FileSource.image));
      }
      return files;
    }

    // 相册单选 或 拍照（仅支持单选）
    final xFile = await picker.pickImage(source: source);
    if (xFile == null) return [];

    final bytes = await xFile.length();
    return [FileInfo(name: xFile.name, path: xFile.path, size: bytes, source: source == ImageSource.gallery ? FileSource.image : FileSource.camera)];
  }
}
