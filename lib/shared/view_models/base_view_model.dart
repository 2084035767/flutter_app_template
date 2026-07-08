import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// ViewModel 基类
///
/// 提供以下开箱即用的功能：
/// - 响应式状态管理（基于 signals）
/// - effect 自动清理
/// - 统一的 dispose 生命周期
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
  void addEffect(void Function() effectFn, {EffectOptions? options}) {
    assert(!_disposed, 'Cannot add effect to disposed ViewModel');
    _disposables.add(
      effect(effectFn, options: options ?? const EffectOptions()),
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
