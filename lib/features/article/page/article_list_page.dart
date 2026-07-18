import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:my_app/core/config/theme_extension.dart';
import 'package:my_app/core/presentation/widgets/empty_widget.dart';
import 'package:my_app/core/presentation/widgets/error_text.dart';
import 'package:my_app/core/presentation/widgets/loading_indicator.dart';
import 'package:my_app/core/routing/router.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:my_app/features/article/data/models/article.dart';
import 'package:my_app/features/article/logic/article_view_model.dart';
import 'package:signals_hooks/signals_hooks.dart';

/// 文章列表页——卡片式阅读列表
@RoutePage()
class ArticleListPage extends HookWidget {
  const ArticleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = useMemoized(() => getIt<ArticleViewModel>());

    useEffect(() {
      vm.loadArticles();
      return;
    }, []);

    final AsyncState<List<Article>> async = useSignalValue(vm.articles);

    return Scaffold(
      appBar: AppBar(title: const Text('文章'), centerTitle: false),
      body: async.map(
        loading: () => const LoadingIndicator(),
        error: (Object? error, StackTrace? _) =>
            ErrorText(error: '$error', onRetry: () => vm.loadArticles()),
        data: (List<Article> list) {
          if (list.isEmpty) {
            return const EmptyWidget(
              icon: Icons.article_outlined,
              message: '暂无文章',
            );
          }
          return RefreshIndicator(
            onRefresh: () => vm.loadArticles(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                final Article article = list[index];
                return _ArticleCard(
                  article: article,
                  index: index,
                  onTap: () => context.pushRoute(
                    ArticleDetailRoute(articleId: article.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final int index;
  final VoidCallback onTap;

  const _ArticleCard({
    required this.article,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appTheme = AppThemeExtension.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(appTheme.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(appTheme.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Number badge ──
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(appTheme.radiusSm),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // ── Content ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击阅读更多...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: appTheme.textSubtle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '阅读',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
