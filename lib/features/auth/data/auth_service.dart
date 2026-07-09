import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/storage/auth_storage.dart';
import '../domain/auth_repository.dart';
import '../domain/models/user.dart';
import 'auth_api.dart';

/// 认证服务实现
///
/// 负责与远程 API 交互，并将底层错误转换为统一的 [Failure] 类型
@LazySingleton(as: AuthRepository)
class AuthService implements AuthRepository {
  final AuthApi _api;
  final AuthStorage _storage;

  AuthService(this._api, this._storage);

  @override
  Future<Result<User, Failure>> login(String email, String password) async {
    try {
      final user = await _api.login(email, password);
      // 保存用户信息到本地存储
      await _storage.saveUser(user);
      return Result.success(user);
    } on DioException catch (e) {
      final apiError = handleError(e);
      return Result.failure(Failure.fromApiError(apiError));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> logout() async {
    try {
      await _api.logout();
      // 清除本地存储
      await _storage.clearAuth();
      return const Result.success(null);
    } on DioException catch (e) {
      final apiError = handleError(e);
      return Result.failure(Failure.fromApiError(apiError));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<User?, Failure>> getCurrentUser() async {
    try {
      // 从本地存储获取当前用户
      final user = _storage.currentUser.value;
      return Result.success(user);
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
