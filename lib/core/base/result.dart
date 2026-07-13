/// 统一结果类型
///
/// 提供类型安全的结果处理，避免裸抛异常。
/// 所有可能失败的操作都应返回此类型。
///
/// 使用示例：
/// ```dart
/// Future<Result<User, Failure>> login(String email, String password);
///
/// final result = await repo.login(email, password);
/// result.when(
///   success: (user) => print('欢迎 $user'),
///   failure: (error) => print('登录失败: ${error.message}'),
/// );
/// ```
sealed class Result<T, E> {
  const Result();

  /// 创建成功结果
  const factory Result.success(T data) = Ok<T, E>;

  /// 创建失败结果
  const factory Result.failure(E error) = Err<T, E>;

  /// 模式匹配
  R when<R>({
    required R Function(T data) success,
    required R Function(E error) failure,
  });

  /// 是否成功
  bool get isSuccess => this is Ok<T, E>;

  /// 是否失败
  bool get isFailure => this is Err<T, E>;

  /// 获取成功值（可能抛出 StateError）
  T get getOrThrow => switch (this) {
    Ok<T, E>(:final data) => data,
    Err<T, E>(:final error) => throw StateError(
      'Called getOrThrow on Err: $error',
    ),
  };

  /// 转换成功值
  Result<R, E> map<R>(R Function(T data) transform) {
    return switch (this) {
      Ok<T, E>(:final data) => Result.success(transform(data)),
      Err<T, E>(:final error) => Result.failure(error),
    };
  }

  /// 转换错误
  Result<T, F> mapError<F>(F Function(E error) transform) {
    return switch (this) {
      Ok<T, E>(:final data) => Result.success(data),
      Err<T, E>(:final error) => Result.failure(transform(error)),
    };
  }

  /// 链式操作
  Result<R, E> flatMap<R>(Result<R, E> Function(T data) transform) {
    return switch (this) {
      Ok<T, E>(:final data) => transform(data),
      Err<T, E>(:final error) => Result.failure(error),
    };
  }
}

/// 成功结果
class Ok<T, E> extends Result<T, E> {
  final T data;

  const Ok(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(E error) failure,
  }) => success(data);

  @override
  String toString() => 'Ok($data)';
}

/// 失败结果
class Err<T, E> extends Result<T, E> {
  final E error;

  const Err(this.error);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(E error) failure,
  }) => failure(error);

  @override
  String toString() => 'Err($error)';
}
