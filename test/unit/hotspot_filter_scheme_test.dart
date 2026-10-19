import 'package:flutter_test/flutter_test.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_filter_scheme.dart';
import 'package:stockpilot/features/hotspot/domain/hotspot_models.dart';

void main() {
  group('HotspotFilterScheme', () {
    final now = DateTime(2026, 10, 9, 10);

    test('系统默认和副本具备可复现的完整规则', () {
      final defaults = HotspotFilterScheme.systemDefault(
        HotspotStockMode.leader,
        now: now,
      );
      final copied = HotspotFilterScheme.copyOfDefault(
        HotspotStockMode.leader,
        now: now,
      );

      expect(defaults.validate(), isEmpty);
      expect(defaults.isSystem, isTrue);
      expect(defaults.isEnabled, isTrue);
      expect(copied.isSystem, isFalse);
      expect(copied.isEnabled, isFalse);
      expect(copied.conditions.length, defaults.conditions.length);
      expect(copied.sortWeights.length, defaults.sortWeights.length);
      expect(copied.canEnable, isTrue);
    });

    test('JSON 往返保留条件、权重、版本和运行元数据', () {
      final source =
          HotspotFilterScheme.copyOfDefault(
            HotspotStockMode.active,
            now: now,
          ).copyWith(
            version: 3,
            minPrice: 5,
            maxPrice: 80,
            lastRunAt: now.add(const Duration(hours: 1)),
            lastMatchCount: 7,
          );

      final restored = HotspotFilterScheme.fromJson(source.toJson());

      expect(restored.id, source.id);
      expect(restored.target, HotspotStockMode.active);
      expect(restored.version, 3);
      expect(restored.minPrice, 5);
      expect(restored.maxPrice, 80);
      expect(restored.lastMatchCount, 7);
      expect(restored.conditions.length, source.conditions.length);
    });

    test('草稿校验覆盖名称、区间、权重、数量和价格边界', () {
      final invalid =
          HotspotFilterScheme.blank(
            target: HotspotStockMode.active,
            now: now,
          ).copyWith(
            name: '',
            conditions: const [
              HotspotFilterCondition(
                metric: HotspotFilterMetric.turnover,
                operator: HotspotFilterOperator.between,
                value: 10,
                upperValue: 2,
                group: 0,
              ),
            ],
            sortWeights: const [
              HotspotSortWeight(metric: HotspotFilterMetric.amount, weight: -1),
            ],
            resultLimit: 51,
            minPrice: 20,
            maxPrice: 10,
          );

      expect(invalid.validate(), contains('请填写方案名称'));
      expect(invalid.validate(), contains('换手率区间上限不能小于下限'));
      expect(invalid.validate(), contains('条件组编号必须从 1 开始'));
      expect(invalid.validate(), contains('排序权重不能为负数或无效数字'));
      expect(invalid.validate(), contains('返回数量必须在1到50之间'));
      expect(invalid.validate(), contains('最高价格不能低于最低价格'));
      expect(invalid.canEnable, isFalse);
    });
  });
}
