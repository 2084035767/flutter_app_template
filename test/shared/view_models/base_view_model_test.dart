import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/shared/view_models/base_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Concrete ViewModel for testing BaseViewModel helpers.
final class TestViewModel extends BaseViewModel {
  final counter = signal(0);

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

    test(
      'disposed guard prevents signal mutation after dispose in async gaps',
      () async {
        vm.dispose();
        await vm.delayedOp();
        expect(vm.counter.value, equals(0));
      },
    );
  });
}
