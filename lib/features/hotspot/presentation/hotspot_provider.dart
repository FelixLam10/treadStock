import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers.dart';
import '../data/hotspot_scheme_repository.dart';
import '../data/hotspot_service.dart';
import '../domain/hotspot_filter_scheme.dart';
import '../domain/hotspot_models.dart';
import '../domain/hotspot_ranking_engine.dart';

class HotspotState {
  final HotspotBoardType boardType;
  final HotspotBoardMetric boardMetric;
  final HotspotStockMode stockMode;
  final List<HotspotFilterScheme> schemes;
  final String? selectedSchemeId;
  final List<HotspotBoard> allBoards;
  final List<HotspotBoard> boards;
  final String? selectedBoardCode;
  final List<HotspotCandidate> candidates;
  final List<RankedHotspotStock> rankedStocks;
  final bool isLoadingBoards;
  final bool isLoadingStocks;
  final DateTime? boardsUpdatedAt;
  final DateTime? stocksUpdatedAt;
  final bool boardsFromCache;
  final bool stocksFromCache;
  final String? warning;
  final String? error;

  const HotspotState({
    this.boardType = HotspotBoardType.industry,
    this.boardMetric = HotspotBoardMetric.amount,
    this.stockMode = HotspotStockMode.leader,
    this.schemes = const [],
    this.selectedSchemeId,
    this.allBoards = const [],
    this.boards = const [],
    this.selectedBoardCode,
    this.candidates = const [],
    this.rankedStocks = const [],
    this.isLoadingBoards = false,
    this.isLoadingStocks = false,
    this.boardsUpdatedAt,
    this.stocksUpdatedAt,
    this.boardsFromCache = false,
    this.stocksFromCache = false,
    this.warning,
    this.error,
  });

  HotspotBoard? get selectedBoard {
    for (final board in boards) {
      if (board.code == selectedBoardCode) return board;
    }
    return null;
  }

  bool get hasHistoryData =>
      candidates.any((item) => item.relativeStrength5d != null);

  HotspotFilterScheme? get selectedScheme {
    for (final scheme in schemes) {
      if (scheme.id == selectedSchemeId) return scheme;
    }
    return null;
  }

  HotspotState copyWith({
    HotspotBoardType? boardType,
    HotspotBoardMetric? boardMetric,
    HotspotStockMode? stockMode,
    List<HotspotFilterScheme>? schemes,
    Object? selectedSchemeId = _unchanged,
    List<HotspotBoard>? allBoards,
    List<HotspotBoard>? boards,
    Object? selectedBoardCode = _unchanged,
    List<HotspotCandidate>? candidates,
    List<RankedHotspotStock>? rankedStocks,
    bool? isLoadingBoards,
    bool? isLoadingStocks,
    DateTime? boardsUpdatedAt,
    DateTime? stocksUpdatedAt,
    bool? boardsFromCache,
    bool? stocksFromCache,
    Object? warning = _unchanged,
    Object? error = _unchanged,
  }) => HotspotState(
    boardType: boardType ?? this.boardType,
    boardMetric: boardMetric ?? this.boardMetric,
    stockMode: stockMode ?? this.stockMode,
    schemes: schemes ?? this.schemes,
    selectedSchemeId: identical(selectedSchemeId, _unchanged)
        ? this.selectedSchemeId
        : selectedSchemeId as String?,
    allBoards: allBoards ?? this.allBoards,
    boards: boards ?? this.boards,
    selectedBoardCode: identical(selectedBoardCode, _unchanged)
        ? this.selectedBoardCode
        : selectedBoardCode as String?,
    candidates: candidates ?? this.candidates,
    rankedStocks: rankedStocks ?? this.rankedStocks,
    isLoadingBoards: isLoadingBoards ?? this.isLoadingBoards,
    isLoadingStocks: isLoadingStocks ?? this.isLoadingStocks,
    boardsUpdatedAt: boardsUpdatedAt ?? this.boardsUpdatedAt,
    stocksUpdatedAt: stocksUpdatedAt ?? this.stocksUpdatedAt,
    boardsFromCache: boardsFromCache ?? this.boardsFromCache,
    stocksFromCache: stocksFromCache ?? this.stocksFromCache,
    warning: identical(warning, _unchanged) ? this.warning : warning as String?,
    error: identical(error, _unchanged) ? this.error : error as String?,
  );

