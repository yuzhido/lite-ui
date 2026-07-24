import 'dart:io';

import 'package:flutter/material.dart';

/// 判断是否为图片文件
bool isImageFile(String? fileName) {
  if (fileName == null) return false;
  const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'];
  final lower = fileName.toLowerCase();
  return imageExtensions.any((ext) => lower.endsWith(ext));
}

/// 格式化文件大小
String fileSizeFormat(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

/// 通过 HTTP HEAD 请求获取远程文件大小（字节）
///
/// HEAD 失败时回退到 GET 请求读取 Content-Length。
/// 返回 null 表示获取失败（网络异常、服务器不支持等）。
Future<int?> fetchRemoteFileSize(String url) async {
  HttpClient? client;
  try {
    client = HttpClient();
    // 先尝试 HEAD
    var request = await client.openUrl('HEAD', Uri.parse(url));
    var response = await request.close();
    var contentLength = response.contentLength;
    if (contentLength > 0) {
      client.close();
      return contentLength;
    }
    debugPrint('[fetchRemoteFileSize] HEAD 未返回有效大小($contentLength)，回退 GET');
    // HEAD 失败，回退到 GET
    request = await client.openUrl('GET', Uri.parse(url));
    response = await request.close();
    contentLength = response.contentLength;
    client.close();
    if (contentLength > 0) return contentLength;
    debugPrint('[fetchRemoteFileSize] GET 也未返回有效大小($contentLength)');
  } catch (e) {
    debugPrint('[fetchRemoteFileSize] 请求失败: $e');
    client?.close();
  }
  return null;
}
