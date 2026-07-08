import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:my_app/features/auth/application/auth_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<AuthViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _vm;

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
            Watch.builder(
              builder: (context) {
                final async = vm.user.value;
                if (async.isLoading) {
                  return const SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: vm.canSubmit
                        ? () async {
                            final result = await vm.login();
                            result.when(
                              success: (_) => context.go('/home'),
                              failure: (error) =>
                                  _showError(context, error.message),
                            );
                          }
                        : null,
                    child: const Text('登录'),
                  ),
                );
              },
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

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }
}
