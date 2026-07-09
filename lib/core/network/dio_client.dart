import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:msw_dio_interceptor/msw_dio_interceptor.dart';
import 'package:my_app/core/config/network_config.dart';
import 'package:my_app/core/config/user_preferences.dart';
import 'package:my_app/core/error/failure.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@module
abstract class NetworkModule {
  Dio dio(UserPreferences preferences) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.example.com',
        responseType: ResponseType.json,
        connectTimeout: Duration(seconds: preferences.apiTimeout.value),
        receiveTimeout: Duration(seconds: preferences.apiTimeout.value),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.next(options),
        onResponse: (response, handler) {
          if (response.data is String) {
            try {
              response.data = json.decode(response.data as String);
            } catch (_) {}
          }
          handler.next(response);
        },
        onError: (DioException error, handler) {
          final failure = handleDioError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: failure,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );

    dio.interceptors.add(RetryInterceptor(dio: dio, retries: 3));

    // Mock 拦截器（仅在 isMock=true 时启用）
    if (NetworkConfig.isMock) {
      final mockEngine = MockHttpEngine();
      dio.interceptors.add(MockInterceptor(engine: mockEngine));
      _registerMockRules();
    }

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}

void _registerMockRules() {
  MockRegistry.register(
    MockRule(
      path: '/articles',
      method: 'GET',
      handler: (_) => MockResponse.text(
        '[{"id":1,"title":"Flutter 3.44 新特性解析","body":"Flutter 3.44 新特性详情..."},{"id":2,"title":"Dart 3.12 模式匹配实战","body":"Dart 3.12 模式匹配详解..."}]',
        headers: {'content-type': 'application/json'},
      ),
    ),
  );
  MockRegistry.register(
    MockRule(
      path: '/articles/',
      method: 'GET',
      handler: (_) => MockResponse.text(
        '{"id":1,"title":"Flutter 3.44 新特性解析","body":"Flutter 3.44 新特性详情..."}',
        headers: {'content-type': 'application/json'},
      ),
    ),
  );
  MockRegistry.register(
    MockRule(
      path: '/login',
      method: 'POST',
      handler: (_) => MockResponse.json({'id': 1, 'name': '开发者'}),
    ),
  );
}

/// 安全请求封装
Future<T> safeRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    throw handleDioError(e);
  }
}
