import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_app/core/config/app_config.dart';
import 'package:my_app/core/routing/router.dart';
import 'package:my_app/di/service_locator.dart';

/// 首页仪表盘
@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = getIt<AppConfig>();

    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '你好, ${config.auth.currentUser.name ?? '用户'}',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '今天也是美好的一天',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 快捷入口
            Text('快捷功能', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickActionCard(
                  icon: Icons.article_outlined,
                  label: '文章',
                  color: theme.colorScheme.primary,
                  onTap: () => context.pushRoute(const ArticleListRoute()),
                ),
                _QuickActionCard(
                  icon: Icons.person_outlined,
                  label: '个人',
                  color: theme.colorScheme.secondary,
                  onTap: () => context.pushRoute(const ProfileRoute()),
                ),
                _QuickActionCard(
                  icon: Icons.settings_outlined,
                  label: '设置',
                  color: theme.colorScheme.tertiary,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 80,
            minWidth: 100,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
