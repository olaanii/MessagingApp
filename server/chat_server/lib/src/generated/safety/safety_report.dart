/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

/// User-generated safety report (opaque message ids only; no ciphertext). ADR-0007.
abstract class SafetyReport
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  SafetyReport._({
    this.id,
    required this.reporterAuthUserId,
    this.targetUserId,
    this.targetChatId,
    this.targetMessageId,
    required this.reason,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SafetyReport({
    _i1.UuidValue? id,
    required _i1.UuidValue reporterAuthUserId,
    _i1.UuidValue? targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
    DateTime? createdAt,
  }) = _SafetyReportImpl;

  factory SafetyReport.fromJson(Map<String, dynamic> jsonSerialization) {
    return SafetyReport(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      reporterAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['reporterAuthUserId'],
      ),
      targetUserId: jsonSerialization['targetUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['targetUserId'],
            ),
      targetChatId: jsonSerialization['targetChatId'] as String?,
      targetMessageId: jsonSerialization['targetMessageId'] as String?,
      reason: jsonSerialization['reason'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = SafetyReportTable();

  static const db = SafetyReportRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue reporterAuthUserId;

  _i1.UuidValue? targetUserId;

  String? targetChatId;

  String? targetMessageId;

  String reason;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [SafetyReport]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SafetyReport copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? reporterAuthUserId,
    _i1.UuidValue? targetUserId,
    String? targetChatId,
    String? targetMessageId,
    String? reason,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SafetyReport',
      if (id != null) 'id': id?.toJson(),
      'reporterAuthUserId': reporterAuthUserId.toJson(),
      if (targetUserId != null) 'targetUserId': targetUserId?.toJson(),
      if (targetChatId != null) 'targetChatId': targetChatId,
      if (targetMessageId != null) 'targetMessageId': targetMessageId,
      'reason': reason,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SafetyReport',
      if (id != null) 'id': id?.toJson(),
      'reporterAuthUserId': reporterAuthUserId.toJson(),
      if (targetUserId != null) 'targetUserId': targetUserId?.toJson(),
      if (targetChatId != null) 'targetChatId': targetChatId,
      if (targetMessageId != null) 'targetMessageId': targetMessageId,
      'reason': reason,
      'createdAt': createdAt.toJson(),
    };
  }

  static SafetyReportInclude include() {
    return SafetyReportInclude._();
  }

  static SafetyReportIncludeList includeList({
    _i1.WhereExpressionBuilder<SafetyReportTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SafetyReportTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SafetyReportTable>? orderByList,
    SafetyReportInclude? include,
  }) {
    return SafetyReportIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SafetyReport.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SafetyReport.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SafetyReportImpl extends SafetyReport {
  _SafetyReportImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue reporterAuthUserId,
    _i1.UuidValue? targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
    DateTime? createdAt,
  }) : super._(
         id: id,
         reporterAuthUserId: reporterAuthUserId,
         targetUserId: targetUserId,
         targetChatId: targetChatId,
         targetMessageId: targetMessageId,
         reason: reason,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SafetyReport]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SafetyReport copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? reporterAuthUserId,
    Object? targetUserId = _Undefined,
    Object? targetChatId = _Undefined,
    Object? targetMessageId = _Undefined,
    String? reason,
    DateTime? createdAt,
  }) {
    return SafetyReport(
      id: id is _i1.UuidValue? ? id : this.id,
      reporterAuthUserId: reporterAuthUserId ?? this.reporterAuthUserId,
      targetUserId: targetUserId is _i1.UuidValue?
          ? targetUserId
          : this.targetUserId,
      targetChatId: targetChatId is String? ? targetChatId : this.targetChatId,
      targetMessageId: targetMessageId is String?
          ? targetMessageId
          : this.targetMessageId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SafetyReportUpdateTable extends _i1.UpdateTable<SafetyReportTable> {
  SafetyReportUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> reporterAuthUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.reporterAuthUserId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> targetUserId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.targetUserId,
    value,
  );

  _i1.ColumnValue<String, String> targetChatId(String? value) =>
      _i1.ColumnValue(
        table.targetChatId,
        value,
      );

  _i1.ColumnValue<String, String> targetMessageId(String? value) =>
      _i1.ColumnValue(
        table.targetMessageId,
        value,
      );

  _i1.ColumnValue<String, String> reason(String value) => _i1.ColumnValue(
    table.reason,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class SafetyReportTable extends _i1.Table<_i1.UuidValue?> {
  SafetyReportTable({super.tableRelation}) : super(tableName: 'safety_report') {
    updateTable = SafetyReportUpdateTable(this);
    reporterAuthUserId = _i1.ColumnUuid(
      'reporterAuthUserId',
      this,
    );
    targetUserId = _i1.ColumnUuid(
      'targetUserId',
      this,
    );
    targetChatId = _i1.ColumnString(
      'targetChatId',
      this,
    );
    targetMessageId = _i1.ColumnString(
      'targetMessageId',
      this,
    );
    reason = _i1.ColumnString(
      'reason',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final SafetyReportUpdateTable updateTable;

  late final _i1.ColumnUuid reporterAuthUserId;

  late final _i1.ColumnUuid targetUserId;

  late final _i1.ColumnString targetChatId;

  late final _i1.ColumnString targetMessageId;

  late final _i1.ColumnString reason;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    reporterAuthUserId,
    targetUserId,
    targetChatId,
    targetMessageId,
    reason,
    createdAt,
  ];
}

class SafetyReportInclude extends _i1.IncludeObject {
  SafetyReportInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SafetyReport.t;
}

class SafetyReportIncludeList extends _i1.IncludeList {
  SafetyReportIncludeList._({
    _i1.WhereExpressionBuilder<SafetyReportTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SafetyReport.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SafetyReport.t;
}

class SafetyReportRepository {
  const SafetyReportRepository._();

  /// Returns a list of [SafetyReport]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<SafetyReport>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SafetyReportTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SafetyReportTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SafetyReportTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SafetyReport>(
      where: where?.call(SafetyReport.t),
      orderBy: orderBy?.call(SafetyReport.t),
      orderByList: orderByList?.call(SafetyReport.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SafetyReport] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<SafetyReport?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SafetyReportTable>? where,
    int? offset,
    _i1.OrderByBuilder<SafetyReportTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SafetyReportTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SafetyReport>(
      where: where?.call(SafetyReport.t),
      orderBy: orderBy?.call(SafetyReport.t),
      orderByList: orderByList?.call(SafetyReport.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SafetyReport] by its [id] or null if no such row exists.
  Future<SafetyReport?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SafetyReport>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SafetyReport]s in the list and returns the inserted rows.
  ///
  /// The returned [SafetyReport]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<SafetyReport>> insert(
    _i1.DatabaseSession session,
    List<SafetyReport> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<SafetyReport>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [SafetyReport] and returns the inserted row.
  ///
  /// The returned [SafetyReport] will have its `id` field set.
  Future<SafetyReport> insertRow(
    _i1.DatabaseSession session,
    SafetyReport row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SafetyReport>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SafetyReport]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SafetyReport>> update(
    _i1.DatabaseSession session,
    List<SafetyReport> rows, {
    _i1.ColumnSelections<SafetyReportTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SafetyReport>(
      rows,
      columns: columns?.call(SafetyReport.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SafetyReport]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SafetyReport> updateRow(
    _i1.DatabaseSession session,
    SafetyReport row, {
    _i1.ColumnSelections<SafetyReportTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<SafetyReport>(
      row,
      columns: columns?.call(SafetyReport.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SafetyReport] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SafetyReport?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<SafetyReportUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<SafetyReport>(
      id,
      columnValues: columnValues(SafetyReport.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SafetyReport]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<SafetyReport>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<SafetyReportUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SafetyReportTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SafetyReportTable>? orderBy,
    _i1.OrderByListBuilder<SafetyReportTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<SafetyReport>(
      columnValues: columnValues(SafetyReport.t.updateTable),
      where: where(SafetyReport.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SafetyReport.t),
      orderByList: orderByList?.call(SafetyReport.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [SafetyReport]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SafetyReport>> delete(
    _i1.DatabaseSession session,
    List<SafetyReport> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SafetyReport>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SafetyReport].
  Future<SafetyReport> deleteRow(
    _i1.DatabaseSession session,
    SafetyReport row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SafetyReport>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SafetyReport>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SafetyReportTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SafetyReport>(
      where: where(SafetyReport.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SafetyReportTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SafetyReport>(
      where: where?.call(SafetyReport.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SafetyReport] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SafetyReportTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SafetyReport>(
      where: where(SafetyReport.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
