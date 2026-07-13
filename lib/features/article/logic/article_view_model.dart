import 'package:injectable/injectable.dart';
import 'package:my_app/core/base/failure.dart';
import 'package:my_app/core/base/result.dart';
import 'package:my_app/core/base/run_async.dart';
import 'package:my_app/features/article/data/article_repository.dart';
import 'package:my_app/features/article/data/models/article.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 文章 ViewModel
///
/// 信号直接公开，UI 通过 useSignalValue 订阅。
/// 约定：UI 层只读不写，所有状态变更通过 ViewModel 方法进行。
@injectable
class ArticleViewModel {
  final ArticleRepository _repo;

  ArticleViewModel(this._repo);

  // ========== 信号（公开，UI 通过 hooks 订阅）==========
  final articles = asyncSignal<List<Article>>(AsyncState.data([]));
  final selectedArticle = asyncSignal<Article?>(AsyncState.data(null));

  // ========== 方法 ==========

  /// 加载文章列表
  Future<void> loadArticles() async {
    await runAsync(articles, () => _repo.getArticles());
  }

  /// 加载文章详情
  Future<Result<void, Failure>> loadDetail(int id) {
    return runAsync(selectedArticle, () => _repo.getArticle(id));
  }

  void clearSelected() {
    selectedArticle.value = AsyncState.data(null);
  }
}
