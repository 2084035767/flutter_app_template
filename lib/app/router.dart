import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_app/core/presentation/pages/not_found_page.dart';
import 'package:my_app/core/presentation/pages/splash_page.dart';
import 'package:my_app/features/article/page/article_detail_page.dart';
import 'package:my_app/features/article/page/article_list_page.dart';
import 'package:my_app/features/auth/page/login_page.dart';
import 'package:my_app/features/home/page/home_page.dart';
import 'package:my_app/features/home/page/main_page.dart';
import 'package:my_app/features/profile/page/profile_page.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final bool isAuthenticated;

  AppRouter({required this.isAuthenticated});

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: '/splash', page: SplashRoute.page),
    AutoRoute(path: '/login', page: LoginRoute.page),

    // 主框架（带底部导航）
    AutoRoute(
      path: '/',
      page: MainRoute.page,
      children: [
        AutoRoute(path: 'home', page: HomeRoute.page, initial: true),
        AutoRoute(path: 'articles', page: ArticleListRoute.page),
        AutoRoute(path: 'profile', page: ProfileRoute.page),
      ],
    ),

    // 文章详情（不经过底部导航）
    AutoRoute(path: '/articles/:id', page: ArticleDetailRoute.page),

    // 404
    RedirectRoute(path: '*', redirectTo: '/splash'),
  ];
}
