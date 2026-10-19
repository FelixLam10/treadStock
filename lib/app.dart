import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_text_styles.dart';
import 'shared/providers.dart';
import 'shared/widgets/app_bottom_navigation.dart';
import 'features/alert/data/notification_service.dart';
import 'features/onboarding/data/onboarding_service.dart';
import 'features/onboarding/presentation/onboarding_page.dart';
import 'features/recommendation/presentation/recommendation_tab.dart';
import 'features/hotspot/presentation/hotspot_tab.dart';
import 'features/hotspot/presentation/hotspot_scheme_edit_page.dart';
import 'features/hotspot/presentation/hotspot_scheme_manage_page.dart';
import 'features/hotspot/domain/hotspot_models.dart';
import 'features/watchlist/presentation/watchlist_tab.dart';
import 'features/stock/presentation/stock_detail_page.dart';
import 'features/strategy/presentation/strategy_tab.dart';
import 'features/strategy/presentation/strategy_detail_page.dart';
import 'features/strategy/presentation/strategy_edit_page.dart';
import 'features/strategy/presentation/strategy_knowledge_page.dart';
import 'features/strategy/presentation/backtest_config_page.dart';
import 'features/strategy/presentation/strategy_compare_page.dart';
import 'features/strategy/presentation/strategy_template_page.dart';
import 'features/strategy/presentation/strategy_tuner_page.dart';
import 'features/strategy/presentation/strategy_creation_guide_page.dart';
import 'features/strategy/presentation/strategy_import_page.dart';
import 'features/strategy/presentation/strategy_version_history_page.dart';
import 'features/strategy/domain/strategy_models.dart';
import 'main.dart' show RiskDisclaimerDialog;

/// Root router configuration.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _recommendationHomeRequest = ValueNotifier<int>(0);

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/recommend',
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      final currentPath = state.matchedLocation;
      // If already on onboarding page, do nothing.
      if (currentPath == '/onboarding') return null;
      // Check if onboarding is needed.
      final onboardingService = OnboardingService();
      final completed = await onboardingService.isCompleted();
      if (!completed) return '/onboarding';
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/recommend'),
      GoRoute(path: '/dashboard', redirect: (context, state) => '/recommend'),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recommend',
                builder: (context, state) =>
                    RecommendationTab(homeRequest: _recommendationHomeRequest),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/hotspots',
                builder: (context, state) => const HotspotTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/watchlist',
                builder: (context, state) => const WatchlistTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/strategies',
                builder: (context, state) => const StrategyTab(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/stock/:code',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PersistentNavigationPage(
            child: StockDetailPage(
              code: state.pathParameters['code'] ?? '',
              name: extra?['name'] as String? ?? '',
              market: extra?['market'] as String? ?? 'SH',
              strategyId: extra?['strategyId'] as String?,
              strategyName: extra?['strategyName'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/hotspot/schemes',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PersistentNavigationPage(
            sectionIndex: 1,
            child: HotspotSchemeManagePage(
              initialMode: _hotspotMode(extra?['mode']),
            ),
          );
        },
      ),
      GoRoute(
        path: '/hotspot/scheme/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PersistentNavigationPage(
            sectionIndex: 1,
            child: HotspotSchemeEditPage(
              initialMode: _hotspotMode(extra?['mode']),
              copyDefault: extra?['copyDefault'] as bool? ?? false,
            ),
          );
        },
      ),
      GoRoute(
        path: '/hotspot/scheme/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => PersistentNavigationPage(
          sectionIndex: 1,
          child: HotspotSchemeEditPage(schemeId: state.pathParameters['id']),
        ),
      ),
      // 注意：GoRouter 按声明顺序匹配，字面量子路由（new/create/knowledge/
      // compare/templates/import）必须声明在 /strategy/:id 之前；版本、回测等
      // 多段详情路由也统一放在 :id 之前，便于维护。
      // 否则字面值可能被当作策略 id，导致 StrategyDetailPage 报「未找到该策略」。
      GoRoute(
        path: '/strategy/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PersistentNavigationPage(
          sectionIndex: 3,
          child: StrategyEditPage(),
        ),
      ),
      GoRoute(
        path: '/strategy/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PersistentNavigationPage(
          sectionIndex: 3,
          child: StrategyCreationGuidePage(),
        ),
      ),
      GoRoute(
        path: '/strategy/knowledge',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PersistentNavigationPage(
          sectionIndex: 3,
          child: StrategyKnowledgePage(),
        ),
      ),
      GoRoute(
        path: '/strategy/compare',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PersistentNavigationPage(
          sectionIndex: 3,
          child: StrategyComparePage(),
        ),
      ),
      GoRoute(
        path: '/strategy/templates',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PersistentNavigationPage(
          sectionIndex: 3,
          child: StrategyTemplatePage(),
        ),
      ),
      GoRoute(
        path: '/strategy/import',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PersistentNavigationPage(
          sectionIndex: 3,
          child: StrategyImportPage(),
        ),
      ),
      GoRoute(
        path: '/strategy/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PersistentNavigationPage(
            sectionIndex: 3,
            child: StrategyEditPage(
              strategyId: state.pathParameters['id'],
              suggestion: extra?['suggestion'] as StrategySuggestion?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/strategy/:id/backtest',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PersistentNavigationPage(
            sectionIndex: 3,
            child: BacktestConfigPage(
              strategyId: state.pathParameters['id'] ?? '',
              strategyName: extra?['strategyName'] as String? ?? '',
              initialStockCode: extra?['stockCode'] as String?,
              initialStockName: extra?['stockName'] as String?,
              initialMarket: extra?['market'] as String?,
              initialStrategyVersionId: extra?['strategyVersionId'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/strategy/:id/versions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => PersistentNavigationPage(
          sectionIndex: 3,
          child: StrategyVersionHistoryPage(
            strategyId: state.pathParameters['id'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '/strategy/:id/tuner',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PersistentNavigationPage(
            sectionIndex: 3,
            child: StrategyTunerPage(
              strategyId: state.pathParameters['id'] ?? '',
              stockCode: extra?['stockCode'] as String? ?? '',
            ),
          );
        },
      ),
      // :id 必须放在所有 /strategy/<literal> 子路由之后。
      GoRoute(
        path: '/strategy/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          return PersistentNavigationPage(
            sectionIndex: 3,
            child: StrategyDetailPage(
              strategyId: state.pathParameters['id'] ?? '',
            ),
          );
        },
      ),
    ],
  );

  static HotspotStockMode _hotspotMode(Object? value) {
    if (value is String) {
      for (final mode in HotspotStockMode.values) {
        if (mode.name == value) return mode;
      }
    }
    return HotspotStockMode.leader;
  }
}

