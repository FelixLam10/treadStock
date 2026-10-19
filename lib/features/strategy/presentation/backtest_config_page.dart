import 'package:flutter/material.dart';
import 'package:stockpilot/core/theme/app_semantic_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/toast_helper.dart';
import '../../../shared/widgets/app_bottom_navigation.dart';
import '../../stock/domain/stock_models.dart';
import '../../stock/data/stock_api_service.dart';
import '../domain/backtest_models.dart';
import '../domain/strategy_knowledge_package.dart';
import '../../../shared/providers.dart';
import 'backtest_provider.dart';
import 'backtest_result_page.dart';

/// Page to configure and run a strategy backtest.
class BacktestConfigPage extends ConsumerStatefulWidget {
  final String strategyId;
  final String strategyName;
  final String? initialStockCode;
  final String? initialStockName;
  final String? initialMarket;
  final String? initialStrategyVersionId;

  const BacktestConfigPage({
    super.key,
    required this.strategyId,
    required this.strategyName,
    this.initialStockCode,
    this.initialStockName,
    this.initialMarket,
    this.initialStrategyVersionId,
  });

  @override
  ConsumerState<BacktestConfigPage> createState() => _BacktestConfigPageState();
}

class _BacktestConfigPageState extends ConsumerState<BacktestConfigPage> {
  final _searchController = TextEditingController();
  final _apiService = StockApiService();
  List<StockSearchResult> _searchResults = [];
  StockSearchResult? _selectedStock;
  bool _isSearching = false;

  double _initialCapital = 100000;
  double _positionSize = 1.0;
  double _stopLoss = -5.0;
  double _takeProfit = 15.0;
  bool _isRunning = false;
  bool _versionsLoading = true;
  List<StrategyVersionInfo> _versions = const [];
  String? _selectedVersionId;

