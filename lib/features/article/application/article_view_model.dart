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
/// 负责处理文章列表和详情相关的状态和业务逻辑
@injectable
class ArticleViewModel extends BaseViewModel {
  final ArticleRepository _repo;

  @factoryMethod
  ArticleViewModel(this._repo) {
    // 初始化 effect 监听
    _initEffects();
  }

  /// 文章列表异步状态
  final articles = asyncSignal<List<Article>>(AsyncState.loading());

  /// 选中文章异步状态
  final selectedArticle = asyncSignal<Article?>(AsyncState.data(null));

  /// 当前失败信息
  final currentFailure = signal<Failure?>(null);

  /// 是否正在加载列表
  bool get isLoadingList => articles.value.isLoading;

  /// 是否正在加载详情
  bool get isLoadingDetail => selectedArticle.value.isLoading;

  /// 列表是否有错误
  bool get hasListError =>
      articles.value.hasError || currentFailure.value != null;

  /// 详情是否有错误
  bool get hasDetailError => selectedArticle.value.hasError;

  /// 获取文章列表
  List<Article> get articleList => articles.value.value ?? [];

  /// 获取当前选中的文章
  Article? get currentArticle => selectedArticle.value.value;

  /// 获取错误消息
  String? get errorMessage {
    if (currentFailure.value != null) {
      return currentFailure.value!.message;
    }
    if (articles.value.hasError) {
      return articles.value.error?.toString();
    }
    return null;
  }

  /// 初始化 effect 监听
  void _initEffects() {
    // 监听文章列表状态变化
    addEffect(() {
      if (kReleaseMode) return;
      final state = articles.value;
      if (state.hasValue) {
        debugPrint('文章列表已加载：${state.value?.length} 篇');
      } else if (state.hasError) {
        debugPrint('文章列表加载错误：${state.error}');
      }
    });

    // 监听选中文章状态变化
    addEffect(() {
      if (kReleaseMode) return;
      final state = selectedArticle.value;
      if (state.hasValue) {
        debugPrint('已选中文章：${state.value?.title}');
      }
    });
  }

  /// 加载文章列表
  Future<Result<void, Failure>> load() async {
    final failure = await runAsync(
      () => _repo.getArticles(),
      into: articles,
      failInto: currentFailure,
    );
    if (failure != null) return Result.failure(failure);
    return const Result.success(null);
  }

  /// 加载文章详情
  Future<Result<void, Failure>> loadDetail(int id) async {
    selectedArticle.value = AsyncState.loading();
    currentFailure.value = null;

    final result = await _repo.getArticle(id);
    if (disposed) return const Result.failure(Failure.unknown('ViewModel已释放'));

    return result.when(
      success: (data) {
        selectedArticle.value = AsyncState.data(data);
        return const Result.success(null);
      },
      failure: (failure) {
        selectedArticle.value = AsyncState.error(failure.message);
        currentFailure.value = failure;
        return Result.failure(failure);
      },
    );
  }

  /// 刷新文章列表
  Future<Result<void, Failure>> refresh() async {
    if (articles.value.isLoading) return const Result.success(null);
    return await load();
  }

  /// 清空选中的文章
  void clearSelected() {
    selectedArticle.value = AsyncState.data(null);
  }

  /// 清除错误
  void clearError() {
    currentFailure.value = null;
  }

  /// 从列表中移除文章
  void removeArticle(int id) {
    final state = articles.value;
    if (state.hasValue) {
      final currentList = state.value ?? [];
      articles.value = AsyncState.data(
        currentList.where((a) => a.id != id).toList(),
      );
    }
  }

  @override
  void dispose() {
    debugPrint('ArticleViewModel 已释放');
    super.dispose();
  }
}
