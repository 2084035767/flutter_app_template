import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:my_app/core/error/failure.dart';
import 'package:my_app/core/error/result.dart';
import 'package:my_app/features/auth/application/auth_view_model.dart';
import 'package:my_app/features/auth/domain/auth_repository.dart';
import 'package:my_app/features/auth/domain/models/user.dart';
import 'package:my_app/features/auth/page/login_page.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Mock AuthRepository for testing.
class MockAuthRepository implements AuthRepository {
  @override
  Future<Result<User, Failure>> login(String email, String password) async {
    return Result.success(User(id: 1, name: '测试用户'));
  }

  @override
  Future<Result<User?, Failure>> getCurrentUser() async {
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> logout() async {
    return const Result.success(null);
  }
}

void main() {
  late AuthViewModel vm;

  setUp(() {
    final repo = MockAuthRepository();
    vm = AuthViewModel(repo);
    GetIt.I.registerFactory<AuthViewModel>(() => vm);
  });

  tearDown(() {
    vm.dispose();
    GetIt.I.reset(dispose: false);
  });

  group('LoginPage', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      expect(find.text('邮箱'), findsOneWidget);
      expect(find.text('密码'), findsOneWidget);
      expect(find.text('登录'), findsNWidgets(2)); // AppBar title + button
    });

    testWidgets('button is disabled when fields are empty', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('button is enabled when email and password are valid', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows loading indicator when logging in', (tester) async {
      vm.user.value = AsyncState.loading();

      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
