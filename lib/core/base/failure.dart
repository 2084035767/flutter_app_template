import 'package:dio/dio.dart';

/// -------------------- Failure --------------------
sealed class Failure implements Exception {
  final String message;
  const Failure({required this.message});

  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.auth(String message) = AuthFailure;
  const factory Failure.server(String message) = ServerFailure;
  const factory Failure.unknown(String message) = UnknownFailure;

}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message: message);
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message: message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message: message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message: message);
}

/// -------------------- Dio 错误处理 --------------------

/// 将 DioException 转为统一的 Failure
Failure handleDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const Failure.network('请求超时');
    case DioExceptionType.connectionError:
      return const Failure.network('网络连接失败');
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode ?? -1;
      if (code == 401) return const Failure.auth('未授权，请登录');
      if (code == 403) return const Failure.auth('禁止访问');
      if (code == 404) return const Failure.server('资源不存在');
      if (code == 500) return const Failure.server('服务器错误');
      return Failure.unknown(e.response?.statusMessage ?? '未知错误');
    case DioExceptionType.cancel:
      return const Failure.unknown('请求已取消');
    default:
      return Failure.unknown(e.message ?? '未知错误');
  }
}

/// handleDioError 的别名（Service 层使用）
Failure handleError(DioException e) => handleDioError(e);
