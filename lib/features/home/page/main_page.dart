import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 主框架页面
///
/// 提供响应式导航布局：
/// - 窄屏（< 800px）：底部导航栏
/// - 宽屏（>= 800px）：侧边导航栏
class MainPage extends StatelessWidget {
  final Widget child;

  const MainPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildWideLayout(context);
        } else {
          return _buildNarrowLayout(context);
        }
      },
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) => _onItemTapped(index, context),
            labelType: NavigationRailLabelType.all,
            groupAlignment: -0.9,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('首页'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.article_outlined),
                selectedIcon: Icon(Icons.article),
                label: Text('文章'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('我的'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: '文章',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/articles')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0; // home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/articles');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }
}
