import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/core/base/failure.dart';
import 'package:my_app/core/base/result.dart';
import 'package:my_app/features/article/logic/article_view_model.dart';
import 'package:my_app/features/article/data/article_repository.dart';
import 'package:my_app/features/article/data/models/article.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late MockArticleRepository mockRepo;
  late ArticleViewModel vm;

  setUp(() {
    mockRepo = MockArticleRepository();
    vm = ArticleViewModel(mockRepo);
  });

  group('ArticleViewModel', () {
    test('初始状态为 data([]), 无 error, 不 loading', () {
      expect(vm.articles.value.isLoading, isFalse);
      expect(vm.articles.value.hasError, isFalse);
      expect(vm.articles.value.value, isEmpty);
    });

    group('loadArticles()', () {
      test('成功后更新列表', () async {
        final articles = [
          Article(id: 1, title: 'a', body: 'body a'),
          Article(id: 2, title: 'b', body: 'body b'),
        ];
        when(
          () => mockRepo.getArticles(),
        ).thenAnswer((_) async => Result.success(articles));

        await vm.loadArticles();

        expect(vm.articles.value.value, hasLength(2));
        expect(vm.articles.value.value![0].title, 'a');
        expect(vm.articles.value.isLoading, isFalse);
        expect(vm.articles.value.hasError, isFalse);
      });

      test('失败后设置 error 状态', () async {
        when(() => mockRepo.getArticles()).thenAnswer(
          (_) async => Result.failure(const Failure.network('网络错误')),
        );

        await vm.loadArticles();

        expect(vm.articles.value.hasError, isTrue);
        expect(vm.articles.value.error?.toString(), contains('网络错误'));
        expect(vm.articles.value.value, isNull);
        expect(vm.articles.value.isLoading, isFalse);
      });

      test('加载中时 isLoading 为 true', () {
        when(() => mockRepo.getArticles()).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(seconds: 1));
          return Result.success(<Article>[]);
        });

        final future = vm.loadArticles();

        expect(vm.articles.value.isLoading, isTrue);
        expect(future, completes);
      });
    });

    group('loadDetail()', () {
      test('成功后更新 selectedArticle', () async {
        final article = Article(id: 1, title: 't', body: 'b');
        when(
          () => mockRepo.getArticle(1),
        ).thenAnswer((_) async => Result.success(article));

        final result = await vm.loadDetail(1);

        expect(result.isSuccess, isTrue);
        expect(vm.selectedArticle.value.value?.title, 't');
        expect(vm.selectedArticle.value.isLoading, isFalse);
      });

      test('失败后返回 Failure', () async {
        when(() => mockRepo.getArticle(1)).thenAnswer(
          (_) async => Result.failure(const Failure.server('服务器错误')),
        );

        final result = await vm.loadDetail(1);

        expect(result.isFailure, isTrue);
        expect(vm.selectedArticle.value.hasError, isTrue);
        expect(vm.selectedArticle.value.value, isNull);
      });
    });

    group('clearSelected()', () {
      test('清除选中文章', () async {
        when(() => mockRepo.getArticle(1)).thenAnswer(
          (_) async => Result.success(Article(id: 1, title: 't', body: 'b')),
        );

        await vm.loadDetail(1);
        expect(vm.selectedArticle.value.value, isNotNull);

        vm.clearSelected();
        expect(vm.selectedArticle.value.value, isNull);
        expect(vm.selectedArticle.value.isLoading, isFalse);
      });
    });
  });
}
