import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

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

  /// 清空所有缓存
  Future<void> clearAll() async {
    await delete(articles).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/app.db');
    return NativeDatabase(file);
  });
}
