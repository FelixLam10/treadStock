import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockpilot/features/hotspot/data/hotspot_scheme_repository.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_filter_scheme.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_models.dart';

void main() {
  late HotspotSchemeRepository repository;
  late DateTime clock;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    clock = DateTime(2026, 10, 9, 9);
    repository = HotspotSchemeRepository(now: () => clock);
  });

  test('新建和编辑保存会递增版本并保留历史快照', () async {
    final draft = HotspotFilterScheme.blank(
      target: HotspotStockMode.active,
      now: clock,
    );

    final first = await repository.saveScheme(draft);
    clock = clock.add(const Duration(minutes: 1));
    final second = await repository.saveScheme(first.copyWith(name: '量价异动'));
    final history = await repository.loadHistory(first.id);

    expect(first.version, 1);
    expect(second.version, 2);
    expect(second.name, '量价异动');
    expect(history.map((item) => item.version), [2, 1]);
  });

  test('有效方案可启用，无效草稿会被拒绝', () async {
    final valid = await repository.saveScheme(
      HotspotFilterScheme.blank(target: HotspotStockMode.leader, now: clock),
    );
    final enabled = await repository.setEnabled(valid.id, true);
    expect(enabled.isEnabled, isTrue);

    final invalid = await repository.saveScheme(
      HotspotFilterScheme.blank(
        target: HotspotStockMode.active,
        now: clock.add(const Duration(seconds: 1)),
      ).copyWith(conditions: const []),
    );
    expect(
      () => repository.setEnabled(invalid.id, true),
      throwsA(isA<HotspotSchemeException>()),
    );
  });

  test('复制、恢复默认、记录运行和删除保持各自语义', () async {
    final source = await repository.saveScheme(
      HotspotFilterScheme.blank(
        target: HotspotStockMode.active,
        now: clock,
      ).copyWith(name: '我的热点方案'),
    );
    clock = clock.add(const Duration(minutes: 1));
    final duplicated = await repository.duplicate(source.id);
    expect(duplicated.id, isNot(source.id));
    expect(duplicated.isEnabled, isFalse);

    final restored = await repository.restoreDefault(source.id);
    expect(restored.conditions, hasLength(4));
    expect(restored.isEnabled, isFalse);

    final versionBeforeRun = restored.version;
    clock = clock.add(const Duration(minutes: 1));
    await repository.recordRun(source.id, 6);
    final afterRun = (await repository.loadSchemes()).firstWhere(
      (item) => item.id == source.id,
    );
    expect(afterRun.version, versionBeforeRun);
    expect(afterRun.lastMatchCount, 6);

    await repository.deleteScheme(duplicated.id);
    expect(
      (await repository.loadSchemes()).map((item) => item.id),
      isNot(contains(duplicated.id)),
    );
    expect(await repository.loadHistory(duplicated.id), isEmpty);
  });
}
