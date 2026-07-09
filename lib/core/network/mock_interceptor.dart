import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Mock 拦截器
///
/// 当 [isMock] 为 true 时，拦截所有 HTTP 请求，
/// 从本地的 `/mock/` 目录读取 JSON 文件返回。
class MockInterceptor extends Interceptor {
  final bool isMock;

  MockInterceptor({required this.isMock});

  static const _routeMap = <String, String?>{
    'GET:/articles': 'mock/articles.json',
    'GET:/articles/': 'mock/articles.json',
    'POST:/login': 'mock/login.json',
    'POST:/logout': null,
  };

  String _extractPath(Uri uri) => uri.path.isEmpty ? '/' : uri.path;

  String? _matchRoute(String method, String path) {
    final key = '$method:$path';
    if (_routeMap.containsKey(key)) return _routeMap[key];
    for (final entry in _routeMap.entries) {
      if (entry.key.endsWith('/') && key.startsWith(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!isMock) return handler.next(options);

    final path = _extractPath(Uri.parse(options.path));
    final mockFile = _matchRoute(options.method, path);

    if (mockFile == null) return handler.next(options);

    if (mockFile.isEmpty) {
      return handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: <String, dynamic>{}),
      );
    }

    _loadMock(mockFile)
        .then((data) {
          if (options.uri.pathSegments.contains('articles') &&
              data is List &&
              data.isNotEmpty) {
            return handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: data[0]),
            );
          }
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: data),
          );
        })
        .catchError((e) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: 'Mock file not found: $mockFile',
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: options,
                statusCode: 404,
                data: {'error': 'Mock file not found'},
              ),
            ),
          );
        });
  }

  Future<dynamic> _loadMock(String path) async {
    try {
      final jsonStr = await rootBundle.loadString(path);
      return jsonDecode(jsonStr);
    } catch (_) {
      final file = File(path);
      if (await file.exists()) {
        final jsonStr = await file.readAsString();
        return jsonDecode(jsonStr);
      }
      rethrow;
    }
  }
}