  static const _unchanged = Object();
}

class HotspotNotifier extends StateNotifier<HotspotState> {
  final HotspotService service;
  final HotspotRankingEngine rankingEngine;
  final HotspotSchemeRepository schemeRepository;
  int _requestId = 0;

  HotspotNotifier({
    required this.service,
    required this.rankingEngine,
    required this.schemeRepository,
  }) : super(const HotspotState());

  Future<void> load() async {
    final requestId = ++_requestId;
    state = state.copyWith(
      isLoadingBoards: true,
      isLoadingStocks: false,
      warning: null,
      error: null,
    );
    try {
      final schemes = await schemeRepository.loadSchemes();
      if (requestId != _requestId) return;
      final selectedStillValid = schemes.any(
        (item) =>
            item.id == state.selectedSchemeId &&
            item.isEnabled &&
            item.target == state.stockMode,
      );
      state = state.copyWith(
        schemes: schemes,
        selectedSchemeId: selectedStillValid ? state.selectedSchemeId : null,
      );
      final batch = await service.loadBoards(state.boardType);
      if (requestId != _requestId) return;
      final metric = _supportsMetric(batch.data, state.boardMetric)
          ? state.boardMetric
          : HotspotBoardMetric.amount;
      final boards = rankingEngine.rankBoards(batch.data, metric);
      final selectedCode =
          boards.any((item) => item.code == state.selectedBoardCode)
          ? state.selectedBoardCode
          : boards.firstOrNull?.code;
      state = state.copyWith(
        allBoards: batch.data,
        boardMetric: metric,
        boards: boards,
        selectedBoardCode: selectedCode,
        candidates: const [],
        rankedStocks: const [],
        isLoadingBoards: false,
        boardsUpdatedAt: batch.updatedAt,
        boardsFromCache: batch.fromCache,
        warning: batch.warning,
      );
      if (selectedCode != null) {
        await _loadStocks(selectedCode, requestId: requestId);
      }
    } catch (error) {
      if (requestId != _requestId) return;
      state = state.copyWith(isLoadingBoards: false, error: error.toString());
    }
  }

  Future<void> changeBoardType(HotspotBoardType type) async {
    if (type == state.boardType) return;
    state = state.copyWith(
      boardType: type,
      allBoards: const [],
      boards: const [],
      selectedBoardCode: null,
      candidates: const [],
      rankedStocks: const [],
    );
    await load();
  }

  void changeBoardMetric(HotspotBoardMetric metric) {
    if (metric == state.boardMetric ||
        !_supportsMetric(state.allBoards, metric)) {
      return;
    }
    final oldSelectedCode = state.selectedBoardCode;
    final boards = rankingEngine.rankBoards(state.allBoards, metric);
    final selectedCode =
        boards.any((item) => item.code == state.selectedBoardCode)
        ? state.selectedBoardCode
        : boards.firstOrNull?.code;
    state = state.copyWith(
      boardMetric: metric,
      boards: boards,
      selectedBoardCode: selectedCode,
      candidates: selectedCode != oldSelectedCode ? const [] : null,
      rankedStocks: selectedCode != oldSelectedCode ? const [] : null,
    );
    if (selectedCode != null && selectedCode != oldSelectedCode) {
      selectBoard(selectedCode);
    }
  }

  Future<void> selectBoard(String code) async {
    if (code == state.selectedBoardCode && state.candidates.isNotEmpty) return;
    final requestId = ++_requestId;
    state = state.copyWith(
      selectedBoardCode: code,
      candidates: const [],
      rankedStocks: const [],
      error: null,
    );
    await _loadStocks(code, requestId: requestId);
  }

  void changeStockMode(HotspotStockMode mode) {
    if (mode == state.stockMode) return;
    state = state.copyWith(
      stockMode: mode,
      selectedSchemeId: state.selectedScheme?.target == mode
          ? state.selectedSchemeId
          : null,
    );
    state = state.copyWith(rankedStocks: _rankCandidates(state.candidates));
  }

