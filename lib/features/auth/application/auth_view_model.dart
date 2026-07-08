import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/core/error/failure.dart';
import 'package:my_app/core/error/result.dart';
import 'package:my_app/features/auth/domain/models/user.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'package:my_app/shared/view_models/base_view_model.dart';
import '../domain/auth_repository.dart';

/// 认证 ViewModel
///
/// 负责处理用户认证相关的状态和业务逻辑
@injectable
class AuthViewModel extends BaseViewModel {
  final AuthRepository _repo;

  AuthViewModel(this._repo) {
    _initEffects();
  }

  /// 用户异步状态（内建 loading/error/data）
  final user = asyncSignal<User?>(AsyncState.data(null));

  /// 邮箱输入
  final email = signal('');

  /// 密码输入
  final password = signal('');

  /// 是否可以提交（计算属性）
  bool get canSubmit => email.value.isNotEmpty && password.value.length >= 6;

  /// 是否正在加载
  bool get isLoading => user.value.isLoading;

  /// 是否有错误
  bool get hasError => user.value.hasError;

  /// 当前用户数据
  User? get currentUser => user.value.value;

  /// 获取错误消息
  String? get errorMessage => user.value.error?.toString();

  void _initEffects() {
    addEffect(() {
      if (kReleaseMode) return;
      final state = user.value;
      if (state.hasValue) {
        debugPrint('用户已登录：${state.value?.name}');
      } else if (state.hasError) {
        debugPrint('用户状态错误：${state.error}');
      }
    });
    addEffect(() {
      if (kReleaseMode) return;
      debugPrint('邮箱输入：${email.value}');
    });
    addEffect(() {
      if (kReleaseMode) return;
      debugPrint('密码输入：${password.value}');
    });
  }

  /// 登录
  Future<Result<void, Failure>> login() async {
    user.value = AsyncState.loading();

    final result = await _repo.login(email.value, password.value);
    if (disposed) return const Result.failure(Failure.unknown('ViewModel已释放'));

    return result.when(
      success: (userData) {
        user.value = AsyncState.data(userData);
        return const Result.success(null);
      },
      failure: (failure) {
        user.value = AsyncState.error(failure.message);
        return Result.failure(failure);
      },
    );
  }

  /// 登出
  Future<Result<void, Failure>> logout() async {
    final result = await _repo.logout();
    if (disposed) return const Result.failure(Failure.unknown('ViewModel已释放'));

    return result.when(
      success: (_) {
        user.value = AsyncState.data(null);
        return const Result.success(null);
      },
      failure: (failure) {
        user.value = AsyncState.error(failure.message);
        return Result.failure(failure);
      },
    );
  }

  /// 重置表单和错误状态
  void resetForm() {
    email.value = '';
    password.value = '';
    user.value = AsyncState.data(currentUser);
  }

  /// 清除错误
  void clearError() {
    user.value = AsyncState.data(currentUser);
  }

  /// 更新邮箱
  void updateEmail(String value) {
    email.value = value;
  }

  /// 更新密码
  void updatePassword(String value) {
    password.value = value;
  }

  @override
  void dispose() {
    debugPrint('AuthViewModel 已释放');
    super.dispose();
  }
}
