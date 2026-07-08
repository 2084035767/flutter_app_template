// lib/features/article/data/article_module.dart
import 'package:dio/dio.dart';

import 'article_api.dart';

/// 文章功能模块 - 提供文章相关依赖
abstract class ArticleModule {
  /// Article API 服务
  ArticleApi articleApi(Dio dio) => ArticleApi(dio);
}
