import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/data/database/app_database.dart';

/// 内存数据库供测试用，避免读写设备文件
AppDatabase createTestDb() {
  final db = AppDatabase.connect(NativeDatabase.memory());
  // 确保表已创建
  addTearDown(db.close);
  return db;
}

void main() {
  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() async {
      db = createTestDb();
      // 等待表创建完成
      await db.customSelect('SELECT 1').get();
    });

    group('seed / read', () {
      test('seed 插入示例数据后可以读取', () async {
        await db.seed();

        final articles = await db.getCachedArticles();

        expect(articles, hasLength(2));
        expect(articles[0].title, 'Flutter 3.44 新特性解析');
        expect(articles[1].title, 'Dart 3.12 模式匹配实战');
      });

      test('可以读取单篇文章', () async {
        await db.seed();

        final article = await db.getCachedArticle(1);

        expect(article, isNotNull);
        expect(article!.title, 'Flutter 3.44 新特性解析');
        expect(article.body, startsWith('Flutter'));
      });

      test('读取不存在的 id 返回 null', () async {
        await db.seed();

        final article = await db.getCachedArticle(999);

        expect(article, isNull);
      });
    });

    group('cacheArticles', () {
      test('写入后可通过 getCachedArticles 读取', () async {
        final articles = [
          Article(id: 10, title: 'Test 1', body: 'Body 1'),
          Article(id: 20, title: 'Test 2', body: 'Body 2'),
        ];

        await db.cacheArticles(articles);

        final cached = await db.getCachedArticles();
        expect(cached, hasLength(2));
        expect(cached[0].id, 10);
        expect(cached[1].title, 'Test 2');
      });

      test('重复调用 cacheArticles 会覆盖旧数据', () async {
        await db.cacheArticles([
          Article(id: 1, title: 'First', body: 'First body'),
        ]);
        await db.cacheArticles([
          Article(id: 2, title: 'Second', body: 'Second body'),
        ]);

        final cached = await db.getCachedArticles();
        expect(cached, hasLength(1));
        expect(cached[0].title, 'Second');
      });
    });

    group('clearAll', () {
      test('清空后查询结果为空', () async {
        await db.seed();
        await db.clearAll();

        final articles = await db.getCachedArticles();
        expect(articles, isEmpty);
      });
    });
  });
}