/// Main scaffold with bottom tab bar.
class _MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _MainScaffold({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    AppNavigation.lastSectionIndex = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          if (index == navigationShell.currentIndex) {
            // Tapping the active tab again scrolls its primary scrollable
            // back to the top, matching common list-app behavior.
            final controller = PrimaryScrollController.maybeOf(context);
            if (controller != null && controller.hasClients) {
              controller.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
            return;
          }
          navigationShell.goBranch(index, initialLocation: index == 0);
          if (index == 0) {
            _recommendationHomeRequest.value++;
          }
        },
      ),
    );
  }
}

/// App widget.
class StockPilotApp extends ConsumerStatefulWidget {
  final bool disclaimerAccepted;

  const StockPilotApp({super.key, required this.disclaimerAccepted});

  @override
  ConsumerState<StockPilotApp> createState() => _StockPilotAppState();
}

class _StockPilotAppState extends ConsumerState<StockPilotApp>
    with WidgetsBindingObserver {
  Timer? _foregroundAlertTimer;
  Timer? _startupAlertTimer;
  StreamSubscription<String>? _notificationTapSub;
  StreamSubscription<void>? _appUpdateSub;

  @override
  void initState() {
    super.initState();
    // Observe lifecycle so we can run an alert scan when the user returns to
    // the app, in addition to the periodic foreground timer below.
    WidgetsBinding.instance.addObserver(this);

    // Load the persisted theme mode (defaults to system). Done after first
    // frame so the MaterialApp builds with the correct themeMode immediately
    // rather than flashing the default.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeModeProvider.notifier).init();
    });

    // Periodic foreground alert scan. The background workmanager task is the
    // primary mechanism; this timer ensures alerts still fire reasonably
    // promptly while the app is in the foreground.
    _foregroundAlertTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _runAlertScan(),
    );
    // Kick off one scan shortly after startup so a recently-triggered
    // condition surfaces quickly.
    _startupAlertTimer = Timer(const Duration(seconds: 15), _runAlertScan);

    // Hot-tap notifications: route the payload to the right screen as the
    // user taps while the app is running.
    _notificationTapSub = NotificationService.instance.onTapPayload.listen(
      _routeFromPayload,
    );
    // Cold-start tap: consume the launch payload once the router is mounted
    // (post-frame so GoRouter has a context to navigate with).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final payload = NotificationService.instance.consumeLaunchPayload();
      if (payload != null) _routeFromPayload(payload);
    });

    _appUpdateSub = ref.read(appPlatformServiceProvider).updates.listen((_) {
      _showUpdatePrompt();
    });
    if (widget.disclaimerAccepted) {
      Future<void>.delayed(const Duration(seconds: 3), _maybeShowInstallGuide);
    }
  }

  @override
  void dispose() {
    _foregroundAlertTimer?.cancel();
    _startupAlertTimer?.cancel();
    _notificationTapSub?.cancel();
    _appUpdateSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Decode a notification payload and navigate to the matching screen.
  /// Payload contract (set in AlertScheduler):
  ///   `stock:<code>`  → stock detail page
  ///   `page:watchlist`→ watchlist tab
  ///   `page:recommend`→ recommend tab
  /// Unknown / malformed payloads are ignored (no-op) — never crash on tap.
  void _routeFromPayload(String payload) {
    final ctx = _rootNavigatorKey.currentContext;
    if (ctx == null) return;
    if (payload.startsWith('stock:')) {
      final code = payload.substring('stock:'.length);
      if (code.isNotEmpty) {
        AppRouter.router.go('/stock/$code');
      }
    } else if (payload == 'page:watchlist') {
      AppRouter.router.go('/watchlist');
    } else if (payload == 'page:recommend') {
      AppRouter.router.go('/recommend');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // User came back to the app — run an alert scan immediately. The
      // scheduler coalesces re-entrant calls and de-duplicates per day.
      _runAlertScan();
      // Also run the daily review pass; ReviewScheduler de-duplicates by
      // calendar day so this is cheap when already done today.
      ref.read(reviewSchedulerProvider).runDailyReview();
    }
  }

  void _runAlertScan() {
    // Fire and forget; AlertScheduler swallows per-stock errors and logs them.
    ref.read(alertSchedulerProvider).runScan();
  }

  Future<void> _maybeShowInstallGuide() async {
    if (!mounted) return;
    final platform = ref.read(appPlatformServiceProvider);
    if (!platform.supportsPwa ||
        platform.isStandalone ||
        !platform.isIosSafari) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('pwa_install_guide_seen') ?? false) return;
    await prefs.setBool('pwa_install_guide_seen', true);
    final context = _rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('安装到 iPhone', style: AppTextStyles.h2),
              SizedBox(height: 12),
              Text('点击 Safari 底部的“分享”，然后选择“添加到主屏幕”。'),
              SizedBox(height: 8),
              Text('安装后可从主屏幕独立启动，更新时无需重新安装。'),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdatePrompt() {
    final context = _rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('发现新版本，重新加载后生效'),
        duration: const Duration(days: 1),
        action: SnackBarAction(
          label: '立即更新',
          onPressed: ref.read(appPlatformServiceProvider).applyUpdate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: '股势 TrendStock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      locale: const Locale('zh', 'CN'),
      builder: (context, child) {
        return _DisclaimerWrapper(
          disclaimerAccepted: widget.disclaimerAccepted,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Wrapper that shows risk disclaimer inside MaterialApp context.
class _DisclaimerWrapper extends StatefulWidget {
  final bool disclaimerAccepted;
  final Widget child;

  const _DisclaimerWrapper({
    required this.disclaimerAccepted,
    required this.child,
  });

  @override
  State<_DisclaimerWrapper> createState() => _DisclaimerWrapperState();
}

class _DisclaimerWrapperState extends State<_DisclaimerWrapper> {
  @override
  void initState() {
    super.initState();
    if (!widget.disclaimerAccepted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showRiskDisclaimer();
      });
    }
  }

  Future<void> _showRiskDisclaimer() async {
    final navContext = _rootNavigatorKey.currentContext;
    if (navContext == null) return;
    final accepted = await showDialog<bool>(
      context: navContext,
      barrierDismissible: false,
      builder: (_) => const RiskDisclaimerDialog(),
    );
    if (accepted == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
