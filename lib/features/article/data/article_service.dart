import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/base/failure.dart';
import '../../../core/base/result.dart';
import 'article_repository.dart';
import 'models/article.dart';
import 'article_api.dart';

/// 文章服务实现
///
/// 负责与远程 API 交互，并将底层错误转换为统一的 [Failure] 类型
@LazySingleton(as: ArticleRepository)
class ArticleService implements ArticleRepository {
  final ArticleApi _api;

  ArticleService(this._api);

  @override
  Future<Result<List<Article>, Failure>> getArticles() async {
    try {
      final articles = await _api.getArticles();
      return Result.success(articles);
    } on DioException catch (e) {
      return Result.failure(handleError(e));
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
      return Result.failure(handleError(e));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
