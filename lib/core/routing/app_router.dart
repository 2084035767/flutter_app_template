import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/core/routing/route_constants.dart';
import 'package:my_app/features/article/page/article_list_page.dart';
import 'package:my_app/features/auth/page/login_page.dart';
import 'package:my_app/features/home/page/main_page.dart';
import 'package:my_app/features/profile/page/profile_page.dart';
import 'package:signals_hooks/signals_hooks.dart';

final isAuthenticated = signal<bool>(false, autoDispose: true);
void login() => isAuthenticated.value = true;
void logout() => isAuthenticated.value = false;

final _protectedPaths = {RoutePaths.home};

final router = GoRouter(
  initialLocation: RoutePaths.splash,
  debugLogDiagnostics: true,
  refreshListenable: isAuthenticated,

  redirect: (context, state) {
    final location = state.uri.path;
    final isLoggedIn = isAuthenticated.value;

    if (isLoggedIn && location == RoutePaths.login) return RoutePaths.home;

    if (!isLoggedIn && _protectedPaths.contains(location)) {
      return RoutePaths.login;
    }
    return null;
  },

  routes: [
    GoRoute(
      name: RouteNames.login,
      path: RoutePaths.login,
      builder: (_, _) => const LoginPage(),
    ),
    GoRoute(
      name: RouteNames.home,
      path: RoutePaths.home,
      builder: (_, _) => MainPage(child: Container()),
    ),
    GoRoute(
      name: RouteNames.splash,
      path: RoutePaths.splash,
      builder: (_, _) => MainPage(child: Container()),
    ),
    GoRoute(
      name: RouteNames.profile,
      path: RoutePaths.profile,
      builder: (_, _) => ProfilePage(),
    ),
    GoRoute(
      name: RouteNames.articles,
      path: RoutePaths.articles,
      builder: (_, _) => ArticleListPage(),
    ),
  ],

  errorBuilder: (context, state) => NotFoundPage(path: state.uri.path),
);

class NotFoundPage extends StatelessWidget {
  final String path;

  const NotFoundPage({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Text("你好");
  }
}
