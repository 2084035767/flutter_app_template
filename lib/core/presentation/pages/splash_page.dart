import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 启动页
///
/// 检查认证状态后自动跳转到对应页面。
/// 如果已登录跳转到首页，否则跳转到登录页。
class SplashPage extends StatefulWidget {
  final bool isAuthenticated;

  const SplashPage({super.key, required this.isAuthenticated});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // 短暂延迟展示启动画面
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (widget.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flutter_dash,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text('My App', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
