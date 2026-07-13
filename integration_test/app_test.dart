import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:my_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App smoke test', () {
    testWidgets('launches and shows login page', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 登录页面应包含邮箱和密码输入框
      expect(find.text('邮箱'), findsOneWidget);
      expect(find.text('密码'), findsOneWidget);
      expect(find.text('登录'), findsWidgets);
    });

    testWidgets('login form interaction works', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 输入邮箱
      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.pump();

      // 输入密码
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pump();

      // 验证登录按钮已启用
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows error on empty fields', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 不填任何内容，登录按钮应禁用
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });
}