  @override
  void initState() {
    super.initState();
    if (widget.initialStockCode?.isNotEmpty == true) {
      _selectedStock = StockSearchResult(
        code: widget.initialStockCode!,
        name: widget.initialStockName ?? widget.initialStockCode!,
        market: widget.initialMarket ?? 'SH',
      );
    }
    _loadVersions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.sc.bgPrimary,
      body: ListView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 80,
        ),
        children: [
          _buildHeader(),
          _buildVersionSelector(),
          _buildStockSelector(),
          if (_selectedStock != null) ...[
            _buildConfigSection(),
            _buildRunButton(),
          ],
        ],
      ),
    );
  }

  Future<void> _loadVersions() async {
    final service = ref.read(strategyServiceProvider);
    await service.init();
    final versions = await service.getStrategyVersions(widget.strategyId);
    if (!mounted) return;
    final requested = versions
        .where((version) => version.id == widget.initialStrategyVersionId)
        .firstOrNull;
    final active = versions
        .where((version) => version.status == 'active')
        .firstOrNull;
    setState(() {
      _versions = versions;
      _selectedVersionId = (requested ?? active ?? versions.firstOrNull)?.id;
      _versionsLoading = false;
    });
  }

  Widget _buildVersionSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        16,
        AppTheme.pagePadding,
        0,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.sc.bgSecondary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('策略版本', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          if (_versionsLoading)
            const LinearProgressIndicator(minHeight: 2)
          else if (_versions.isEmpty)
            Text('暂无可回测版本', style: AppTextStyles.caption)
          else
            DropdownButtonFormField<String>(
              initialValue: _selectedVersionId,
              decoration: const InputDecoration(isDense: true),
              items: _versions
                  .map(
                    (version) => DropdownMenuItem(
                      value: version.id,
                      child: Text(
                        'v${version.versionNumber} · ${_versionStatusLabel(version.status)}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedVersionId = value),
            ),
          const SizedBox(height: 6),
          Text(
            '候选版本也可回测，但不会因此自动启用。',
            style: AppTextStyles.micro.copyWith(color: context.sc.textTertiary),
          ),
        ],
      ),
    );
  }

  String _versionStatusLabel(String status) => switch (status) {
    'active' => '当前使用',
    'candidate' => '候选版本',
    'archived' => '历史版本',
    _ => '草稿',
  };

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, AppTheme.pagePadding, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: context.sc.gray700,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
                const Spacer(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.pagePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('策略回测', style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  Text(
                    '策略：${widget.strategyName}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        16,
        AppTheme.pagePadding,
        0,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.sc.bgSecondary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('选择股票', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '输入股票代码或名称搜索',
              hintStyle: AppTextStyles.caption.copyWith(
                color: context.sc.textTertiary,
              ),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _isSearching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              filled: true,
              fillColor: context.sc.bgPrimary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              isDense: true,
            ),
            style: AppTextStyles.body,
            onChanged: _onSearchChanged,
          ),
          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 8),
            ..._searchResults.take(5).map(_buildSearchResultItem),
          ],
          if (_selectedStock != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: StockColors.brand.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: StockColors.brand,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_selectedStock!.name} (${_selectedStock!.fullCode})',
                    style: AppTextStyles.body.copyWith(
                      color: StockColors.brand,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _selectedStock = null),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: context.sc.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(StockSearchResult result) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStock = result;
          _searchResults = [];
          _searchController.clear();
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(result.name, style: AppTextStyles.body),
            const Spacer(),
            Text(
              result.fullCode,
              style: AppTextStyles.caption.copyWith(
                color: context.sc.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        12,
        AppTheme.pagePadding,
        0,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.sc.bgSecondary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('回测参数', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          _configRow(
            '初始资金',
            '${(_initialCapital / 10000).toStringAsFixed(1)}万',
            _initialCapital,
            10000,
            1000000,
            (v) => setState(() => _initialCapital = v),
          ),
          _configRow(
            '仓位比例',
            '${(_positionSize * 100).toStringAsFixed(0)}%',
            _positionSize,
            0.1,
            1.0,
            (v) => setState(() => _positionSize = v),
            divisions: 9,
          ),
          _configRow(
            '止损',
            '${_stopLoss.toStringAsFixed(1)}%',
            _stopLoss.abs(),
            1,
            20,
            (v) => setState(() => _stopLoss = -v),
          ),
          _configRow(
            '止盈',
            '${_takeProfit.toStringAsFixed(1)}%',
            _takeProfit,
            1,
            50,
            (v) => setState(() => _takeProfit = v),
          ),
          const SizedBox(height: 6),
          Text(
            '固定口径：前复权 · 单边佣金 0.03% · 卖出印花税 0.10% · 滑点 0 元/股',
            style: AppTextStyles.micro.copyWith(color: context.sc.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _configRow(
    String label,
    String value,
    double current,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int? divisions,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.body),
              Text(value, style: AppTextStyles.numberSm),
            ],
          ),
          Slider(
            value: current,
            min: min,
            max: max,
            divisions: divisions ?? ((max - min).toInt()),
            activeColor: StockColors.brand,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildRunButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        20,
        AppTheme.pagePadding,
        0,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _isRunning || _selectedVersionId == null
              ? null
              : _runBacktest,
          style: ElevatedButton.styleFrom(
            backgroundColor: StockColors.brand,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
          ),
          child: _isRunning
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  '开始回测',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await _apiService.searchStock(query);
      if (mounted) {
        setState(() {
          _searchResults = results.take(10).toList();
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _runBacktest() async {
    if (_selectedStock == null) return;
    setState(() => _isRunning = true);

    final market = _selectedStock!.market;
    ref.read(backtestProvider.notifier).reset();

    await ref
        .read(backtestProvider.notifier)
        .runBacktest(
          strategyId: widget.strategyId,
          stockCode: _selectedStock!.code,
          stockName: _selectedStock!.name,
          market: market,
          strategyVersionId: _selectedVersionId,
          config: BacktestConfig(
            initialCapital: _initialCapital,
            positionSize: _positionSize,
            stopLossPct: _stopLoss / 100,
            takeProfitPct: _takeProfit / 100,
          ),
        );

    if (!mounted) return;
    setState(() => _isRunning = false);

    final state = ref.read(backtestProvider);
    if (state.status == BacktestStatus.done && state.report != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PersistentNavigationPage(
            sectionIndex: 3,
            child: BacktestResultPage(
              report: state.report!,
              comparison: state.comparison,
            ),
          ),
        ),
      );
    } else if (state.status == BacktestStatus.error) {
      if (mounted) {
        ToastHelper.showError(context, state.errorMessage ?? '回测失败');
      }
    }
  }
}
