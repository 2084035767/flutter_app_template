import 'package:injectable/injectable.dart';
import 'package:my_app/core/error/failure.dart';
import 'package:my_app/core/error/result.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:my_app/features/auth/domain/auth_repository.dart';
import 'package:my_app/features/auth/domain/models/user.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 认证 ViewModel
///
/// 信号私有、Readonly 暴露，UI 通过 hooks 订阅。
@injectable
class AuthViewModel {
  final AuthRepository _repo = getIt<AuthRepository>();

  final _user = asyncSignal<User?>(AsyncState.data(null));
  final _email = signal('');
  final _password = signal('');

  ReadonlySignal<AsyncState<User?>> get user => _user;
  ReadonlySignal<String> get email => _email;
  ReadonlySignal<String> get password => _password;

  late final Computed<bool> canSubmit = computed(
    () => _email.value.isNotEmpty && _password.value.length >= 6,
  );
  bool get isLoading => _user.value.isLoading;
  bool get hasError => _user.value.hasError;
  User? get currentUser => _user.value.value;
  String? get errorMessage => _user.value.error?.toString();

  /// 登录
  Future<Result<void, Failure>> login() async {
    _user.value = AsyncState.loading();
    final result = await _repo.login(_email.value, _password.value);
    return result.when(
      success: (userData) {
        _user.value = AsyncState.data(userData);
        return const Result.success(null);
      },
      failure: (failure) {
        _user.value = AsyncState.error(failure.message);
        return Result.failure(failure);
      },
    );
  }

  /// 登出
  Future<Result<void, Failure>> logout() async {
    final result = await _repo.logout();
    return result.when(
      success: (_) {
        _user.value = AsyncState.data(null);
        return const Result.success(null);
      },
      failure: (failure) {
        _user.value = AsyncState.error(failure.message);
        return Result.failure(failure);
      },
    );
  }

  void resetForm() {
    _email.value = '';
    _password.value = '';
  }

  void updateEmail(String value) => _email.value = value;
  void updatePassword(String value) => _password.value = value;
}
