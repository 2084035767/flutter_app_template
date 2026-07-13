import 'package:my_app/core/base/failure.dart';
import 'package:my_app/core/base/result.dart';

import 'models/article.dart';

/// 文章仓库抽象
///
/// 定义文章功能的核心业务逻辑接口
/// 所有返回值都使用 Result 类型以确保类型安全的错误处理
abstract class ArticleRepository {
  /// 获取文章列表
  ///
  /// 返回 [Result] 类型：
  /// - [Success] 包含文章列表
  /// - [Failure] 包含失败原因（网络错误、服务器错误等）
  Future<Result<List<Article>, Failure>> getArticles();

  /// 获取文章详情
  ///
  /// 返回 [Result] 类型：
  /// - [Success] 包含文章详情
  /// - [Failure] 包含失败原因
  Future<Result<Article, Failure>> getArticle(int id);
}
