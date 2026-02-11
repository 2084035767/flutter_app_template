import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/features/article/domain/models/article.dart';
import 'package:retrofit/retrofit.dart';

part 'article_api.g.dart';

@RestApi()
abstract class ArticleApi {
  @factoryMethod
  factory ArticleApi(Dio dio) = _ArticleApi;

  @GET('/articles')
  Future<List<Article>> getArticles();

  @GET('/articles/{id}')
  Future<Article> getArticle(@Path('id') int id);
}
