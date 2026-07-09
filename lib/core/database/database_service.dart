import 'package:my_app/features/article/domain/models/article.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

/// SQLite 本地数据库服务
///
/// 使用原生 SQLite（通过 drift 依赖的 sqlite3 包）。
/// 零代码生成，手写 SQL。支持离线缓存、迁移、事务。
class DatabaseService {
  Database? _db;
  bool _initialized = false;

  /// 初始化数据库
  Future<void> init() async {
    if (_initialized) return;

    // Android 兼容处理
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/app.db';
    _db = sqlite3.open(path);

    // 启用 WAL 模式（更好的并发性能）
    _db!.execute('PRAGMA journal_mode=WAL');

    // 创建表
    _db!.execute('''
      CREATE TABLE IF NOT EXISTS articles (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL DEFAULT '',
        body TEXT NOT NULL DEFAULT ''
      )
    ''');

    _initialized = true;
  }

  void _checkInit() {
    if (_db == null) throw StateError('Database not initialized');
  }

  // ========== 文章缓存 ==========

  /// 缓存文章列表
  Future<void> cacheArticles(List<Article> articles) async {
    _checkInit();
    _db!.execute('DELETE FROM articles');

    final stmt = _db!.prepare(
      'INSERT INTO articles (id, title, body) VALUES (?, ?, ?)',
    );
    try {
      for (final article in articles) {
        stmt.execute([article.id, article.title, article.body]);
      }
    } finally {
      stmt.dispose();
    }
  }

  /// 获取缓存的文章列表
  Future<List<Article>> getCachedArticles() async {
    _checkInit();
    final rows = _db!.select('SELECT * FROM articles ORDER BY id');
    return rows
        .map(
          (row) => Article(
            id: row['id'] as int,
            title: row['title'] as String,
            body: row['body'] as String,
          ),
        )
        .toList();
  }

  /// 获取单篇缓存文章
  Future<Article?> getCachedArticle(int id) async {
    _checkInit();
    final stmt = _db!.prepare('SELECT * FROM articles WHERE id = ?');
    try {
      final rows = stmt.select([id]);
      if (rows.isEmpty) return null;
      final row = rows.first;
      return Article(
        id: row['id'] as int,
        title: row['title'] as String,
        body: row['body'] as String,
      );
    } finally {
      stmt.dispose();
    }
  }

  /// 清空所有缓存
  Future<void> clearAll() async {
    _checkInit();
    _db!.execute('DELETE FROM articles');
  }

  /// 关闭数据库
  void dispose() {
    _db?.dispose();
    _db = null;
    _initialized = false;
  }
}
