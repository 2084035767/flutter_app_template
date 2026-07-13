import 'package:signals_flutter/signals_flutter.dart';

import 'failure.dart';
import 'result.dart';

/// 跨层错误信息
String userErrorMessage(Failure failure) => failure.message;

/// 异步操作辅助
///
/// 封装 ViewModel 中重复的三态模式：
/// - 设置信号为 loading
/// - 执行异步任务
/// - 成功 → 信号设为 data，返回 `Result.success(null)`
/// - 失败 → 信号设为 error，返回 `Result.failure(failure)`
///
/// ```dart
/// // 不需要返回值时
/// await runAsync(articles, () => repo.getArticles());
///
/// // 需要返回值（如登录后导航）
/// return runAsync(user, () => repo.login(...));
/// ```
///
/// [disposed] 可选：如果提供，在异步操作完成后检查是否已释放。
Future<Result<void, Failure>> runAsync<T>(
  Signal<AsyncState<T>> signal,
  Future<Result<T, Failure>> Function() task, {
  Signal<bool>? disposed,
}) async {
  signal.value = AsyncState<T>.loading();
  try {
    final result = await task();
    if (disposed?.value == true) {
      return const Result.failure(Failure.unknown('ViewModel 已释放'));
    }
    return result.when(
      success: (data) {
        signal.value = AsyncState.data(data);
        return const Result.success(null);
      },
      failure: (failure) {
        signal.value = AsyncState.error(userErrorMessage(failure));
        return Result.failure(failure);
      },
    );
  } catch (e) {
    if (disposed?.value == true) {
      return const Result.failure(Failure.unknown('ViewModel 已释放'));
    }
    signal.value = AsyncState.error(e.toString());
    return Result.failure(Failure.unknown(e.toString()));
  }
}
