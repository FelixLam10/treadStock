import 'dart:async';
import 'package:stockpilot/core/theme/app_semantic_colors.dart';
import 'package:stockpilot/shared/widgets/app_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/stock_list_item.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/toast_helper.dart';
import '../../../shared/widgets/disclaimer_label.dart';
import 'watchlist_provider.dart';

/// Watchlist tab (Tab 2) with search, swipe actions (delete/pin).
/// Design: DESIGN.md Page 2 - Watchlist Page.
class WatchlistTab extends ConsumerStatefulWidget {
  const WatchlistTab({super.key});

  @override
  ConsumerState<WatchlistTab> createState() => _WatchlistTabState();
}

class _WatchlistTabState extends ConsumerState<WatchlistTab> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
    Future.microtask(() {
      ref.read(watchlistProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(watchlistProvider.notifier).searchStock(value);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(watchlistProvider.notifier).searchStock('');
    _searchFocusNode.unfocus();
    setState(() {});
  }

  /// Toggle a search result in the watchlist without clearing the search.
  Future<void> _handleToggleSearchResult(
    WatchlistNotifier notifier,
    String code,
    String name,
    String market,
  ) async {
    final result = await notifier.toggleWatchlist(code, name, market);
    if (!mounted) return;

    switch (result) {
      case WatchlistToggleResult.added:
        ToastHelper.showSuccess(context, '已添加$name到关注列表');
        break;
      case WatchlistToggleResult.removed:
        ToastHelper.showWithAction(
          context,
          '已取消关注$name',
          actionText: '撤销',
          onAction: () async {
            final undoResult = await notifier.toggleWatchlist(
              code,
              name,
              market,
            );
            if (!mounted) return;
            if (undoResult == WatchlistToggleResult.added) {
              ToastHelper.showSuccess(context, '已恢复关注$name');
            } else {
              ToastHelper.showError(context, '恢复关注失败，请重试');
            }
          },
        );
        break;
      case WatchlistToggleResult.failed:
        ToastHelper.showError(context, '操作失败，请重试');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(watchlistProvider);
    final notifier = ref.read(watchlistProvider.notifier);
    // Reactive watched codes for search result status
    final watchedCodes = ref.watch(watchedCodesProvider);
    final showSearchPanel =
        _isSearchFocused ||
        _searchController.text.isNotEmpty ||
        state.isSearching ||
        state.hasSearchError;

    return Scaffold(
      backgroundColor: context.sc.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Title + theme switcher
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pagePadding,
                12,
                AppTheme.pagePadding,
                8,
              ),
              child: Row(
                children: [
                  Text('关注', style: AppTextStyles.h1),
                  const Spacer(),
                  const AppMenuButton(),
                ],
              ),
            ),

            // Search bar
            _buildSearchBar(state, notifier),

            // Watchlist
            Expanded(
              child: showSearchPanel
                  ? _buildSearchResults(state, notifier, watchedCodes)
                  : state.isEmpty
                  ? _buildEmptyState()
                  : _buildWatchList(state, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(WatchlistState state, WatchlistNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: AppTheme.searchBarHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: _isSearchFocused
                      ? context.sc.borderActive
                      : context.sc.borderFocus,
                  width: 1,
                ),
                boxShadow: _isSearchFocused
                    ? [
                        const BoxShadow(
                          color: StockColors.shadow,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.text,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onTap: () {
                    _searchFocusNode.requestFocus();
                    setState(() {});
                  },
                  onChanged: _onSearchChanged,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(fontSize: 14, color: context.sc.textPrimary),
                  decoration: InputDecoration(
                    hintText: '搜索股票代码或名称',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: context.sc.gray400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: _isSearchFocused
                          ? StockColors.brand
                          : context.sc.gray500,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: _clearSearch,
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: context.sc.gray500,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    WatchlistState state,
    WatchlistNotifier notifier,
    Set<String> watchedCodes,
  ) {
    if (state.isSearching) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: StockColors.brand,
          ),
        ),
      );
    }

    if (_searchController.text.isEmpty && !state.hasSearchError) {
      return EmptyState(
        icon: Icons.search,
        title: '搜索股票',
        subtitle: '输入股票代码或名称添加关注',
      );
    }

    if (state.hasSearchError) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
        alignment: Alignment.center,
        child: Text(
          state.searchError ?? '搜索服务暂不可用，请稍后重试',
          style: AppTextStyles.body.copyWith(color: context.sc.gray500),
        ),
      );
    }

    final results = state.searchResults;
    if (results.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
        alignment: Alignment.center,
        child: Text(
          '未找到匹配股票',
          style: TextStyle(fontSize: 13, color: context.sc.gray500),
        ),
      );
    }

    return ListView.separated(
      itemCount: results.length + 1,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: context.sc.border,
        indent: AppTheme.pagePadding,
        endIndent: AppTheme.pagePadding,
      ),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.pagePadding,
              4,
              AppTheme.pagePadding,
              8,
            ),
            child: Text(
              '点击右侧按钮可关注或取消关注',
              style: AppTextStyles.caption.copyWith(
                color: context.sc.textTertiary,
              ),
            ),
          );
        }

        final result = results[index - 1];
        // Use reactive watchedCodes instead of notifier.isWatched
        final isWatched = watchedCodes.contains(result.code);
        final isMutating = state.isAdding && state.addingCode == result.code;

        return InkWell(
          key: ValueKey('search-watch-toggle-${result.code}'),
          onTap: isMutating
              ? null
              : () => _handleToggleSearchResult(
                  notifier,
                  result.code,
                  result.name,
                  result.market,
                ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.pagePadding,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: context.sc.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.name, style: AppTextStyles.bodyLg),
                      const SizedBox(height: 2),
                      Text(
                        '${result.code} ${result.displayMarket}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isMutating)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: StockColors.brand,
                    ),
                  )
                else if (isWatched)
                  AnimatedContainer(
                    duration: AppTheme.fastDuration,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: StockColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Text(
                      '取消关注',
                      style: TextStyle(
                        fontSize: 13,
                        color: StockColors.danger,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: StockColors.brand.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Text(
                      '关注',
                      style: TextStyle(
                        fontSize: 13,
                        color: StockColors.brand,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.search,
      title: '暂无关注的股票',
      subtitle: '搜索添加你感兴趣的股票',
    );
  }

  Widget _buildWatchList(WatchlistState state, WatchlistNotifier notifier) {
    return RefreshIndicator(
      color: StockColors.brand,
      onRefresh: () => notifier.refreshAll(),
      child: ListView.builder(
        itemCount: state.items.length + 1, // +1 for disclaimer
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Column(
              children: [DisclaimerLabel(), SizedBox(height: 64)],
            );
          }

          final item = state.items[index];
          final bestStrategy = state.bestStrategies[item.stockCode];
          return Slidable(
            key: ValueKey(item.id),
            startActionPane: ActionPane(
              motion: const BehindMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) async {
                    await notifier.togglePin(item.id, !item.isPinned);
                    if (!mounted) return;
                    ToastHelper.showSuccess(
                      this.context,
                      item.isPinned
                          ? '已取消置顶${item.stockName}'
                          : '已置顶${item.stockName}',
                    );
                  },
                  backgroundColor: item.isPinned
                      ? context.sc.gray500
                      : StockColors.pin,
                  foregroundColor: Colors.white,
                  label: item.isPinned ? '取消置顶' : '置顶',
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const BehindMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) async {
                    // Snapshot before removal so the user can undo.
                    final snapshot = (
                      id: item.id,
                      code: item.stockCode,
                      name: item.stockName,
                      market: item.market,
                    );
                    await notifier.removeFromWatchlist(item.id);
                    if (!mounted) return;
                    ToastHelper.showWithAction(
                      this.context,
                      '已移除${item.stockName}',
                      actionText: '撤销',
                      onAction: () async {
                        await ref
                            .read(watchlistProvider.notifier)
                            .addToWatchlist(
                              snapshot.code,
                              snapshot.name,
                              snapshot.market,
                            );
                      },
                    );
                  },
                  backgroundColor: StockColors.danger,
                  foregroundColor: Colors.white,
                  label: '移除',
                ),
              ],
            ),
            child: StockListItem(
              name: item.stockName,
              code: item.stockCode,
              market: item.market,
              price: item.currentPrice ?? 0,
              changePct: item.currentChangePct ?? 0,
              score: item.currentScore?.score,
              isBandLow: item.currentScore?.isBandLow ?? false,
              isPinned: item.isPinned,
              isAlertTriggered: item.isAlertTriggered ?? false,
              expectedRange: item.isPinned ? _formatRange(item) : null,
              strategyName: bestStrategy?.strategyName,
              scoreReason: bestStrategy?.displayReason,
              riskText: bestStrategy == null ? null : '仅供参考',
              onTap: () => context.push(
                '/stock/${item.stockCode}',
                extra: {
                  'code': item.stockCode,
                  'name': item.stockName,
                  'market': item.market,
                  'strategyId': bestStrategy?.strategyId,
                  'strategyName': bestStrategy?.strategyName,
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // TODO(stage2): populate once K-line / Bollinger band data is wired into the
  // watchlist item. Currently returns null, so expected range is never shown.
  String? _formatRange(dynamic item) {
    return null;
  }
}
