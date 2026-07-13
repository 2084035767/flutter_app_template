import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_app/core/config/app_config.dart';
import 'package:my_app/core/config/theme_extension.dart';
import 'package:my_app/core/routing/router.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:my_app/features/auth/data/models/user.dart';

/// 个人中心页
@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appTheme = AppThemeExtension.of(context);
    final config = getIt<AppConfig>();
    final user = config.auth.currentUser.value;

    return Scaffold(
      appBar: AppBar(title: const Text('个人'), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Profile header card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.primaryContainer.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(appTheme.radiusMd),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      _userInitial(user),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? '未登录',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '欢迎使用',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: appTheme.textSubtle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Settings section ──
            Text(
              '设置',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            _SettingsCard(
              children: [
                _SettingItem(
                  icon: Icons.notifications_outlined,
                  title: '通知',
                  onTap: () {},
                ),
                _Divider(colorScheme: colorScheme),
                _SettingItem(
                  icon: Icons.lock_outlined,
                  title: '隐私',
                  onTap: () {},
                ),
                _Divider(colorScheme: colorScheme),
                _SettingItem(
                  icon: Icons.palette_outlined,
                  title: '外观',
                  onTap: () {},
                ),
                _Divider(colorScheme: colorScheme),
                _SettingItem(
                  icon: Icons.help_outline,
                  title: '帮助与支持',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Logout button ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _logout(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: BorderSide(
                    color: colorScheme.error.withValues(alpha: 0.4),
                  ),
                  foregroundColor: colorScheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(appTheme.radiusSm),
                  ),
                ),
                child: const Text('退出登录'),
              ),
            ),
            const SizedBox(height: 40),
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

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appTheme = AppThemeExtension.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(appTheme.radiusMd),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(appTheme.radiusMd),
        child: Column(children: children),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        icon,
        color: colorScheme.onSurface.withValues(alpha: 0.6),
        size: 22,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurface.withValues(alpha: 0.2),
        size: 20,
      ),
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  final ColorScheme colorScheme;

  const _Divider({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 56),
      child: Divider(
        height: 1,
        thickness: 1,
        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
    );
  }
}
