import 'package:go_router/go_router.dart';
import 'package:my_app/core/presentation/pages/not_found_page.dart';
import 'package:my_app/core/presentation/pages/splash_page.dart';
import 'package:my_app/core/routing/route_constants.dart';
import 'package:my_app/core/routing/router_extension.dart';
import 'package:my_app/features/article/page/article_detail_page.dart';
import 'package:my_app/features/article/page/article_list_page.dart';
import 'package:my_app/features/auth/page/login_page.dart';
import 'package:my_app/features/home/page/home_page.dart';
import 'package:my_app/features/home/page/main_page.dart';
import 'package:my_app/features/profile/page/profile_page.dart';

class AppRouter {
  final bool isAuthenticated;

  AppRouter({required this.isAuthenticated});

  late final router = GoRouter(
    initialLocation: RoutePaths.splash,
    routes: [
      // 启动页
      GoRoute(
        name: RouteNames.splash,
        path: RoutePaths.splash,
        builder: (_, _) => SplashPage(isAuthenticated: isAuthenticated),
      ),

      // 登录页
      GoRoute(
        name: RouteNames.login,
        path: RoutePaths.login,
        builder: (_, _) => const LoginPage(),
      ),

      // 主框架（共享底部导航）
      ShellRoute(
        builder: (context, state, child) => MainPage(child: child),
        routes: [
          GoRoute(
            name: RouteNames.home,
            path: RoutePaths.home,
            pageBuilder: (_, _) => const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            name: RouteNames.articles,
            path: RoutePaths.articles,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: ArticleListPage()),
          ),
          GoRoute(
            name: RouteNames.profile,
            path: RoutePaths.profile,
            pageBuilder: (_, _) => const NoTransitionPage(child: ProfilePage()),
          ),
        ],
      ),

      // 文章详情（独立页面，不需要底部导航）
      GoRoute(
        name: RouteNames.articleDetail,
        path: RoutePaths.articleDetail,
        builder: (_, state) {
          final id = state.getInt('id');
          return ArticleDetailPage(articleId: id);
        },
      ),
    ],
    errorBuilder: (_, _) => const NotFoundPage(),
    redirect: (context, state) {
      final loggingIn = state.uri.toString() == RoutePaths.login;
      if (!isAuthenticated && !loggingIn) return RoutePaths.login;
      if (isAuthenticated && loggingIn) return RoutePaths.home;
      return null;
    },
  );
}
