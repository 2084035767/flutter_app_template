import 'package:injectable/injectable.dart';
import 'package:my_app/core/base/failure.dart';
import 'package:my_app/core/base/result.dart';
import 'package:my_app/core/base/run_async.dart';
import 'package:my_app/features/auth/data/auth_repository.dart';
import 'package:my_app/features/auth/data/models/user.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 认证 ViewModel
///
/// 信号直接公开，UI 通过 useSignalValue 订阅。
/// 约定：UI 层只读不写，所有状态变更通过 ViewModel 方法进行。
@injectable
class AuthViewModel {
  final AuthRepository _repo;

  AuthViewModel(this._repo);

  // ========== 信号（公开，UI 通过 hooks 订阅）==========
  final user = asyncSignal<User?>(AsyncState.data(null));
  final email = signal('');
  final password = signal('');

  // ========== 计算信号 ==========
  late final canSubmit = computed(
    () => email.value.isNotEmpty && password.value.length >= 6,
  );

  // ========== 方法 ==========

  /// 登录
  Future<Result<void, Failure>> login() {
    return runAsync(user, () async {
      final result = await _repo.login(email.value, password.value);
      return result.map<User?>((u) => u);
    });
  }

  /// 登出
  Future<Result<void, Failure>> logout() {
    return runAsync(user, () async {
      final result = await _repo.logout();
      return result.map<User?>((_) => null);
    });
  }

  void resetForm() {
    email.value = '';
    password.value = '';
  }

  void updateEmail(String value) => email.value = value;
  void updatePassword(String value) => password.value = value;
}
