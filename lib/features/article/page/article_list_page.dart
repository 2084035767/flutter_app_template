import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/core/presentation/widgets/empty_widget.dart';
import 'package:my_app/core/presentation/widgets/error_text.dart';
import 'package:my_app/core/presentation/widgets/loading_indicator.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:my_app/features/article/application/article_view_model.dart';
import 'package:my_app/features/article/domain/models/article.dart';
import 'package:signals_hooks/signals_hooks.dart';

class ArticleListPage extends HookWidget {
  const ArticleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = useMemoized(() => getIt<ArticleViewModel>());
    final AsyncState<List<Article>> async = useSignalValue(vm.articles);
    final List<Article> list = async.value ?? <Article>[];

    final Widget body;
    if (async.isLoading && list.isEmpty) {
      body = const LoadingIndicator();
    } else if (async.hasError && list.isEmpty) {
      body = ErrorText(
        error: vm.errorMessage ?? '加载失败',
        onRetry: () => vm.reloadArticles(),
      );
    } else if (list.isEmpty) {
      body = const EmptyWidget(icon: Icons.article_outlined, message: '暂无文章');
    } else {
      body = RefreshIndicator(
        onRefresh: () => Future<void>.sync(() => vm.reloadArticles()),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            final Article article = list[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('/articles/${article.id}'),
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
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
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
          },
        ),
      );
    }

    return Scaffold(body: body);
  }
}
