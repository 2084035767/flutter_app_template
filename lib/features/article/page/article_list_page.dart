import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/core/presentation/widgets/empty_widget.dart';
import 'package:my_app/core/presentation/widgets/error_text.dart';
import 'package:my_app/core/presentation/widgets/loading_indicator.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:my_app/features/article/application/article_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  late final ArticleViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<ArticleViewModel>();
    _vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SignalBuilder(
        builder: (context) {
          final async = _vm.articles.value;

          if (async.isLoading && _vm.articleList.isEmpty) {
            return const LoadingIndicator();
          }

          if (_vm.hasListError && _vm.articleList.isEmpty) {
            return ErrorText(
              error: _vm.errorMessage ?? '加载失败',
              onRetry: () => _vm.load(),
            );
          }

          final list = _vm.articleList;
          if (list.isEmpty) {
            return const EmptyWidget(
              icon: Icons.article_outlined,
              message: '暂无文章',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _vm.load(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final article = list[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        context.push('/articles/${article.id}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title,
                              style: theme.textTheme.titleLarge,
                            ),
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
        },
      ),
    );
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }
}
