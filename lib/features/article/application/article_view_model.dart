import 'package:injectable/injectable.dart';
import 'package:my_app/core/error/failure.dart';
import 'package:my_app/core/error/result.dart';
import 'package:my_app/di/service_locator.dart';
import 'package:my_app/features/article/domain/article_repository.dart';
import 'package:my_app/features/article/domain/models/article.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 文章 ViewModel
///
/// 信号私有、Readonly 暴露，UI 通过 hooks 订阅。
@injectable
class ArticleViewModel {
  final ArticleRepository _repo = getIt<ArticleRepository>();

  ArticleViewModel() {
    _articles = futureSignal<List<Article>>(() async {
      final result = await _repo.getArticles();
      return result.when(success: (data) => data, failure: (f) => throw f);
    });
  }

  late final FutureSignal<List<Article>> _articles;

  /// 文章列表信号（只读）
  ReadonlySignal<AsyncState<List<Article>>> get articles => _articles;

  /// 选中文章（action 触发，手动管理）
  final _selectedArticle = asyncSignal<Article?>(AsyncState.data(null));

  ReadonlySignal<AsyncState<Article?>> get selectedArticle => _selectedArticle;

  bool get isLoadingList => _articles.value.isLoading;
  bool get isLoadingDetail => _selectedArticle.value.isLoading;
  bool get hasListError => _articles.value.hasError;
  bool get hasDetailError => _selectedArticle.value.hasError;
  List<Article> get articleList => _articles.value.value ?? [];
  Article? get currentArticle => _selectedArticle.value.value;

  String? get errorMessage => _articles.value.error?.toString();

  /// 加载文章详情
  Future<Result<void, Failure>> loadDetail(int id) async {
    _selectedArticle.value = AsyncState.loading();
    final result = await _repo.getArticle(id);
    return result.when(
      success: (data) {
        _selectedArticle.value = AsyncState.data(data);
        return const Result.success(null);
      },
      failure: (failure) {
        _selectedArticle.value = AsyncState.error(failure.message);
        return Result.failure(failure);
      },
    );
  }

  /// 刷新文章列表
  void reloadArticles() => _articles.reload();

  void clearSelected() {
    _selectedArticle.value = AsyncState.data(null);
  }
}
