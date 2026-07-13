import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:my_app/core/base/run_async.dart';
import 'package:my_app/core/routing/router.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:my_app/features/auth/logic/auth_view_model.dart';
import 'package:signals_hooks/signals_hooks.dart';

@RoutePage()
class LoginPage extends HookWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = useMemoized(() => getIt<AuthViewModel>());
    final AsyncState<dynamic> userState = useSignalValue(vm.user);
    final bool canSubmit = useSignalValue(vm.canSubmit);

    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              onChanged: (v) => vm.updateEmail(v),
              decoration: const InputDecoration(labelText: '邮箱'),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => vm.updatePassword(v),
              obscureText: true,
              decoration: const InputDecoration(labelText: '密码'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: userState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton(
                      onPressed: canSubmit
                          ? () {
                              // 使用未命名闭包包裹 async 以防止按钮回调中的未捕获异常
                              Future.microtask(() async {
                                final result = await vm.login();
                                result.when(
                                  success: (_) =>
                                      context.replaceRoute(const HomeRoute()),
                                  failure: (error) => _showError(
                                    context,
                                    userErrorMessage(error),
                                  ),
                                );
                              });
                            }
                          : null,
                      child: const Text('登录'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
