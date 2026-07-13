import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/base/failure.dart';
import 'package:my_app/core/base/result.dart';
import 'package:my_app/core/base/run_async.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 模拟的销毁信号
Signal<bool> disposedSignal() => signal(false);

void main() {
  group('runAsync', () {
    test('成功后信号设为 data', () async {
      final signal = asyncSignal<String>(AsyncState.data(''));
      final result = await runAsync(
        signal,
        () async => Result.success('hello'),
      );

      expect(result.isSuccess, isTrue);
      expect(signal.value.value, 'hello');
      expect(signal.value.isLoading, isFalse);
      expect(signal.value.hasError, isFalse);
    });

    test('失败后信号设为 error', () async {
      final signal = asyncSignal<String>(AsyncState.data(''));
      Future<Result<String, Failure>> task() async =>
          Result.failure(const Failure.network('网络错误'));
      final result = await runAsync(signal, task);

      expect(result.isFailure, isTrue);
      expect(signal.value.hasError, isTrue);
      expect(signal.value.error?.toString(), contains('网络错误'));
      expect(signal.value.isLoading, isFalse);
    });

    test('执行中状态为 loading', () async {
      final signal = asyncSignal<String>(AsyncState.data(''));

      final future = runAsync(signal, () async {
        await Future<void>.delayed(const Duration(seconds: 1));
        return Result.success('done');
      });

      expect(signal.value.isLoading, isTrue);
      await future;
    });

    test('异常时信号设为 error 并返回 Failure', () async {
      final signal = asyncSignal<int>(AsyncState.data(0));
      final result = await runAsync(
        signal,
        () async => throw Exception('意外的错误'),
      );

      expect(result.isFailure, isTrue);
      expect(signal.value.hasError, isTrue);
      expect(signal.value.isLoading, isFalse);
    });

    test('disposed 后返回 Failure 而不更新信号值', () async {
      final signal = asyncSignal<String>(AsyncState.data('初始值'));
      final disposed = disposedSignal();
      disposed.value = true;

      Future<Result<String, Failure>> task() async => Result.success('新值');
      final result = await runAsync(signal, task, disposed: disposed);

      // 信号被设为 loading 后因 disposed 提前返回
      // 不会更新为 data('新值')
      expect(signal.value.value, isNot('新值'));
      expect(result.isFailure, isTrue);
    });

    test('loading 状态在成功前设置', () async {
      final signal = asyncSignal<int>(AsyncState.data(0));

      // 在 runAsync 执行前先检查 loading
      late Future<Result<void, Failure>> future;
      future = runAsync(signal, () async {
        expect(signal.value.isLoading, isTrue);
        return Result.success(42);
      });

      await future;
      expect(signal.value.value, 42);
    });
  });
}
