import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stockpilot/shared/widgets/app_bottom_navigation.dart';

void main() {
  tearDown(() => AppNavigation.lastSectionIndex = 0);

  testWidgets(
    'secondary page keeps navigation and can jump to a main section',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/detail',
        routes: [
          GoRoute(
            path: '/detail',
            builder: (context, state) => const PersistentNavigationPage(
              sectionIndex: 3,
              child: Scaffold(body: Text('detail page')),
            ),
          ),
          for (var index = 0; index < AppNavigation.paths.length; index++)
            GoRoute(
              path: AppNavigation.paths[index],
              builder: (context, state) =>
                  Scaffold(body: Text('main section $index')),
            ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.text('detail page'), findsOneWidget);
      expect(find.byType(AppBottomNavigationBar), findsOneWidget);
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        3,
      );

      await tester.tap(find.text('推荐'));
      await tester.pumpAndSettle();

      expect(find.text('main section 0'), findsOneWidget);
      expect(AppNavigation.lastSectionIndex, 0);
    },
  );

  testWidgets('generic detail page highlights the most recent main section', (
    tester,
  ) async {
    AppNavigation.lastSectionIndex = 2;

    await tester.pumpWidget(
      const MaterialApp(
        home: PersistentNavigationPage(
          child: Scaffold(body: Text('stock detail')),
        ),
      ),
    );

    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      2,
    );
  });
}
