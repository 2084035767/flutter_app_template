import 'package:flutter/foundation.dart';
import 'package:my_app/core/error/failure.dart';
import 'package:my_app/core/error/result.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// ViewModel 基类
///
/// 提供以下开箱即用的功能：
/// - 响应式状态管理（基于 signals）
/// - effect 自动清理
/// - 统一的 dispose 生命周期
/// - [runAsync] 异步操作辅助方法，自动管理 loading/data/error 状态
/// - [isDisposed] 守卫，方便在异步操作后检查是否已释放
///
/// 使用示例：
/// ```dart
/// @injectable
/// class CounterViewModel extends BaseViewModel {
///   final count = signal(0);
///
///   void increment() {
///     count.value++;
///   }
/// }
/// ```
abstract class BaseViewModel {
  final List<VoidCallback> _disposables = [];
  bool _disposed = false;

  /// 是否已释放
  bool get disposed => _disposed;

  /// 是否已释放（语义化别名）
  bool get isDisposed => _disposed;

  /// 添加 effect，在 dispose 时自动清理
  @protected
  void addEffect(void Function() effectFn, {void Function()? onDispose}) {
    assert(!_disposed, 'Cannot add effect to disposed ViewModel');
    _disposables.add(effect(effectFn, onDispose: onDispose));
  }

  /// 异步操作辅助方法
  ///
  /// 封装了标准的 loading → data/error 流程：
  /// 1. 设置 [into] 为 [AsyncState.loading]
  /// 2. 如果提供了 [failInto] 则清除其值
  /// 3. 执行异步操作
  /// 4. 检查 [isDisposed] 守卫
  /// 5. 根据结果更新 [into]（data 或 error）和 [failInto]
  ///
  /// 返回 [Failure?]，为 null 表示成功，否则为失败原因
  @protected
  Future<Failure?> runAsync<T>(
    Future<Result<T, Failure>> Function() call, {
    required Signal<AsyncState<T>> into,
    Signal<Failure?>? failInto,
  }) async {
    if (disposed) return const Failure.unknown('ViewModel已释放');
    into.value = AsyncState.loading();
    failInto?.value = null;

    final result = await call();
    if (disposed) return const Failure.unknown('ViewModel已释放');

    return result.when(
      success: (data) {
        into.value = AsyncState.data(data);
        return null;
      },
      failure: (failure) {
        into.value = AsyncState.error(failure.message);
        failInto?.value = failure;
        return failure;
      },
    );
  }

  /// 释放资源
  @mustCallSuper
  void dispose() {
    if (_disposed) return;
    for (final disposable in _disposables) {
      disposable();
    }
    _disposables.clear();
    _disposed = true;
  }
}
