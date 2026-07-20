import 'dart:async';

import 'package:flutter/foundation.dart';

import '../model/enum.dart';
import '../model/file_info.dart';
import '../model/upload_config.dart';
import 'upload_service.dart';

/// 上传流程控制器
///
/// 负责上传的完整生命周期管理：
/// - 并发控制（[UploadConfig.maxConcurrent]）
/// - 重试逻辑（[UploadConfig.retryCount]）
/// - 取消支持
/// - 进度追踪
/// - 自定义/内置上传分发
///
/// 与 [FileUploadState] 通过回调通信，自身不持有文件列表，
/// 状态更新由外部通过回调处理。
/// 所有文件标识均使用 [FileInfo.id] 进行匹配。
class UploadController {
  final UploadConfig _config;
  final FileInfo Function(String id) _getFile;
  final void Function(String id, UploadStatus status, {Map<String, dynamic>? data}) _onFileStatusChanged;
  final void Function(String id, double progress) _onFileProgress;

  int _activeUploadCount = 0;
  final Map<String, bool> _cancelFlags = {};

  /// 当前正在上传的文件数量
  int get activeUploadCount => _activeUploadCount;

  UploadController({required this._config, required this._getFile, required this._onFileStatusChanged, required this._onFileProgress});

  /// 开始上传指定文件（通过文件 id 标识）
  ///
  /// 受 [UploadConfig.maxConcurrent] 限制，超出并发上限时等待。
  Future<void> startUpload(String id) async {
    final file = _getFile(id);
    if (file.status == UploadStatus.uploading) return;

    // 并发控制：等待直到活跃数低于上限
    while (_activeUploadCount >= _config.maxConcurrent) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }

    await _executeUpload(id);
  }

  /// 开始上传所有文件
  ///
  /// 按 [UploadConfig.maxConcurrent] 并发上限逐批上传。
  Future<void> startAllUpload(Iterable<String> ids) async {
    final futures = ids.map((id) => startUpload(id));
    await Future.wait(futures);
  }

  /// 取消指定文件的上传（通过文件 id 标识）
  ///
  /// 将文件状态恢复为 [UploadStatus.pending]。
  void cancelUpload(String id) {
    _cancelFlags[id] = true;
    _onFileStatusChanged(id, UploadStatus.pending);
  }

  /// 执行实际上传，含重试逻辑
  Future<void> _executeUpload(String id) async {
    _cancelFlags.remove(id);

    _onFileStatusChanged(id, UploadStatus.uploading);

    _activeUploadCount++;
    UploadResult? result;

    try {
      for (int attempt = 0; attempt <= _config.retryCount; attempt++) {
        // 检查是否被取消
        if (_cancelFlags[id] == true) return;

        if (attempt > 0) {
          // 重试前短暂延迟
          _onFileStatusChanged(id, UploadStatus.uploading);
          await Future<void>.delayed(Duration(seconds: attempt));
        }

        // 获取文件信息（用 path 做实际上传）
        final file = _getFile(id);
        final filePath = file.path;
        if (filePath == null || filePath.isEmpty) {
          debugPrint('[UploadController] 文件路径为空，无法上传: id=$id');
          _onFileStatusChanged(id, UploadStatus.failed);
          return;
        }

        // 执行上传
        result = _config.mode == UploadMode.custom && _config.customUpload != null ? await _customUpload(id, filePath) : await _builtinUpload(id, filePath);

        if (result.success) break;
      }

      if (_cancelFlags[id] == true) return;

      if (result != null && result.success) {
        // 业务校验
        final isValid = _config.validateResult == null || _config.validateResult!(result.data);

        if (isValid) {
          _onFileStatusChanged(id, UploadStatus.success, data: result.data);
        } else {
          debugPrint('[UploadController] 业务校验失败: id=$id, response=${result.data}');
          _onFileStatusChanged(id, UploadStatus.failed);
        }
      } else {
        debugPrint('[UploadController] 上传失败: id=$id, error=${result?.error}');
        _onFileStatusChanged(id, UploadStatus.failed);
      }
    } finally {
      _activeUploadCount--;
      _cancelFlags.remove(id);
    }
  }

  /// 自定义上传
  Future<UploadResult> _customUpload(String id, String filePath) async {
    final file = _getFile(id);
    try {
      return await _config.customUpload!(file, (progress) {
        if (_cancelFlags[id] == true) return;
        _onFileProgress(id, progress);
      });
    } catch (e) {
      return UploadResult.failure(error: e.toString());
    }
  }

  /// 内置 HTTP 上传
  Future<UploadResult> _builtinUpload(String id, String filePath) async {
    if (_config.url == null) {
      return UploadResult.failure(error: '未配置上传地址（url）');
    }

    final file = _getFile(id);
    try {
      return await UploadService.upload(
        filePath: filePath,
        url: _config.url!,
        method: _config.method,
        headers: _config.headers,
        fields: _config.fields,
        fileField: _config.fileField,
        fileName: file.name,
        onProgress: (progress) {
          if (_cancelFlags[id] == true) return;
          _onFileProgress(id, progress);
        },
      );
    } catch (e) {
      return UploadResult.failure(error: e.toString());
    }
  }
}
