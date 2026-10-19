// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WatchlistItemsTable extends WatchlistItems
    with TableInfo<$WatchlistItemsTable, WatchlistRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchlistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockCodeMeta = const VerificationMeta(
    'stockCode',
  );
  @override
  late final GeneratedColumn<String> stockCode = GeneratedColumn<String>(
    'stock_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockNameMeta = const VerificationMeta(
    'stockName',
  );
  @override
  late final GeneratedColumn<String> stockName = GeneratedColumn<String>(
    'stock_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('SH'),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _alertEnabledMeta = const VerificationMeta(
    'alertEnabled',
  );
  @override
  late final GeneratedColumn<bool> alertEnabled = GeneratedColumn<bool>(
    'alert_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("alert_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _alertPriceThresholdMeta =
      const VerificationMeta('alertPriceThreshold');
  @override
  late final GeneratedColumn<double> alertPriceThreshold =
      GeneratedColumn<double>(
        'alert_price_threshold',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _alertTriggeredDateMeta =
      const VerificationMeta('alertTriggeredDate');
  @override
  late final GeneratedColumn<String> alertTriggeredDate =
      GeneratedColumn<String>(
        'alert_triggered_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stockCode,
    stockName,
    market,
    isPinned,
    sortOrder,
    alertEnabled,
    alertPriceThreshold,
    alertTriggeredDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watchlist_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchlistRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('stock_code')) {
      context.handle(
        _stockCodeMeta,
        stockCode.isAcceptableOrUnknown(data['stock_code']!, _stockCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_stockCodeMeta);
    }
    if (data.containsKey('stock_name')) {
      context.handle(
        _stockNameMeta,
        stockName.isAcceptableOrUnknown(data['stock_name']!, _stockNameMeta),
      );
    } else if (isInserting) {
      context.missing(_stockNameMeta);
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('alert_enabled')) {
      context.handle(
        _alertEnabledMeta,
        alertEnabled.isAcceptableOrUnknown(
          data['alert_enabled']!,
          _alertEnabledMeta,
        ),
      );
    }
    if (data.containsKey('alert_price_threshold')) {
      context.handle(
        _alertPriceThresholdMeta,
        alertPriceThreshold.isAcceptableOrUnknown(
          data['alert_price_threshold']!,
          _alertPriceThresholdMeta,
        ),
      );
    }
    if (data.containsKey('alert_triggered_date')) {
      context.handle(
        _alertTriggeredDateMeta,
        alertTriggeredDate.isAcceptableOrUnknown(
          data['alert_triggered_date']!,
          _alertTriggeredDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchlistRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchlistRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      stockCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_code'],
      )!,
      stockName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_name'],
      )!,
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      alertEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}alert_enabled'],
      )!,
      alertPriceThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}alert_price_threshold'],
      ),
      alertTriggeredDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_triggered_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WatchlistItemsTable createAlias(String alias) {
    return $WatchlistItemsTable(attachedDatabase, alias);
  }
}

