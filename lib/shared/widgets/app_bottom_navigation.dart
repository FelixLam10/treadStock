import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared destinations used by the app-wide bottom navigation.
abstract final class AppNavigation {
  static const paths = <String>[
    '/recommend',
    '/hotspots',
    '/watchlist',
    '/strategies',
  ];

  /// Remembers the last main section so generic pages such as stock details
  /// can keep the section the user came from highlighted.
  static int lastSectionIndex = 0;

  static void goToSection(BuildContext context, int index) {
    assert(index >= 0 && index < paths.length);
    lastSectionIndex = index;
    context.go(paths[index]);
  }
}

/// The single bottom-navigation implementation shared by main and detail
/// pages, keeping labels and icons consistent throughout the app.
class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up_outlined, size: 24),
          activeIcon: Icon(Icons.trending_up, size: 24),
          label: '推荐',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_fire_department, size: 24),
          activeIcon: Icon(Icons.local_fire_department, size: 24),
          label: '热点',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star_outline, size: 24),
          activeIcon: Icon(Icons.star, size: 24),
          label: '关注',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb_outline, size: 24),
          activeIcon: Icon(Icons.lightbulb, size: 24),
          label: '策略',
        ),
      ],
    );
  }
}

/// Adds the app navigation to a secondary or deeper page without changing
/// that page's own back-button behavior.
class PersistentNavigationPage extends StatelessWidget {
  final Widget child;
  final int? sectionIndex;

  const PersistentNavigationPage({
    super.key,
    required this.child,
    this.sectionIndex,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = sectionIndex ?? AppNavigation.lastSectionIndex;
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => AppNavigation.goToSection(context, index),
      ),
    );
  }
}
