import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import '../../../core/constants/api_constants.dart';
import '../../../shared/providers.dart';
import 'alert_scheduler.dart';
import 'notification_service.dart';
import 'review_scheduler.dart';

const String kAlertScanTaskName = 'stockpilot-alert-scan';
const String kDailyReviewTaskName = 'stockpilot-daily-review';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      switch (taskName) {
        case kAlertScanTaskName:
          await _runBackgroundScan();
          break;
        case kDailyReviewTaskName:
          await _runBackgroundReview();
          break;
        default:
          debugPrint('[Workmanager] unknown task: $taskName');
      }
    } catch (e, st) {
      debugPrint('[Workmanager] task $taskName failed: $e\n$st');
      return false;
    }
    return true;
  });
}

Future<void> _runBackgroundScan() async {
  await NotificationService.instance.init();
  final container = ProviderContainer();
  try {
    final scheduler = AlertScheduler(
      watchlistService: container.read(watchlistServiceProvider),
      apiService: container.read(stockApiServiceProvider),
      analysisEngine: container.read(analysisEngineProvider),
      notificationService: NotificationService.instance,
    );
    await scheduler.runScan();
  } finally {
    container.dispose();
  }
}

Future<void> _runBackgroundReview() async {
  await NotificationService.instance.init();
  final container = ProviderContainer();
  try {
    final scheduler = ReviewScheduler(
      strategyService: container.read(strategyServiceProvider),
      notificationService: NotificationService.instance,
    );
    await scheduler.runDailyReview();
  } finally {
    container.dispose();
  }
}

Future<void> initBackgroundAlerts() async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    debugPrint(
      '[Workmanager] skipped on ${Platform.operatingSystem} (unsupported)',
    );
    return;
  }

  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    kAlertScanTaskName,
    kAlertScanTaskName,
    frequency: Duration(minutes: AppConstants.backgroundTaskIntervalMinutes),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    backoffPolicy: BackoffPolicy.exponential,
  );
  await Workmanager().registerPeriodicTask(
    kDailyReviewTaskName,
    kDailyReviewTaskName,
    frequency: const Duration(hours: 6),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}
