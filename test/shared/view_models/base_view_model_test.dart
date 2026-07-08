import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/error/failure.dart';
import 'package:my_app/core/error/result.dart';
import 'package:my_app/shared/view_models/base_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Concrete ViewModel for testing BaseViewModel helpers.
final class TestViewModel extends BaseViewModel {
  final counter = signal(0);
  final data = asyncSignal<String>(AsyncState.data(''));
  final error = signal<Failure?>(null);

  Future<Result<void, Failure>> doSomething() async {
    return const Result.success(null);
  }

  Future<Result<void, Failure>> fetchData() async {
    final failure = await runAsync<String>(
      () async => const Result.success('hello'),
      into: data,
      failInto: error,
    );
    if (failure != null) return Result.failure(failure);
    return const Result.success(null);
  }

  Future<Result<void, Failure>> fetchFails() async {
    final failure = await runAsync<String>(
      () async => const Result.failure(Failure.server('error')),
      into: data,
      failInto: error,
    );
    if (failure != null) return Result.failure(failure);
    return const Result.success(null);
  }

  Future<void> delayedOp() async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (disposed) return;
    counter.value++;
  }
}

void main() {
  group('BaseViewModel', () {
    late TestViewModel vm;

    setUp(() {
      vm = TestViewModel();
    });

    tearDown(() {
      vm.dispose();
    });

    test('initial state', () {
      expect(vm.disposed, isFalse);
      expect(vm.isDisposed, isFalse);
      expect(vm.counter.value, equals(0));
    });

    test('dispose marks as disposed', () {
      vm.dispose();
      expect(vm.disposed, isTrue);
      expect(vm.isDisposed, isTrue);
    });

    test('dispose is idempotent', () {
      vm.dispose();
      vm.dispose(); // should not throw
      expect(vm.disposed, isTrue);
    });

    test('addEffect registers and disposes effects', () {
      var times = 0;
      vm.addEffect(() {
        times++;
        vm.counter.value; // track dependency
      });

      expect(times, equals(1)); // effect runs immediately

      vm.counter.value = 42; // triggers effect
      expect(times, equals(2));

      vm.dispose();
      vm.counter.value = 100; // effect should NOT run
      expect(times, equals(2));
    });

    group('runAsync', () {
      test('updates signal with data on success', () async {
        final result = await vm.fetchData();
        expect(result.isSuccess, isTrue);
        expect(vm.data.value.value, equals('hello'));
        expect(vm.error.value, isNull);
      });

      test('updates signal with error on failure', () async {
        final result = await vm.fetchFails();
        expect(result.isFailure, isTrue);
        expect(vm.data.value.hasError, isTrue);
        expect(vm.error.value, isNotNull);
        expect(vm.error.value!.message, contains('error'));
      });

      test('does not update signal after dispose', () async {
        vm.dispose();
        final result = await vm.fetchData();
        // After dispose, the signal should remain untouched
        expect(vm.data.value.value, equals(''));
      });
    });

    group('disposed guard', () {
      test('prevents signal mutation after dispose in async gaps', () async {
        vm.dispose();
        // This would throw if disposed guard wasn't present
        await vm.delayedOp();
        expect(vm.counter.value, equals(0));
      });
    });
  });
}
