import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:my_app/core/presentation/widgets/error_text.dart';
import 'package:my_app/core/presentation/widgets/loading_indicator.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:my_app/features/article/data/models/article.dart';
import 'package:my_app/features/article/logic/article_view_model.dart';
import 'package:signals_hooks/signals_hooks.dart';

@RoutePage()
class ArticleDetailPage extends HookWidget {
  final int articleId;

  const ArticleDetailPage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = useMemoized(() => getIt<ArticleViewModel>());

    // 加载详情（mount 时触发，articleId 变化时重新加载）
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
              SliverAppBar.large(title: Text(article.title)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(article.body, style: theme.textTheme.bodyLarge),
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
