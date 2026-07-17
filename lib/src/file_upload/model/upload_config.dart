import 'dart:convert';

import 'file_info.dart';

/// 上传模式
enum UploadMode {
  /// 选择文件后自动开始上传
  auto,

  /// 手动触发上传（调用 [FileUploadState.startUpload] / [FileUploadState.startAllUpload]）
  manual,

  /// 自定义上传函数，完全由外部控制上传逻辑
  custom,
}

/// 上传配置
///
/// 提供给 [FileUpload] 的 [uploadConfig] 参数以启用上传能力。
/// 支持三种模式：
/// - [UploadMode.auto]：选择文件后自动上传，需提供 [url]
/// - [UploadMode.manual]：手动触发上传，需提供 [url]
/// - [UploadMode.custom]：自定义上传，需提供 [customUpload]
class UploadConfig {
  /// 上传模式
  final UploadMode mode;

  /// 上传接口地址（[UploadMode.auto] / [UploadMode.manual] 时必填）
  final String? url;

  /// HTTP 请求方法，默认 POST
  final String method;

  /// 自定义请求头
  final Map<String, String>? headers;

  /// 额外表单字段（和文件一起以 multipart/form-data 发送）
  final Map<String, String>? fields;

  /// 文件对应的表单字段名，默认 "file"
  final String fileField;

  /// 最大并发上传数，默认 3
  final int maxConcurrent;

  /// 失败自动重试次数，默认 0
  final int retryCount;

  /// 自定义上传函数（[UploadMode.custom] 时必填）
  ///
  /// 参数：
  /// - [file]：当前上传的文件信息
  /// - [onProgress]：上报进度的回调，参数 0.0 ~ 1.0
  ///
  /// 返回 [UploadResult] 表示上传结果。
  final Future<UploadResult> Function(FileInfo file, void Function(double progress) onProgress)? customUpload;

  /// 验证上传结果是否为业务成功
  ///
  /// 内置上传收到 HTTP 2xx 后，会将响应体解析为 JSON Map 传入此函数。
  /// 自定义上传可直接传入已解析的 Map。
  /// 返回 `true` 表示业务成功，`false` 表示业务失败。
  /// **不提供时默认 HTTP 2xx 即视为成功**，仅校验传输层状态码。
  ///
  /// 典型用法：
  /// ```dart
  /// validateResult: (body) {
  ///   return body?['success'] == true;
  /// },
  /// ```
  final bool Function(Map<String, dynamic>? body)? validateResult;

  const UploadConfig({
    required this.mode,
    this.url,
    this.method = 'POST',
    this.headers,
    this.fields,
    this.fileField = 'file',
    this.maxConcurrent = 3,
    this.retryCount = 0,
    this.customUpload,
    this.validateResult,
  });
}

/// 上传结果
class UploadResult {
  /// 是否上传成功
  final bool success;

  /// 服务端返回的响应体（已解析为 JSON Map，解析失败时为 null）
  final Map<String, dynamic>? responseBody;

  /// 错误信息
  final String? error;

  const UploadResult._({required this.success, this.responseBody, this.error});

  /// 创建成功结果
  ///
  /// [responseBody] 为已解析的 JSON Map，自定义上传可直接传入业务数据。
  factory UploadResult.success({Map<String, dynamic>? responseBody}) {
    return UploadResult._(success: true, responseBody: responseBody);
  }

  /// 创建失败结果
  factory UploadResult.failure({String? error}) {
    return UploadResult._(success: false, error: error);
  }

  /// 从原始响应字符串解析并创建成功结果（内置上传使用）
  ///
  /// 尝试将 [rawBody] 解析为 JSON，解析失败时 [responseBody] 为 null。
  factory UploadResult.successFromRaw(String rawBody) {
    Map<String, dynamic>? parsed;
    try {
      parsed = jsonDecode(rawBody) as Map<String, dynamic>;
    } catch (_) {
      // 非 JSON 格式，responseBody 保持 null
    }
    return UploadResult._(success: true, responseBody: parsed);
  }
}
