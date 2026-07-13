import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:my_app/core/presentation/widgets/empty_widget.dart';
import 'package:my_app/core/presentation/widgets/error_text.dart';
import 'package:my_app/core/presentation/widgets/loading_indicator.dart';
import 'package:my_app/core/routing/router.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:my_app/features/article/data/models/article.dart';
import 'package:my_app/features/article/logic/article_view_model.dart';
import 'package:signals_hooks/signals_hooks.dart';

class _ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _ArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '点击阅读更多...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '阅读',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@RoutePage()
class ArticleListPage extends HookWidget {
  const ArticleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = useMemoized(() => getIt<ArticleViewModel>());

    useEffect(() {
      vm.loadArticles();
      return null;
    }, []);

    final AsyncState<List<Article>> async = useSignalValue(vm.articles);
    return Scaffold(
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
            onRefresh: () => Future<void>.sync(() => vm.loadArticles()),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                final Article article = list[index];
                return _ArticleCard(
                  article: article,
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
