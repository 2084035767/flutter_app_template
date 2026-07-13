import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:my_app/core/config/theme_extension.dart';
import 'package:my_app/core/presentation/widgets/error_text.dart';
import 'package:my_app/core/presentation/widgets/loading_indicator.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:my_app/features/article/data/models/article.dart';
import 'package:my_app/features/article/logic/article_view_model.dart';
import 'package:signals_hooks/signals_hooks.dart';

/// 文章详情页——沉浸式阅读体验
@RoutePage()
class ArticleDetailPage extends HookWidget {
  final int articleId;

  const ArticleDetailPage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appTheme = AppThemeExtension.of(context);

    final vm = useMemoized(() => getIt<ArticleViewModel>());

    useEffect(() {
      vm.loadDetail(articleId);
      return () => vm.clearSelected();
    }, [articleId]);

    final AsyncState<Article?> async = useSignalValue(vm.selectedArticle);

    return async.map(
      loading: () => Scaffold(appBar: AppBar(), body: const LoadingIndicator()),
      error: (Object? e) => Scaffold(
        appBar: AppBar(),
        body: ErrorText(error: '$e', onRetry: () => vm.loadDetail(articleId)),
      ),
      data: (d) {
        final article = d!;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ── Sliver app bar ──
              SliverAppBar.large(
                title: Text(
                  article.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.primaryContainer.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.article_outlined,
                        size: 64,
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Article body ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meta info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '技术',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: appTheme.textSubtle,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '5 分钟阅读',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: appTheme.textSubtle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Body text
                      Text(
                        article.body,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.8,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
