import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'auth_api.dart';

@module
abstract class AuthModule {
  @LazySingleton()
  AuthApi authApi(Dio dio) => AuthApi(dio);
}
