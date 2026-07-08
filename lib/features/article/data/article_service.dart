import 'package:dio/dio.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../domain/article_repository.dart';
import '../domain/models/article.dart';
import 'article_api.dart';

/// 文章服务实现
///
/// 负责与远程 API 交互，并将底层错误转换为统一的 [Failure] 类型
class ArticleService implements ArticleRepository {
  final ArticleApi _api;

  ArticleService(this._api);

  @override
  Future<Result<List<Article>, Failure>> getArticles() async {
    try {
      final articles = await _api.getArticles();
      return Result.success(articles);
    } on DioException catch (e) {
      final apiError = handleError(e);
      return Result.failure(Failure.fromApiError(apiError));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<Article, Failure>> getArticle(int id) async {
    try {
      final article = await _api.getArticle(id);
      return Result.success(article);
    } on DioException catch (e) {
      final apiError = handleError(e);
      return Result.failure(Failure.fromApiError(apiError));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
