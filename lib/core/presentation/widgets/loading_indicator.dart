import 'package:flutter/material.dart';
import 'package:my_app/gen/assets.gen.dart';

/// 统一加载指示器
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.size = 40.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Assets.json.lottieCta.lottie(width: size, height: size),
      ),
    );
  }
}

/// 全屏骨架加载图
class ScreenLoadingIndicator extends StatelessWidget {
  const ScreenLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Assets.json.lottieCta.lottie(width: 48, height: 48),
            ),
            const SizedBox(height: 20),
            Text(
              '加载中...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
