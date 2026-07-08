// lib/features/auth/data/auth_module.dart
import 'package:dio/dio.dart';

import 'auth_api.dart';

/// 认证功能模块 - 提供认证相关依赖
abstract class AuthModule {
  /// Auth API 服务
  AuthApi authApi(Dio dio) => AuthApi(dio);
}
