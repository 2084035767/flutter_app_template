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
    // 初始化 effect 监听
    _initEffects();
  }

  /// 用户异步状态
  final user = asyncSignal<User?>(AsyncState.data(null));

  /// 当前失败信息
  final currentFailure = signal<Failure?>(null);

  /// 邮箱输入
  final email = signal('');

  /// 密码输入
  final password = signal('');

  /// 是否可以提交（计算属性）
  bool get canSubmit => email.value.isNotEmpty && password.value.length >= 6;

  /// 是否正在加载
  bool get isLoading => user.value.isLoading;

  /// 是否有错误
  bool get hasError => user.value.hasError || currentFailure.value != null;

  /// 当前用户数据
  User? get currentUser => user.value.value;

  /// 获取错误消息
  String? get errorMessage {
    if (currentFailure.value != null) {
      return currentFailure.value!.message;
    }
    if (user.value.hasError) {
      return user.value.error?.toString();
    }
    return null;
  }

  /// 初始化 effect 监听
  void _initEffects() {
    // 监听用户状态变化
    addEffect(() {
      if (kReleaseMode) return;
      final state = user.value;
      if (state.hasValue) {
        debugPrint('用户已登录：${state.value?.name}');
      } else if (state.hasError) {
        debugPrint('用户状态错误：${state.error}');
      }
    });

    // 监听表单输入变化
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
    currentFailure.value = null;

    final result = await _repo.login(email.value, password.value);
    if (disposed) return const Result.failure(Failure.unknown('ViewModel已释放'));

    return result.when(
      success: (userData) {
        user.value = AsyncState.data(userData);
        return const Result.success(null);
      },
      failure: (failure) {
        user.value = AsyncState.error(failure.message);
        currentFailure.value = failure;
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
        currentFailure.value = null;
        return const Result.success(null);
      },
      failure: (failure) {
        currentFailure.value = failure;
        return Result.failure(failure);
      },
    );
  }

  /// 重置表单和错误状态
  void resetForm() {
    email.value = '';
    password.value = '';
    currentFailure.value = null;
  }

  /// 清除错误
  void clearError() {
    currentFailure.value = null;
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
