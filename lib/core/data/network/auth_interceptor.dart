import 'package:dio/dio.dart';
import 'package:my_app/core/data/storage/auth_storage.dart';

/// 认证拦截器
///
/// 1. 为每个请求附加 Bearer token
/// 2. 收到 401 响应时清除本地认证信息（触发登出）
///
/// token 刷新由具体业务层（AuthService）处理，本拦截器不做自动重试。
class AuthInterceptor extends Interceptor {
  final AuthStorage _auth;
  bool _isClearing = false;

  AuthInterceptor(this._auth);
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _auth.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 && !_isClearing) {
      _isClearing = true;
      _auth.clearAuth();
    }
    handler.next(err);
  }
}
