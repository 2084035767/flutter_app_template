import 'package:flutter/material.dart';

/// 首页仪表盘
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 欢迎卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('欢迎回来', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    '今天也是美好的一天',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
              ),
              _QuickActionCard(
                icon: Icons.person_outlined,
                label: '个人',
                color: theme.colorScheme.secondary,
              ),
              _QuickActionCard(
                icon: Icons.settings_outlined,
                label: '设置',
                color: theme.colorScheme.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          width: 100,
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