  void selectScheme(String? id) {
    if (id == null) {
      state = state.copyWith(
        selectedSchemeId: null,
        rankedStocks: rankingEngine.rankStocks(
          state.candidates,
          state.stockMode,
        ),
      );
      return;
    }
    final scheme = state.schemes.where((item) => item.id == id).firstOrNull;
    if (scheme == null ||
        !scheme.isEnabled ||
        scheme.target != state.stockMode) {
      return;
    }
    final ranked = rankingEngine.rankWithScheme(state.candidates, scheme);
    state = state.copyWith(selectedSchemeId: id, rankedStocks: ranked);
    schemeRepository.recordRun(id, ranked.length);
  }

  Future<HotspotFilterScheme> saveScheme(HotspotFilterScheme scheme) async {
    final saved = await schemeRepository.saveScheme(scheme);
    await reloadSchemes();
    return saved;
  }

  Future<void> reloadSchemes() async {
    final schemes = await schemeRepository.loadSchemes();
    final selectedStillValid = schemes.any(
      (item) =>
          item.id == state.selectedSchemeId &&
          item.isEnabled &&
          item.target == state.stockMode,
    );
    state = state.copyWith(
      schemes: schemes,
      selectedSchemeId: selectedStillValid ? state.selectedSchemeId : null,
    );
    state = state.copyWith(rankedStocks: _rankCandidates(state.candidates));
  }

  Future<void> setSchemeEnabled(String id, bool enabled) async {
    await schemeRepository.setEnabled(id, enabled);
    await reloadSchemes();
  }

  Future<HotspotFilterScheme> duplicateScheme(String id) async {
    final saved = await schemeRepository.duplicate(id);
    await reloadSchemes();
    return saved;
  }

  Future<void> restoreSchemeDefault(String id) async {
    await schemeRepository.restoreDefault(id);
    await reloadSchemes();
  }

  Future<void> deleteScheme(String id) async {
    await schemeRepository.deleteScheme(id);
    await reloadSchemes();
  }

  Future<List<HotspotSchemeRevision>> loadSchemeHistory(String id) {
    return schemeRepository.loadHistory(id);
  }

  Future<void> _loadStocks(String code, {required int requestId}) async {
    state = state.copyWith(isLoadingStocks: true, error: null);
    try {
      final batch = await service.loadCandidates(code);
      if (requestId != _requestId) return;
      state = state.copyWith(
        candidates: batch.data,
        rankedStocks: _rankCandidates(batch.data),
        isLoadingStocks: false,
        stocksUpdatedAt: batch.updatedAt,
        stocksFromCache: batch.fromCache,
        warning: batch.warning ?? state.warning,
      );
    } catch (error) {
      if (requestId != _requestId) return;
      state = state.copyWith(isLoadingStocks: false, error: error.toString());
    }
  }

  List<RankedHotspotStock> _rankCandidates(List<HotspotCandidate> candidates) {
    final scheme = state.selectedScheme;
    if (scheme != null &&
        scheme.isEnabled &&
        scheme.target == state.stockMode) {
      final ranked = rankingEngine.rankWithScheme(candidates, scheme);
      schemeRepository.recordRun(scheme.id, ranked.length);
      return ranked;
    }
    return rankingEngine.rankStocks(candidates, state.stockMode);
  }

  bool _supportsMetric(List<HotspotBoard> boards, HotspotBoardMetric metric) {
    if (metric == HotspotBoardMetric.amount) return true;
    return boards.any((board) {
      return switch (metric) {
        HotspotBoardMetric.amount => board.amount > 0,
        HotspotBoardMetric.volume => board.volume > 0,
        HotspotBoardMetric.turnover => board.turnover > 0,
        HotspotBoardMetric.changePct => board.changePct != 0,
        HotspotBoardMetric.volumeRatio => board.volumeRatio > 0,
      };
    });
  }
}

final hotspotProvider = StateNotifierProvider<HotspotNotifier, HotspotState>((
  ref,
) {
  return HotspotNotifier(
    service: ref.watch(hotspotServiceProvider),
    rankingEngine: ref.watch(hotspotRankingEngineProvider),
    schemeRepository: ref.watch(hotspotSchemeRepositoryProvider),
  );
});
