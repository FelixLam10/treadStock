import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers.dart';
import '../domain/strategy_knowledge_package.dart';

final strategyVersionsProvider = FutureProvider.autoDispose
    .family<List<StrategyVersionInfo>, String>((ref, strategyId) async {
      final service = ref.watch(strategyServiceProvider);
      await service.init();
      return service.getStrategyVersions(strategyId);
    });
