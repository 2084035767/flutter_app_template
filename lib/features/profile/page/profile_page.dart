import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                      '用',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('用户名', style: theme.textTheme.headlineMedium),
                  Text(
                    '个人简介',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Settings Section
            Text('设置', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildSettingItem(context, '通知', Icons.notifications_outlined),
            _buildSettingItem(context, '隐私', Icons.lock_outline),
            _buildSettingItem(context, '外观', Icons.palette_outlined),
            _buildSettingItem(context, '帮助与支持', Icons.help_outline),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
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

  Widget _buildSettingItem(BuildContext context, String title, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }
}
