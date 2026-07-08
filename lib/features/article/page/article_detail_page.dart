import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:my_app/core/presentation/widgets/error_text.dart';
import 'package:my_app/core/presentation/widgets/loading_indicator.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:my_app/features/article/application/article_view_model.dart';
import 'package:my_app/features/article/domain/models/article.dart';
import 'package:signals_hooks/signals_hooks.dart';

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
    final Article? article = async.value;

    if (async.isLoading) {
      return Scaffold(appBar: AppBar(), body: const LoadingIndicator());
    }

    if (async.hasError || article == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorText(
          error: vm.selectedArticle.value.error?.toString() ?? '加载失败',
          onRetry: () => vm.loadDetail(articleId),
        ),
      );
    }

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
  }
}
