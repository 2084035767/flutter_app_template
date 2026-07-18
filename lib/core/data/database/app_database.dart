import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ========== 表定义 ==========

class Articles extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get body => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// ========== DAO ==========

@DriftDatabase(tables: [Articles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 注入自定义 [QueryExecutor]（主要用于测试）
  AppDatabase.connect(super.e);

  @override
  int get schemaVersion => 1;

  // ========== 文章缓存 ==========

  /// 缓存文章列表（先清后写）
  Future<void> cacheArticles(List<Article> items) async {
    await batch((batch) {
      batch.deleteAll(articles);
      for (final article in items) {
        batch.insert(
          articles,
          ArticlesCompanion(
            id: Value(article.id),
            title: Value(article.title),
            body: Value(article.body),
          ),
        );
      }
    });
  }

  /// 获取缓存的文章列表
  Future<List<Article>> getCachedArticles() async {
    final rows = await select(articles).get();
    return rows
        .map((r) => Article(id: r.id, title: r.title, body: r.body))
        .toList();
  }

  /// 获取单篇缓存文章
  Future<Article?> getCachedArticle(int id) async {
    final row = await (select(
      articles,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return Article(id: row.id, title: row.title, body: row.body);
  }

  /// 插入示例数据（开发用）
  Future<void> seed() async {
    await batch((batch) {
      batch.insertAll(articles, [
        ArticlesCompanion(
          id: Value(1),
          title: Value('Flutter 3.44 新特性解析'),
          body: Value(
            'Flutter 3.44 引入了多项新特性和改进，'
            '包括更好的性能优化和新的 widget 组件。',
          ),
        ),
        ArticlesCompanion(
          id: Value(2),
          title: Value('Dart 3.12 模式匹配实战'),
          body: Value(
            'Dart 3.12 增强了模式匹配功能，'
            '使得代码更加简洁和表达力更强。',
          ),
        ),
      ]);
    });
  }

  /// 清空所有缓存
  Future<void> clearAll() async {
    await delete(articles).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/app.db');
    return NativeDatabase(file);
  });
}
