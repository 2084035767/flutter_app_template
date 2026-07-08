import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

final class TestViewModel {
  final counter = signal(0);

  Future<void> delayedOp() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    counter.value++;
  }
}

void main() {
  group('ViewModel signal pattern', () {
    test('signal initial value', () {
      final vm = TestViewModel();
      expect(vm.counter.value, equals(0));
    });

    test('signal updates correctly', () {
      final vm = TestViewModel();
      vm.counter.value = 42;
      expect(vm.counter.value, equals(42));
    });
  });
}
