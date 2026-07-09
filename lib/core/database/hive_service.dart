import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:my_app/features/article/domain/models/article.dart';
import 'package:path_provider/path_provider.dart';

/// Hive 本地数据库服务
///
/// 提供类型安全的本地持久化，支持离线缓存。
/// 使用 Hive CE（Community Edition），零代码生成。
class HiveService {
  static const _articleBoxName = 'articles';

  bool _initialized = false;

  /// 初始化 Hive，在 app 启动时调用
  Future<void> init() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    _initialized = true;
  }

  /// 打开/获取文章缓存 Box
  Future<Box<String>> get articleBox async {
    if (!_initialized) await init();
    return Hive.openBox<String>(_articleBoxName);
  }

  /// 缓存文章列表
  Future<void> cacheArticles(List<Article> articles) async {
    final box = await articleBox;
    await box.clear();
    for (final article in articles) {
      await box.put(
        article.id.toString(),
        jsonEncode(article.toJson()),
      );
    }
  }

  /// 获取缓存的文章列表
  Future<List<Article>> getCachedArticles() async {
    final box = await articleBox;
    return box.values
        .map((json) => Article.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  /// 获取单篇缓存文章
  Future<Article?> getCachedArticle(int id) async {
    final box = await articleBox;
    final json = box.get(id.toString());
    if (json == null) return null;
    return Article.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// 清空所有缓存
  Future<void> clearAll() async {
    final box = await articleBox;
    await box.clear();
  }
}
