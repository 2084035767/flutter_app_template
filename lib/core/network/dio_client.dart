import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/core/config/user_preferences.dart';
import 'package:my_app/core/error/failure.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// 网络模块
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

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}

/// 安全请求封装
Future<T> safeRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    throw handleDioError(e);
  }
}
