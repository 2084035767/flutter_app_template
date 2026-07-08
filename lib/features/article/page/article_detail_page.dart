import 'package:flutter/material.dart';
import 'package:my_app/core/presentation/widgets/error_text.dart';
import 'package:my_app/core/presentation/widgets/loading_indicator.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:my_app/features/article/application/article_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ArticleDetailPage extends StatefulWidget {
  final int articleId;

  const ArticleDetailPage({super.key, required this.articleId});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late final ArticleViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<ArticleViewModel>();
    _vm.loadDetail(widget.articleId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Watch.builder(
      builder: (context) {
        final async = _vm.selectedArticle.value;

        if (async.isLoading) {
          return Scaffold(appBar: AppBar(), body: const LoadingIndicator());
        }

        if (_vm.hasDetailError) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorText(
              error: _vm.selectedArticle.value.error?.toString() ?? '加载失败',
              onRetry: () => _vm.loadDetail(widget.articleId),
            ),
          );
        }

        final article = _vm.currentArticle;
        if (article == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('文章不存在')),
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
      },
    );
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }
}
