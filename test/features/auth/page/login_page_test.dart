import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/core/base/result.dart';
import 'package:my_app/features/auth/data/auth_repository.dart';
import 'package:my_app/features/auth/data/models/user.dart';
import 'package:my_app/features/auth/logic/auth_view_model.dart';
import 'package:my_app/features/auth/page/login_page.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();

    when(
      () => mockRepo.getCurrentUser(),
    ).thenAnswer((_) async => const Result.success(null));
    when(
      () => mockRepo.logout(),
    ).thenAnswer((_) async => const Result.success(null));
    when(
      () => mockRepo.login(any(), any()),
    ).thenAnswer((_) async => Result.success(User(id: 1, name: '测试用户')));

    GetIt.I.registerFactory<AuthViewModel>(() => AuthViewModel(mockRepo));
  });

  tearDown(() {
    GetIt.I.reset(dispose: false);
  });

  group('LoginPage', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      expect(find.text('邮箱'), findsOneWidget);
      expect(find.text('密码'), findsOneWidget);
      expect(find.text('登录'), findsNWidgets(2));
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
  });
}
