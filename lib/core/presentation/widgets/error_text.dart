import 'package:flutter/material.dart';

/// 错误状态组件
///
/// 统一展示加载失败时的错误提示和重试按钮。
class ErrorText extends StatelessWidget {
  const ErrorText({super.key, required this.error, this.onRetry, this.icon});

  /// 错误信息
  final Object error;

  /// 重试回调（为 null 时不显示重试按钮）
  final VoidCallback? onRetry;

  /// 自定义图标（默认使用错误图标）
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '$error',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
