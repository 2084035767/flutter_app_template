import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_app/core/routing/router.dart';

/// 主框架页面——响应式导航布局
///
/// - 窄屏（< 800px）：底部导航栏
/// - 宽屏（>= 800px）：侧边导航栏
@RoutePage()
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final _routes = const [HomeRoute(), ArticleListRoute(), ProfileRoute()];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    context.replaceRoute(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // ── Wide: NavigationRail ──
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onTabTapped,
                  labelType: NavigationRailLabelType.all,
                  groupAlignment: -0.9,
                  backgroundColor: colorScheme.surfaceContainerLow,
                  indicatorColor: colorScheme.secondaryContainer,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Icon(
                      Icons.spa_outlined,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(
                        Icons.home_outlined,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      selectedIcon: Icon(
                        Icons.home,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        '首页',
                        style: TextStyle(
                          fontWeight: _currentIndex == 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    NavigationRailDestination(
                      icon: Icon(
                        Icons.article_outlined,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      selectedIcon: Icon(
                        Icons.article,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        '文章',
                        style: TextStyle(
                          fontWeight: _currentIndex == 1
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    NavigationRailDestination(
                      icon: Icon(
                        Icons.person_outline,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      selectedIcon: Icon(
                        Icons.person,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        '我的',
                        style: TextStyle(
                          fontWeight: _currentIndex == 2
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                const Expanded(child: AutoRouter()),
              ],
            ),
          );
        } else {
          // ── Narrow: Bottom Navigation ──
          return Scaffold(
            body: const AutoRouter(),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabTapped,
              backgroundColor: colorScheme.surfaceContainerLow,
              indicatorColor: colorScheme.secondaryContainer,
              elevation: 0,
              shadowColor: Colors.transparent,
              height: 72,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.home_outlined,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  selectedIcon: Icon(Icons.home, color: colorScheme.primary),
                  label: '首页',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.article_outlined,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  selectedIcon: Icon(Icons.article, color: colorScheme.primary),
                  label: '文章',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.person_outline,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  selectedIcon: Icon(Icons.person, color: colorScheme.primary),
                  label: '我的',
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