class WatchlistRow extends DataClass implements Insertable<WatchlistRow> {
  final String id;
  final String stockCode;
  final String stockName;
  final String market;
  final bool isPinned;
  final int sortOrder;
  final bool alertEnabled;
  final double? alertPriceThreshold;
  final String? alertTriggeredDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WatchlistRow({
    required this.id,
    required this.stockCode,
    required this.stockName,
    required this.market,
    required this.isPinned,
    required this.sortOrder,
    required this.alertEnabled,
    this.alertPriceThreshold,
    this.alertTriggeredDate,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['stock_code'] = Variable<String>(stockCode);
    map['stock_name'] = Variable<String>(stockName);
    map['market'] = Variable<String>(market);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['sort_order'] = Variable<int>(sortOrder);
    map['alert_enabled'] = Variable<bool>(alertEnabled);
    if (!nullToAbsent || alertPriceThreshold != null) {
      map['alert_price_threshold'] = Variable<double>(alertPriceThreshold);
    }
    if (!nullToAbsent || alertTriggeredDate != null) {
      map['alert_triggered_date'] = Variable<String>(alertTriggeredDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WatchlistItemsCompanion toCompanion(bool nullToAbsent) {
    return WatchlistItemsCompanion(
      id: Value(id),
      stockCode: Value(stockCode),
      stockName: Value(stockName),
      market: Value(market),
      isPinned: Value(isPinned),
      sortOrder: Value(sortOrder),
      alertEnabled: Value(alertEnabled),
      alertPriceThreshold: alertPriceThreshold == null && nullToAbsent
          ? const Value.absent()
          : Value(alertPriceThreshold),
      alertTriggeredDate: alertTriggeredDate == null && nullToAbsent
          ? const Value.absent()
          : Value(alertTriggeredDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WatchlistRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchlistRow(
      id: serializer.fromJson<String>(json['id']),
      stockCode: serializer.fromJson<String>(json['stockCode']),
      stockName: serializer.fromJson<String>(json['stockName']),
      market: serializer.fromJson<String>(json['market']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      alertEnabled: serializer.fromJson<bool>(json['alertEnabled']),
      alertPriceThreshold: serializer.fromJson<double?>(
        json['alertPriceThreshold'],
      ),
      alertTriggeredDate: serializer.fromJson<String?>(
        json['alertTriggeredDate'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'stockCode': serializer.toJson<String>(stockCode),
      'stockName': serializer.toJson<String>(stockName),
      'market': serializer.toJson<String>(market),
      'isPinned': serializer.toJson<bool>(isPinned),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'alertEnabled': serializer.toJson<bool>(alertEnabled),
      'alertPriceThreshold': serializer.toJson<double?>(alertPriceThreshold),
      'alertTriggeredDate': serializer.toJson<String?>(alertTriggeredDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WatchlistRow copyWith({
    String? id,
    String? stockCode,
    String? stockName,
    String? market,
    bool? isPinned,
    int? sortOrder,
    bool? alertEnabled,
    Value<double?> alertPriceThreshold = const Value.absent(),
    Value<String?> alertTriggeredDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WatchlistRow(
    id: id ?? this.id,
    stockCode: stockCode ?? this.stockCode,
    stockName: stockName ?? this.stockName,
    market: market ?? this.market,
    isPinned: isPinned ?? this.isPinned,
    sortOrder: sortOrder ?? this.sortOrder,
    alertEnabled: alertEnabled ?? this.alertEnabled,
    alertPriceThreshold: alertPriceThreshold.present
        ? alertPriceThreshold.value
        : this.alertPriceThreshold,
    alertTriggeredDate: alertTriggeredDate.present
        ? alertTriggeredDate.value
        : this.alertTriggeredDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WatchlistRow copyWithCompanion(WatchlistItemsCompanion data) {
    return WatchlistRow(
      id: data.id.present ? data.id.value : this.id,
      stockCode: data.stockCode.present ? data.stockCode.value : this.stockCode,
      stockName: data.stockName.present ? data.stockName.value : this.stockName,
      market: data.market.present ? data.market.value : this.market,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      alertEnabled: data.alertEnabled.present
          ? data.alertEnabled.value
          : this.alertEnabled,
      alertPriceThreshold: data.alertPriceThreshold.present
          ? data.alertPriceThreshold.value
          : this.alertPriceThreshold,
      alertTriggeredDate: data.alertTriggeredDate.present
          ? data.alertTriggeredDate.value
          : this.alertTriggeredDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistRow(')
          ..write('id: $id, ')
          ..write('stockCode: $stockCode, ')
          ..write('stockName: $stockName, ')
          ..write('market: $market, ')
          ..write('isPinned: $isPinned, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('alertEnabled: $alertEnabled, ')
          ..write('alertPriceThreshold: $alertPriceThreshold, ')
          ..write('alertTriggeredDate: $alertTriggeredDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    stockCode,
    stockName,
    market,
    isPinned,
    sortOrder,
    alertEnabled,
    alertPriceThreshold,
    alertTriggeredDate,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchlistRow &&
          other.id == this.id &&
          other.stockCode == this.stockCode &&
          other.stockName == this.stockName &&
          other.market == this.market &&
          other.isPinned == this.isPinned &&
          other.sortOrder == this.sortOrder &&
          other.alertEnabled == this.alertEnabled &&
          other.alertPriceThreshold == this.alertPriceThreshold &&
          other.alertTriggeredDate == this.alertTriggeredDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WatchlistItemsCompanion extends UpdateCompanion<WatchlistRow> {
  final Value<String> id;
  final Value<String> stockCode;
  final Value<String> stockName;
  final Value<String> market;
  final Value<bool> isPinned;
  final Value<int> sortOrder;
  final Value<bool> alertEnabled;
  final Value<double?> alertPriceThreshold;
  final Value<String?> alertTriggeredDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WatchlistItemsCompanion({
    this.id = const Value.absent(),
    this.stockCode = const Value.absent(),
    this.stockName = const Value.absent(),
    this.market = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.alertEnabled = const Value.absent(),
    this.alertPriceThreshold = const Value.absent(),
    this.alertTriggeredDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchlistItemsCompanion.insert({
    required String id,
    required String stockCode,
    required String stockName,
    this.market = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.alertEnabled = const Value.absent(),
    this.alertPriceThreshold = const Value.absent(),
    this.alertTriggeredDate = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       stockCode = Value(stockCode),
       stockName = Value(stockName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WatchlistRow> custom({
    Expression<String>? id,
    Expression<String>? stockCode,
    Expression<String>? stockName,
    Expression<String>? market,
    Expression<bool>? isPinned,
    Expression<int>? sortOrder,
    Expression<bool>? alertEnabled,
    Expression<double>? alertPriceThreshold,
    Expression<String>? alertTriggeredDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stockCode != null) 'stock_code': stockCode,
      if (stockName != null) 'stock_name': stockName,
      if (market != null) 'market': market,
      if (isPinned != null) 'is_pinned': isPinned,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (alertEnabled != null) 'alert_enabled': alertEnabled,
      if (alertPriceThreshold != null)
        'alert_price_threshold': alertPriceThreshold,
      if (alertTriggeredDate != null)
        'alert_triggered_date': alertTriggeredDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchlistItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? stockCode,
    Value<String>? stockName,
    Value<String>? market,
    Value<bool>? isPinned,
    Value<int>? sortOrder,
    Value<bool>? alertEnabled,
    Value<double?>? alertPriceThreshold,
    Value<String?>? alertTriggeredDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WatchlistItemsCompanion(
      id: id ?? this.id,
      stockCode: stockCode ?? this.stockCode,
      stockName: stockName ?? this.stockName,
      market: market ?? this.market,
      isPinned: isPinned ?? this.isPinned,
      sortOrder: sortOrder ?? this.sortOrder,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      alertPriceThreshold: alertPriceThreshold ?? this.alertPriceThreshold,
      alertTriggeredDate: alertTriggeredDate ?? this.alertTriggeredDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (stockCode.present) {
      map['stock_code'] = Variable<String>(stockCode.value);
    }
    if (stockName.present) {
      map['stock_name'] = Variable<String>(stockName.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (alertEnabled.present) {
      map['alert_enabled'] = Variable<bool>(alertEnabled.value);
    }
    if (alertPriceThreshold.present) {
      map['alert_price_threshold'] = Variable<double>(
        alertPriceThreshold.value,
      );
    }
    if (alertTriggeredDate.present) {
      map['alert_triggered_date'] = Variable<String>(alertTriggeredDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistItemsCompanion(')
          ..write('id: $id, ')
          ..write('stockCode: $stockCode, ')
          ..write('stockName: $stockName, ')
          ..write('market: $market, ')
          ..write('isPinned: $isPinned, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('alertEnabled: $alertEnabled, ')
          ..write('alertPriceThreshold: $alertPriceThreshold, ')
          ..write('alertTriggeredDate: $alertTriggeredDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StrategiesTable extends Strategies
    with TableInfo<$StrategiesTable, StrategyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrategiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _maShortPeriodMeta = const VerificationMeta(
    'maShortPeriod',
  );
  @override
  late final GeneratedColumn<int> maShortPeriod = GeneratedColumn<int>(
    'ma_short_period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _maLongPeriodMeta = const VerificationMeta(
    'maLongPeriod',
  );
  @override
  late final GeneratedColumn<int> maLongPeriod = GeneratedColumn<int>(
    'ma_long_period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _bollPeriodMeta = const VerificationMeta(
    'bollPeriod',
  );
  @override
  late final GeneratedColumn<int> bollPeriod = GeneratedColumn<int>(
    'boll_period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _bollStdDevMeta = const VerificationMeta(
    'bollStdDev',
  );
  @override
  late final GeneratedColumn<double> bollStdDev = GeneratedColumn<double>(
    'boll_std_dev',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.0),
  );
  static const VerificationMeta _weightMAMeta = const VerificationMeta(
    'weightMA',
  );
  @override
  late final GeneratedColumn<double> weightMA = GeneratedColumn<double>(
    'weight_m_a',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.30),
  );
  static const VerificationMeta _weightBollMeta = const VerificationMeta(
    'weightBoll',
  );
  @override
  late final GeneratedColumn<double> weightBoll = GeneratedColumn<double>(
    'weight_boll',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.30),
  );
  static const VerificationMeta _weightVolMeta = const VerificationMeta(
    'weightVol',
  );
  @override
  late final GeneratedColumn<double> weightVol = GeneratedColumn<double>(
    'weight_vol',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.20),
  );
  static const VerificationMeta _weightTrendMeta = const VerificationMeta(
    'weightTrend',
  );
  @override
  late final GeneratedColumn<double> weightTrend = GeneratedColumn<double>(
    'weight_trend',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.20),
  );
  static const VerificationMeta _recommendThresholdMeta =
      const VerificationMeta('recommendThreshold');
  @override
  late final GeneratedColumn<int> recommendThreshold = GeneratedColumn<int>(
    'recommend_threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _entryRulesJsonMeta = const VerificationMeta(
    'entryRulesJson',
  );
  @override
  late final GeneratedColumn<String> entryRulesJson = GeneratedColumn<String>(
    'entry_rules_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exitRulesJsonMeta = const VerificationMeta(
    'exitRulesJson',
  );
  @override
  late final GeneratedColumn<String> exitRulesJson = GeneratedColumn<String>(
    'exit_rules_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryGroupsJsonMeta = const VerificationMeta(
    'entryGroupsJson',
  );
  @override
  late final GeneratedColumn<String> entryGroupsJson = GeneratedColumn<String>(
    'entry_groups_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exitGroupsJsonMeta = const VerificationMeta(
    'exitGroupsJson',
  );
  @override
  late final GeneratedColumn<String> exitGroupsJson = GeneratedColumn<String>(
    'exit_groups_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stockFilterJsonMeta = const VerificationMeta(
    'stockFilterJson',
  );
  @override
  late final GeneratedColumn<String> stockFilterJson = GeneratedColumn<String>(
    'stock_filter_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReviewAtMeta = const VerificationMeta(
    'lastReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewAt = GeneratedColumn<DateTime>(
    'last_review_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    maShortPeriod,
    maLongPeriod,
    bollPeriod,
    bollStdDev,
    weightMA,
    weightBoll,
    weightVol,
    weightTrend,
    recommendThreshold,
    entryRulesJson,
    exitRulesJson,
    entryGroupsJson,
    exitGroupsJson,
    stockFilterJson,
    isEnabled,
    isDefault,
    createdAt,
    updatedAt,
    lastReviewAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strategies';
  @override
  VerificationContext validateIntegrity(
    Insertable<StrategyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('ma_short_period')) {
      context.handle(
        _maShortPeriodMeta,
        maShortPeriod.isAcceptableOrUnknown(
          data['ma_short_period']!,
          _maShortPeriodMeta,
        ),
      );
    }
    if (data.containsKey('ma_long_period')) {
      context.handle(
        _maLongPeriodMeta,
        maLongPeriod.isAcceptableOrUnknown(
          data['ma_long_period']!,
          _maLongPeriodMeta,
        ),
      );
    }
    if (data.containsKey('boll_period')) {
      context.handle(
        _bollPeriodMeta,
        bollPeriod.isAcceptableOrUnknown(data['boll_period']!, _bollPeriodMeta),
      );
    }
    if (data.containsKey('boll_std_dev')) {
      context.handle(
        _bollStdDevMeta,
        bollStdDev.isAcceptableOrUnknown(
          data['boll_std_dev']!,
          _bollStdDevMeta,
        ),
      );
    }
    if (data.containsKey('weight_m_a')) {
      context.handle(
        _weightMAMeta,
        weightMA.isAcceptableOrUnknown(data['weight_m_a']!, _weightMAMeta),
      );
    }
    if (data.containsKey('weight_boll')) {
      context.handle(
        _weightBollMeta,
        weightBoll.isAcceptableOrUnknown(data['weight_boll']!, _weightBollMeta),
      );
    }
    if (data.containsKey('weight_vol')) {
      context.handle(
        _weightVolMeta,
        weightVol.isAcceptableOrUnknown(data['weight_vol']!, _weightVolMeta),
      );
    }
    if (data.containsKey('weight_trend')) {
      context.handle(
        _weightTrendMeta,
        weightTrend.isAcceptableOrUnknown(
          data['weight_trend']!,
          _weightTrendMeta,
        ),
      );
    }
    if (data.containsKey('recommend_threshold')) {
      context.handle(
        _recommendThresholdMeta,
        recommendThreshold.isAcceptableOrUnknown(
          data['recommend_threshold']!,
          _recommendThresholdMeta,
        ),
      );
    }
    if (data.containsKey('entry_rules_json')) {
      context.handle(
        _entryRulesJsonMeta,
        entryRulesJson.isAcceptableOrUnknown(
          data['entry_rules_json']!,
          _entryRulesJsonMeta,
        ),
      );
    }
    if (data.containsKey('exit_rules_json')) {
      context.handle(
        _exitRulesJsonMeta,
        exitRulesJson.isAcceptableOrUnknown(
          data['exit_rules_json']!,
          _exitRulesJsonMeta,
        ),
      );
    }
    if (data.containsKey('entry_groups_json')) {
      context.handle(
        _entryGroupsJsonMeta,
        entryGroupsJson.isAcceptableOrUnknown(
          data['entry_groups_json']!,
          _entryGroupsJsonMeta,
        ),
      );
    }
    if (data.containsKey('exit_groups_json')) {
      context.handle(
        _exitGroupsJsonMeta,
        exitGroupsJson.isAcceptableOrUnknown(
          data['exit_groups_json']!,
          _exitGroupsJsonMeta,
        ),
      );
    }
    if (data.containsKey('stock_filter_json')) {
      context.handle(
        _stockFilterJsonMeta,
        stockFilterJson.isAcceptableOrUnknown(
          data['stock_filter_json']!,
          _stockFilterJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_review_at')) {
      context.handle(
        _lastReviewAtMeta,
        lastReviewAt.isAcceptableOrUnknown(
          data['last_review_at']!,
          _lastReviewAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StrategyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StrategyRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      maShortPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ma_short_period'],
      )!,
      maLongPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ma_long_period'],
      )!,
      bollPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}boll_period'],
      )!,
      bollStdDev: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}boll_std_dev'],
      )!,
      weightMA: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_m_a'],
      )!,
      weightBoll: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_boll'],
      )!,
      weightVol: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_vol'],
      )!,
      weightTrend: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_trend'],
      )!,
      recommendThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recommend_threshold'],
      )!,
      entryRulesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_rules_json'],
      ),
      exitRulesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exit_rules_json'],
      ),
      entryGroupsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_groups_json'],
      ),
      exitGroupsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exit_groups_json'],
      ),
      stockFilterJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_filter_json'],
      ),
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_review_at'],
      ),
    );
  }

  @override
  $StrategiesTable createAlias(String alias) {
    return $StrategiesTable(attachedDatabase, alias);
  }
}

class StrategyRow extends DataClass implements Insertable<StrategyRow> {
  final String id;
  final String name;
  final String description;
  final int maShortPeriod;
  final int maLongPeriod;
  final int bollPeriod;
  final double bollStdDev;
  final double weightMA;
  final double weightBoll;
  final double weightVol;
  final double weightTrend;
  final int recommendThreshold;
  final String? entryRulesJson;
  final String? exitRulesJson;
  final String? entryGroupsJson;
  final String? exitGroupsJson;
  final String? stockFilterJson;
  final bool isEnabled;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastReviewAt;
  const StrategyRow({
    required this.id,
    required this.name,
    required this.description,
    required this.maShortPeriod,
    required this.maLongPeriod,
    required this.bollPeriod,
    required this.bollStdDev,
    required this.weightMA,
    required this.weightBoll,
    required this.weightVol,
    required this.weightTrend,
    required this.recommendThreshold,
    this.entryRulesJson,
    this.exitRulesJson,
    this.entryGroupsJson,
    this.exitGroupsJson,
    this.stockFilterJson,
    required this.isEnabled,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    this.lastReviewAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['ma_short_period'] = Variable<int>(maShortPeriod);
    map['ma_long_period'] = Variable<int>(maLongPeriod);
    map['boll_period'] = Variable<int>(bollPeriod);
    map['boll_std_dev'] = Variable<double>(bollStdDev);
    map['weight_m_a'] = Variable<double>(weightMA);
    map['weight_boll'] = Variable<double>(weightBoll);
    map['weight_vol'] = Variable<double>(weightVol);
    map['weight_trend'] = Variable<double>(weightTrend);
    map['recommend_threshold'] = Variable<int>(recommendThreshold);
    if (!nullToAbsent || entryRulesJson != null) {
      map['entry_rules_json'] = Variable<String>(entryRulesJson);
    }
    if (!nullToAbsent || exitRulesJson != null) {
      map['exit_rules_json'] = Variable<String>(exitRulesJson);
    }
    if (!nullToAbsent || entryGroupsJson != null) {
      map['entry_groups_json'] = Variable<String>(entryGroupsJson);
    }
    if (!nullToAbsent || exitGroupsJson != null) {
      map['exit_groups_json'] = Variable<String>(exitGroupsJson);
    }
    if (!nullToAbsent || stockFilterJson != null) {
      map['stock_filter_json'] = Variable<String>(stockFilterJson);
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastReviewAt != null) {
      map['last_review_at'] = Variable<DateTime>(lastReviewAt);
    }
    return map;
  }

  StrategiesCompanion toCompanion(bool nullToAbsent) {
    return StrategiesCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      maShortPeriod: Value(maShortPeriod),
      maLongPeriod: Value(maLongPeriod),
      bollPeriod: Value(bollPeriod),
      bollStdDev: Value(bollStdDev),
      weightMA: Value(weightMA),
      weightBoll: Value(weightBoll),
      weightVol: Value(weightVol),
      weightTrend: Value(weightTrend),
      recommendThreshold: Value(recommendThreshold),
      entryRulesJson: entryRulesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(entryRulesJson),
      exitRulesJson: exitRulesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(exitRulesJson),
      entryGroupsJson: entryGroupsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(entryGroupsJson),
      exitGroupsJson: exitGroupsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(exitGroupsJson),
      stockFilterJson: stockFilterJson == null && nullToAbsent
          ? const Value.absent()
          : Value(stockFilterJson),
      isEnabled: Value(isEnabled),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastReviewAt: lastReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewAt),
    );
  }

  factory StrategyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StrategyRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      maShortPeriod: serializer.fromJson<int>(json['maShortPeriod']),
      maLongPeriod: serializer.fromJson<int>(json['maLongPeriod']),
      bollPeriod: serializer.fromJson<int>(json['bollPeriod']),
      bollStdDev: serializer.fromJson<double>(json['bollStdDev']),
      weightMA: serializer.fromJson<double>(json['weightMA']),
      weightBoll: serializer.fromJson<double>(json['weightBoll']),
      weightVol: serializer.fromJson<double>(json['weightVol']),
      weightTrend: serializer.fromJson<double>(json['weightTrend']),
      recommendThreshold: serializer.fromJson<int>(json['recommendThreshold']),
      entryRulesJson: serializer.fromJson<String?>(json['entryRulesJson']),
      exitRulesJson: serializer.fromJson<String?>(json['exitRulesJson']),
      entryGroupsJson: serializer.fromJson<String?>(json['entryGroupsJson']),
      exitGroupsJson: serializer.fromJson<String?>(json['exitGroupsJson']),
      stockFilterJson: serializer.fromJson<String?>(json['stockFilterJson']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastReviewAt: serializer.fromJson<DateTime?>(json['lastReviewAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'maShortPeriod': serializer.toJson<int>(maShortPeriod),
      'maLongPeriod': serializer.toJson<int>(maLongPeriod),
      'bollPeriod': serializer.toJson<int>(bollPeriod),
      'bollStdDev': serializer.toJson<double>(bollStdDev),
      'weightMA': serializer.toJson<double>(weightMA),
      'weightBoll': serializer.toJson<double>(weightBoll),
      'weightVol': serializer.toJson<double>(weightVol),
      'weightTrend': serializer.toJson<double>(weightTrend),
      'recommendThreshold': serializer.toJson<int>(recommendThreshold),
      'entryRulesJson': serializer.toJson<String?>(entryRulesJson),
      'exitRulesJson': serializer.toJson<String?>(exitRulesJson),
      'entryGroupsJson': serializer.toJson<String?>(entryGroupsJson),
      'exitGroupsJson': serializer.toJson<String?>(exitGroupsJson),
      'stockFilterJson': serializer.toJson<String?>(stockFilterJson),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastReviewAt': serializer.toJson<DateTime?>(lastReviewAt),
    };
  }

  StrategyRow copyWith({
    String? id,
    String? name,
    String? description,
    int? maShortPeriod,
    int? maLongPeriod,
    int? bollPeriod,
    double? bollStdDev,
    double? weightMA,
    double? weightBoll,
    double? weightVol,
    double? weightTrend,
    int? recommendThreshold,
    Value<String?> entryRulesJson = const Value.absent(),
    Value<String?> exitRulesJson = const Value.absent(),
    Value<String?> entryGroupsJson = const Value.absent(),
    Value<String?> exitGroupsJson = const Value.absent(),
    Value<String?> stockFilterJson = const Value.absent(),
    bool? isEnabled,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastReviewAt = const Value.absent(),
  }) => StrategyRow(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    maShortPeriod: maShortPeriod ?? this.maShortPeriod,
    maLongPeriod: maLongPeriod ?? this.maLongPeriod,
    bollPeriod: bollPeriod ?? this.bollPeriod,
    bollStdDev: bollStdDev ?? this.bollStdDev,
    weightMA: weightMA ?? this.weightMA,
    weightBoll: weightBoll ?? this.weightBoll,
    weightVol: weightVol ?? this.weightVol,
    weightTrend: weightTrend ?? this.weightTrend,
    recommendThreshold: recommendThreshold ?? this.recommendThreshold,
    entryRulesJson: entryRulesJson.present
        ? entryRulesJson.value
        : this.entryRulesJson,
    exitRulesJson: exitRulesJson.present
        ? exitRulesJson.value
        : this.exitRulesJson,
    entryGroupsJson: entryGroupsJson.present
        ? entryGroupsJson.value
        : this.entryGroupsJson,
    exitGroupsJson: exitGroupsJson.present
        ? exitGroupsJson.value
        : this.exitGroupsJson,
    stockFilterJson: stockFilterJson.present
        ? stockFilterJson.value
        : this.stockFilterJson,
    isEnabled: isEnabled ?? this.isEnabled,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastReviewAt: lastReviewAt.present ? lastReviewAt.value : this.lastReviewAt,
  );
  StrategyRow copyWithCompanion(StrategiesCompanion data) {
    return StrategyRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      maShortPeriod: data.maShortPeriod.present
          ? data.maShortPeriod.value
          : this.maShortPeriod,
      maLongPeriod: data.maLongPeriod.present
          ? data.maLongPeriod.value
          : this.maLongPeriod,
      bollPeriod: data.bollPeriod.present
          ? data.bollPeriod.value
          : this.bollPeriod,
      bollStdDev: data.bollStdDev.present
          ? data.bollStdDev.value
          : this.bollStdDev,
      weightMA: data.weightMA.present ? data.weightMA.value : this.weightMA,
      weightBoll: data.weightBoll.present
          ? data.weightBoll.value
          : this.weightBoll,
      weightVol: data.weightVol.present ? data.weightVol.value : this.weightVol,
      weightTrend: data.weightTrend.present
          ? data.weightTrend.value
          : this.weightTrend,
      recommendThreshold: data.recommendThreshold.present
          ? data.recommendThreshold.value
          : this.recommendThreshold,
      entryRulesJson: data.entryRulesJson.present
          ? data.entryRulesJson.value
          : this.entryRulesJson,
      exitRulesJson: data.exitRulesJson.present
          ? data.exitRulesJson.value
          : this.exitRulesJson,
      entryGroupsJson: data.entryGroupsJson.present
          ? data.entryGroupsJson.value
          : this.entryGroupsJson,
      exitGroupsJson: data.exitGroupsJson.present
          ? data.exitGroupsJson.value
          : this.exitGroupsJson,
      stockFilterJson: data.stockFilterJson.present
          ? data.stockFilterJson.value
          : this.stockFilterJson,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastReviewAt: data.lastReviewAt.present
          ? data.lastReviewAt.value
          : this.lastReviewAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StrategyRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('maShortPeriod: $maShortPeriod, ')
          ..write('maLongPeriod: $maLongPeriod, ')
          ..write('bollPeriod: $bollPeriod, ')
          ..write('bollStdDev: $bollStdDev, ')
          ..write('weightMA: $weightMA, ')
          ..write('weightBoll: $weightBoll, ')
          ..write('weightVol: $weightVol, ')
          ..write('weightTrend: $weightTrend, ')
          ..write('recommendThreshold: $recommendThreshold, ')
          ..write('entryRulesJson: $entryRulesJson, ')
          ..write('exitRulesJson: $exitRulesJson, ')
          ..write('entryGroupsJson: $entryGroupsJson, ')
          ..write('exitGroupsJson: $exitGroupsJson, ')
          ..write('stockFilterJson: $stockFilterJson, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastReviewAt: $lastReviewAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    description,
    maShortPeriod,
    maLongPeriod,
    bollPeriod,
    bollStdDev,
    weightMA,
    weightBoll,
    weightVol,
    weightTrend,
    recommendThreshold,
    entryRulesJson,
    exitRulesJson,
    entryGroupsJson,
    exitGroupsJson,
    stockFilterJson,
    isEnabled,
    isDefault,
    createdAt,
    updatedAt,
    lastReviewAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrategyRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.maShortPeriod == this.maShortPeriod &&
          other.maLongPeriod == this.maLongPeriod &&
          other.bollPeriod == this.bollPeriod &&
          other.bollStdDev == this.bollStdDev &&
          other.weightMA == this.weightMA &&
          other.weightBoll == this.weightBoll &&
          other.weightVol == this.weightVol &&
          other.weightTrend == this.weightTrend &&
          other.recommendThreshold == this.recommendThreshold &&
          other.entryRulesJson == this.entryRulesJson &&
          other.exitRulesJson == this.exitRulesJson &&
          other.entryGroupsJson == this.entryGroupsJson &&
          other.exitGroupsJson == this.exitGroupsJson &&
          other.stockFilterJson == this.stockFilterJson &&
          other.isEnabled == this.isEnabled &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastReviewAt == this.lastReviewAt);
}

class StrategiesCompanion extends UpdateCompanion<StrategyRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<int> maShortPeriod;
  final Value<int> maLongPeriod;
  final Value<int> bollPeriod;
  final Value<double> bollStdDev;
  final Value<double> weightMA;
  final Value<double> weightBoll;
  final Value<double> weightVol;
  final Value<double> weightTrend;
  final Value<int> recommendThreshold;
  final Value<String?> entryRulesJson;
  final Value<String?> exitRulesJson;
  final Value<String?> entryGroupsJson;
  final Value<String?> exitGroupsJson;
  final Value<String?> stockFilterJson;
  final Value<bool> isEnabled;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastReviewAt;
  final Value<int> rowid;
  const StrategiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.maShortPeriod = const Value.absent(),
    this.maLongPeriod = const Value.absent(),
    this.bollPeriod = const Value.absent(),
    this.bollStdDev = const Value.absent(),
    this.weightMA = const Value.absent(),
    this.weightBoll = const Value.absent(),
    this.weightVol = const Value.absent(),
    this.weightTrend = const Value.absent(),
    this.recommendThreshold = const Value.absent(),
    this.entryRulesJson = const Value.absent(),
    this.exitRulesJson = const Value.absent(),
    this.entryGroupsJson = const Value.absent(),
    this.exitGroupsJson = const Value.absent(),
    this.stockFilterJson = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastReviewAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StrategiesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.maShortPeriod = const Value.absent(),
    this.maLongPeriod = const Value.absent(),
    this.bollPeriod = const Value.absent(),
    this.bollStdDev = const Value.absent(),
    this.weightMA = const Value.absent(),
    this.weightBoll = const Value.absent(),
    this.weightVol = const Value.absent(),
    this.weightTrend = const Value.absent(),
    this.recommendThreshold = const Value.absent(),
    this.entryRulesJson = const Value.absent(),
    this.exitRulesJson = const Value.absent(),
    this.entryGroupsJson = const Value.absent(),
    this.exitGroupsJson = const Value.absent(),
    this.stockFilterJson = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.isDefault = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastReviewAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<StrategyRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? maShortPeriod,
    Expression<int>? maLongPeriod,
    Expression<int>? bollPeriod,
    Expression<double>? bollStdDev,
    Expression<double>? weightMA,
    Expression<double>? weightBoll,
    Expression<double>? weightVol,
    Expression<double>? weightTrend,
    Expression<int>? recommendThreshold,
    Expression<String>? entryRulesJson,
    Expression<String>? exitRulesJson,
    Expression<String>? entryGroupsJson,
    Expression<String>? exitGroupsJson,
    Expression<String>? stockFilterJson,
    Expression<bool>? isEnabled,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastReviewAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (maShortPeriod != null) 'ma_short_period': maShortPeriod,
      if (maLongPeriod != null) 'ma_long_period': maLongPeriod,
      if (bollPeriod != null) 'boll_period': bollPeriod,
      if (bollStdDev != null) 'boll_std_dev': bollStdDev,
      if (weightMA != null) 'weight_m_a': weightMA,
      if (weightBoll != null) 'weight_boll': weightBoll,
      if (weightVol != null) 'weight_vol': weightVol,
      if (weightTrend != null) 'weight_trend': weightTrend,
      if (recommendThreshold != null) 'recommend_threshold': recommendThreshold,
      if (entryRulesJson != null) 'entry_rules_json': entryRulesJson,
      if (exitRulesJson != null) 'exit_rules_json': exitRulesJson,
      if (entryGroupsJson != null) 'entry_groups_json': entryGroupsJson,
      if (exitGroupsJson != null) 'exit_groups_json': exitGroupsJson,
      if (stockFilterJson != null) 'stock_filter_json': stockFilterJson,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastReviewAt != null) 'last_review_at': lastReviewAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StrategiesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<int>? maShortPeriod,
    Value<int>? maLongPeriod,
    Value<int>? bollPeriod,
    Value<double>? bollStdDev,
    Value<double>? weightMA,
    Value<double>? weightBoll,
    Value<double>? weightVol,
    Value<double>? weightTrend,
    Value<int>? recommendThreshold,
    Value<String?>? entryRulesJson,
    Value<String?>? exitRulesJson,
    Value<String?>? entryGroupsJson,
    Value<String?>? exitGroupsJson,
    Value<String?>? stockFilterJson,
    Value<bool>? isEnabled,
    Value<bool>? isDefault,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastReviewAt,
    Value<int>? rowid,
  }) {
    return StrategiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      maShortPeriod: maShortPeriod ?? this.maShortPeriod,
      maLongPeriod: maLongPeriod ?? this.maLongPeriod,
      bollPeriod: bollPeriod ?? this.bollPeriod,
      bollStdDev: bollStdDev ?? this.bollStdDev,
      weightMA: weightMA ?? this.weightMA,
      weightBoll: weightBoll ?? this.weightBoll,
      weightVol: weightVol ?? this.weightVol,
      weightTrend: weightTrend ?? this.weightTrend,
      recommendThreshold: recommendThreshold ?? this.recommendThreshold,
      entryRulesJson: entryRulesJson ?? this.entryRulesJson,
      exitRulesJson: exitRulesJson ?? this.exitRulesJson,
      entryGroupsJson: entryGroupsJson ?? this.entryGroupsJson,
      exitGroupsJson: exitGroupsJson ?? this.exitGroupsJson,
      stockFilterJson: stockFilterJson ?? this.stockFilterJson,
      isEnabled: isEnabled ?? this.isEnabled,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastReviewAt: lastReviewAt ?? this.lastReviewAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (maShortPeriod.present) {
      map['ma_short_period'] = Variable<int>(maShortPeriod.value);
    }
    if (maLongPeriod.present) {
      map['ma_long_period'] = Variable<int>(maLongPeriod.value);
    }
    if (bollPeriod.present) {
      map['boll_period'] = Variable<int>(bollPeriod.value);
    }
    if (bollStdDev.present) {
      map['boll_std_dev'] = Variable<double>(bollStdDev.value);
    }
    if (weightMA.present) {
      map['weight_m_a'] = Variable<double>(weightMA.value);
    }
    if (weightBoll.present) {
      map['weight_boll'] = Variable<double>(weightBoll.value);
    }
    if (weightVol.present) {
      map['weight_vol'] = Variable<double>(weightVol.value);
    }
    if (weightTrend.present) {
      map['weight_trend'] = Variable<double>(weightTrend.value);
    }
    if (recommendThreshold.present) {
      map['recommend_threshold'] = Variable<int>(recommendThreshold.value);
    }
    if (entryRulesJson.present) {
      map['entry_rules_json'] = Variable<String>(entryRulesJson.value);
    }
    if (exitRulesJson.present) {
      map['exit_rules_json'] = Variable<String>(exitRulesJson.value);
    }
    if (entryGroupsJson.present) {
      map['entry_groups_json'] = Variable<String>(entryGroupsJson.value);
    }
    if (exitGroupsJson.present) {
      map['exit_groups_json'] = Variable<String>(exitGroupsJson.value);
    }
    if (stockFilterJson.present) {
      map['stock_filter_json'] = Variable<String>(stockFilterJson.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastReviewAt.present) {
      map['last_review_at'] = Variable<DateTime>(lastReviewAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrategiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('maShortPeriod: $maShortPeriod, ')
          ..write('maLongPeriod: $maLongPeriod, ')
          ..write('bollPeriod: $bollPeriod, ')
          ..write('bollStdDev: $bollStdDev, ')
          ..write('weightMA: $weightMA, ')
          ..write('weightBoll: $weightBoll, ')
          ..write('weightVol: $weightVol, ')
          ..write('weightTrend: $weightTrend, ')
          ..write('recommendThreshold: $recommendThreshold, ')
          ..write('entryRulesJson: $entryRulesJson, ')
          ..write('exitRulesJson: $exitRulesJson, ')
          ..write('entryGroupsJson: $entryGroupsJson, ')
          ..write('exitGroupsJson: $exitGroupsJson, ')
          ..write('stockFilterJson: $stockFilterJson, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastReviewAt: $lastReviewAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StrategyHitRecordsTable extends StrategyHitRecords
    with TableInfo<$StrategyHitRecordsTable, StrategyHitRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrategyHitRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strategyIdMeta = const VerificationMeta(
    'strategyId',
  );
  @override
  late final GeneratedColumn<String> strategyId = GeneratedColumn<String>(
    'strategy_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockCodeMeta = const VerificationMeta(
    'stockCode',
  );
  @override
  late final GeneratedColumn<String> stockCode = GeneratedColumn<String>(
    'stock_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockNameMeta = const VerificationMeta(
    'stockName',
  );
  @override
  late final GeneratedColumn<String> stockName = GeneratedColumn<String>(
    'stock_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recommendDateMeta = const VerificationMeta(
    'recommendDate',
  );
  @override
  late final GeneratedColumn<String> recommendDate = GeneratedColumn<String>(
    'recommend_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recommendScoreMeta = const VerificationMeta(
    'recommendScore',
  );
  @override
  late final GeneratedColumn<int> recommendScore = GeneratedColumn<int>(
    'recommend_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recommendPriceMeta = const VerificationMeta(
    'recommendPrice',
  );
  @override
  late final GeneratedColumn<double> recommendPrice = GeneratedColumn<double>(
    'recommend_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualChange5dMeta = const VerificationMeta(
    'actualChange5d',
  );
  @override
  late final GeneratedColumn<double> actualChange5d = GeneratedColumn<double>(
    'actual_change5d',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHitMeta = const VerificationMeta('isHit');
  @override
  late final GeneratedColumn<bool> isHit = GeneratedColumn<bool>(
    'is_hit',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hit" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    strategyId,
    stockCode,
    stockName,
    recommendDate,
    recommendScore,
    recommendPrice,
    actualChange5d,
    isHit,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strategy_hit_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<StrategyHitRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('strategy_id')) {
      context.handle(
        _strategyIdMeta,
        strategyId.isAcceptableOrUnknown(data['strategy_id']!, _strategyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_strategyIdMeta);
    }
    if (data.containsKey('stock_code')) {
      context.handle(
        _stockCodeMeta,
        stockCode.isAcceptableOrUnknown(data['stock_code']!, _stockCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_stockCodeMeta);
    }
    if (data.containsKey('stock_name')) {
      context.handle(
        _stockNameMeta,
        stockName.isAcceptableOrUnknown(data['stock_name']!, _stockNameMeta),
      );
    } else if (isInserting) {
      context.missing(_stockNameMeta);
    }
    if (data.containsKey('recommend_date')) {
      context.handle(
        _recommendDateMeta,
        recommendDate.isAcceptableOrUnknown(
          data['recommend_date']!,
          _recommendDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendDateMeta);
    }
    if (data.containsKey('recommend_score')) {
      context.handle(
        _recommendScoreMeta,
        recommendScore.isAcceptableOrUnknown(
          data['recommend_score']!,
          _recommendScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendScoreMeta);
    }
    if (data.containsKey('recommend_price')) {
      context.handle(
        _recommendPriceMeta,
        recommendPrice.isAcceptableOrUnknown(
          data['recommend_price']!,
          _recommendPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendPriceMeta);
    }
    if (data.containsKey('actual_change5d')) {
      context.handle(
        _actualChange5dMeta,
        actualChange5d.isAcceptableOrUnknown(
          data['actual_change5d']!,
          _actualChange5dMeta,
        ),
      );
    }
    if (data.containsKey('is_hit')) {
      context.handle(
        _isHitMeta,
        isHit.isAcceptableOrUnknown(data['is_hit']!, _isHitMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StrategyHitRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StrategyHitRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      strategyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strategy_id'],
      )!,
      stockCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_code'],
      )!,
      stockName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_name'],
      )!,
      recommendDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recommend_date'],
      )!,
      recommendScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recommend_score'],
      )!,
      recommendPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recommend_price'],
      )!,
      actualChange5d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_change5d'],
      ),
      isHit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hit'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StrategyHitRecordsTable createAlias(String alias) {
    return $StrategyHitRecordsTable(attachedDatabase, alias);
  }
}

class StrategyHitRecordRow extends DataClass
    implements Insertable<StrategyHitRecordRow> {
  final String id;
  final String strategyId;
  final String stockCode;
  final String stockName;
  final String recommendDate;
  final int recommendScore;
  final double recommendPrice;
  final double? actualChange5d;
  final bool? isHit;
  final DateTime createdAt;
  const StrategyHitRecordRow({
    required this.id,
    required this.strategyId,
    required this.stockCode,
    required this.stockName,
    required this.recommendDate,
    required this.recommendScore,
    required this.recommendPrice,
    this.actualChange5d,
    this.isHit,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['strategy_id'] = Variable<String>(strategyId);
    map['stock_code'] = Variable<String>(stockCode);
    map['stock_name'] = Variable<String>(stockName);
    map['recommend_date'] = Variable<String>(recommendDate);
    map['recommend_score'] = Variable<int>(recommendScore);
    map['recommend_price'] = Variable<double>(recommendPrice);
    if (!nullToAbsent || actualChange5d != null) {
      map['actual_change5d'] = Variable<double>(actualChange5d);
    }
    if (!nullToAbsent || isHit != null) {
      map['is_hit'] = Variable<bool>(isHit);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StrategyHitRecordsCompanion toCompanion(bool nullToAbsent) {
    return StrategyHitRecordsCompanion(
      id: Value(id),
      strategyId: Value(strategyId),
      stockCode: Value(stockCode),
      stockName: Value(stockName),
      recommendDate: Value(recommendDate),
      recommendScore: Value(recommendScore),
      recommendPrice: Value(recommendPrice),
      actualChange5d: actualChange5d == null && nullToAbsent
          ? const Value.absent()
          : Value(actualChange5d),
      isHit: isHit == null && nullToAbsent
          ? const Value.absent()
          : Value(isHit),
      createdAt: Value(createdAt),
    );
  }

  factory StrategyHitRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StrategyHitRecordRow(
      id: serializer.fromJson<String>(json['id']),
      strategyId: serializer.fromJson<String>(json['strategyId']),
      stockCode: serializer.fromJson<String>(json['stockCode']),
      stockName: serializer.fromJson<String>(json['stockName']),
      recommendDate: serializer.fromJson<String>(json['recommendDate']),
      recommendScore: serializer.fromJson<int>(json['recommendScore']),
      recommendPrice: serializer.fromJson<double>(json['recommendPrice']),
      actualChange5d: serializer.fromJson<double?>(json['actualChange5d']),
      isHit: serializer.fromJson<bool?>(json['isHit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'strategyId': serializer.toJson<String>(strategyId),
      'stockCode': serializer.toJson<String>(stockCode),
      'stockName': serializer.toJson<String>(stockName),
      'recommendDate': serializer.toJson<String>(recommendDate),
      'recommendScore': serializer.toJson<int>(recommendScore),
      'recommendPrice': serializer.toJson<double>(recommendPrice),
      'actualChange5d': serializer.toJson<double?>(actualChange5d),
      'isHit': serializer.toJson<bool?>(isHit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StrategyHitRecordRow copyWith({
    String? id,
    String? strategyId,
    String? stockCode,
    String? stockName,
    String? recommendDate,
    int? recommendScore,
    double? recommendPrice,
    Value<double?> actualChange5d = const Value.absent(),
    Value<bool?> isHit = const Value.absent(),
    DateTime? createdAt,
  }) => StrategyHitRecordRow(
    id: id ?? this.id,
    strategyId: strategyId ?? this.strategyId,
    stockCode: stockCode ?? this.stockCode,
    stockName: stockName ?? this.stockName,
    recommendDate: recommendDate ?? this.recommendDate,
    recommendScore: recommendScore ?? this.recommendScore,
    recommendPrice: recommendPrice ?? this.recommendPrice,
    actualChange5d: actualChange5d.present
        ? actualChange5d.value
        : this.actualChange5d,
    isHit: isHit.present ? isHit.value : this.isHit,
    createdAt: createdAt ?? this.createdAt,
  );
  StrategyHitRecordRow copyWithCompanion(StrategyHitRecordsCompanion data) {
    return StrategyHitRecordRow(
      id: data.id.present ? data.id.value : this.id,
      strategyId: data.strategyId.present
          ? data.strategyId.value
          : this.strategyId,
      stockCode: data.stockCode.present ? data.stockCode.value : this.stockCode,
      stockName: data.stockName.present ? data.stockName.value : this.stockName,
      recommendDate: data.recommendDate.present
          ? data.recommendDate.value
          : this.recommendDate,
      recommendScore: data.recommendScore.present
          ? data.recommendScore.value
          : this.recommendScore,
      recommendPrice: data.recommendPrice.present
          ? data.recommendPrice.value
          : this.recommendPrice,
      actualChange5d: data.actualChange5d.present
          ? data.actualChange5d.value
          : this.actualChange5d,
      isHit: data.isHit.present ? data.isHit.value : this.isHit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StrategyHitRecordRow(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('stockCode: $stockCode, ')
          ..write('stockName: $stockName, ')
          ..write('recommendDate: $recommendDate, ')
          ..write('recommendScore: $recommendScore, ')
          ..write('recommendPrice: $recommendPrice, ')
          ..write('actualChange5d: $actualChange5d, ')
          ..write('isHit: $isHit, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    strategyId,
    stockCode,
    stockName,
    recommendDate,
    recommendScore,
    recommendPrice,
    actualChange5d,
    isHit,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrategyHitRecordRow &&
          other.id == this.id &&
          other.strategyId == this.strategyId &&
          other.stockCode == this.stockCode &&
          other.stockName == this.stockName &&
          other.recommendDate == this.recommendDate &&
          other.recommendScore == this.recommendScore &&
          other.recommendPrice == this.recommendPrice &&
          other.actualChange5d == this.actualChange5d &&
          other.isHit == this.isHit &&
          other.createdAt == this.createdAt);
}

class StrategyHitRecordsCompanion
    extends UpdateCompanion<StrategyHitRecordRow> {
  final Value<String> id;
  final Value<String> strategyId;
  final Value<String> stockCode;
  final Value<String> stockName;
  final Value<String> recommendDate;
  final Value<int> recommendScore;
  final Value<double> recommendPrice;
  final Value<double?> actualChange5d;
  final Value<bool?> isHit;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StrategyHitRecordsCompanion({
    this.id = const Value.absent(),
    this.strategyId = const Value.absent(),
    this.stockCode = const Value.absent(),
    this.stockName = const Value.absent(),
    this.recommendDate = const Value.absent(),
    this.recommendScore = const Value.absent(),
    this.recommendPrice = const Value.absent(),
    this.actualChange5d = const Value.absent(),
    this.isHit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StrategyHitRecordsCompanion.insert({
    required String id,
    required String strategyId,
    required String stockCode,
    required String stockName,
    required String recommendDate,
    required int recommendScore,
    required double recommendPrice,
    this.actualChange5d = const Value.absent(),
    this.isHit = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       strategyId = Value(strategyId),
       stockCode = Value(stockCode),
       stockName = Value(stockName),
       recommendDate = Value(recommendDate),
       recommendScore = Value(recommendScore),
       recommendPrice = Value(recommendPrice),
       createdAt = Value(createdAt);
  static Insertable<StrategyHitRecordRow> custom({
    Expression<String>? id,
    Expression<String>? strategyId,
    Expression<String>? stockCode,
    Expression<String>? stockName,
    Expression<String>? recommendDate,
    Expression<int>? recommendScore,
    Expression<double>? recommendPrice,
    Expression<double>? actualChange5d,
    Expression<bool>? isHit,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (strategyId != null) 'strategy_id': strategyId,
      if (stockCode != null) 'stock_code': stockCode,
      if (stockName != null) 'stock_name': stockName,
      if (recommendDate != null) 'recommend_date': recommendDate,
      if (recommendScore != null) 'recommend_score': recommendScore,
      if (recommendPrice != null) 'recommend_price': recommendPrice,
      if (actualChange5d != null) 'actual_change5d': actualChange5d,
      if (isHit != null) 'is_hit': isHit,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StrategyHitRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? strategyId,
    Value<String>? stockCode,
    Value<String>? stockName,
    Value<String>? recommendDate,
    Value<int>? recommendScore,
    Value<double>? recommendPrice,
    Value<double?>? actualChange5d,
    Value<bool?>? isHit,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StrategyHitRecordsCompanion(
      id: id ?? this.id,
      strategyId: strategyId ?? this.strategyId,
      stockCode: stockCode ?? this.stockCode,
      stockName: stockName ?? this.stockName,
      recommendDate: recommendDate ?? this.recommendDate,
      recommendScore: recommendScore ?? this.recommendScore,
      recommendPrice: recommendPrice ?? this.recommendPrice,
      actualChange5d: actualChange5d ?? this.actualChange5d,
      isHit: isHit ?? this.isHit,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (strategyId.present) {
      map['strategy_id'] = Variable<String>(strategyId.value);
    }
    if (stockCode.present) {
      map['stock_code'] = Variable<String>(stockCode.value);
    }
    if (stockName.present) {
      map['stock_name'] = Variable<String>(stockName.value);
    }
    if (recommendDate.present) {
      map['recommend_date'] = Variable<String>(recommendDate.value);
    }
    if (recommendScore.present) {
      map['recommend_score'] = Variable<int>(recommendScore.value);
    }
    if (recommendPrice.present) {
      map['recommend_price'] = Variable<double>(recommendPrice.value);
    }
    if (actualChange5d.present) {
      map['actual_change5d'] = Variable<double>(actualChange5d.value);
    }
    if (isHit.present) {
      map['is_hit'] = Variable<bool>(isHit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrategyHitRecordsCompanion(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('stockCode: $stockCode, ')
          ..write('stockName: $stockName, ')
          ..write('recommendDate: $recommendDate, ')
          ..write('recommendScore: $recommendScore, ')
          ..write('recommendPrice: $recommendPrice, ')
          ..write('actualChange5d: $actualChange5d, ')
          ..write('isHit: $isHit, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StrategyReviewsTable extends StrategyReviews
    with TableInfo<$StrategyReviewsTable, StrategyReviewRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrategyReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strategyIdMeta = const VerificationMeta(
    'strategyId',
  );
  @override
  late final GeneratedColumn<String> strategyId = GeneratedColumn<String>(
    'strategy_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewDateMeta = const VerificationMeta(
    'reviewDate',
  );
  @override
  late final GeneratedColumn<DateTime> reviewDate = GeneratedColumn<DateTime>(
    'review_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _healthScoreMeta = const VerificationMeta(
    'healthScore',
  );
  @override
  late final GeneratedColumn<double> healthScore = GeneratedColumn<double>(
    'health_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hitRate30dMeta = const VerificationMeta(
    'hitRate30d',
  );
  @override
  late final GeneratedColumn<double> hitRate30d = GeneratedColumn<double>(
    'hit_rate30d',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgChange30dMeta = const VerificationMeta(
    'avgChange30d',
  );
  @override
  late final GeneratedColumn<double> avgChange30d = GeneratedColumn<double>(
    'avg_change30d',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxLoss30dMeta = const VerificationMeta(
    'maxLoss30d',
  );
  @override
  late final GeneratedColumn<double> maxLoss30d = GeneratedColumn<double>(
    'max_loss30d',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hitRateTrendMeta = const VerificationMeta(
    'hitRateTrend',
  );
  @override
  late final GeneratedColumn<String> hitRateTrend = GeneratedColumn<String>(
    'hit_rate_trend',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgDailyCount30dMeta = const VerificationMeta(
    'avgDailyCount30d',
  );
  @override
  late final GeneratedColumn<int> avgDailyCount30d = GeneratedColumn<int>(
    'avg_daily_count30d',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checklistResultMeta = const VerificationMeta(
    'checklistResult',
  );
  @override
  late final GeneratedColumn<String> checklistResult = GeneratedColumn<String>(
    'checklist_result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    strategyId,
    reviewDate,
    healthScore,
    hitRate30d,
    avgChange30d,
    maxLoss30d,
    hitRateTrend,
    avgDailyCount30d,
    checklistResult,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strategy_reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<StrategyReviewRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('strategy_id')) {
      context.handle(
        _strategyIdMeta,
        strategyId.isAcceptableOrUnknown(data['strategy_id']!, _strategyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_strategyIdMeta);
    }
    if (data.containsKey('review_date')) {
      context.handle(
        _reviewDateMeta,
        reviewDate.isAcceptableOrUnknown(data['review_date']!, _reviewDateMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewDateMeta);
    }
    if (data.containsKey('health_score')) {
      context.handle(
        _healthScoreMeta,
        healthScore.isAcceptableOrUnknown(
          data['health_score']!,
          _healthScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_healthScoreMeta);
    }
    if (data.containsKey('hit_rate30d')) {
      context.handle(
        _hitRate30dMeta,
        hitRate30d.isAcceptableOrUnknown(data['hit_rate30d']!, _hitRate30dMeta),
      );
    } else if (isInserting) {
      context.missing(_hitRate30dMeta);
    }
    if (data.containsKey('avg_change30d')) {
      context.handle(
        _avgChange30dMeta,
        avgChange30d.isAcceptableOrUnknown(
          data['avg_change30d']!,
          _avgChange30dMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avgChange30dMeta);
    }
    if (data.containsKey('max_loss30d')) {
      context.handle(
        _maxLoss30dMeta,
        maxLoss30d.isAcceptableOrUnknown(data['max_loss30d']!, _maxLoss30dMeta),
      );
    }
    if (data.containsKey('hit_rate_trend')) {
      context.handle(
        _hitRateTrendMeta,
        hitRateTrend.isAcceptableOrUnknown(
          data['hit_rate_trend']!,
          _hitRateTrendMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hitRateTrendMeta);
    }
    if (data.containsKey('avg_daily_count30d')) {
      context.handle(
        _avgDailyCount30dMeta,
        avgDailyCount30d.isAcceptableOrUnknown(
          data['avg_daily_count30d']!,
          _avgDailyCount30dMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avgDailyCount30dMeta);
    }
    if (data.containsKey('checklist_result')) {
      context.handle(
        _checklistResultMeta,
        checklistResult.isAcceptableOrUnknown(
          data['checklist_result']!,
          _checklistResultMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checklistResultMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StrategyReviewRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StrategyReviewRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      strategyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strategy_id'],
      )!,
      reviewDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}review_date'],
      )!,
      healthScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}health_score'],
      )!,
      hitRate30d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hit_rate30d'],
      )!,
      avgChange30d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_change30d'],
      )!,
      maxLoss30d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_loss30d'],
      ),
      hitRateTrend: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hit_rate_trend'],
      )!,
      avgDailyCount30d: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_daily_count30d'],
      )!,
      checklistResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checklist_result'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StrategyReviewsTable createAlias(String alias) {
    return $StrategyReviewsTable(attachedDatabase, alias);
  }
}

class StrategyReviewRow extends DataClass
    implements Insertable<StrategyReviewRow> {
  final String id;
  final String strategyId;
  final DateTime reviewDate;
  final double healthScore;
  final double hitRate30d;
  final double avgChange30d;
  final double? maxLoss30d;
  final String hitRateTrend;
  final int avgDailyCount30d;
  final String checklistResult;
  final String? note;
  final DateTime createdAt;
  const StrategyReviewRow({
    required this.id,
    required this.strategyId,
    required this.reviewDate,
    required this.healthScore,
    required this.hitRate30d,
    required this.avgChange30d,
    this.maxLoss30d,
    required this.hitRateTrend,
    required this.avgDailyCount30d,
    required this.checklistResult,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['strategy_id'] = Variable<String>(strategyId);
    map['review_date'] = Variable<DateTime>(reviewDate);
    map['health_score'] = Variable<double>(healthScore);
    map['hit_rate30d'] = Variable<double>(hitRate30d);
    map['avg_change30d'] = Variable<double>(avgChange30d);
    if (!nullToAbsent || maxLoss30d != null) {
      map['max_loss30d'] = Variable<double>(maxLoss30d);
    }
    map['hit_rate_trend'] = Variable<String>(hitRateTrend);
    map['avg_daily_count30d'] = Variable<int>(avgDailyCount30d);
    map['checklist_result'] = Variable<String>(checklistResult);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StrategyReviewsCompanion toCompanion(bool nullToAbsent) {
    return StrategyReviewsCompanion(
      id: Value(id),
      strategyId: Value(strategyId),
      reviewDate: Value(reviewDate),
      healthScore: Value(healthScore),
      hitRate30d: Value(hitRate30d),
      avgChange30d: Value(avgChange30d),
      maxLoss30d: maxLoss30d == null && nullToAbsent
          ? const Value.absent()
          : Value(maxLoss30d),
      hitRateTrend: Value(hitRateTrend),
      avgDailyCount30d: Value(avgDailyCount30d),
      checklistResult: Value(checklistResult),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory StrategyReviewRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StrategyReviewRow(
      id: serializer.fromJson<String>(json['id']),
      strategyId: serializer.fromJson<String>(json['strategyId']),
      reviewDate: serializer.fromJson<DateTime>(json['reviewDate']),
      healthScore: serializer.fromJson<double>(json['healthScore']),
      hitRate30d: serializer.fromJson<double>(json['hitRate30d']),
      avgChange30d: serializer.fromJson<double>(json['avgChange30d']),
      maxLoss30d: serializer.fromJson<double?>(json['maxLoss30d']),
      hitRateTrend: serializer.fromJson<String>(json['hitRateTrend']),
      avgDailyCount30d: serializer.fromJson<int>(json['avgDailyCount30d']),
      checklistResult: serializer.fromJson<String>(json['checklistResult']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'strategyId': serializer.toJson<String>(strategyId),
      'reviewDate': serializer.toJson<DateTime>(reviewDate),
      'healthScore': serializer.toJson<double>(healthScore),
      'hitRate30d': serializer.toJson<double>(hitRate30d),
      'avgChange30d': serializer.toJson<double>(avgChange30d),
      'maxLoss30d': serializer.toJson<double?>(maxLoss30d),
      'hitRateTrend': serializer.toJson<String>(hitRateTrend),
      'avgDailyCount30d': serializer.toJson<int>(avgDailyCount30d),
      'checklistResult': serializer.toJson<String>(checklistResult),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StrategyReviewRow copyWith({
    String? id,
    String? strategyId,
    DateTime? reviewDate,
    double? healthScore,
    double? hitRate30d,
    double? avgChange30d,
    Value<double?> maxLoss30d = const Value.absent(),
    String? hitRateTrend,
    int? avgDailyCount30d,
    String? checklistResult,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => StrategyReviewRow(
    id: id ?? this.id,
    strategyId: strategyId ?? this.strategyId,
    reviewDate: reviewDate ?? this.reviewDate,
    healthScore: healthScore ?? this.healthScore,
    hitRate30d: hitRate30d ?? this.hitRate30d,
    avgChange30d: avgChange30d ?? this.avgChange30d,
    maxLoss30d: maxLoss30d.present ? maxLoss30d.value : this.maxLoss30d,
    hitRateTrend: hitRateTrend ?? this.hitRateTrend,
    avgDailyCount30d: avgDailyCount30d ?? this.avgDailyCount30d,
    checklistResult: checklistResult ?? this.checklistResult,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  StrategyReviewRow copyWithCompanion(StrategyReviewsCompanion data) {
    return StrategyReviewRow(
      id: data.id.present ? data.id.value : this.id,
      strategyId: data.strategyId.present
          ? data.strategyId.value
          : this.strategyId,
      reviewDate: data.reviewDate.present
          ? data.reviewDate.value
          : this.reviewDate,
      healthScore: data.healthScore.present
          ? data.healthScore.value
          : this.healthScore,
      hitRate30d: data.hitRate30d.present
          ? data.hitRate30d.value
          : this.hitRate30d,
      avgChange30d: data.avgChange30d.present
          ? data.avgChange30d.value
          : this.avgChange30d,
      maxLoss30d: data.maxLoss30d.present
          ? data.maxLoss30d.value
          : this.maxLoss30d,
      hitRateTrend: data.hitRateTrend.present
          ? data.hitRateTrend.value
          : this.hitRateTrend,
      avgDailyCount30d: data.avgDailyCount30d.present
          ? data.avgDailyCount30d.value
          : this.avgDailyCount30d,
      checklistResult: data.checklistResult.present
          ? data.checklistResult.value
          : this.checklistResult,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StrategyReviewRow(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('reviewDate: $reviewDate, ')
          ..write('healthScore: $healthScore, ')
          ..write('hitRate30d: $hitRate30d, ')
          ..write('avgChange30d: $avgChange30d, ')
          ..write('maxLoss30d: $maxLoss30d, ')
          ..write('hitRateTrend: $hitRateTrend, ')
          ..write('avgDailyCount30d: $avgDailyCount30d, ')
          ..write('checklistResult: $checklistResult, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    strategyId,
    reviewDate,
    healthScore,
    hitRate30d,
    avgChange30d,
    maxLoss30d,
    hitRateTrend,
    avgDailyCount30d,
    checklistResult,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrategyReviewRow &&
          other.id == this.id &&
          other.strategyId == this.strategyId &&
          other.reviewDate == this.reviewDate &&
          other.healthScore == this.healthScore &&
          other.hitRate30d == this.hitRate30d &&
          other.avgChange30d == this.avgChange30d &&
          other.maxLoss30d == this.maxLoss30d &&
          other.hitRateTrend == this.hitRateTrend &&
          other.avgDailyCount30d == this.avgDailyCount30d &&
          other.checklistResult == this.checklistResult &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class StrategyReviewsCompanion extends UpdateCompanion<StrategyReviewRow> {
  final Value<String> id;
  final Value<String> strategyId;
  final Value<DateTime> reviewDate;
  final Value<double> healthScore;
  final Value<double> hitRate30d;
  final Value<double> avgChange30d;
  final Value<double?> maxLoss30d;
  final Value<String> hitRateTrend;
  final Value<int> avgDailyCount30d;
  final Value<String> checklistResult;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StrategyReviewsCompanion({
    this.id = const Value.absent(),
    this.strategyId = const Value.absent(),
    this.reviewDate = const Value.absent(),
    this.healthScore = const Value.absent(),
    this.hitRate30d = const Value.absent(),
    this.avgChange30d = const Value.absent(),
    this.maxLoss30d = const Value.absent(),
    this.hitRateTrend = const Value.absent(),
    this.avgDailyCount30d = const Value.absent(),
    this.checklistResult = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StrategyReviewsCompanion.insert({
    required String id,
    required String strategyId,
    required DateTime reviewDate,
    required double healthScore,
    required double hitRate30d,
    required double avgChange30d,
    this.maxLoss30d = const Value.absent(),
    required String hitRateTrend,
    required int avgDailyCount30d,
    required String checklistResult,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       strategyId = Value(strategyId),
       reviewDate = Value(reviewDate),
       healthScore = Value(healthScore),
       hitRate30d = Value(hitRate30d),
       avgChange30d = Value(avgChange30d),
       hitRateTrend = Value(hitRateTrend),
       avgDailyCount30d = Value(avgDailyCount30d),
       checklistResult = Value(checklistResult),
       createdAt = Value(createdAt);
  static Insertable<StrategyReviewRow> custom({
    Expression<String>? id,
    Expression<String>? strategyId,
    Expression<DateTime>? reviewDate,
    Expression<double>? healthScore,
    Expression<double>? hitRate30d,
    Expression<double>? avgChange30d,
    Expression<double>? maxLoss30d,
    Expression<String>? hitRateTrend,
    Expression<int>? avgDailyCount30d,
    Expression<String>? checklistResult,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (strategyId != null) 'strategy_id': strategyId,
      if (reviewDate != null) 'review_date': reviewDate,
      if (healthScore != null) 'health_score': healthScore,
      if (hitRate30d != null) 'hit_rate30d': hitRate30d,
      if (avgChange30d != null) 'avg_change30d': avgChange30d,
      if (maxLoss30d != null) 'max_loss30d': maxLoss30d,
      if (hitRateTrend != null) 'hit_rate_trend': hitRateTrend,
      if (avgDailyCount30d != null) 'avg_daily_count30d': avgDailyCount30d,
      if (checklistResult != null) 'checklist_result': checklistResult,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StrategyReviewsCompanion copyWith({
    Value<String>? id,
    Value<String>? strategyId,
    Value<DateTime>? reviewDate,
    Value<double>? healthScore,
    Value<double>? hitRate30d,
    Value<double>? avgChange30d,
    Value<double?>? maxLoss30d,
    Value<String>? hitRateTrend,
    Value<int>? avgDailyCount30d,
    Value<String>? checklistResult,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StrategyReviewsCompanion(
      id: id ?? this.id,
      strategyId: strategyId ?? this.strategyId,
      reviewDate: reviewDate ?? this.reviewDate,
      healthScore: healthScore ?? this.healthScore,
      hitRate30d: hitRate30d ?? this.hitRate30d,
      avgChange30d: avgChange30d ?? this.avgChange30d,
      maxLoss30d: maxLoss30d ?? this.maxLoss30d,
      hitRateTrend: hitRateTrend ?? this.hitRateTrend,
      avgDailyCount30d: avgDailyCount30d ?? this.avgDailyCount30d,
      checklistResult: checklistResult ?? this.checklistResult,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (strategyId.present) {
      map['strategy_id'] = Variable<String>(strategyId.value);
    }
    if (reviewDate.present) {
      map['review_date'] = Variable<DateTime>(reviewDate.value);
    }
    if (healthScore.present) {
      map['health_score'] = Variable<double>(healthScore.value);
    }
    if (hitRate30d.present) {
      map['hit_rate30d'] = Variable<double>(hitRate30d.value);
    }
    if (avgChange30d.present) {
      map['avg_change30d'] = Variable<double>(avgChange30d.value);
    }
    if (maxLoss30d.present) {
      map['max_loss30d'] = Variable<double>(maxLoss30d.value);
    }
    if (hitRateTrend.present) {
      map['hit_rate_trend'] = Variable<String>(hitRateTrend.value);
    }
    if (avgDailyCount30d.present) {
      map['avg_daily_count30d'] = Variable<int>(avgDailyCount30d.value);
    }
    if (checklistResult.present) {
      map['checklist_result'] = Variable<String>(checklistResult.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrategyReviewsCompanion(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('reviewDate: $reviewDate, ')
          ..write('healthScore: $healthScore, ')
          ..write('hitRate30d: $hitRate30d, ')
          ..write('avgChange30d: $avgChange30d, ')
          ..write('maxLoss30d: $maxLoss30d, ')
          ..write('hitRateTrend: $hitRateTrend, ')
          ..write('avgDailyCount30d: $avgDailyCount30d, ')
          ..write('checklistResult: $checklistResult, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StrategySourcesTable extends StrategySources
    with TableInfo<$StrategySourcesTable, StrategySourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrategySourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strategyIdMeta = const VerificationMeta(
    'strategyId',
  );
  @override
  late final GeneratedColumn<String> strategyId = GeneratedColumn<String>(
    'strategy_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES strategies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _externalRefMeta = const VerificationMeta(
    'externalRef',
  );
  @override
  late final GeneratedColumn<String> externalRef = GeneratedColumn<String>(
    'external_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speakerMeta = const VerificationMeta(
    'speaker',
  );
  @override
  late final GeneratedColumn<String> speaker = GeneratedColumn<String>(
    'speaker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sanitizedTextMeta = const VerificationMeta(
    'sanitizedText',
  );
  @override
  late final GeneratedColumn<String> sanitizedText = GeneratedColumn<String>(
    'sanitized_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    strategyId,
    externalRef,
    sourceType,
    speaker,
    capturedAt,
    summary,
    sanitizedText,
    fingerprint,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strategy_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<StrategySourceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('strategy_id')) {
      context.handle(
        _strategyIdMeta,
        strategyId.isAcceptableOrUnknown(data['strategy_id']!, _strategyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_strategyIdMeta);
    }
    if (data.containsKey('external_ref')) {
      context.handle(
        _externalRefMeta,
        externalRef.isAcceptableOrUnknown(
          data['external_ref']!,
          _externalRefMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_externalRefMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('speaker')) {
      context.handle(
        _speakerMeta,
        speaker.isAcceptableOrUnknown(data['speaker']!, _speakerMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('sanitized_text')) {
      context.handle(
        _sanitizedTextMeta,
        sanitizedText.isAcceptableOrUnknown(
          data['sanitized_text']!,
          _sanitizedTextMeta,
        ),
      );
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {strategyId, fingerprint},
  ];
  @override
  StrategySourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StrategySourceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      strategyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strategy_id'],
      )!,
      externalRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_ref'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      speaker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}speaker'],
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      sanitizedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sanitized_text'],
      ),
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StrategySourcesTable createAlias(String alias) {
    return $StrategySourcesTable(attachedDatabase, alias);
  }
}

class StrategySourceRow extends DataClass
    implements Insertable<StrategySourceRow> {
  final String id;
  final String strategyId;
  final String externalRef;
  final String sourceType;
  final String? speaker;
  final DateTime? capturedAt;
  final String summary;
  final String? sanitizedText;
  final String fingerprint;
  final DateTime createdAt;
  const StrategySourceRow({
    required this.id,
    required this.strategyId,
    required this.externalRef,
    required this.sourceType,
    this.speaker,
    this.capturedAt,
    required this.summary,
    this.sanitizedText,
    required this.fingerprint,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['strategy_id'] = Variable<String>(strategyId);
    map['external_ref'] = Variable<String>(externalRef);
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || speaker != null) {
      map['speaker'] = Variable<String>(speaker);
    }
    if (!nullToAbsent || capturedAt != null) {
      map['captured_at'] = Variable<DateTime>(capturedAt);
    }
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || sanitizedText != null) {
      map['sanitized_text'] = Variable<String>(sanitizedText);
    }
    map['fingerprint'] = Variable<String>(fingerprint);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StrategySourcesCompanion toCompanion(bool nullToAbsent) {
    return StrategySourcesCompanion(
      id: Value(id),
      strategyId: Value(strategyId),
      externalRef: Value(externalRef),
      sourceType: Value(sourceType),
      speaker: speaker == null && nullToAbsent
          ? const Value.absent()
          : Value(speaker),
      capturedAt: capturedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedAt),
      summary: Value(summary),
      sanitizedText: sanitizedText == null && nullToAbsent
          ? const Value.absent()
          : Value(sanitizedText),
      fingerprint: Value(fingerprint),
      createdAt: Value(createdAt),
    );
  }

  factory StrategySourceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StrategySourceRow(
      id: serializer.fromJson<String>(json['id']),
      strategyId: serializer.fromJson<String>(json['strategyId']),
      externalRef: serializer.fromJson<String>(json['externalRef']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      speaker: serializer.fromJson<String?>(json['speaker']),
      capturedAt: serializer.fromJson<DateTime?>(json['capturedAt']),
      summary: serializer.fromJson<String>(json['summary']),
      sanitizedText: serializer.fromJson<String?>(json['sanitizedText']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'strategyId': serializer.toJson<String>(strategyId),
      'externalRef': serializer.toJson<String>(externalRef),
      'sourceType': serializer.toJson<String>(sourceType),
      'speaker': serializer.toJson<String?>(speaker),
      'capturedAt': serializer.toJson<DateTime?>(capturedAt),
      'summary': serializer.toJson<String>(summary),
      'sanitizedText': serializer.toJson<String?>(sanitizedText),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StrategySourceRow copyWith({
    String? id,
    String? strategyId,
    String? externalRef,
    String? sourceType,
    Value<String?> speaker = const Value.absent(),
    Value<DateTime?> capturedAt = const Value.absent(),
    String? summary,
    Value<String?> sanitizedText = const Value.absent(),
    String? fingerprint,
    DateTime? createdAt,
  }) => StrategySourceRow(
    id: id ?? this.id,
    strategyId: strategyId ?? this.strategyId,
    externalRef: externalRef ?? this.externalRef,
    sourceType: sourceType ?? this.sourceType,
    speaker: speaker.present ? speaker.value : this.speaker,
    capturedAt: capturedAt.present ? capturedAt.value : this.capturedAt,
    summary: summary ?? this.summary,
    sanitizedText: sanitizedText.present
        ? sanitizedText.value
        : this.sanitizedText,
    fingerprint: fingerprint ?? this.fingerprint,
    createdAt: createdAt ?? this.createdAt,
  );
  StrategySourceRow copyWithCompanion(StrategySourcesCompanion data) {
    return StrategySourceRow(
      id: data.id.present ? data.id.value : this.id,
      strategyId: data.strategyId.present
          ? data.strategyId.value
          : this.strategyId,
      externalRef: data.externalRef.present
          ? data.externalRef.value
          : this.externalRef,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      speaker: data.speaker.present ? data.speaker.value : this.speaker,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      summary: data.summary.present ? data.summary.value : this.summary,
      sanitizedText: data.sanitizedText.present
          ? data.sanitizedText.value
          : this.sanitizedText,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StrategySourceRow(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('externalRef: $externalRef, ')
          ..write('sourceType: $sourceType, ')
          ..write('speaker: $speaker, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('summary: $summary, ')
          ..write('sanitizedText: $sanitizedText, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    strategyId,
    externalRef,
    sourceType,
    speaker,
    capturedAt,
    summary,
    sanitizedText,
    fingerprint,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrategySourceRow &&
          other.id == this.id &&
          other.strategyId == this.strategyId &&
          other.externalRef == this.externalRef &&
          other.sourceType == this.sourceType &&
          other.speaker == this.speaker &&
          other.capturedAt == this.capturedAt &&
          other.summary == this.summary &&
          other.sanitizedText == this.sanitizedText &&
          other.fingerprint == this.fingerprint &&
          other.createdAt == this.createdAt);
}

class StrategySourcesCompanion extends UpdateCompanion<StrategySourceRow> {
  final Value<String> id;
  final Value<String> strategyId;
  final Value<String> externalRef;
  final Value<String> sourceType;
  final Value<String?> speaker;
  final Value<DateTime?> capturedAt;
  final Value<String> summary;
  final Value<String?> sanitizedText;
  final Value<String> fingerprint;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StrategySourcesCompanion({
    this.id = const Value.absent(),
    this.strategyId = const Value.absent(),
    this.externalRef = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.speaker = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.summary = const Value.absent(),
    this.sanitizedText = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StrategySourcesCompanion.insert({
    required String id,
    required String strategyId,
    required String externalRef,
    required String sourceType,
    this.speaker = const Value.absent(),
    this.capturedAt = const Value.absent(),
    required String summary,
    this.sanitizedText = const Value.absent(),
    required String fingerprint,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       strategyId = Value(strategyId),
       externalRef = Value(externalRef),
       sourceType = Value(sourceType),
       summary = Value(summary),
       fingerprint = Value(fingerprint),
       createdAt = Value(createdAt);
  static Insertable<StrategySourceRow> custom({
    Expression<String>? id,
    Expression<String>? strategyId,
    Expression<String>? externalRef,
    Expression<String>? sourceType,
    Expression<String>? speaker,
    Expression<DateTime>? capturedAt,
    Expression<String>? summary,
    Expression<String>? sanitizedText,
    Expression<String>? fingerprint,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (strategyId != null) 'strategy_id': strategyId,
      if (externalRef != null) 'external_ref': externalRef,
      if (sourceType != null) 'source_type': sourceType,
      if (speaker != null) 'speaker': speaker,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (summary != null) 'summary': summary,
      if (sanitizedText != null) 'sanitized_text': sanitizedText,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StrategySourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? strategyId,
    Value<String>? externalRef,
    Value<String>? sourceType,
    Value<String?>? speaker,
    Value<DateTime?>? capturedAt,
    Value<String>? summary,
    Value<String?>? sanitizedText,
    Value<String>? fingerprint,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StrategySourcesCompanion(
      id: id ?? this.id,
      strategyId: strategyId ?? this.strategyId,
      externalRef: externalRef ?? this.externalRef,
      sourceType: sourceType ?? this.sourceType,
      speaker: speaker ?? this.speaker,
      capturedAt: capturedAt ?? this.capturedAt,
      summary: summary ?? this.summary,
      sanitizedText: sanitizedText ?? this.sanitizedText,
      fingerprint: fingerprint ?? this.fingerprint,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (strategyId.present) {
      map['strategy_id'] = Variable<String>(strategyId.value);
    }
    if (externalRef.present) {
      map['external_ref'] = Variable<String>(externalRef.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (speaker.present) {
      map['speaker'] = Variable<String>(speaker.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (sanitizedText.present) {
      map['sanitized_text'] = Variable<String>(sanitizedText.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrategySourcesCompanion(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('externalRef: $externalRef, ')
          ..write('sourceType: $sourceType, ')
          ..write('speaker: $speaker, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('summary: $summary, ')
          ..write('sanitizedText: $sanitizedText, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StrategyVersionsTable extends StrategyVersions
    with TableInfo<$StrategyVersionsTable, StrategyVersionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrategyVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strategyIdMeta = const VerificationMeta(
    'strategyId',
  );
  @override
  late final GeneratedColumn<String> strategyId = GeneratedColumn<String>(
    'strategy_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES strategies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _versionNumberMeta = const VerificationMeta(
    'versionNumber',
  );
  @override
  late final GeneratedColumn<int> versionNumber = GeneratedColumn<int>(
    'version_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strategyTypeMeta = const VerificationMeta(
    'strategyType',
  );
  @override
  late final GeneratedColumn<String> strategyType = GeneratedColumn<String>(
    'strategy_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strategySnapshotJsonMeta =
      const VerificationMeta('strategySnapshotJson');
  @override
  late final GeneratedColumn<String> strategySnapshotJson =
      GeneratedColumn<String>(
        'strategy_snapshot_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _packageJsonMeta = const VerificationMeta(
    'packageJson',
  );
  @override
  late final GeneratedColumn<String> packageJson = GeneratedColumn<String>(
    'package_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _applicabilityJsonMeta = const VerificationMeta(
    'applicabilityJson',
  );
  @override
  late final GeneratedColumn<String> applicabilityJson =
      GeneratedColumn<String>(
        'applicability_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _riskNotesJsonMeta = const VerificationMeta(
    'riskNotesJson',
  );
  @override
  late final GeneratedColumn<String> riskNotesJson = GeneratedColumn<String>(
    'risk_notes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingQuestionsJsonMeta =
      const VerificationMeta('pendingQuestionsJson');
  @override
  late final GeneratedColumn<String> pendingQuestionsJson =
      GeneratedColumn<String>(
        'pending_questions_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _compatibilityIssuesJsonMeta =
      const VerificationMeta('compatibilityIssuesJson');
  @override
  late final GeneratedColumn<String> compatibilityIssuesJson =
      GeneratedColumn<String>(
        'compatibility_issues_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _previousVersionIdMeta = const VerificationMeta(
    'previousVersionId',
  );
  @override
  late final GeneratedColumn<String> previousVersionId =
      GeneratedColumn<String>(
        'previous_version_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    strategyId,
    versionNumber,
    status,
    strategyType,
    strategySnapshotJson,
    packageJson,
    applicabilityJson,
    riskNotesJson,
    pendingQuestionsJson,
    compatibilityIssuesJson,
    previousVersionId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strategy_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StrategyVersionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('strategy_id')) {
      context.handle(
        _strategyIdMeta,
        strategyId.isAcceptableOrUnknown(data['strategy_id']!, _strategyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_strategyIdMeta);
    }
    if (data.containsKey('version_number')) {
      context.handle(
        _versionNumberMeta,
        versionNumber.isAcceptableOrUnknown(
          data['version_number']!,
          _versionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versionNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('strategy_type')) {
      context.handle(
        _strategyTypeMeta,
        strategyType.isAcceptableOrUnknown(
          data['strategy_type']!,
          _strategyTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strategyTypeMeta);
    }
    if (data.containsKey('strategy_snapshot_json')) {
      context.handle(
        _strategySnapshotJsonMeta,
        strategySnapshotJson.isAcceptableOrUnknown(
          data['strategy_snapshot_json']!,
          _strategySnapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strategySnapshotJsonMeta);
    }
    if (data.containsKey('package_json')) {
      context.handle(
        _packageJsonMeta,
        packageJson.isAcceptableOrUnknown(
          data['package_json']!,
          _packageJsonMeta,
        ),
      );
    }
    if (data.containsKey('applicability_json')) {
      context.handle(
        _applicabilityJsonMeta,
        applicabilityJson.isAcceptableOrUnknown(
          data['applicability_json']!,
          _applicabilityJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_applicabilityJsonMeta);
    }
    if (data.containsKey('risk_notes_json')) {
      context.handle(
        _riskNotesJsonMeta,
        riskNotesJson.isAcceptableOrUnknown(
          data['risk_notes_json']!,
          _riskNotesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_riskNotesJsonMeta);
    }
    if (data.containsKey('pending_questions_json')) {
      context.handle(
        _pendingQuestionsJsonMeta,
        pendingQuestionsJson.isAcceptableOrUnknown(
          data['pending_questions_json']!,
          _pendingQuestionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pendingQuestionsJsonMeta);
    }
    if (data.containsKey('compatibility_issues_json')) {
      context.handle(
        _compatibilityIssuesJsonMeta,
        compatibilityIssuesJson.isAcceptableOrUnknown(
          data['compatibility_issues_json']!,
          _compatibilityIssuesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compatibilityIssuesJsonMeta);
    }
    if (data.containsKey('previous_version_id')) {
      context.handle(
        _previousVersionIdMeta,
        previousVersionId.isAcceptableOrUnknown(
          data['previous_version_id']!,
          _previousVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {strategyId, versionNumber},
  ];
  @override
  StrategyVersionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StrategyVersionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      strategyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strategy_id'],
      )!,
      versionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      strategyType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strategy_type'],
      )!,
      strategySnapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strategy_snapshot_json'],
      )!,
      packageJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_json'],
      ),
      applicabilityJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}applicability_json'],
      )!,
      riskNotesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}risk_notes_json'],
      )!,
      pendingQuestionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_questions_json'],
      )!,
      compatibilityIssuesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compatibility_issues_json'],
      )!,
      previousVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_version_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StrategyVersionsTable createAlias(String alias) {
    return $StrategyVersionsTable(attachedDatabase, alias);
  }
}

class StrategyVersionRow extends DataClass
    implements Insertable<StrategyVersionRow> {
  final String id;
  final String strategyId;
  final int versionNumber;
  final String status;
  final String strategyType;
  final String strategySnapshotJson;
  final String? packageJson;
  final String applicabilityJson;
  final String riskNotesJson;
  final String pendingQuestionsJson;
  final String compatibilityIssuesJson;
  final String? previousVersionId;
  final DateTime createdAt;
  const StrategyVersionRow({
    required this.id,
    required this.strategyId,
    required this.versionNumber,
    required this.status,
    required this.strategyType,
    required this.strategySnapshotJson,
    this.packageJson,
    required this.applicabilityJson,
    required this.riskNotesJson,
    required this.pendingQuestionsJson,
    required this.compatibilityIssuesJson,
    this.previousVersionId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['strategy_id'] = Variable<String>(strategyId);
    map['version_number'] = Variable<int>(versionNumber);
    map['status'] = Variable<String>(status);
    map['strategy_type'] = Variable<String>(strategyType);
    map['strategy_snapshot_json'] = Variable<String>(strategySnapshotJson);
    if (!nullToAbsent || packageJson != null) {
      map['package_json'] = Variable<String>(packageJson);
    }
    map['applicability_json'] = Variable<String>(applicabilityJson);
    map['risk_notes_json'] = Variable<String>(riskNotesJson);
    map['pending_questions_json'] = Variable<String>(pendingQuestionsJson);
    map['compatibility_issues_json'] = Variable<String>(
      compatibilityIssuesJson,
    );
    if (!nullToAbsent || previousVersionId != null) {
      map['previous_version_id'] = Variable<String>(previousVersionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StrategyVersionsCompanion toCompanion(bool nullToAbsent) {
    return StrategyVersionsCompanion(
      id: Value(id),
      strategyId: Value(strategyId),
      versionNumber: Value(versionNumber),
      status: Value(status),
      strategyType: Value(strategyType),
      strategySnapshotJson: Value(strategySnapshotJson),
      packageJson: packageJson == null && nullToAbsent
          ? const Value.absent()
          : Value(packageJson),
      applicabilityJson: Value(applicabilityJson),
      riskNotesJson: Value(riskNotesJson),
      pendingQuestionsJson: Value(pendingQuestionsJson),
      compatibilityIssuesJson: Value(compatibilityIssuesJson),
      previousVersionId: previousVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(previousVersionId),
      createdAt: Value(createdAt),
    );
  }

  factory StrategyVersionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StrategyVersionRow(
      id: serializer.fromJson<String>(json['id']),
      strategyId: serializer.fromJson<String>(json['strategyId']),
      versionNumber: serializer.fromJson<int>(json['versionNumber']),
      status: serializer.fromJson<String>(json['status']),
      strategyType: serializer.fromJson<String>(json['strategyType']),
      strategySnapshotJson: serializer.fromJson<String>(
        json['strategySnapshotJson'],
      ),
      packageJson: serializer.fromJson<String?>(json['packageJson']),
      applicabilityJson: serializer.fromJson<String>(json['applicabilityJson']),
      riskNotesJson: serializer.fromJson<String>(json['riskNotesJson']),
      pendingQuestionsJson: serializer.fromJson<String>(
        json['pendingQuestionsJson'],
      ),
      compatibilityIssuesJson: serializer.fromJson<String>(
        json['compatibilityIssuesJson'],
      ),
      previousVersionId: serializer.fromJson<String?>(
        json['previousVersionId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'strategyId': serializer.toJson<String>(strategyId),
      'versionNumber': serializer.toJson<int>(versionNumber),
      'status': serializer.toJson<String>(status),
      'strategyType': serializer.toJson<String>(strategyType),
      'strategySnapshotJson': serializer.toJson<String>(strategySnapshotJson),
      'packageJson': serializer.toJson<String?>(packageJson),
      'applicabilityJson': serializer.toJson<String>(applicabilityJson),
      'riskNotesJson': serializer.toJson<String>(riskNotesJson),
      'pendingQuestionsJson': serializer.toJson<String>(pendingQuestionsJson),
      'compatibilityIssuesJson': serializer.toJson<String>(
        compatibilityIssuesJson,
      ),
      'previousVersionId': serializer.toJson<String?>(previousVersionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StrategyVersionRow copyWith({
    String? id,
    String? strategyId,
    int? versionNumber,
    String? status,
    String? strategyType,
    String? strategySnapshotJson,
    Value<String?> packageJson = const Value.absent(),
    String? applicabilityJson,
    String? riskNotesJson,
    String? pendingQuestionsJson,
    String? compatibilityIssuesJson,
    Value<String?> previousVersionId = const Value.absent(),
    DateTime? createdAt,
  }) => StrategyVersionRow(
    id: id ?? this.id,
    strategyId: strategyId ?? this.strategyId,
    versionNumber: versionNumber ?? this.versionNumber,
    status: status ?? this.status,
    strategyType: strategyType ?? this.strategyType,
    strategySnapshotJson: strategySnapshotJson ?? this.strategySnapshotJson,
    packageJson: packageJson.present ? packageJson.value : this.packageJson,
    applicabilityJson: applicabilityJson ?? this.applicabilityJson,
    riskNotesJson: riskNotesJson ?? this.riskNotesJson,
    pendingQuestionsJson: pendingQuestionsJson ?? this.pendingQuestionsJson,
    compatibilityIssuesJson:
        compatibilityIssuesJson ?? this.compatibilityIssuesJson,
    previousVersionId: previousVersionId.present
        ? previousVersionId.value
        : this.previousVersionId,
    createdAt: createdAt ?? this.createdAt,
  );
  StrategyVersionRow copyWithCompanion(StrategyVersionsCompanion data) {
    return StrategyVersionRow(
      id: data.id.present ? data.id.value : this.id,
      strategyId: data.strategyId.present
          ? data.strategyId.value
          : this.strategyId,
      versionNumber: data.versionNumber.present
          ? data.versionNumber.value
          : this.versionNumber,
      status: data.status.present ? data.status.value : this.status,
      strategyType: data.strategyType.present
          ? data.strategyType.value
          : this.strategyType,
      strategySnapshotJson: data.strategySnapshotJson.present
          ? data.strategySnapshotJson.value
          : this.strategySnapshotJson,
      packageJson: data.packageJson.present
          ? data.packageJson.value
          : this.packageJson,
      applicabilityJson: data.applicabilityJson.present
          ? data.applicabilityJson.value
          : this.applicabilityJson,
      riskNotesJson: data.riskNotesJson.present
          ? data.riskNotesJson.value
          : this.riskNotesJson,
      pendingQuestionsJson: data.pendingQuestionsJson.present
          ? data.pendingQuestionsJson.value
          : this.pendingQuestionsJson,
      compatibilityIssuesJson: data.compatibilityIssuesJson.present
          ? data.compatibilityIssuesJson.value
          : this.compatibilityIssuesJson,
      previousVersionId: data.previousVersionId.present
          ? data.previousVersionId.value
          : this.previousVersionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StrategyVersionRow(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('versionNumber: $versionNumber, ')
          ..write('status: $status, ')
          ..write('strategyType: $strategyType, ')
          ..write('strategySnapshotJson: $strategySnapshotJson, ')
          ..write('packageJson: $packageJson, ')
          ..write('applicabilityJson: $applicabilityJson, ')
          ..write('riskNotesJson: $riskNotesJson, ')
          ..write('pendingQuestionsJson: $pendingQuestionsJson, ')
          ..write('compatibilityIssuesJson: $compatibilityIssuesJson, ')
          ..write('previousVersionId: $previousVersionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    strategyId,
    versionNumber,
    status,
    strategyType,
    strategySnapshotJson,
    packageJson,
    applicabilityJson,
    riskNotesJson,
    pendingQuestionsJson,
    compatibilityIssuesJson,
    previousVersionId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrategyVersionRow &&
          other.id == this.id &&
          other.strategyId == this.strategyId &&
          other.versionNumber == this.versionNumber &&
          other.status == this.status &&
          other.strategyType == this.strategyType &&
          other.strategySnapshotJson == this.strategySnapshotJson &&
          other.packageJson == this.packageJson &&
          other.applicabilityJson == this.applicabilityJson &&
          other.riskNotesJson == this.riskNotesJson &&
          other.pendingQuestionsJson == this.pendingQuestionsJson &&
          other.compatibilityIssuesJson == this.compatibilityIssuesJson &&
          other.previousVersionId == this.previousVersionId &&
          other.createdAt == this.createdAt);
}

class StrategyVersionsCompanion extends UpdateCompanion<StrategyVersionRow> {
  final Value<String> id;
  final Value<String> strategyId;
  final Value<int> versionNumber;
  final Value<String> status;
  final Value<String> strategyType;
  final Value<String> strategySnapshotJson;
  final Value<String?> packageJson;
  final Value<String> applicabilityJson;
  final Value<String> riskNotesJson;
  final Value<String> pendingQuestionsJson;
  final Value<String> compatibilityIssuesJson;
  final Value<String?> previousVersionId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StrategyVersionsCompanion({
    this.id = const Value.absent(),
    this.strategyId = const Value.absent(),
    this.versionNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.strategyType = const Value.absent(),
    this.strategySnapshotJson = const Value.absent(),
    this.packageJson = const Value.absent(),
    this.applicabilityJson = const Value.absent(),
    this.riskNotesJson = const Value.absent(),
    this.pendingQuestionsJson = const Value.absent(),
    this.compatibilityIssuesJson = const Value.absent(),
    this.previousVersionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StrategyVersionsCompanion.insert({
    required String id,
    required String strategyId,
    required int versionNumber,
    required String status,
    required String strategyType,
    required String strategySnapshotJson,
    this.packageJson = const Value.absent(),
    required String applicabilityJson,
    required String riskNotesJson,
    required String pendingQuestionsJson,
    required String compatibilityIssuesJson,
    this.previousVersionId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       strategyId = Value(strategyId),
       versionNumber = Value(versionNumber),
       status = Value(status),
       strategyType = Value(strategyType),
       strategySnapshotJson = Value(strategySnapshotJson),
       applicabilityJson = Value(applicabilityJson),
       riskNotesJson = Value(riskNotesJson),
       pendingQuestionsJson = Value(pendingQuestionsJson),
       compatibilityIssuesJson = Value(compatibilityIssuesJson),
       createdAt = Value(createdAt);
  static Insertable<StrategyVersionRow> custom({
    Expression<String>? id,
    Expression<String>? strategyId,
    Expression<int>? versionNumber,
    Expression<String>? status,
    Expression<String>? strategyType,
    Expression<String>? strategySnapshotJson,
    Expression<String>? packageJson,
    Expression<String>? applicabilityJson,
    Expression<String>? riskNotesJson,
    Expression<String>? pendingQuestionsJson,
    Expression<String>? compatibilityIssuesJson,
    Expression<String>? previousVersionId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (strategyId != null) 'strategy_id': strategyId,
      if (versionNumber != null) 'version_number': versionNumber,
      if (status != null) 'status': status,
      if (strategyType != null) 'strategy_type': strategyType,
      if (strategySnapshotJson != null)
        'strategy_snapshot_json': strategySnapshotJson,
      if (packageJson != null) 'package_json': packageJson,
      if (applicabilityJson != null) 'applicability_json': applicabilityJson,
      if (riskNotesJson != null) 'risk_notes_json': riskNotesJson,
      if (pendingQuestionsJson != null)
        'pending_questions_json': pendingQuestionsJson,
      if (compatibilityIssuesJson != null)
        'compatibility_issues_json': compatibilityIssuesJson,
      if (previousVersionId != null) 'previous_version_id': previousVersionId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StrategyVersionsCompanion copyWith({
    Value<String>? id,
    Value<String>? strategyId,
    Value<int>? versionNumber,
    Value<String>? status,
    Value<String>? strategyType,
    Value<String>? strategySnapshotJson,
    Value<String?>? packageJson,
    Value<String>? applicabilityJson,
    Value<String>? riskNotesJson,
    Value<String>? pendingQuestionsJson,
    Value<String>? compatibilityIssuesJson,
    Value<String?>? previousVersionId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StrategyVersionsCompanion(
      id: id ?? this.id,
      strategyId: strategyId ?? this.strategyId,
      versionNumber: versionNumber ?? this.versionNumber,
      status: status ?? this.status,
      strategyType: strategyType ?? this.strategyType,
      strategySnapshotJson: strategySnapshotJson ?? this.strategySnapshotJson,
      packageJson: packageJson ?? this.packageJson,
      applicabilityJson: applicabilityJson ?? this.applicabilityJson,
      riskNotesJson: riskNotesJson ?? this.riskNotesJson,
      pendingQuestionsJson: pendingQuestionsJson ?? this.pendingQuestionsJson,
      compatibilityIssuesJson:
          compatibilityIssuesJson ?? this.compatibilityIssuesJson,
      previousVersionId: previousVersionId ?? this.previousVersionId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (strategyId.present) {
      map['strategy_id'] = Variable<String>(strategyId.value);
    }
    if (versionNumber.present) {
      map['version_number'] = Variable<int>(versionNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (strategyType.present) {
      map['strategy_type'] = Variable<String>(strategyType.value);
    }
    if (strategySnapshotJson.present) {
      map['strategy_snapshot_json'] = Variable<String>(
        strategySnapshotJson.value,
      );
    }
    if (packageJson.present) {
      map['package_json'] = Variable<String>(packageJson.value);
    }
    if (applicabilityJson.present) {
      map['applicability_json'] = Variable<String>(applicabilityJson.value);
    }
    if (riskNotesJson.present) {
      map['risk_notes_json'] = Variable<String>(riskNotesJson.value);
    }
    if (pendingQuestionsJson.present) {
      map['pending_questions_json'] = Variable<String>(
        pendingQuestionsJson.value,
      );
    }
    if (compatibilityIssuesJson.present) {
      map['compatibility_issues_json'] = Variable<String>(
        compatibilityIssuesJson.value,
      );
    }
    if (previousVersionId.present) {
      map['previous_version_id'] = Variable<String>(previousVersionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrategyVersionsCompanion(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('versionNumber: $versionNumber, ')
          ..write('status: $status, ')
          ..write('strategyType: $strategyType, ')
          ..write('strategySnapshotJson: $strategySnapshotJson, ')
          ..write('packageJson: $packageJson, ')
          ..write('applicabilityJson: $applicabilityJson, ')
          ..write('riskNotesJson: $riskNotesJson, ')
          ..write('pendingQuestionsJson: $pendingQuestionsJson, ')
          ..write('compatibilityIssuesJson: $compatibilityIssuesJson, ')
          ..write('previousVersionId: $previousVersionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StrategyVersionSourcesTable extends StrategyVersionSources
    with TableInfo<$StrategyVersionSourcesTable, StrategyVersionSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrategyVersionSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  @override
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES strategy_versions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES strategy_sources (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ruleIdsJsonMeta = const VerificationMeta(
    'ruleIdsJson',
  );
  @override
  late final GeneratedColumn<String> ruleIdsJson = GeneratedColumn<String>(
    'rule_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [versionId, sourceId, ruleIdsJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strategy_version_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<StrategyVersionSourceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('rule_ids_json')) {
      context.handle(
        _ruleIdsJsonMeta,
        ruleIdsJson.isAcceptableOrUnknown(
          data['rule_ids_json']!,
          _ruleIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ruleIdsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {versionId, sourceId};
  @override
  StrategyVersionSourceRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StrategyVersionSourceRow(
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      ruleIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_ids_json'],
      )!,
    );
  }

  @override
  $StrategyVersionSourcesTable createAlias(String alias) {
    return $StrategyVersionSourcesTable(attachedDatabase, alias);
  }
}

class StrategyVersionSourceRow extends DataClass
    implements Insertable<StrategyVersionSourceRow> {
  final String versionId;
  final String sourceId;
  final String ruleIdsJson;
  const StrategyVersionSourceRow({
    required this.versionId,
    required this.sourceId,
    required this.ruleIdsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['version_id'] = Variable<String>(versionId);
    map['source_id'] = Variable<String>(sourceId);
    map['rule_ids_json'] = Variable<String>(ruleIdsJson);
    return map;
  }

  StrategyVersionSourcesCompanion toCompanion(bool nullToAbsent) {
    return StrategyVersionSourcesCompanion(
      versionId: Value(versionId),
      sourceId: Value(sourceId),
      ruleIdsJson: Value(ruleIdsJson),
    );
  }

  factory StrategyVersionSourceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StrategyVersionSourceRow(
      versionId: serializer.fromJson<String>(json['versionId']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      ruleIdsJson: serializer.fromJson<String>(json['ruleIdsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'versionId': serializer.toJson<String>(versionId),
      'sourceId': serializer.toJson<String>(sourceId),
      'ruleIdsJson': serializer.toJson<String>(ruleIdsJson),
    };
  }

  StrategyVersionSourceRow copyWith({
    String? versionId,
    String? sourceId,
    String? ruleIdsJson,
  }) => StrategyVersionSourceRow(
    versionId: versionId ?? this.versionId,
    sourceId: sourceId ?? this.sourceId,
    ruleIdsJson: ruleIdsJson ?? this.ruleIdsJson,
  );
  StrategyVersionSourceRow copyWithCompanion(
    StrategyVersionSourcesCompanion data,
  ) {
    return StrategyVersionSourceRow(
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      ruleIdsJson: data.ruleIdsJson.present
          ? data.ruleIdsJson.value
          : this.ruleIdsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StrategyVersionSourceRow(')
          ..write('versionId: $versionId, ')
          ..write('sourceId: $sourceId, ')
          ..write('ruleIdsJson: $ruleIdsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(versionId, sourceId, ruleIdsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrategyVersionSourceRow &&
          other.versionId == this.versionId &&
          other.sourceId == this.sourceId &&
          other.ruleIdsJson == this.ruleIdsJson);
}

class StrategyVersionSourcesCompanion
    extends UpdateCompanion<StrategyVersionSourceRow> {
  final Value<String> versionId;
  final Value<String> sourceId;
  final Value<String> ruleIdsJson;
  final Value<int> rowid;
  const StrategyVersionSourcesCompanion({
    this.versionId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.ruleIdsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StrategyVersionSourcesCompanion.insert({
    required String versionId,
    required String sourceId,
    required String ruleIdsJson,
    this.rowid = const Value.absent(),
  }) : versionId = Value(versionId),
       sourceId = Value(sourceId),
       ruleIdsJson = Value(ruleIdsJson);
  static Insertable<StrategyVersionSourceRow> custom({
    Expression<String>? versionId,
    Expression<String>? sourceId,
    Expression<String>? ruleIdsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (versionId != null) 'version_id': versionId,
      if (sourceId != null) 'source_id': sourceId,
      if (ruleIdsJson != null) 'rule_ids_json': ruleIdsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StrategyVersionSourcesCompanion copyWith({
    Value<String>? versionId,
    Value<String>? sourceId,
    Value<String>? ruleIdsJson,
    Value<int>? rowid,
  }) {
    return StrategyVersionSourcesCompanion(
      versionId: versionId ?? this.versionId,
      sourceId: sourceId ?? this.sourceId,
      ruleIdsJson: ruleIdsJson ?? this.ruleIdsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (ruleIdsJson.present) {
      map['rule_ids_json'] = Variable<String>(ruleIdsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrategyVersionSourcesCompanion(')
          ..write('versionId: $versionId, ')
          ..write('sourceId: $sourceId, ')
          ..write('ruleIdsJson: $ruleIdsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StrategyBacktestRunsTable extends StrategyBacktestRuns
    with TableInfo<$StrategyBacktestRunsTable, StrategyBacktestRunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrategyBacktestRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strategyIdMeta = const VerificationMeta(
    'strategyId',
  );
  @override
  late final GeneratedColumn<String> strategyId = GeneratedColumn<String>(
    'strategy_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES strategies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _strategyVersionIdMeta = const VerificationMeta(
    'strategyVersionId',
  );
  @override
  late final GeneratedColumn<String> strategyVersionId =
      GeneratedColumn<String>(
        'strategy_version_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES strategy_versions (id) ON DELETE CASCADE',
        ),
      );
  static const VerificationMeta _strategyVersionNumberMeta =
      const VerificationMeta('strategyVersionNumber');
  @override
  late final GeneratedColumn<int> strategyVersionNumber = GeneratedColumn<int>(
    'strategy_version_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockCodeMeta = const VerificationMeta(
    'stockCode',
  );
  @override
  late final GeneratedColumn<String> stockCode = GeneratedColumn<String>(
    'stock_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockNameMeta = const VerificationMeta(
    'stockName',
  );
  @override
  late final GeneratedColumn<String> stockName = GeneratedColumn<String>(
    'stock_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultJsonMeta = const VerificationMeta(
    'resultJson',
  );
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
    'result_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adjustmentModeMeta = const VerificationMeta(
    'adjustmentMode',
  );
  @override
  late final GeneratedColumn<String> adjustmentMode = GeneratedColumn<String>(
    'adjustment_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataFingerprintMeta = const VerificationMeta(
    'dataFingerprint',
  );
  @override
  late final GeneratedColumn<String> dataFingerprint = GeneratedColumn<String>(
    'data_fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataStartMeta = const VerificationMeta(
    'dataStart',
  );
  @override
  late final GeneratedColumn<DateTime> dataStart = GeneratedColumn<DateTime>(
    'data_start',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataEndMeta = const VerificationMeta(
    'dataEnd',
  );
  @override
  late final GeneratedColumn<DateTime> dataEnd = GeneratedColumn<DateTime>(
    'data_end',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataAsOfMeta = const VerificationMeta(
    'dataAsOf',
  );
  @override
  late final GeneratedColumn<DateTime> dataAsOf = GeneratedColumn<DateTime>(
    'data_as_of',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barsProcessedMeta = const VerificationMeta(
    'barsProcessed',
  );
  @override
  late final GeneratedColumn<int> barsProcessed = GeneratedColumn<int>(
    'bars_processed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sampleCountMeta = const VerificationMeta(
    'sampleCount',
  );
  @override
  late final GeneratedColumn<int> sampleCount = GeneratedColumn<int>(
    'sample_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    strategyId,
    strategyVersionId,
    strategyVersionNumber,
    stockCode,
    stockName,
    market,
    configJson,
    resultJson,
    adjustmentMode,
    dataFingerprint,
    dataStart,
    dataEnd,
    dataAsOf,
    barsProcessed,
    sampleCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strategy_backtest_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<StrategyBacktestRunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('strategy_id')) {
      context.handle(
        _strategyIdMeta,
        strategyId.isAcceptableOrUnknown(data['strategy_id']!, _strategyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_strategyIdMeta);
    }
    if (data.containsKey('strategy_version_id')) {
      context.handle(
        _strategyVersionIdMeta,
        strategyVersionId.isAcceptableOrUnknown(
          data['strategy_version_id']!,
          _strategyVersionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strategyVersionIdMeta);
    }
    if (data.containsKey('strategy_version_number')) {
      context.handle(
        _strategyVersionNumberMeta,
        strategyVersionNumber.isAcceptableOrUnknown(
          data['strategy_version_number']!,
          _strategyVersionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strategyVersionNumberMeta);
    }
    if (data.containsKey('stock_code')) {
      context.handle(
        _stockCodeMeta,
        stockCode.isAcceptableOrUnknown(data['stock_code']!, _stockCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_stockCodeMeta);
    }
    if (data.containsKey('stock_name')) {
      context.handle(
        _stockNameMeta,
        stockName.isAcceptableOrUnknown(data['stock_name']!, _stockNameMeta),
      );
    } else if (isInserting) {
      context.missing(_stockNameMeta);
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    } else if (isInserting) {
      context.missing(_marketMeta);
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
    }
    if (data.containsKey('result_json')) {
      context.handle(
        _resultJsonMeta,
        resultJson.isAcceptableOrUnknown(data['result_json']!, _resultJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_resultJsonMeta);
    }
    if (data.containsKey('adjustment_mode')) {
      context.handle(
        _adjustmentModeMeta,
        adjustmentMode.isAcceptableOrUnknown(
          data['adjustment_mode']!,
          _adjustmentModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_adjustmentModeMeta);
    }
    if (data.containsKey('data_fingerprint')) {
      context.handle(
        _dataFingerprintMeta,
        dataFingerprint.isAcceptableOrUnknown(
          data['data_fingerprint']!,
          _dataFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataFingerprintMeta);
    }
    if (data.containsKey('data_start')) {
      context.handle(
        _dataStartMeta,
        dataStart.isAcceptableOrUnknown(data['data_start']!, _dataStartMeta),
      );
    }
    if (data.containsKey('data_end')) {
      context.handle(
        _dataEndMeta,
        dataEnd.isAcceptableOrUnknown(data['data_end']!, _dataEndMeta),
      );
    }
    if (data.containsKey('data_as_of')) {
      context.handle(
        _dataAsOfMeta,
        dataAsOf.isAcceptableOrUnknown(data['data_as_of']!, _dataAsOfMeta),
      );
    } else if (isInserting) {
      context.missing(_dataAsOfMeta);
    }
    if (data.containsKey('bars_processed')) {
      context.handle(
        _barsProcessedMeta,
        barsProcessed.isAcceptableOrUnknown(
          data['bars_processed']!,
          _barsProcessedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_barsProcessedMeta);
    }
    if (data.containsKey('sample_count')) {
      context.handle(
        _sampleCountMeta,
        sampleCount.isAcceptableOrUnknown(
          data['sample_count']!,
          _sampleCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sampleCountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StrategyBacktestRunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StrategyBacktestRunRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      strategyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strategy_id'],
      )!,
      strategyVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strategy_version_id'],
      )!,
      strategyVersionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}strategy_version_number'],
      )!,
      stockCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_code'],
      )!,
      stockName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_name'],
      )!,
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      resultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_json'],
      )!,
      adjustmentMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adjustment_mode'],
      )!,
      dataFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_fingerprint'],
      )!,
      dataStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_start'],
      ),
      dataEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_end'],
      ),
      dataAsOf: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_as_of'],
      )!,
      barsProcessed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bars_processed'],
      )!,
      sampleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StrategyBacktestRunsTable createAlias(String alias) {
    return $StrategyBacktestRunsTable(attachedDatabase, alias);
  }
}

class StrategyBacktestRunRow extends DataClass
    implements Insertable<StrategyBacktestRunRow> {
  final String id;
  final String strategyId;
  final String strategyVersionId;
  final int strategyVersionNumber;
  final String stockCode;
  final String stockName;
  final String market;
  final String configJson;
  final String resultJson;
  final String adjustmentMode;
  final String dataFingerprint;
  final DateTime? dataStart;
  final DateTime? dataEnd;
  final DateTime dataAsOf;
  final int barsProcessed;
  final int sampleCount;
  final DateTime createdAt;
  const StrategyBacktestRunRow({
    required this.id,
    required this.strategyId,
    required this.strategyVersionId,
    required this.strategyVersionNumber,
    required this.stockCode,
    required this.stockName,
    required this.market,
    required this.configJson,
    required this.resultJson,
    required this.adjustmentMode,
    required this.dataFingerprint,
    this.dataStart,
    this.dataEnd,
    required this.dataAsOf,
    required this.barsProcessed,
    required this.sampleCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['strategy_id'] = Variable<String>(strategyId);
    map['strategy_version_id'] = Variable<String>(strategyVersionId);
    map['strategy_version_number'] = Variable<int>(strategyVersionNumber);
    map['stock_code'] = Variable<String>(stockCode);
    map['stock_name'] = Variable<String>(stockName);
    map['market'] = Variable<String>(market);
    map['config_json'] = Variable<String>(configJson);
    map['result_json'] = Variable<String>(resultJson);
    map['adjustment_mode'] = Variable<String>(adjustmentMode);
    map['data_fingerprint'] = Variable<String>(dataFingerprint);
    if (!nullToAbsent || dataStart != null) {
      map['data_start'] = Variable<DateTime>(dataStart);
    }
    if (!nullToAbsent || dataEnd != null) {
      map['data_end'] = Variable<DateTime>(dataEnd);
    }
    map['data_as_of'] = Variable<DateTime>(dataAsOf);
    map['bars_processed'] = Variable<int>(barsProcessed);
    map['sample_count'] = Variable<int>(sampleCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StrategyBacktestRunsCompanion toCompanion(bool nullToAbsent) {
    return StrategyBacktestRunsCompanion(
      id: Value(id),
      strategyId: Value(strategyId),
      strategyVersionId: Value(strategyVersionId),
      strategyVersionNumber: Value(strategyVersionNumber),
      stockCode: Value(stockCode),
      stockName: Value(stockName),
      market: Value(market),
      configJson: Value(configJson),
      resultJson: Value(resultJson),
      adjustmentMode: Value(adjustmentMode),
      dataFingerprint: Value(dataFingerprint),
      dataStart: dataStart == null && nullToAbsent
          ? const Value.absent()
          : Value(dataStart),
      dataEnd: dataEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(dataEnd),
      dataAsOf: Value(dataAsOf),
      barsProcessed: Value(barsProcessed),
      sampleCount: Value(sampleCount),
      createdAt: Value(createdAt),
    );
  }

  factory StrategyBacktestRunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StrategyBacktestRunRow(
      id: serializer.fromJson<String>(json['id']),
      strategyId: serializer.fromJson<String>(json['strategyId']),
      strategyVersionId: serializer.fromJson<String>(json['strategyVersionId']),
      strategyVersionNumber: serializer.fromJson<int>(
        json['strategyVersionNumber'],
      ),
      stockCode: serializer.fromJson<String>(json['stockCode']),
      stockName: serializer.fromJson<String>(json['stockName']),
      market: serializer.fromJson<String>(json['market']),
      configJson: serializer.fromJson<String>(json['configJson']),
      resultJson: serializer.fromJson<String>(json['resultJson']),
      adjustmentMode: serializer.fromJson<String>(json['adjustmentMode']),
      dataFingerprint: serializer.fromJson<String>(json['dataFingerprint']),
      dataStart: serializer.fromJson<DateTime?>(json['dataStart']),
      dataEnd: serializer.fromJson<DateTime?>(json['dataEnd']),
      dataAsOf: serializer.fromJson<DateTime>(json['dataAsOf']),
      barsProcessed: serializer.fromJson<int>(json['barsProcessed']),
      sampleCount: serializer.fromJson<int>(json['sampleCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'strategyId': serializer.toJson<String>(strategyId),
      'strategyVersionId': serializer.toJson<String>(strategyVersionId),
      'strategyVersionNumber': serializer.toJson<int>(strategyVersionNumber),
      'stockCode': serializer.toJson<String>(stockCode),
      'stockName': serializer.toJson<String>(stockName),
      'market': serializer.toJson<String>(market),
      'configJson': serializer.toJson<String>(configJson),
      'resultJson': serializer.toJson<String>(resultJson),
      'adjustmentMode': serializer.toJson<String>(adjustmentMode),
      'dataFingerprint': serializer.toJson<String>(dataFingerprint),
      'dataStart': serializer.toJson<DateTime?>(dataStart),
      'dataEnd': serializer.toJson<DateTime?>(dataEnd),
      'dataAsOf': serializer.toJson<DateTime>(dataAsOf),
      'barsProcessed': serializer.toJson<int>(barsProcessed),
      'sampleCount': serializer.toJson<int>(sampleCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StrategyBacktestRunRow copyWith({
    String? id,
    String? strategyId,
    String? strategyVersionId,
    int? strategyVersionNumber,
    String? stockCode,
    String? stockName,
    String? market,
    String? configJson,
    String? resultJson,
    String? adjustmentMode,
    String? dataFingerprint,
    Value<DateTime?> dataStart = const Value.absent(),
    Value<DateTime?> dataEnd = const Value.absent(),
    DateTime? dataAsOf,
    int? barsProcessed,
    int? sampleCount,
    DateTime? createdAt,
  }) => StrategyBacktestRunRow(
    id: id ?? this.id,
    strategyId: strategyId ?? this.strategyId,
    strategyVersionId: strategyVersionId ?? this.strategyVersionId,
    strategyVersionNumber: strategyVersionNumber ?? this.strategyVersionNumber,
    stockCode: stockCode ?? this.stockCode,
    stockName: stockName ?? this.stockName,
    market: market ?? this.market,
    configJson: configJson ?? this.configJson,
    resultJson: resultJson ?? this.resultJson,
    adjustmentMode: adjustmentMode ?? this.adjustmentMode,
    dataFingerprint: dataFingerprint ?? this.dataFingerprint,
    dataStart: dataStart.present ? dataStart.value : this.dataStart,
    dataEnd: dataEnd.present ? dataEnd.value : this.dataEnd,
    dataAsOf: dataAsOf ?? this.dataAsOf,
    barsProcessed: barsProcessed ?? this.barsProcessed,
    sampleCount: sampleCount ?? this.sampleCount,
    createdAt: createdAt ?? this.createdAt,
  );
  StrategyBacktestRunRow copyWithCompanion(StrategyBacktestRunsCompanion data) {
    return StrategyBacktestRunRow(
      id: data.id.present ? data.id.value : this.id,
      strategyId: data.strategyId.present
          ? data.strategyId.value
          : this.strategyId,
      strategyVersionId: data.strategyVersionId.present
          ? data.strategyVersionId.value
          : this.strategyVersionId,
      strategyVersionNumber: data.strategyVersionNumber.present
          ? data.strategyVersionNumber.value
          : this.strategyVersionNumber,
      stockCode: data.stockCode.present ? data.stockCode.value : this.stockCode,
      stockName: data.stockName.present ? data.stockName.value : this.stockName,
      market: data.market.present ? data.market.value : this.market,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      resultJson: data.resultJson.present
          ? data.resultJson.value
          : this.resultJson,
      adjustmentMode: data.adjustmentMode.present
          ? data.adjustmentMode.value
          : this.adjustmentMode,
      dataFingerprint: data.dataFingerprint.present
          ? data.dataFingerprint.value
          : this.dataFingerprint,
      dataStart: data.dataStart.present ? data.dataStart.value : this.dataStart,
      dataEnd: data.dataEnd.present ? data.dataEnd.value : this.dataEnd,
      dataAsOf: data.dataAsOf.present ? data.dataAsOf.value : this.dataAsOf,
      barsProcessed: data.barsProcessed.present
          ? data.barsProcessed.value
          : this.barsProcessed,
      sampleCount: data.sampleCount.present
          ? data.sampleCount.value
          : this.sampleCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StrategyBacktestRunRow(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('strategyVersionId: $strategyVersionId, ')
          ..write('strategyVersionNumber: $strategyVersionNumber, ')
          ..write('stockCode: $stockCode, ')
          ..write('stockName: $stockName, ')
          ..write('market: $market, ')
          ..write('configJson: $configJson, ')
          ..write('resultJson: $resultJson, ')
          ..write('adjustmentMode: $adjustmentMode, ')
          ..write('dataFingerprint: $dataFingerprint, ')
          ..write('dataStart: $dataStart, ')
          ..write('dataEnd: $dataEnd, ')
          ..write('dataAsOf: $dataAsOf, ')
          ..write('barsProcessed: $barsProcessed, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    strategyId,
    strategyVersionId,
    strategyVersionNumber,
    stockCode,
    stockName,
    market,
    configJson,
    resultJson,
    adjustmentMode,
    dataFingerprint,
    dataStart,
    dataEnd,
    dataAsOf,
    barsProcessed,
    sampleCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrategyBacktestRunRow &&
          other.id == this.id &&
          other.strategyId == this.strategyId &&
          other.strategyVersionId == this.strategyVersionId &&
          other.strategyVersionNumber == this.strategyVersionNumber &&
          other.stockCode == this.stockCode &&
          other.stockName == this.stockName &&
          other.market == this.market &&
          other.configJson == this.configJson &&
          other.resultJson == this.resultJson &&
          other.adjustmentMode == this.adjustmentMode &&
          other.dataFingerprint == this.dataFingerprint &&
          other.dataStart == this.dataStart &&
          other.dataEnd == this.dataEnd &&
          other.dataAsOf == this.dataAsOf &&
          other.barsProcessed == this.barsProcessed &&
          other.sampleCount == this.sampleCount &&
          other.createdAt == this.createdAt);
}

class StrategyBacktestRunsCompanion
    extends UpdateCompanion<StrategyBacktestRunRow> {
  final Value<String> id;
  final Value<String> strategyId;
  final Value<String> strategyVersionId;
  final Value<int> strategyVersionNumber;
  final Value<String> stockCode;
  final Value<String> stockName;
  final Value<String> market;
  final Value<String> configJson;
  final Value<String> resultJson;
  final Value<String> adjustmentMode;
  final Value<String> dataFingerprint;
  final Value<DateTime?> dataStart;
  final Value<DateTime?> dataEnd;
  final Value<DateTime> dataAsOf;
  final Value<int> barsProcessed;
  final Value<int> sampleCount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StrategyBacktestRunsCompanion({
    this.id = const Value.absent(),
    this.strategyId = const Value.absent(),
    this.strategyVersionId = const Value.absent(),
    this.strategyVersionNumber = const Value.absent(),
    this.stockCode = const Value.absent(),
    this.stockName = const Value.absent(),
    this.market = const Value.absent(),
    this.configJson = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.adjustmentMode = const Value.absent(),
    this.dataFingerprint = const Value.absent(),
    this.dataStart = const Value.absent(),
    this.dataEnd = const Value.absent(),
    this.dataAsOf = const Value.absent(),
    this.barsProcessed = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StrategyBacktestRunsCompanion.insert({
    required String id,
    required String strategyId,
    required String strategyVersionId,
    required int strategyVersionNumber,
    required String stockCode,
    required String stockName,
    required String market,
    required String configJson,
    required String resultJson,
    required String adjustmentMode,
    required String dataFingerprint,
    this.dataStart = const Value.absent(),
    this.dataEnd = const Value.absent(),
    required DateTime dataAsOf,
    required int barsProcessed,
    required int sampleCount,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       strategyId = Value(strategyId),
       strategyVersionId = Value(strategyVersionId),
       strategyVersionNumber = Value(strategyVersionNumber),
       stockCode = Value(stockCode),
       stockName = Value(stockName),
       market = Value(market),
       configJson = Value(configJson),
       resultJson = Value(resultJson),
       adjustmentMode = Value(adjustmentMode),
       dataFingerprint = Value(dataFingerprint),
       dataAsOf = Value(dataAsOf),
       barsProcessed = Value(barsProcessed),
       sampleCount = Value(sampleCount),
       createdAt = Value(createdAt);
  static Insertable<StrategyBacktestRunRow> custom({
    Expression<String>? id,
    Expression<String>? strategyId,
    Expression<String>? strategyVersionId,
    Expression<int>? strategyVersionNumber,
    Expression<String>? stockCode,
    Expression<String>? stockName,
    Expression<String>? market,
    Expression<String>? configJson,
    Expression<String>? resultJson,
    Expression<String>? adjustmentMode,
    Expression<String>? dataFingerprint,
    Expression<DateTime>? dataStart,
    Expression<DateTime>? dataEnd,
    Expression<DateTime>? dataAsOf,
    Expression<int>? barsProcessed,
    Expression<int>? sampleCount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (strategyId != null) 'strategy_id': strategyId,
      if (strategyVersionId != null) 'strategy_version_id': strategyVersionId,
      if (strategyVersionNumber != null)
        'strategy_version_number': strategyVersionNumber,
      if (stockCode != null) 'stock_code': stockCode,
      if (stockName != null) 'stock_name': stockName,
      if (market != null) 'market': market,
      if (configJson != null) 'config_json': configJson,
      if (resultJson != null) 'result_json': resultJson,
      if (adjustmentMode != null) 'adjustment_mode': adjustmentMode,
      if (dataFingerprint != null) 'data_fingerprint': dataFingerprint,
      if (dataStart != null) 'data_start': dataStart,
      if (dataEnd != null) 'data_end': dataEnd,
      if (dataAsOf != null) 'data_as_of': dataAsOf,
      if (barsProcessed != null) 'bars_processed': barsProcessed,
      if (sampleCount != null) 'sample_count': sampleCount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StrategyBacktestRunsCompanion copyWith({
    Value<String>? id,
    Value<String>? strategyId,
    Value<String>? strategyVersionId,
    Value<int>? strategyVersionNumber,
    Value<String>? stockCode,
    Value<String>? stockName,
    Value<String>? market,
    Value<String>? configJson,
    Value<String>? resultJson,
    Value<String>? adjustmentMode,
    Value<String>? dataFingerprint,
    Value<DateTime?>? dataStart,
    Value<DateTime?>? dataEnd,
    Value<DateTime>? dataAsOf,
    Value<int>? barsProcessed,
    Value<int>? sampleCount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StrategyBacktestRunsCompanion(
      id: id ?? this.id,
      strategyId: strategyId ?? this.strategyId,
      strategyVersionId: strategyVersionId ?? this.strategyVersionId,
      strategyVersionNumber:
          strategyVersionNumber ?? this.strategyVersionNumber,
      stockCode: stockCode ?? this.stockCode,
      stockName: stockName ?? this.stockName,
      market: market ?? this.market,
      configJson: configJson ?? this.configJson,
      resultJson: resultJson ?? this.resultJson,
      adjustmentMode: adjustmentMode ?? this.adjustmentMode,
      dataFingerprint: dataFingerprint ?? this.dataFingerprint,
      dataStart: dataStart ?? this.dataStart,
      dataEnd: dataEnd ?? this.dataEnd,
      dataAsOf: dataAsOf ?? this.dataAsOf,
      barsProcessed: barsProcessed ?? this.barsProcessed,
      sampleCount: sampleCount ?? this.sampleCount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (strategyId.present) {
      map['strategy_id'] = Variable<String>(strategyId.value);
    }
    if (strategyVersionId.present) {
      map['strategy_version_id'] = Variable<String>(strategyVersionId.value);
    }
    if (strategyVersionNumber.present) {
      map['strategy_version_number'] = Variable<int>(
        strategyVersionNumber.value,
      );
    }
    if (stockCode.present) {
      map['stock_code'] = Variable<String>(stockCode.value);
    }
    if (stockName.present) {
      map['stock_name'] = Variable<String>(stockName.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (adjustmentMode.present) {
      map['adjustment_mode'] = Variable<String>(adjustmentMode.value);
    }
    if (dataFingerprint.present) {
      map['data_fingerprint'] = Variable<String>(dataFingerprint.value);
    }
    if (dataStart.present) {
      map['data_start'] = Variable<DateTime>(dataStart.value);
    }
    if (dataEnd.present) {
      map['data_end'] = Variable<DateTime>(dataEnd.value);
    }
    if (dataAsOf.present) {
      map['data_as_of'] = Variable<DateTime>(dataAsOf.value);
    }
    if (barsProcessed.present) {
      map['bars_processed'] = Variable<int>(barsProcessed.value);
    }
    if (sampleCount.present) {
      map['sample_count'] = Variable<int>(sampleCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrategyBacktestRunsCompanion(')
          ..write('id: $id, ')
          ..write('strategyId: $strategyId, ')
          ..write('strategyVersionId: $strategyVersionId, ')
          ..write('strategyVersionNumber: $strategyVersionNumber, ')
          ..write('stockCode: $stockCode, ')
          ..write('stockName: $stockName, ')
          ..write('market: $market, ')
          ..write('configJson: $configJson, ')
          ..write('resultJson: $resultJson, ')
          ..write('adjustmentMode: $adjustmentMode, ')
          ..write('dataFingerprint: $dataFingerprint, ')
          ..write('dataStart: $dataStart, ')
          ..write('dataEnd: $dataEnd, ')
          ..write('dataAsOf: $dataAsOf, ')
          ..write('barsProcessed: $barsProcessed, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WatchlistItemsTable watchlistItems = $WatchlistItemsTable(this);
  late final $StrategiesTable strategies = $StrategiesTable(this);
  late final $StrategyHitRecordsTable strategyHitRecords =
      $StrategyHitRecordsTable(this);
  late final $StrategyReviewsTable strategyReviews = $StrategyReviewsTable(
    this,
  );
  late final $StrategySourcesTable strategySources = $StrategySourcesTable(
    this,
  );
  late final $StrategyVersionsTable strategyVersions = $StrategyVersionsTable(
    this,
  );
  late final $StrategyVersionSourcesTable strategyVersionSources =
      $StrategyVersionSourcesTable(this);
  late final $StrategyBacktestRunsTable strategyBacktestRuns =
      $StrategyBacktestRunsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    watchlistItems,
    strategies,
    strategyHitRecords,
    strategyReviews,
    strategySources,
    strategyVersions,
    strategyVersionSources,
    strategyBacktestRuns,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'strategies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('strategy_sources', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'strategies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('strategy_versions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'strategy_versions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('strategy_version_sources', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'strategy_sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('strategy_version_sources', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'strategies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('strategy_backtest_runs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'strategy_versions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('strategy_backtest_runs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$WatchlistItemsTableCreateCompanionBuilder =
    WatchlistItemsCompanion Function({
      required String id,
      required String stockCode,
      required String stockName,
      Value<String> market,
      Value<bool> isPinned,
      Value<int> sortOrder,
      Value<bool> alertEnabled,
      Value<double?> alertPriceThreshold,
      Value<String?> alertTriggeredDate,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WatchlistItemsTableUpdateCompanionBuilder =
    WatchlistItemsCompanion Function({
      Value<String> id,
      Value<String> stockCode,
      Value<String> stockName,
      Value<String> market,
      Value<bool> isPinned,
      Value<int> sortOrder,
      Value<bool> alertEnabled,
      Value<double?> alertPriceThreshold,
      Value<String?> alertTriggeredDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$WatchlistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WatchlistItemsTable> {
  $$WatchlistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stockCode => $composableBuilder(
    column: $table.stockCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stockName => $composableBuilder(
    column: $table.stockName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get alertEnabled => $composableBuilder(
    column: $table.alertEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get alertPriceThreshold => $composableBuilder(
    column: $table.alertPriceThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alertTriggeredDate => $composableBuilder(
    column: $table.alertTriggeredDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WatchlistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchlistItemsTable> {
  $$WatchlistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stockCode => $composableBuilder(
    column: $table.stockCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stockName => $composableBuilder(
    column: $table.stockName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get alertEnabled => $composableBuilder(
    column: $table.alertEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get alertPriceThreshold => $composableBuilder(
    column: $table.alertPriceThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertTriggeredDate => $composableBuilder(
    column: $table.alertTriggeredDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WatchlistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchlistItemsTable> {
  $$WatchlistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stockCode =>
      $composableBuilder(column: $table.stockCode, builder: (column) => column);

  GeneratedColumn<String> get stockName =>
      $composableBuilder(column: $table.stockName, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get alertEnabled => $composableBuilder(
    column: $table.alertEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<double> get alertPriceThreshold => $composableBuilder(
    column: $table.alertPriceThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alertTriggeredDate => $composableBuilder(
    column: $table.alertTriggeredDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WatchlistItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchlistItemsTable,
          WatchlistRow,
          $$WatchlistItemsTableFilterComposer,
          $$WatchlistItemsTableOrderingComposer,
          $$WatchlistItemsTableAnnotationComposer,
          $$WatchlistItemsTableCreateCompanionBuilder,
          $$WatchlistItemsTableUpdateCompanionBuilder,
          (
            WatchlistRow,
            BaseReferences<_$AppDatabase, $WatchlistItemsTable, WatchlistRow>,
          ),
          WatchlistRow,
          PrefetchHooks Function()
        > {
  $$WatchlistItemsTableTableManager(
    _$AppDatabase db,
    $WatchlistItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchlistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchlistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchlistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> stockCode = const Value.absent(),
                Value<String> stockName = const Value.absent(),
                Value<String> market = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> alertEnabled = const Value.absent(),
                Value<double?> alertPriceThreshold = const Value.absent(),
                Value<String?> alertTriggeredDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchlistItemsCompanion(
                id: id,
                stockCode: stockCode,
                stockName: stockName,
                market: market,
                isPinned: isPinned,
                sortOrder: sortOrder,
                alertEnabled: alertEnabled,
                alertPriceThreshold: alertPriceThreshold,
                alertTriggeredDate: alertTriggeredDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String stockCode,
                required String stockName,
                Value<String> market = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> alertEnabled = const Value.absent(),
                Value<double?> alertPriceThreshold = const Value.absent(),
                Value<String?> alertTriggeredDate = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WatchlistItemsCompanion.insert(
                id: id,
                stockCode: stockCode,
                stockName: stockName,
                market: market,
                isPinned: isPinned,
                sortOrder: sortOrder,
                alertEnabled: alertEnabled,
                alertPriceThreshold: alertPriceThreshold,
                alertTriggeredDate: alertTriggeredDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WatchlistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchlistItemsTable,
      WatchlistRow,
      $$WatchlistItemsTableFilterComposer,
      $$WatchlistItemsTableOrderingComposer,
      $$WatchlistItemsTableAnnotationComposer,
      $$WatchlistItemsTableCreateCompanionBuilder,
      $$WatchlistItemsTableUpdateCompanionBuilder,
      (
        WatchlistRow,
        BaseReferences<_$AppDatabase, $WatchlistItemsTable, WatchlistRow>,
      ),
      WatchlistRow,
      PrefetchHooks Function()
    >;
typedef $$StrategiesTableCreateCompanionBuilder =
    StrategiesCompanion Function({
      required String id,
      required String name,
      Value<String> description,
      Value<int> maShortPeriod,
      Value<int> maLongPeriod,
      Value<int> bollPeriod,
      Value<double> bollStdDev,
      Value<double> weightMA,
      Value<double> weightBoll,
      Value<double> weightVol,
      Value<double> weightTrend,
      Value<int> recommendThreshold,
      Value<String?> entryRulesJson,
      Value<String?> exitRulesJson,
      Value<String?> entryGroupsJson,
      Value<String?> exitGroupsJson,
      Value<String?> stockFilterJson,
      Value<bool> isEnabled,
      Value<bool> isDefault,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> lastReviewAt,
      Value<int> rowid,
    });
typedef $$StrategiesTableUpdateCompanionBuilder =
    StrategiesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<int> maShortPeriod,
      Value<int> maLongPeriod,
      Value<int> bollPeriod,
      Value<double> bollStdDev,
      Value<double> weightMA,
      Value<double> weightBoll,
      Value<double> weightVol,
      Value<double> weightTrend,
      Value<int> recommendThreshold,
      Value<String?> entryRulesJson,
      Value<String?> exitRulesJson,
      Value<String?> entryGroupsJson,
      Value<String?> exitGroupsJson,
      Value<String?> stockFilterJson,
      Value<bool> isEnabled,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastReviewAt,
      Value<int> rowid,
    });

final class $$StrategiesTableReferences
    extends BaseReferences<_$AppDatabase, $StrategiesTable, StrategyRow> {
  $$StrategiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StrategySourcesTable, List<StrategySourceRow>>
  _strategySourcesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.strategySources,
    aliasName: $_aliasNameGenerator(
      db.strategies.id,
      db.strategySources.strategyId,
    ),
  );

  $$StrategySourcesTableProcessedTableManager get strategySourcesRefs {
    final manager = $$StrategySourcesTableTableManager(
      $_db,
      $_db.strategySources,
    ).filter((f) => f.strategyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _strategySourcesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StrategyVersionsTable, List<StrategyVersionRow>>
  _strategyVersionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.strategyVersions,
    aliasName: $_aliasNameGenerator(
      db.strategies.id,
      db.strategyVersions.strategyId,
    ),
  );

  $$StrategyVersionsTableProcessedTableManager get strategyVersionsRefs {
    final manager = $$StrategyVersionsTableTableManager(
      $_db,
      $_db.strategyVersions,
    ).filter((f) => f.strategyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _strategyVersionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StrategyBacktestRunsTable,
    List<StrategyBacktestRunRow>
  >
  _strategyBacktestRunsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.strategyBacktestRuns,
        aliasName: $_aliasNameGenerator(
          db.strategies.id,
          db.strategyBacktestRuns.strategyId,
        ),
      );

  $$StrategyBacktestRunsTableProcessedTableManager
  get strategyBacktestRunsRefs {
    final manager = $$StrategyBacktestRunsTableTableManager(
      $_db,
      $_db.strategyBacktestRuns,
    ).filter((f) => f.strategyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _strategyBacktestRunsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StrategiesTableFilterComposer
    extends Composer<_$AppDatabase, $StrategiesTable> {
  $$StrategiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maShortPeriod => $composableBuilder(
    column: $table.maShortPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maLongPeriod => $composableBuilder(
    column: $table.maLongPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bollPeriod => $composableBuilder(
    column: $table.bollPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bollStdDev => $composableBuilder(
    column: $table.bollStdDev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightMA => $composableBuilder(
    column: $table.weightMA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightBoll => $composableBuilder(
    column: $table.weightBoll,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightVol => $composableBuilder(
    column: $table.weightVol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightTrend => $composableBuilder(
    column: $table.weightTrend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recommendThreshold => $composableBuilder(
    column: $table.recommendThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryRulesJson => $composableBuilder(
    column: $table.entryRulesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exitRulesJson => $composableBuilder(
    column: $table.exitRulesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryGroupsJson => $composableBuilder(
    column: $table.entryGroupsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exitGroupsJson => $composableBuilder(
    column: $table.exitGroupsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stockFilterJson => $composableBuilder(
    column: $table.stockFilterJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewAt => $composableBuilder(
    column: $table.lastReviewAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> strategySourcesRefs(
    Expression<bool> Function($$StrategySourcesTableFilterComposer f) f,
  ) {
    final $$StrategySourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strategySources,
      getReferencedColumn: (t) => t.strategyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategySourcesTableFilterComposer(
            $db: $db,
            $table: $db.strategySources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> strategyVersionsRefs(
    Expression<bool> Function($$StrategyVersionsTableFilterComposer f) f,
  ) {
    final $$StrategyVersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strategyVersions,
      getReferencedColumn: (t) => t.strategyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategyVersionsTableFilterComposer(
            $db: $db,
            $table: $db.strategyVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> strategyBacktestRunsRefs(
    Expression<bool> Function($$StrategyBacktestRunsTableFilterComposer f) f,
  ) {
    final $$StrategyBacktestRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strategyBacktestRuns,
      getReferencedColumn: (t) => t.strategyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategyBacktestRunsTableFilterComposer(
            $db: $db,
            $table: $db.strategyBacktestRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StrategiesTableOrderingComposer
    extends Composer<_$AppDatabase, $StrategiesTable> {
  $$StrategiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maShortPeriod => $composableBuilder(
    column: $table.maShortPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maLongPeriod => $composableBuilder(
    column: $table.maLongPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bollPeriod => $composableBuilder(
    column: $table.bollPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bollStdDev => $composableBuilder(
    column: $table.bollStdDev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightMA => $composableBuilder(
    column: $table.weightMA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightBoll => $composableBuilder(
    column: $table.weightBoll,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightVol => $composableBuilder(
    column: $table.weightVol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightTrend => $composableBuilder(
    column: $table.weightTrend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recommendThreshold => $composableBuilder(
    column: $table.recommendThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryRulesJson => $composableBuilder(
    column: $table.entryRulesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exitRulesJson => $composableBuilder(
    column: $table.exitRulesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryGroupsJson => $composableBuilder(
    column: $table.entryGroupsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exitGroupsJson => $composableBuilder(
    column: $table.exitGroupsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stockFilterJson => $composableBuilder(
    column: $table.stockFilterJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewAt => $composableBuilder(
    column: $table.lastReviewAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StrategiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrategiesTable> {
  $$StrategiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maShortPeriod => $composableBuilder(
    column: $table.maShortPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maLongPeriod => $composableBuilder(
    column: $table.maLongPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bollPeriod => $composableBuilder(
    column: $table.bollPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bollStdDev => $composableBuilder(
    column: $table.bollStdDev,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightMA =>
      $composableBuilder(column: $table.weightMA, builder: (column) => column);

  GeneratedColumn<double> get weightBoll => $composableBuilder(
    column: $table.weightBoll,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightVol =>
      $composableBuilder(column: $table.weightVol, builder: (column) => column);

  GeneratedColumn<double> get weightTrend => $composableBuilder(
    column: $table.weightTrend,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recommendThreshold => $composableBuilder(
    column: $table.recommendThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryRulesJson => $composableBuilder(
    column: $table.entryRulesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exitRulesJson => $composableBuilder(
    column: $table.exitRulesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryGroupsJson => $composableBuilder(
    column: $table.entryGroupsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exitGroupsJson => $composableBuilder(
    column: $table.exitGroupsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stockFilterJson => $composableBuilder(
    column: $table.stockFilterJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewAt => $composableBuilder(
    column: $table.lastReviewAt,
    builder: (column) => column,
  );

  Expression<T> strategySourcesRefs<T extends Object>(
    Expression<T> Function($$StrategySourcesTableAnnotationComposer a) f,
  ) {
    final $$StrategySourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strategySources,
      getReferencedColumn: (t) => t.strategyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategySourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.strategySources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> strategyVersionsRefs<T extends Object>(
    Expression<T> Function($$StrategyVersionsTableAnnotationComposer a) f,
  ) {
    final $$StrategyVersionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strategyVersions,
      getReferencedColumn: (t) => t.strategyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategyVersionsTableAnnotationComposer(
            $db: $db,
            $table: $db.strategyVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> strategyBacktestRunsRefs<T extends Object>(
    Expression<T> Function($$StrategyBacktestRunsTableAnnotationComposer a) f,
  ) {
    final $$StrategyBacktestRunsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.strategyBacktestRuns,
          getReferencedColumn: (t) => t.strategyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StrategyBacktestRunsTableAnnotationComposer(
                $db: $db,
                $table: $db.strategyBacktestRuns,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StrategiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrategiesTable,
          StrategyRow,
          $$StrategiesTableFilterComposer,
          $$StrategiesTableOrderingComposer,
          $$StrategiesTableAnnotationComposer,
          $$StrategiesTableCreateCompanionBuilder,
          $$StrategiesTableUpdateCompanionBuilder,
          (StrategyRow, $$StrategiesTableReferences),
          StrategyRow,
          PrefetchHooks Function({
            bool strategySourcesRefs,
            bool strategyVersionsRefs,
            bool strategyBacktestRunsRefs,
          })
        > {
  $$StrategiesTableTableManager(_$AppDatabase db, $StrategiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrategiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrategiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrategiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> maShortPeriod = const Value.absent(),
                Value<int> maLongPeriod = const Value.absent(),
                Value<int> bollPeriod = const Value.absent(),
                Value<double> bollStdDev = const Value.absent(),
                Value<double> weightMA = const Value.absent(),
                Value<double> weightBoll = const Value.absent(),
                Value<double> weightVol = const Value.absent(),
                Value<double> weightTrend = const Value.absent(),
                Value<int> recommendThreshold = const Value.absent(),
                Value<String?> entryRulesJson = const Value.absent(),
                Value<String?> exitRulesJson = const Value.absent(),
                Value<String?> entryGroupsJson = const Value.absent(),
                Value<String?> exitGroupsJson = const Value.absent(),
                Value<String?> stockFilterJson = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastReviewAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrategiesCompanion(
                id: id,
                name: name,
                description: description,
                maShortPeriod: maShortPeriod,
                maLongPeriod: maLongPeriod,
                bollPeriod: bollPeriod,
                bollStdDev: bollStdDev,
                weightMA: weightMA,
                weightBoll: weightBoll,
                weightVol: weightVol,
                weightTrend: weightTrend,
                recommendThreshold: recommendThreshold,
                entryRulesJson: entryRulesJson,
                exitRulesJson: exitRulesJson,
                entryGroupsJson: entryGroupsJson,
                exitGroupsJson: exitGroupsJson,
                stockFilterJson: stockFilterJson,
                isEnabled: isEnabled,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastReviewAt: lastReviewAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> description = const Value.absent(),
                Value<int> maShortPeriod = const Value.absent(),
                Value<int> maLongPeriod = const Value.absent(),
                Value<int> bollPeriod = const Value.absent(),
                Value<double> bollStdDev = const Value.absent(),
                Value<double> weightMA = const Value.absent(),
                Value<double> weightBoll = const Value.absent(),
                Value<double> weightVol = const Value.absent(),
                Value<double> weightTrend = const Value.absent(),
                Value<int> recommendThreshold = const Value.absent(),
                Value<String?> entryRulesJson = const Value.absent(),
                Value<String?> exitRulesJson = const Value.absent(),
                Value<String?> entryGroupsJson = const Value.absent(),
                Value<String?> exitGroupsJson = const Value.absent(),
                Value<String?> stockFilterJson = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> lastReviewAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrategiesCompanion.insert(
                id: id,
                name: name,
                description: description,
                maShortPeriod: maShortPeriod,
                maLongPeriod: maLongPeriod,
                bollPeriod: bollPeriod,
                bollStdDev: bollStdDev,
                weightMA: weightMA,
                weightBoll: weightBoll,
                weightVol: weightVol,
                weightTrend: weightTrend,
                recommendThreshold: recommendThreshold,
                entryRulesJson: entryRulesJson,
                exitRulesJson: exitRulesJson,
                entryGroupsJson: entryGroupsJson,
                exitGroupsJson: exitGroupsJson,
                stockFilterJson: stockFilterJson,
                isEnabled: isEnabled,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastReviewAt: lastReviewAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StrategiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                strategySourcesRefs = false,
                strategyVersionsRefs = false,
                strategyBacktestRunsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (strategySourcesRefs) db.strategySources,
                    if (strategyVersionsRefs) db.strategyVersions,
                    if (strategyBacktestRunsRefs) db.strategyBacktestRuns,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (strategySourcesRefs)
                        await $_getPrefetchedData<
                          StrategyRow,
                          $StrategiesTable,
                          StrategySourceRow
                        >(
                          currentTable: table,
                          referencedTable: $$StrategiesTableReferences
                              ._strategySourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StrategiesTableReferences(
                                db,
                                table,
                                p0,
                              ).strategySourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.strategyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (strategyVersionsRefs)
                        await $_getPrefetchedData<
                          StrategyRow,
                          $StrategiesTable,
                          StrategyVersionRow
                        >(
                          currentTable: table,
                          referencedTable: $$StrategiesTableReferences
                              ._strategyVersionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StrategiesTableReferences(
                                db,
                                table,
                                p0,
                              ).strategyVersionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.strategyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (strategyBacktestRunsRefs)
                        await $_getPrefetchedData<
                          StrategyRow,
                          $StrategiesTable,
                          StrategyBacktestRunRow
                        >(
                          currentTable: table,
                          referencedTable: $$StrategiesTableReferences
                              ._strategyBacktestRunsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StrategiesTableReferences(
                                db,
                                table,
                                p0,
                              ).strategyBacktestRunsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.strategyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StrategiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrategiesTable,
      StrategyRow,
      $$StrategiesTableFilterComposer,
      $$StrategiesTableOrderingComposer,
      $$StrategiesTableAnnotationComposer,
      $$StrategiesTableCreateCompanionBuilder,
      $$StrategiesTableUpdateCompanionBuilder,
      (StrategyRow, $$StrategiesTableReferences),
      StrategyRow,
      PrefetchHooks Function({
        bool strategySourcesRefs,
        bool strategyVersionsRefs,
        bool strategyBacktestRunsRefs,
      })
    >;
typedef $$StrategyHitRecordsTableCreateCompanionBuilder =
    StrategyHitRecordsCompanion Function({
      required String id,
      required String strategyId,
      required String stockCode,
      required String stockName,
      required String recommendDate,
      required int recommendScore,
      required double recommendPrice,
      Value<double?> actualChange5d,
      Value<bool?> isHit,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StrategyHitRecordsTableUpdateCompanionBuilder =
    StrategyHitRecordsCompanion Function({
      Value<String> id,
      Value<String> strategyId,
      Value<String> stockCode,
      Value<String> stockName,
      Value<String> recommendDate,
      Value<int> recommendScore,
      Value<double> recommendPrice,
      Value<double?> actualChange5d,
      Value<bool?> isHit,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$StrategyHitRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $StrategyHitRecordsTable> {
  $$StrategyHitRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strategyId => $composableBuilder(
    column: $table.strategyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stockCode => $composableBuilder(
    column: $table.stockCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stockName => $composableBuilder(
    column: $table.stockName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendDate => $composableBuilder(
    column: $table.recommendDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recommendScore => $composableBuilder(
    column: $table.recommendScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recommendPrice => $composableBuilder(
    column: $table.recommendPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualChange5d => $composableBuilder(
    column: $table.actualChange5d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHit => $composableBuilder(
    column: $table.isHit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StrategyHitRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $StrategyHitRecordsTable> {
  $$StrategyHitRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strategyId => $composableBuilder(
    column: $table.strategyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stockCode => $composableBuilder(
    column: $table.stockCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stockName => $composableBuilder(
    column: $table.stockName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendDate => $composableBuilder(
    column: $table.recommendDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recommendScore => $composableBuilder(
    column: $table.recommendScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recommendPrice => $composableBuilder(
    column: $table.recommendPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualChange5d => $composableBuilder(
    column: $table.actualChange5d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHit => $composableBuilder(
    column: $table.isHit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StrategyHitRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrategyHitRecordsTable> {
  $$StrategyHitRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get strategyId => $composableBuilder(
    column: $table.strategyId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stockCode =>
      $composableBuilder(column: $table.stockCode, builder: (column) => column);

  GeneratedColumn<String> get stockName =>
      $composableBuilder(column: $table.stockName, builder: (column) => column);

  GeneratedColumn<String> get recommendDate => $composableBuilder(
    column: $table.recommendDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recommendScore => $composableBuilder(
    column: $table.recommendScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recommendPrice => $composableBuilder(
    column: $table.recommendPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualChange5d => $composableBuilder(
    column: $table.actualChange5d,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHit =>
      $composableBuilder(column: $table.isHit, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StrategyHitRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrategyHitRecordsTable,
          StrategyHitRecordRow,
          $$StrategyHitRecordsTableFilterComposer,
          $$StrategyHitRecordsTableOrderingComposer,
          $$StrategyHitRecordsTableAnnotationComposer,
          $$StrategyHitRecordsTableCreateCompanionBuilder,
          $$StrategyHitRecordsTableUpdateCompanionBuilder,
          (
            StrategyHitRecordRow,
            BaseReferences<
              _$AppDatabase,
              $StrategyHitRecordsTable,
              StrategyHitRecordRow
            >,
          ),
          StrategyHitRecordRow,
          PrefetchHooks Function()
        > {
  $$StrategyHitRecordsTableTableManager(
    _$AppDatabase db,
    $StrategyHitRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrategyHitRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrategyHitRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrategyHitRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> strategyId = const Value.absent(),
                Value<String> stockCode = const Value.absent(),
                Value<String> stockName = const Value.absent(),
                Value<String> recommendDate = const Value.absent(),
                Value<int> recommendScore = const Value.absent(),
                Value<double> recommendPrice = const Value.absent(),
                Value<double?> actualChange5d = const Value.absent(),
                Value<bool?> isHit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrategyHitRecordsCompanion(
                id: id,
                strategyId: strategyId,
                stockCode: stockCode,
                stockName: stockName,
                recommendDate: recommendDate,
                recommendScore: recommendScore,
                recommendPrice: recommendPrice,
                actualChange5d: actualChange5d,
                isHit: isHit,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String strategyId,
                required String stockCode,
                required String stockName,
                required String recommendDate,
                required int recommendScore,
                required double recommendPrice,
                Value<double?> actualChange5d = const Value.absent(),
                Value<bool?> isHit = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StrategyHitRecordsCompanion.insert(
                id: id,
                strategyId: strategyId,
                stockCode: stockCode,
                stockName: stockName,
                recommendDate: recommendDate,
                recommendScore: recommendScore,
                recommendPrice: recommendPrice,
                actualChange5d: actualChange5d,
                isHit: isHit,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StrategyHitRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrategyHitRecordsTable,
      StrategyHitRecordRow,
      $$StrategyHitRecordsTableFilterComposer,
      $$StrategyHitRecordsTableOrderingComposer,
      $$StrategyHitRecordsTableAnnotationComposer,
      $$StrategyHitRecordsTableCreateCompanionBuilder,
      $$StrategyHitRecordsTableUpdateCompanionBuilder,
      (
        StrategyHitRecordRow,
        BaseReferences<
          _$AppDatabase,
          $StrategyHitRecordsTable,
          StrategyHitRecordRow
        >,
      ),
      StrategyHitRecordRow,
      PrefetchHooks Function()
    >;
typedef $$StrategyReviewsTableCreateCompanionBuilder =
    StrategyReviewsCompanion Function({
      required String id,
      required String strategyId,
      required DateTime reviewDate,
      required double healthScore,
      required double hitRate30d,
      required double avgChange30d,
      Value<double?> maxLoss30d,
      required String hitRateTrend,
      required int avgDailyCount30d,
      required String checklistResult,
      Value<String?> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StrategyReviewsTableUpdateCompanionBuilder =
    StrategyReviewsCompanion Function({
      Value<String> id,
      Value<String> strategyId,
      Value<DateTime> reviewDate,
      Value<double> healthScore,
      Value<double> hitRate30d,
      Value<double> avgChange30d,
      Value<double?> maxLoss30d,
      Value<String> hitRateTrend,
      Value<int> avgDailyCount30d,
      Value<String> checklistResult,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$StrategyReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $StrategyReviewsTable> {
  $$StrategyReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strategyId => $composableBuilder(
    column: $table.strategyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewDate => $composableBuilder(
    column: $table.reviewDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get healthScore => $composableBuilder(
    column: $table.healthScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hitRate30d => $composableBuilder(
    column: $table.hitRate30d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgChange30d => $composableBuilder(
    column: $table.avgChange30d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxLoss30d => $composableBuilder(
    column: $table.maxLoss30d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hitRateTrend => $composableBuilder(
    column: $table.hitRateTrend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgDailyCount30d => $composableBuilder(
    column: $table.avgDailyCount30d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checklistResult => $composableBuilder(
    column: $table.checklistResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StrategyReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $StrategyReviewsTable> {
  $$StrategyReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strategyId => $composableBuilder(
    column: $table.strategyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewDate => $composableBuilder(
    column: $table.reviewDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get healthScore => $composableBuilder(
    column: $table.healthScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hitRate30d => $composableBuilder(
    column: $table.hitRate30d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgChange30d => $composableBuilder(
    column: $table.avgChange30d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxLoss30d => $composableBuilder(
    column: $table.maxLoss30d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hitRateTrend => $composableBuilder(
    column: $table.hitRateTrend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgDailyCount30d => $composableBuilder(
    column: $table.avgDailyCount30d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checklistResult => $composableBuilder(
    column: $table.checklistResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StrategyReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrategyReviewsTable> {
  $$StrategyReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get strategyId => $composableBuilder(
    column: $table.strategyId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewDate => $composableBuilder(
    column: $table.reviewDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get healthScore => $composableBuilder(
    column: $table.healthScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hitRate30d => $composableBuilder(
    column: $table.hitRate30d,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgChange30d => $composableBuilder(
    column: $table.avgChange30d,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxLoss30d => $composableBuilder(
    column: $table.maxLoss30d,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hitRateTrend => $composableBuilder(
    column: $table.hitRateTrend,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgDailyCount30d => $composableBuilder(
    column: $table.avgDailyCount30d,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checklistResult => $composableBuilder(
    column: $table.checklistResult,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StrategyReviewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrategyReviewsTable,
          StrategyReviewRow,
          $$StrategyReviewsTableFilterComposer,
          $$StrategyReviewsTableOrderingComposer,
          $$StrategyReviewsTableAnnotationComposer,
          $$StrategyReviewsTableCreateCompanionBuilder,
          $$StrategyReviewsTableUpdateCompanionBuilder,
          (
            StrategyReviewRow,
            BaseReferences<
              _$AppDatabase,
              $StrategyReviewsTable,
              StrategyReviewRow
            >,
          ),
          StrategyReviewRow,
          PrefetchHooks Function()
        > {
  $$StrategyReviewsTableTableManager(
    _$AppDatabase db,
    $StrategyReviewsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrategyReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrategyReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrategyReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> strategyId = const Value.absent(),
                Value<DateTime> reviewDate = const Value.absent(),
                Value<double> healthScore = const Value.absent(),
                Value<double> hitRate30d = const Value.absent(),
                Value<double> avgChange30d = const Value.absent(),
                Value<double?> maxLoss30d = const Value.absent(),
                Value<String> hitRateTrend = const Value.absent(),
                Value<int> avgDailyCount30d = const Value.absent(),
                Value<String> checklistResult = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrategyReviewsCompanion(
                id: id,
                strategyId: strategyId,
                reviewDate: reviewDate,
                healthScore: healthScore,
                hitRate30d: hitRate30d,
                avgChange30d: avgChange30d,
                maxLoss30d: maxLoss30d,
                hitRateTrend: hitRateTrend,
                avgDailyCount30d: avgDailyCount30d,
                checklistResult: checklistResult,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String strategyId,
                required DateTime reviewDate,
                required double healthScore,
                required double hitRate30d,
                required double avgChange30d,
                Value<double?> maxLoss30d = const Value.absent(),
                required String hitRateTrend,
                required int avgDailyCount30d,
                required String checklistResult,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StrategyReviewsCompanion.insert(
                id: id,
                strategyId: strategyId,
                reviewDate: reviewDate,
                healthScore: healthScore,
                hitRate30d: hitRate30d,
                avgChange30d: avgChange30d,
                maxLoss30d: maxLoss30d,
                hitRateTrend: hitRateTrend,
                avgDailyCount30d: avgDailyCount30d,
                checklistResult: checklistResult,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StrategyReviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrategyReviewsTable,
      StrategyReviewRow,
      $$StrategyReviewsTableFilterComposer,
      $$StrategyReviewsTableOrderingComposer,
      $$StrategyReviewsTableAnnotationComposer,
      $$StrategyReviewsTableCreateCompanionBuilder,
      $$StrategyReviewsTableUpdateCompanionBuilder,
      (
        StrategyReviewRow,
        BaseReferences<_$AppDatabase, $StrategyReviewsTable, StrategyReviewRow>,
      ),
      StrategyReviewRow,
      PrefetchHooks Function()
    >;
typedef $$StrategySourcesTableCreateCompanionBuilder =
    StrategySourcesCompanion Function({
      required String id,
      required String strategyId,
      required String externalRef,
      required String sourceType,
      Value<String?> speaker,
      Value<DateTime?> capturedAt,
      required String summary,
      Value<String?> sanitizedText,
      required String fingerprint,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StrategySourcesTableUpdateCompanionBuilder =
    StrategySourcesCompanion Function({
      Value<String> id,
      Value<String> strategyId,
      Value<String> externalRef,
      Value<String> sourceType,
      Value<String?> speaker,
      Value<DateTime?> capturedAt,
      Value<String> summary,
      Value<String?> sanitizedText,
      Value<String> fingerprint,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$StrategySourcesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StrategySourcesTable,
          StrategySourceRow
        > {
  $$StrategySourcesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StrategiesTable _strategyIdTable(_$AppDatabase db) =>
      db.strategies.createAlias(
        $_aliasNameGenerator(db.strategySources.strategyId, db.strategies.id),
      );

  $$StrategiesTableProcessedTableManager get strategyId {
    final $_column = $_itemColumn<String>('strategy_id')!;

    final manager = $$StrategiesTableTableManager(
      $_db,
      $_db.strategies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_strategyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $StrategyVersionSourcesTable,
    List<StrategyVersionSourceRow>
  >
  _strategyVersionSourcesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.strategyVersionSources,
        aliasName: $_aliasNameGenerator(
          db.strategySources.id,
          db.strategyVersionSources.sourceId,
        ),
      );

  $$StrategyVersionSourcesTableProcessedTableManager
  get strategyVersionSourcesRefs {
    final manager = $$StrategyVersionSourcesTableTableManager(
      $_db,
      $_db.strategyVersionSources,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _strategyVersionSourcesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StrategySourcesTableFilterComposer
    extends Composer<_$AppDatabase, $StrategySourcesTable> {
  $$StrategySourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sanitizedText => $composableBuilder(
    column: $table.sanitizedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StrategiesTableFilterComposer get strategyId {
    final $$StrategiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableFilterComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> strategyVersionSourcesRefs(
    Expression<bool> Function($$StrategyVersionSourcesTableFilterComposer f) f,
  ) {
    final $$StrategyVersionSourcesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.strategyVersionSources,
          getReferencedColumn: (t) => t.sourceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StrategyVersionSourcesTableFilterComposer(
                $db: $db,
                $table: $db.strategyVersionSources,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StrategySourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $StrategySourcesTable> {
  $$StrategySourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sanitizedText => $composableBuilder(
    column: $table.sanitizedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StrategiesTableOrderingComposer get strategyId {
    final $$StrategiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableOrderingComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrategySourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrategySourcesTable> {
  $$StrategySourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get speaker =>
      $composableBuilder(column: $table.speaker, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get sanitizedText => $composableBuilder(
    column: $table.sanitizedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StrategiesTableAnnotationComposer get strategyId {
    final $$StrategiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableAnnotationComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> strategyVersionSourcesRefs<T extends Object>(
    Expression<T> Function($$StrategyVersionSourcesTableAnnotationComposer a) f,
  ) {
    final $$StrategyVersionSourcesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.strategyVersionSources,
          getReferencedColumn: (t) => t.sourceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StrategyVersionSourcesTableAnnotationComposer(
                $db: $db,
                $table: $db.strategyVersionSources,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StrategySourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrategySourcesTable,
          StrategySourceRow,
          $$StrategySourcesTableFilterComposer,
          $$StrategySourcesTableOrderingComposer,
          $$StrategySourcesTableAnnotationComposer,
          $$StrategySourcesTableCreateCompanionBuilder,
          $$StrategySourcesTableUpdateCompanionBuilder,
          (StrategySourceRow, $$StrategySourcesTableReferences),
          StrategySourceRow,
          PrefetchHooks Function({
            bool strategyId,
            bool strategyVersionSourcesRefs,
          })
        > {
  $$StrategySourcesTableTableManager(
    _$AppDatabase db,
    $StrategySourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrategySourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrategySourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrategySourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> strategyId = const Value.absent(),
                Value<String> externalRef = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String?> speaker = const Value.absent(),
                Value<DateTime?> capturedAt = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> sanitizedText = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrategySourcesCompanion(
                id: id,
                strategyId: strategyId,
                externalRef: externalRef,
                sourceType: sourceType,
                speaker: speaker,
                capturedAt: capturedAt,
                summary: summary,
                sanitizedText: sanitizedText,
                fingerprint: fingerprint,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String strategyId,
                required String externalRef,
                required String sourceType,
                Value<String?> speaker = const Value.absent(),
                Value<DateTime?> capturedAt = const Value.absent(),
                required String summary,
                Value<String?> sanitizedText = const Value.absent(),
                required String fingerprint,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StrategySourcesCompanion.insert(
                id: id,
                strategyId: strategyId,
                externalRef: externalRef,
                sourceType: sourceType,
                speaker: speaker,
                capturedAt: capturedAt,
                summary: summary,
                sanitizedText: sanitizedText,
                fingerprint: fingerprint,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StrategySourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({strategyId = false, strategyVersionSourcesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (strategyVersionSourcesRefs) db.strategyVersionSources,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (strategyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.strategyId,
                                    referencedTable:
                                        $$StrategySourcesTableReferences
                                            ._strategyIdTable(db),
                                    referencedColumn:
                                        $$StrategySourcesTableReferences
                                            ._strategyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (strategyVersionSourcesRefs)
                        await $_getPrefetchedData<
                          StrategySourceRow,
                          $StrategySourcesTable,
                          StrategyVersionSourceRow
                        >(
                          currentTable: table,
                          referencedTable: $$StrategySourcesTableReferences
                              ._strategyVersionSourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StrategySourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).strategyVersionSourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StrategySourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrategySourcesTable,
      StrategySourceRow,
      $$StrategySourcesTableFilterComposer,
      $$StrategySourcesTableOrderingComposer,
      $$StrategySourcesTableAnnotationComposer,
      $$StrategySourcesTableCreateCompanionBuilder,
      $$StrategySourcesTableUpdateCompanionBuilder,
      (StrategySourceRow, $$StrategySourcesTableReferences),
      StrategySourceRow,
      PrefetchHooks Function({bool strategyId, bool strategyVersionSourcesRefs})
    >;
typedef $$StrategyVersionsTableCreateCompanionBuilder =
    StrategyVersionsCompanion Function({
      required String id,
      required String strategyId,
      required int versionNumber,
      required String status,
      required String strategyType,
      required String strategySnapshotJson,
      Value<String?> packageJson,
      required String applicabilityJson,
      required String riskNotesJson,
      required String pendingQuestionsJson,
      required String compatibilityIssuesJson,
      Value<String?> previousVersionId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StrategyVersionsTableUpdateCompanionBuilder =
    StrategyVersionsCompanion Function({
      Value<String> id,
      Value<String> strategyId,
      Value<int> versionNumber,
      Value<String> status,
      Value<String> strategyType,
      Value<String> strategySnapshotJson,
      Value<String?> packageJson,
      Value<String> applicabilityJson,
      Value<String> riskNotesJson,
      Value<String> pendingQuestionsJson,
      Value<String> compatibilityIssuesJson,
      Value<String?> previousVersionId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$StrategyVersionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StrategyVersionsTable,
          StrategyVersionRow
        > {
  $$StrategyVersionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StrategiesTable _strategyIdTable(_$AppDatabase db) =>
      db.strategies.createAlias(
        $_aliasNameGenerator(db.strategyVersions.strategyId, db.strategies.id),
      );

  $$StrategiesTableProcessedTableManager get strategyId {
    final $_column = $_itemColumn<String>('strategy_id')!;

    final manager = $$StrategiesTableTableManager(
      $_db,
      $_db.strategies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_strategyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $StrategyVersionSourcesTable,
    List<StrategyVersionSourceRow>
  >
  _strategyVersionSourcesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.strategyVersionSources,
        aliasName: $_aliasNameGenerator(
          db.strategyVersions.id,
          db.strategyVersionSources.versionId,
        ),
      );

  $$StrategyVersionSourcesTableProcessedTableManager
  get strategyVersionSourcesRefs {
    final manager = $$StrategyVersionSourcesTableTableManager(
      $_db,
      $_db.strategyVersionSources,
    ).filter((f) => f.versionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _strategyVersionSourcesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StrategyBacktestRunsTable,
    List<StrategyBacktestRunRow>
  >
  _strategyBacktestRunsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.strategyBacktestRuns,
        aliasName: $_aliasNameGenerator(
          db.strategyVersions.id,
          db.strategyBacktestRuns.strategyVersionId,
        ),
      );

  $$StrategyBacktestRunsTableProcessedTableManager
  get strategyBacktestRunsRefs {
    final manager =
        $$StrategyBacktestRunsTableTableManager(
          $_db,
          $_db.strategyBacktestRuns,
        ).filter(
          (f) => f.strategyVersionId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _strategyBacktestRunsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StrategyVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $StrategyVersionsTable> {
  $$StrategyVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strategyType => $composableBuilder(
    column: $table.strategyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strategySnapshotJson => $composableBuilder(
    column: $table.strategySnapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageJson => $composableBuilder(
    column: $table.packageJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get applicabilityJson => $composableBuilder(
    column: $table.applicabilityJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riskNotesJson => $composableBuilder(
    column: $table.riskNotesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingQuestionsJson => $composableBuilder(
    column: $table.pendingQuestionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get compatibilityIssuesJson => $composableBuilder(
    column: $table.compatibilityIssuesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousVersionId => $composableBuilder(
    column: $table.previousVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StrategiesTableFilterComposer get strategyId {
    final $$StrategiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableFilterComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> strategyVersionSourcesRefs(
    Expression<bool> Function($$StrategyVersionSourcesTableFilterComposer f) f,
  ) {
    final $$StrategyVersionSourcesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.strategyVersionSources,
          getReferencedColumn: (t) => t.versionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StrategyVersionSourcesTableFilterComposer(
                $db: $db,
                $table: $db.strategyVersionSources,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> strategyBacktestRunsRefs(
    Expression<bool> Function($$StrategyBacktestRunsTableFilterComposer f) f,
  ) {
    final $$StrategyBacktestRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strategyBacktestRuns,
      getReferencedColumn: (t) => t.strategyVersionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategyBacktestRunsTableFilterComposer(
            $db: $db,
            $table: $db.strategyBacktestRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StrategyVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StrategyVersionsTable> {
  $$StrategyVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strategyType => $composableBuilder(
    column: $table.strategyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strategySnapshotJson => $composableBuilder(
    column: $table.strategySnapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageJson => $composableBuilder(
    column: $table.packageJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get applicabilityJson => $composableBuilder(
    column: $table.applicabilityJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riskNotesJson => $composableBuilder(
    column: $table.riskNotesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingQuestionsJson => $composableBuilder(
    column: $table.pendingQuestionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get compatibilityIssuesJson => $composableBuilder(
    column: $table.compatibilityIssuesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousVersionId => $composableBuilder(
    column: $table.previousVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StrategiesTableOrderingComposer get strategyId {
    final $$StrategiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableOrderingComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrategyVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrategyVersionsTable> {
  $$StrategyVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get strategyType => $composableBuilder(
    column: $table.strategyType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get strategySnapshotJson => $composableBuilder(
    column: $table.strategySnapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packageJson => $composableBuilder(
    column: $table.packageJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get applicabilityJson => $composableBuilder(
    column: $table.applicabilityJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get riskNotesJson => $composableBuilder(
    column: $table.riskNotesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pendingQuestionsJson => $composableBuilder(
    column: $table.pendingQuestionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get compatibilityIssuesJson => $composableBuilder(
    column: $table.compatibilityIssuesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousVersionId => $composableBuilder(
    column: $table.previousVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StrategiesTableAnnotationComposer get strategyId {
    final $$StrategiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableAnnotationComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> strategyVersionSourcesRefs<T extends Object>(
    Expression<T> Function($$StrategyVersionSourcesTableAnnotationComposer a) f,
  ) {
    final $$StrategyVersionSourcesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.strategyVersionSources,
          getReferencedColumn: (t) => t.versionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StrategyVersionSourcesTableAnnotationComposer(
                $db: $db,
                $table: $db.strategyVersionSources,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> strategyBacktestRunsRefs<T extends Object>(
    Expression<T> Function($$StrategyBacktestRunsTableAnnotationComposer a) f,
  ) {
    final $$StrategyBacktestRunsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.strategyBacktestRuns,
          getReferencedColumn: (t) => t.strategyVersionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StrategyBacktestRunsTableAnnotationComposer(
                $db: $db,
                $table: $db.strategyBacktestRuns,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StrategyVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrategyVersionsTable,
          StrategyVersionRow,
          $$StrategyVersionsTableFilterComposer,
          $$StrategyVersionsTableOrderingComposer,
          $$StrategyVersionsTableAnnotationComposer,
          $$StrategyVersionsTableCreateCompanionBuilder,
          $$StrategyVersionsTableUpdateCompanionBuilder,
          (StrategyVersionRow, $$StrategyVersionsTableReferences),
          StrategyVersionRow,
          PrefetchHooks Function({
            bool strategyId,
            bool strategyVersionSourcesRefs,
            bool strategyBacktestRunsRefs,
          })
        > {
  $$StrategyVersionsTableTableManager(
    _$AppDatabase db,
    $StrategyVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrategyVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrategyVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrategyVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> strategyId = const Value.absent(),
                Value<int> versionNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> strategyType = const Value.absent(),
                Value<String> strategySnapshotJson = const Value.absent(),
                Value<String?> packageJson = const Value.absent(),
                Value<String> applicabilityJson = const Value.absent(),
                Value<String> riskNotesJson = const Value.absent(),
                Value<String> pendingQuestionsJson = const Value.absent(),
                Value<String> compatibilityIssuesJson = const Value.absent(),
                Value<String?> previousVersionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrategyVersionsCompanion(
                id: id,
                strategyId: strategyId,
                versionNumber: versionNumber,
                status: status,
                strategyType: strategyType,
                strategySnapshotJson: strategySnapshotJson,
                packageJson: packageJson,
                applicabilityJson: applicabilityJson,
                riskNotesJson: riskNotesJson,
                pendingQuestionsJson: pendingQuestionsJson,
                compatibilityIssuesJson: compatibilityIssuesJson,
                previousVersionId: previousVersionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String strategyId,
                required int versionNumber,
                required String status,
                required String strategyType,
                required String strategySnapshotJson,
                Value<String?> packageJson = const Value.absent(),
                required String applicabilityJson,
                required String riskNotesJson,
                required String pendingQuestionsJson,
                required String compatibilityIssuesJson,
                Value<String?> previousVersionId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StrategyVersionsCompanion.insert(
                id: id,
                strategyId: strategyId,
                versionNumber: versionNumber,
                status: status,
                strategyType: strategyType,
                strategySnapshotJson: strategySnapshotJson,
                packageJson: packageJson,
                applicabilityJson: applicabilityJson,
                riskNotesJson: riskNotesJson,
                pendingQuestionsJson: pendingQuestionsJson,
                compatibilityIssuesJson: compatibilityIssuesJson,
                previousVersionId: previousVersionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StrategyVersionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                strategyId = false,
                strategyVersionSourcesRefs = false,
                strategyBacktestRunsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (strategyVersionSourcesRefs) db.strategyVersionSources,
                    if (strategyBacktestRunsRefs) db.strategyBacktestRuns,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (strategyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.strategyId,
                                    referencedTable:
                                        $$StrategyVersionsTableReferences
                                            ._strategyIdTable(db),
                                    referencedColumn:
                                        $$StrategyVersionsTableReferences
                                            ._strategyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (strategyVersionSourcesRefs)
                        await $_getPrefetchedData<
                          StrategyVersionRow,
                          $StrategyVersionsTable,
                          StrategyVersionSourceRow
                        >(
                          currentTable: table,
                          referencedTable: $$StrategyVersionsTableReferences
                              ._strategyVersionSourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StrategyVersionsTableReferences(
                                db,
                                table,
                                p0,
                              ).strategyVersionSourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.versionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (strategyBacktestRunsRefs)
                        await $_getPrefetchedData<
                          StrategyVersionRow,
                          $StrategyVersionsTable,
                          StrategyBacktestRunRow
                        >(
                          currentTable: table,
                          referencedTable: $$StrategyVersionsTableReferences
                              ._strategyBacktestRunsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StrategyVersionsTableReferences(
                                db,
                                table,
                                p0,
                              ).strategyBacktestRunsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.strategyVersionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StrategyVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrategyVersionsTable,
      StrategyVersionRow,
      $$StrategyVersionsTableFilterComposer,
      $$StrategyVersionsTableOrderingComposer,
      $$StrategyVersionsTableAnnotationComposer,
      $$StrategyVersionsTableCreateCompanionBuilder,
      $$StrategyVersionsTableUpdateCompanionBuilder,
      (StrategyVersionRow, $$StrategyVersionsTableReferences),
      StrategyVersionRow,
      PrefetchHooks Function({
        bool strategyId,
        bool strategyVersionSourcesRefs,
        bool strategyBacktestRunsRefs,
      })
    >;
typedef $$StrategyVersionSourcesTableCreateCompanionBuilder =
    StrategyVersionSourcesCompanion Function({
      required String versionId,
      required String sourceId,
      required String ruleIdsJson,
      Value<int> rowid,
    });
typedef $$StrategyVersionSourcesTableUpdateCompanionBuilder =
    StrategyVersionSourcesCompanion Function({
      Value<String> versionId,
      Value<String> sourceId,
      Value<String> ruleIdsJson,
      Value<int> rowid,
    });

final class $$StrategyVersionSourcesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StrategyVersionSourcesTable,
          StrategyVersionSourceRow
        > {
  $$StrategyVersionSourcesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StrategyVersionsTable _versionIdTable(_$AppDatabase db) =>
      db.strategyVersions.createAlias(
        $_aliasNameGenerator(
          db.strategyVersionSources.versionId,
          db.strategyVersions.id,
        ),
      );

  $$StrategyVersionsTableProcessedTableManager get versionId {
    final $_column = $_itemColumn<String>('version_id')!;

    final manager = $$StrategyVersionsTableTableManager(
      $_db,
      $_db.strategyVersions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_versionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StrategySourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.strategySources.createAlias(
        $_aliasNameGenerator(
          db.strategyVersionSources.sourceId,
          db.strategySources.id,
        ),
      );

  $$StrategySourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$StrategySourcesTableTableManager(
      $_db,
      $_db.strategySources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StrategyVersionSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $StrategyVersionSourcesTable> {
  $$StrategyVersionSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ruleIdsJson => $composableBuilder(
    column: $table.ruleIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  $$StrategyVersionsTableFilterComposer get versionId {
    final $$StrategyVersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.strategyVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategyVersionsTableFilterComposer(
            $db: $db,
            $table: $db.strategyVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrategySourcesTableFilterComposer get sourceId {
    final $$StrategySourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.strategySources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategySourcesTableFilterComposer(
            $db: $db,
            $table: $db.strategySources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrategyVersionSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $StrategyVersionSourcesTable> {
  $$StrategyVersionSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ruleIdsJson => $composableBuilder(
    column: $table.ruleIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$StrategyVersionsTableOrderingComposer get versionId {
    final $$StrategyVersionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.strategyVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategyVersionsTableOrderingComposer(
            $db: $db,
            $table: $db.strategyVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrategySourcesTableOrderingComposer get sourceId {
    final $$StrategySourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.strategySources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategySourcesTableOrderingComposer(
            $db: $db,
            $table: $db.strategySources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrategyVersionSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrategyVersionSourcesTable> {
  $$StrategyVersionSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ruleIdsJson => $composableBuilder(
    column: $table.ruleIdsJson,
    builder: (column) => column,
  );

  $$StrategyVersionsTableAnnotationComposer get versionId {
    final $$StrategyVersionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.strategyVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategyVersionsTableAnnotationComposer(
            $db: $db,
            $table: $db.strategyVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrategySourcesTableAnnotationComposer get sourceId {
    final $$StrategySourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.strategySources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategySourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.strategySources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrategyVersionSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrategyVersionSourcesTable,
          StrategyVersionSourceRow,
          $$StrategyVersionSourcesTableFilterComposer,
          $$StrategyVersionSourcesTableOrderingComposer,
          $$StrategyVersionSourcesTableAnnotationComposer,
          $$StrategyVersionSourcesTableCreateCompanionBuilder,
          $$StrategyVersionSourcesTableUpdateCompanionBuilder,
          (StrategyVersionSourceRow, $$StrategyVersionSourcesTableReferences),
          StrategyVersionSourceRow,
          PrefetchHooks Function({bool versionId, bool sourceId})
        > {
  $$StrategyVersionSourcesTableTableManager(
    _$AppDatabase db,
    $StrategyVersionSourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrategyVersionSourcesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$StrategyVersionSourcesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StrategyVersionSourcesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> versionId = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> ruleIdsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrategyVersionSourcesCompanion(
                versionId: versionId,
                sourceId: sourceId,
                ruleIdsJson: ruleIdsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String versionId,
                required String sourceId,
                required String ruleIdsJson,
                Value<int> rowid = const Value.absent(),
              }) => StrategyVersionSourcesCompanion.insert(
                versionId: versionId,
                sourceId: sourceId,
                ruleIdsJson: ruleIdsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StrategyVersionSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({versionId = false, sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (versionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.versionId,
                                referencedTable:
                                    $$StrategyVersionSourcesTableReferences
                                        ._versionIdTable(db),
                                referencedColumn:
                                    $$StrategyVersionSourcesTableReferences
                                        ._versionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (sourceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sourceId,
                                referencedTable:
                                    $$StrategyVersionSourcesTableReferences
                                        ._sourceIdTable(db),
                                referencedColumn:
                                    $$StrategyVersionSourcesTableReferences
                                        ._sourceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StrategyVersionSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrategyVersionSourcesTable,
      StrategyVersionSourceRow,
      $$StrategyVersionSourcesTableFilterComposer,
      $$StrategyVersionSourcesTableOrderingComposer,
      $$StrategyVersionSourcesTableAnnotationComposer,
      $$StrategyVersionSourcesTableCreateCompanionBuilder,
      $$StrategyVersionSourcesTableUpdateCompanionBuilder,
      (StrategyVersionSourceRow, $$StrategyVersionSourcesTableReferences),
      StrategyVersionSourceRow,
      PrefetchHooks Function({bool versionId, bool sourceId})
    >;
typedef $$StrategyBacktestRunsTableCreateCompanionBuilder =
    StrategyBacktestRunsCompanion Function({
      required String id,
      required String strategyId,
      required String strategyVersionId,
      required int strategyVersionNumber,
      required String stockCode,
      required String stockName,
      required String market,
      required String configJson,
      required String resultJson,
      required String adjustmentMode,
      required String dataFingerprint,
      Value<DateTime?> dataStart,
      Value<DateTime?> dataEnd,
      required DateTime dataAsOf,
      required int barsProcessed,
      required int sampleCount,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StrategyBacktestRunsTableUpdateCompanionBuilder =
    StrategyBacktestRunsCompanion Function({
      Value<String> id,
      Value<String> strategyId,
      Value<String> strategyVersionId,
      Value<int> strategyVersionNumber,
      Value<String> stockCode,
      Value<String> stockName,
      Value<String> market,
      Value<String> configJson,
      Value<String> resultJson,
      Value<String> adjustmentMode,
      Value<String> dataFingerprint,
      Value<DateTime?> dataStart,
      Value<DateTime?> dataEnd,
      Value<DateTime> dataAsOf,
      Value<int> barsProcessed,
      Value<int> sampleCount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$StrategyBacktestRunsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StrategyBacktestRunsTable,
          StrategyBacktestRunRow
        > {
  $$StrategyBacktestRunsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StrategiesTable _strategyIdTable(_$AppDatabase db) =>
      db.strategies.createAlias(
        $_aliasNameGenerator(
          db.strategyBacktestRuns.strategyId,
          db.strategies.id,
        ),
      );

  $$StrategiesTableProcessedTableManager get strategyId {
    final $_column = $_itemColumn<String>('strategy_id')!;

    final manager = $$StrategiesTableTableManager(
      $_db,
      $_db.strategies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_strategyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StrategyVersionsTable _strategyVersionIdTable(_$AppDatabase db) =>
      db.strategyVersions.createAlias(
        $_aliasNameGenerator(
          db.strategyBacktestRuns.strategyVersionId,
          db.strategyVersions.id,
        ),
      );

  $$StrategyVersionsTableProcessedTableManager get strategyVersionId {
    final $_column = $_itemColumn<String>('strategy_version_id')!;

    final manager = $$StrategyVersionsTableTableManager(
      $_db,
      $_db.strategyVersions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_strategyVersionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StrategyBacktestRunsTableFilterComposer
    extends Composer<_$AppDatabase, $StrategyBacktestRunsTable> {
  $$StrategyBacktestRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strategyVersionNumber => $composableBuilder(
    column: $table.strategyVersionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stockCode => $composableBuilder(
    column: $table.stockCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stockName => $composableBuilder(
    column: $table.stockName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adjustmentMode => $composableBuilder(
    column: $table.adjustmentMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataFingerprint => $composableBuilder(
    column: $table.dataFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataStart => $composableBuilder(
    column: $table.dataStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataEnd => $composableBuilder(
    column: $table.dataEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataAsOf => $composableBuilder(
    column: $table.dataAsOf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get barsProcessed => $composableBuilder(
    column: $table.barsProcessed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StrategiesTableFilterComposer get strategyId {
    final $$StrategiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableFilterComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrategyVersionsTableFilterComposer get strategyVersionId {
    final $$StrategyVersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyVersionId,
      referencedTable: $db.strategyVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategyVersionsTableFilterComposer(
            $db: $db,
            $table: $db.strategyVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrategyBacktestRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $StrategyBacktestRunsTable> {
  $$StrategyBacktestRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strategyVersionNumber => $composableBuilder(
    column: $table.strategyVersionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stockCode => $composableBuilder(
    column: $table.stockCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stockName => $composableBuilder(
    column: $table.stockName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adjustmentMode => $composableBuilder(
    column: $table.adjustmentMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataFingerprint => $composableBuilder(
    column: $table.dataFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataStart => $composableBuilder(
    column: $table.dataStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataEnd => $composableBuilder(
    column: $table.dataEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataAsOf => $composableBuilder(
    column: $table.dataAsOf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get barsProcessed => $composableBuilder(
    column: $table.barsProcessed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StrategiesTableOrderingComposer get strategyId {
    final $$StrategiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableOrderingComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrategyVersionsTableOrderingComposer get strategyVersionId {
    final $$StrategyVersionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyVersionId,
      referencedTable: $db.strategyVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategyVersionsTableOrderingComposer(
            $db: $db,
            $table: $db.strategyVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrategyBacktestRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrategyBacktestRunsTable> {
  $$StrategyBacktestRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get strategyVersionNumber => $composableBuilder(
    column: $table.strategyVersionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stockCode =>
      $composableBuilder(column: $table.stockCode, builder: (column) => column);

  GeneratedColumn<String> get stockName =>
      $composableBuilder(column: $table.stockName, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adjustmentMode => $composableBuilder(
    column: $table.adjustmentMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataFingerprint => $composableBuilder(
    column: $table.dataFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataStart =>
      $composableBuilder(column: $table.dataStart, builder: (column) => column);

  GeneratedColumn<DateTime> get dataEnd =>
      $composableBuilder(column: $table.dataEnd, builder: (column) => column);

  GeneratedColumn<DateTime> get dataAsOf =>
      $composableBuilder(column: $table.dataAsOf, builder: (column) => column);

  GeneratedColumn<int> get barsProcessed => $composableBuilder(
    column: $table.barsProcessed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StrategiesTableAnnotationComposer get strategyId {
    final $$StrategiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableAnnotationComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrategyVersionsTableAnnotationComposer get strategyVersionId {
    final $$StrategyVersionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyVersionId,
      referencedTable: $db.strategyVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategyVersionsTableAnnotationComposer(
            $db: $db,
            $table: $db.strategyVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrategyBacktestRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrategyBacktestRunsTable,
          StrategyBacktestRunRow,
          $$StrategyBacktestRunsTableFilterComposer,
          $$StrategyBacktestRunsTableOrderingComposer,
          $$StrategyBacktestRunsTableAnnotationComposer,
          $$StrategyBacktestRunsTableCreateCompanionBuilder,
          $$StrategyBacktestRunsTableUpdateCompanionBuilder,
          (StrategyBacktestRunRow, $$StrategyBacktestRunsTableReferences),
          StrategyBacktestRunRow,
          PrefetchHooks Function({bool strategyId, bool strategyVersionId})
        > {
  $$StrategyBacktestRunsTableTableManager(
    _$AppDatabase db,
    $StrategyBacktestRunsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrategyBacktestRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrategyBacktestRunsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StrategyBacktestRunsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> strategyId = const Value.absent(),
                Value<String> strategyVersionId = const Value.absent(),
                Value<int> strategyVersionNumber = const Value.absent(),
                Value<String> stockCode = const Value.absent(),
                Value<String> stockName = const Value.absent(),
                Value<String> market = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<String> resultJson = const Value.absent(),
                Value<String> adjustmentMode = const Value.absent(),
                Value<String> dataFingerprint = const Value.absent(),
                Value<DateTime?> dataStart = const Value.absent(),
                Value<DateTime?> dataEnd = const Value.absent(),
                Value<DateTime> dataAsOf = const Value.absent(),
                Value<int> barsProcessed = const Value.absent(),
                Value<int> sampleCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrategyBacktestRunsCompanion(
                id: id,
                strategyId: strategyId,
                strategyVersionId: strategyVersionId,
                strategyVersionNumber: strategyVersionNumber,
                stockCode: stockCode,
                stockName: stockName,
                market: market,
                configJson: configJson,
                resultJson: resultJson,
                adjustmentMode: adjustmentMode,
                dataFingerprint: dataFingerprint,
                dataStart: dataStart,
                dataEnd: dataEnd,
                dataAsOf: dataAsOf,
                barsProcessed: barsProcessed,
                sampleCount: sampleCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String strategyId,
                required String strategyVersionId,
                required int strategyVersionNumber,
                required String stockCode,
                required String stockName,
                required String market,
                required String configJson,
                required String resultJson,
                required String adjustmentMode,
                required String dataFingerprint,
                Value<DateTime?> dataStart = const Value.absent(),
                Value<DateTime?> dataEnd = const Value.absent(),
                required DateTime dataAsOf,
                required int barsProcessed,
                required int sampleCount,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StrategyBacktestRunsCompanion.insert(
                id: id,
                strategyId: strategyId,
                strategyVersionId: strategyVersionId,
                strategyVersionNumber: strategyVersionNumber,
                stockCode: stockCode,
                stockName: stockName,
                market: market,
                configJson: configJson,
                resultJson: resultJson,
                adjustmentMode: adjustmentMode,
                dataFingerprint: dataFingerprint,
                dataStart: dataStart,
                dataEnd: dataEnd,
                dataAsOf: dataAsOf,
                barsProcessed: barsProcessed,
                sampleCount: sampleCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StrategyBacktestRunsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({strategyId = false, strategyVersionId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (strategyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.strategyId,
                                    referencedTable:
                                        $$StrategyBacktestRunsTableReferences
                                            ._strategyIdTable(db),
                                    referencedColumn:
                                        $$StrategyBacktestRunsTableReferences
                                            ._strategyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (strategyVersionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.strategyVersionId,
                                    referencedTable:
                                        $$StrategyBacktestRunsTableReferences
                                            ._strategyVersionIdTable(db),
                                    referencedColumn:
                                        $$StrategyBacktestRunsTableReferences
                                            ._strategyVersionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$StrategyBacktestRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrategyBacktestRunsTable,
      StrategyBacktestRunRow,
      $$StrategyBacktestRunsTableFilterComposer,
      $$StrategyBacktestRunsTableOrderingComposer,
      $$StrategyBacktestRunsTableAnnotationComposer,
      $$StrategyBacktestRunsTableCreateCompanionBuilder,
      $$StrategyBacktestRunsTableUpdateCompanionBuilder,
      (StrategyBacktestRunRow, $$StrategyBacktestRunsTableReferences),
      StrategyBacktestRunRow,
      PrefetchHooks Function({bool strategyId, bool strategyVersionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WatchlistItemsTableTableManager get watchlistItems =>
      $$WatchlistItemsTableTableManager(_db, _db.watchlistItems);
  $$StrategiesTableTableManager get strategies =>
      $$StrategiesTableTableManager(_db, _db.strategies);
  $$StrategyHitRecordsTableTableManager get strategyHitRecords =>
      $$StrategyHitRecordsTableTableManager(_db, _db.strategyHitRecords);
  $$StrategyReviewsTableTableManager get strategyReviews =>
      $$StrategyReviewsTableTableManager(_db, _db.strategyReviews);
  $$StrategySourcesTableTableManager get strategySources =>
      $$StrategySourcesTableTableManager(_db, _db.strategySources);
  $$StrategyVersionsTableTableManager get strategyVersions =>
      $$StrategyVersionsTableTableManager(_db, _db.strategyVersions);
  $$StrategyVersionSourcesTableTableManager get strategyVersionSources =>
      $$StrategyVersionSourcesTableTableManager(
        _db,
        _db.strategyVersionSources,
      );
  $$StrategyBacktestRunsTableTableManager get strategyBacktestRuns =>
      $$StrategyBacktestRunsTableTableManager(_db, _db.strategyBacktestRuns);
}
