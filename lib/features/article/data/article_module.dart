import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'article_api.dart';

@module
abstract class ArticleModule {
  @LazySingleton()
  ArticleApi articleApi(Dio dio) => ArticleApi(dio);
}
