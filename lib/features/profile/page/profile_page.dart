import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_app/core/config/app_config.dart';
import 'package:my_app/core/routing/router.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:my_app/features/auth/data/models/user.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = getIt<AppConfig>();
    final user = config.auth.currentUser.value;

    return Scaffold(
      appBar: AppBar(title: const Text('个人')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      _userInitial(user),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? '未登录',
                    style: theme.textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Settings Section
            Text('设置', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            const _SettingItem(title: '通知', icon: Icons.notifications_outlined),
            const _SettingItem(title: '隐私', icon: Icons.lock_outline),
            const _SettingItem(title: '外观', icon: Icons.palette_outlined),
            const _SettingItem(title: '帮助与支持', icon: Icons.help_outline),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _logout(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: BorderSide(color: theme.colorScheme.error),
                  foregroundColor: theme.colorScheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('退出登录'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _userInitial(User? user) {
    if (user == null) return '?';
    return user.name.isNotEmpty ? user.name[0] : '?';
  }

  Future<void> _logout(BuildContext context) async {
    final config = getIt<AppConfig>();
    await config.auth.clearAuth();
    if (context.mounted) {
      context.replaceRoute(const LoginRoute());
    }
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SettingItem({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }
}
