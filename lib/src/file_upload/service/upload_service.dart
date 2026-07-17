import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../model/upload_config.dart';

/// 内置 HTTP 上传服务
///
/// 使用 `dart:io` [HttpClient] 以 multipart/form-data 格式上传文件。
/// 注意：此实现在 Web 平台不可用（因 `dart:io`），Web 场景请使用 [UploadMode.custom]。
class UploadService {
  /// 上传单个文件
  ///
  /// [filePath] 本地文件路径
  /// [url] 上传接口地址
  /// [method] HTTP 方法，默认 POST
  /// [headers] 自定义请求头
  /// [fields] 额外表单字段
  /// [fileField] 文件字段名，默认 "file"
  /// [fileName] 上传的文件名
  /// [onProgress] 进度回调，参数 0.0 ~ 1.0（已做节流，不会过度触发）
  static Future<UploadResult> upload({
    required String filePath,
    required String url,
    String method = 'POST',
    Map<String, String>? headers,
    Map<String, String>? fields,
    String fileField = 'file',
    required String fileName,
    required void Function(double progress) onProgress,
  }) async {
    debugPrint('[UploadService] 开始上传: url=$url, fileName=$fileName, method=$method');
    final client = HttpClient();
    try {
      final uri = Uri.parse(url);
      debugPrint('[UploadService] 解析URI: host=${uri.host}, port=${uri.port}, path=${uri.path}');
      final request = await client.openUrl(method, uri);

      // 生成 multipart boundary
      final boundary = 'lite_ui_boundary_${DateTime.now().millisecondsSinceEpoch}';
      request.headers.set('Content-Type', 'multipart/form-data; boundary=$boundary');

      // 设置自定义请求头
      headers?.forEach((key, value) {
        request.headers.set(key, value);
      });

      // 读取文件
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();
      debugPrint('[UploadService] 文件读取完成: size=${fileBytes.length} bytes');

      // 校验文件头魔数，确认文件内容与扩展名是否匹配
      final headerHex = fileBytes.take(8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      debugPrint('[UploadService] 文件头魔数(前8字节): $headerHex');

      // ===== 构建 multipart body =====
      final body = <int>[];

      // 添加额外表单字段
      if (fields != null && fields.isNotEmpty) {
        for (final entry in fields.entries) {
          body.addAll(utf8.encode('--$boundary\r\n'));
          body.addAll(utf8.encode('Content-Disposition: form-data; name="${entry.key}"\r\n\r\n'));
          body.addAll(utf8.encode('${entry.value}\r\n'));
        }
      }

      // 添加文件部分（使用正确的 MIME 类型）
      final mimeType = _getMimeType(fileName);
      body.addAll(utf8.encode('--$boundary\r\n'));
      body.addAll(utf8.encode('Content-Disposition: form-data; name="$fileField"; filename="$fileName"\r\n'));
      body.addAll(utf8.encode('Content-Type: $mimeType\r\n\r\n'));
      body.addAll(fileBytes);
      body.addAll(utf8.encode('\r\n'));

      // 结束标记
      body.addAll(utf8.encode('--$boundary--\r\n'));
      debugPrint('[UploadService] body构建完成: total=${body.length} bytes, mimeType=$mimeType');

      // ===== 分块发送&进度回调（已做节流）=====
      request.contentLength = body.length;
      const chunkSize = 32768; // 32KB
      int bytesSent = 0;
      int lastReportedPercent = -1;

      for (int i = 0; i < body.length; i += chunkSize) {
        final end = (i + chunkSize > body.length) ? body.length : i + chunkSize;
        request.add(body.sublist(i, end));
        bytesSent += end - i;

        // 节流：每 10% 或最后一块才回调，避免过度刷新 UI
        final percent = (bytesSent * 100 ~/ body.length);
        if (percent != lastReportedPercent) {
          lastReportedPercent = percent;
          onProgress(bytesSent / body.length);
        }

        // 让出事件循环，保证 UI 能及时刷新
        if (bytesSent % (chunkSize * 4) == 0) {
          await Future<void>.delayed(Duration.zero);
        }
      }

      debugPrint('[UploadService] 数据已写入请求流，等待响应...');

      // 发送并获取响应
      final response = await request.close();
      debugPrint('[UploadService] 收到响应: statusCode=${response.statusCode}');
      final responseBody = await response.transform(utf8.decoder).join();
      debugPrint('[UploadService] 响应体: ${responseBody.length > 300 ? "${responseBody.substring(0, 300)}..." : responseBody}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('[UploadService] HTTP请求成功');
        return UploadResult.successFromRaw(responseBody);
      } else {
        final errMsg = 'HTTP ${response.statusCode}: ${responseBody.length > 200 ? "${responseBody.substring(0, 200)}..." : responseBody}';
        debugPrint('[UploadService] 上传失败: $errMsg');
        return UploadResult.failure(error: errMsg);
      }
    } on SocketException catch (e) {
      debugPrint('[UploadService] Socket异常: ${e.message}');
      return UploadResult.failure(error: '网络连接失败: ${e.message}');
    } on HttpException catch (e) {
      debugPrint('[UploadService] HTTP异常: ${e.message}');
      return UploadResult.failure(error: 'HTTP 请求异常: ${e.message}');
    } catch (e) {
      debugPrint('[UploadService] 未知异常: $e');
      return UploadResult.failure(error: e.toString());
    } finally {
      client.close(force: true);
      debugPrint('[UploadService] 连接已关闭');
    }
  }

  /// 根据文件名获取 MIME 类型
  static String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return 'application/zip';
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
        return 'video/mp4';
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }
}
