import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:my_app/core/app_config.dart';
import 'package:my_app/core/database/hive_service.dart';
import 'package:my_app/core/config/user_preferences.dart';
import 'package:my_app/core/error/failure.dart';
import 'package:my_app/core/local/file_storage.dart';
import 'package:my_app/core/storage/auth_storage.dart';
import 'package:my_app/features/article/data/article_api.dart';
import 'package:my_app/features/article/data/article_service.dart';
import 'package:my_app/features/article/domain/article_repository.dart';
import 'package:my_app/features/auth/data/auth_api.dart';
import 'package:my_app/features/auth/data/auth_service.dart';
import 'package:my_app/features/auth/domain/auth_repository.dart';
import 'package:my_app/features/article/application/article_view_model.dart';
import 'package:my_app/features/auth/application/auth_view_model.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Dio _createDio(UserPreferences preferences) {
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

Future<void> configureDependencies() async {
  // 1. SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // 2. UserPreferences
  final userPrefs = UserPreferences();
  await userPrefs.init();
  getIt.registerSingleton<UserPreferences>(userPrefs);

  // 3. AuthStorage
  final authStorage = AuthStorage();
  await authStorage.init();
  getIt.registerSingleton<AuthStorage>(authStorage);

  // 4. FileStorage
  final fileStorage = FileStorage();
  await fileStorage.init();
  getIt.registerSingleton<FileStorage>(fileStorage);

  // 5. Dio
  final dio = _createDio(userPrefs);
  getIt.registerSingleton<Dio>(dio);

  // 6. APIs
  getIt.registerSingleton<ArticleApi>(ArticleApi(dio));
  getIt.registerSingleton<AuthApi>(AuthApi(dio));

  // 7. Services
  getIt.registerSingleton<ArticleRepository>(
    ArticleService(getIt<ArticleApi>()),
  );
  getIt.registerSingleton<AuthRepository>(
    AuthService(getIt<AuthApi>(), authStorage),
  );

  // 8. AppConfig
  getIt.registerSingleton<AppConfig>(AppConfig(userPrefs, authStorage));

  // 9. Hive database
  final hive = HiveService();
  await hive.init();
  getIt.registerSingleton<HiveService>(hive);

  // 10. ViewModels (factory — new instance per page)
  getIt.registerFactory<ArticleViewModel>(() => ArticleViewModel());
  getIt.registerFactory<AuthViewModel>(() => AuthViewModel());
}
