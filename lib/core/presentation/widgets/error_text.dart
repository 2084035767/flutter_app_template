import 'package:flutter/material.dart';
import 'package:my_app/core/config/theme_extension.dart';

/// 统一错误状态组件
class ErrorText extends StatelessWidget {
  const ErrorText({super.key, required this.error, this.onRetry, this.icon});

  final Object error;
  final VoidCallback? onRetry;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appTheme = AppThemeExtension.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Error icon container ──
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(appTheme.radiusLg),
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 32,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '出错了',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: appTheme.textSubtle,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 28),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('重试'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(appTheme.radiusSm),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
