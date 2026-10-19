import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/hotspot_filter_scheme.dart';

class HotspotSchemeRepository {
  static const _schemesKey = 'hotspot_filter_schemes_v1';
  static const _historyKey = 'hotspot_filter_scheme_history_v1';

  final Future<SharedPreferences> Function() _preferences;
  final DateTime Function() _now;

  const HotspotSchemeRepository({
    Future<SharedPreferences> Function()? preferences,
    DateTime Function()? now,
  }) : _preferences = preferences ?? SharedPreferences.getInstance,
       _now = now ?? DateTime.now;

  Future<List<HotspotFilterScheme>> loadSchemes() async {
    try {
      final prefs = await _preferences();
      final raw = prefs.getString(_schemesKey);
      if (raw == null) return <HotspotFilterScheme>[];
      final decoded = jsonDecode(raw) as List<dynamic>;
      final schemes =
          decoded
              .map(
                (item) =>
                    HotspotFilterScheme.fromJson(item as Map<String, dynamic>),
              )
              .where((item) => !item.isSystem)
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return schemes;
    } catch (_) {
      return <HotspotFilterScheme>[];
    }
  }

  Future<HotspotFilterScheme> saveScheme(HotspotFilterScheme input) async {
    if (input.isSystem) {
      throw const HotspotSchemeException('系统默认方案只读，请先复制后修改');
    }
    final schemes = await loadSchemes();
    final index = schemes.indexWhere((item) => item.id == input.id);
    final timestamp = _now();
    final saved = input.copyWith(
      version: index < 0 ? 1 : schemes[index].version + 1,
      createdAt: index < 0 ? input.createdAt : schemes[index].createdAt,
      updatedAt: timestamp,
      isSystem: false,
    );
    if (index < 0) {
      schemes.add(saved);
    } else {
      schemes[index] = saved;
    }
    await _writeSchemes(schemes);
    await _appendRevision(saved);
    return saved;
  }

  Future<HotspotFilterScheme> setEnabled(String id, bool enabled) async {
    final schemes = await loadSchemes();
    final index = schemes.indexWhere((item) => item.id == id);
    if (index < 0) throw const HotspotSchemeException('未找到该筛选方案');
    final current = schemes[index];
    if (enabled && !current.canEnable) {
      throw HotspotSchemeException(current.validate().join('；'));
    }
    return saveScheme(current.copyWith(isEnabled: enabled));
  }

  Future<HotspotFilterScheme> duplicate(String id) async {
    final schemes = await loadSchemes();
    final source = schemes.where((item) => item.id == id).firstOrNull;
    if (source == null) throw const HotspotSchemeException('未找到待复制方案');
    final timestamp = _now();
    return saveScheme(
      source.copyWith(
        id: 'hotspot_${timestamp.microsecondsSinceEpoch}',
        name: '${source.name}（副本）',
        isEnabled: false,
        version: 1,
        createdAt: timestamp,
        updatedAt: timestamp,
        lastRunAt: null,
        lastMatchCount: null,
      ),
    );
  }

  Future<HotspotFilterScheme> restoreDefault(String id) async {
    final schemes = await loadSchemes();
    final current = schemes.where((item) => item.id == id).firstOrNull;
    if (current == null) throw const HotspotSchemeException('未找到待恢复方案');
    final defaults = HotspotFilterScheme.systemDefault(current.target);
    return saveScheme(
      current.copyWith(
        logic: defaults.logic,
        conditions: defaults.conditions,
        sortWeights: defaults.sortWeights,
        resultLimit: defaults.resultLimit,
        excludeRiskWarnings: defaults.excludeRiskWarnings,
        excludeSuspended: defaults.excludeSuspended,
        minPrice: null,
        maxPrice: null,
        isEnabled: false,
      ),
    );
  }

  Future<void> deleteScheme(String id) async {
    final schemes = await loadSchemes();
    schemes.removeWhere((item) => item.id == id);
    await _writeSchemes(schemes);
    await _deleteHistory(id);
  }

  Future<void> recordRun(String id, int matchCount) async {
    final schemes = await loadSchemes();
    final index = schemes.indexWhere((item) => item.id == id);
    if (index < 0) return;
    schemes[index] = schemes[index].copyWith(
      lastRunAt: _now(),
      lastMatchCount: matchCount,
    );
    // Run metadata is not a rule change, so do not bump version/history.
    await _writeSchemes(schemes);
  }

  Future<List<HotspotSchemeRevision>> loadHistory(String id) async {
    try {
      final prefs = await _preferences();
      final raw = prefs.getString(_historyKey);
      if (raw == null) return const [];
      final root = jsonDecode(raw) as Map<String, dynamic>;
      final rows = root[id] as List<dynamic>? ?? const [];
      final history =
          rows
              .map(
                (item) => HotspotSchemeRevision.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList()
            ..sort((a, b) => b.version.compareTo(a.version));
      return history;
    } catch (_) {
      return const [];
    }
  }

  Future<void> _writeSchemes(List<HotspotFilterScheme> schemes) async {
    final prefs = await _preferences();
    await prefs.setString(
      _schemesKey,
      jsonEncode(schemes.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> _appendRevision(HotspotFilterScheme scheme) async {
    final prefs = await _preferences();
    Map<String, dynamic> root;
    try {
      root =
          jsonDecode(prefs.getString(_historyKey) ?? '{}')
              as Map<String, dynamic>;
    } catch (_) {
      root = {};
    }
    final rows = List<dynamic>.from(
      root[scheme.id] as List<dynamic>? ?? const [],
    );
    rows.add(
      HotspotSchemeRevision(
        version: scheme.version,
        savedAt: scheme.updatedAt,
        snapshot: scheme,
      ).toJson(),
    );
    // Keep history bounded on device.
    root[scheme.id] = rows.length > 30 ? rows.sublist(rows.length - 30) : rows;
    await prefs.setString(_historyKey, jsonEncode(root));
  }

  Future<void> _deleteHistory(String id) async {
    final prefs = await _preferences();
    try {
      final root =
          jsonDecode(prefs.getString(_historyKey) ?? '{}')
              as Map<String, dynamic>;
      if (root.remove(id) != null) {
        await prefs.setString(_historyKey, jsonEncode(root));
      }
    } catch (_) {
      // Corrupt history must not prevent deleting the active scheme.
    }
  }
}

class HotspotSchemeException implements Exception {
  final String message;
  const HotspotSchemeException(this.message);

  @override
  String toString() => message;
}
