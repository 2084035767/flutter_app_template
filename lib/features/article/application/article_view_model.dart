import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../shared/view_models/base_view_model.dart';
import '../domain/article_repository.dart';
import '../domain/models/article.dart';

/// 文章 ViewModel
///
/// 负责处理文章列表和详情相关的状态和业务逻辑。
/// 列表使用 [futureSignal] 自动管理 loading→data/error 状态，
/// 详情由 action 触发，使用 dispose-guarded 手动模式。
@injectable
class ArticleViewModel extends BaseViewModel {
  final ArticleRepository _repo;

  @factoryMethod
  ArticleViewModel(this._repo) {
    articles = futureSignal<List<Article>>(() async {
      final result = await _repo.getArticles();
      return result.when(success: (data) => data, failure: (f) => throw f);
    });
    _initEffects();
  }

  /// 文章列表 — futureSignal 自动处理 loading→data/error
  late final FutureSignal<List<Article>> articles;

  /// 选中文章异步状态（action 触发，手动管理）
  final selectedArticle = asyncSignal<Article?>(AsyncState.data(null));

  /// 是否正在加载列表
  bool get isLoadingList => articles.value.isLoading;

  /// 是否正在加载详情
  bool get isLoadingDetail => selectedArticle.value.isLoading;

  /// 列表是否有错误
  bool get hasListError => articles.value.hasError;

  /// 详情是否有错误
  bool get hasDetailError => selectedArticle.value.hasError;

  /// 获取文章列表
  List<Article> get articleList => articles.value.value ?? [];

  /// 获取当前选中的文章
  Article? get currentArticle => selectedArticle.value.value;

  /// 获取错误消息
  String? get errorMessage {
    if (articles.value.hasError) {
      return articles.value.error?.toString();
    }
    return null;
  }

  void _initEffects() {
    addEffect(() {
      if (kReleaseMode) return;
      final state = articles.value;
      if (state.hasValue) {
        debugPrint('文章列表已加载：${state.value?.length} 篇');
      } else if (state.hasError) {
        debugPrint('文章列表加载错误：${state.error}');
      }
    });
    addEffect(() {
      if (kReleaseMode) return;
      final state = selectedArticle.value;
      if (state.hasValue) {
        debugPrint('已选中文章：${state.value?.title}');
      }
    });
  }

  /// 加载文章详情（action 触发，手动管理）
  Future<Result<void, Failure>> loadDetail(int id) async {
    selectedArticle.value = AsyncState.loading();

    final result = await _repo.getArticle(id);
    if (disposed) return const Result.failure(Failure.unknown('已释放'));

    return result.when(
      success: (data) {
        selectedArticle.value = AsyncState.data(data);
        return const Result.success(null);
      },
      failure: (failure) {
        selectedArticle.value = AsyncState.error(failure.message);
        return Result.failure(failure);
      },
    );
  }

  /// 清空选中的文章
  void clearSelected() {
    selectedArticle.value = AsyncState.data(null);
  }

  /// 刷新文章列表
  Future<void> refresh() async {
    await articles.reload();
  }

  @override
  void dispose() {
    debugPrint('ArticleViewModel 已释放');
    super.dispose();
  }
}
