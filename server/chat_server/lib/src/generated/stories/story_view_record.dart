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

/// Story view record (who viewed which story).
abstract class StoryViewRecord
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  StoryViewRecord._({
    this.id,
    required this.storyId,
    required this.viewerAuthUserId,
    DateTime? viewedAt,
  }) : viewedAt = viewedAt ?? DateTime.now();

  factory StoryViewRecord({
    _i1.UuidValue? id,
    required _i1.UuidValue storyId,
    required _i1.UuidValue viewerAuthUserId,
    DateTime? viewedAt,
  }) = _StoryViewRecordImpl;

  factory StoryViewRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return StoryViewRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      storyId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['storyId'],
      ),
      viewerAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['viewerAuthUserId'],
      ),
      viewedAt: jsonSerialization['viewedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['viewedAt']),
    );
  }

  static final t = StoryViewRecordTable();

  static const db = StoryViewRecordRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue storyId;

  _i1.UuidValue viewerAuthUserId;

  DateTime viewedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [StoryViewRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StoryViewRecord copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? storyId,
    _i1.UuidValue? viewerAuthUserId,
    DateTime? viewedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StoryViewRecord',
      if (id != null) 'id': id?.toJson(),
      'storyId': storyId.toJson(),
      'viewerAuthUserId': viewerAuthUserId.toJson(),
      'viewedAt': viewedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StoryViewRecord',
      if (id != null) 'id': id?.toJson(),
      'storyId': storyId.toJson(),
      'viewerAuthUserId': viewerAuthUserId.toJson(),
      'viewedAt': viewedAt.toJson(),
    };
  }

  static StoryViewRecordInclude include() {
    return StoryViewRecordInclude._();
  }

  static StoryViewRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<StoryViewRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StoryViewRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StoryViewRecordTable>? orderByList,
    StoryViewRecordInclude? include,
  }) {
    return StoryViewRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StoryViewRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(StoryViewRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoryViewRecordImpl extends StoryViewRecord {
  _StoryViewRecordImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue storyId,
    required _i1.UuidValue viewerAuthUserId,
    DateTime? viewedAt,
  }) : super._(
         id: id,
         storyId: storyId,
         viewerAuthUserId: viewerAuthUserId,
         viewedAt: viewedAt,
       );

  /// Returns a shallow copy of this [StoryViewRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StoryViewRecord copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? storyId,
    _i1.UuidValue? viewerAuthUserId,
    DateTime? viewedAt,
  }) {
    return StoryViewRecord(
      id: id is _i1.UuidValue? ? id : this.id,
      storyId: storyId ?? this.storyId,
      viewerAuthUserId: viewerAuthUserId ?? this.viewerAuthUserId,
      viewedAt: viewedAt ?? this.viewedAt,
    );
  }
}

class StoryViewRecordUpdateTable extends _i1.UpdateTable<StoryViewRecordTable> {
  StoryViewRecordUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> storyId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.storyId,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> viewerAuthUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.viewerAuthUserId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> viewedAt(DateTime value) =>
      _i1.ColumnValue(
        table.viewedAt,
        value,
      );
}

class StoryViewRecordTable extends _i1.Table<_i1.UuidValue?> {
  StoryViewRecordTable({super.tableRelation}) : super(tableName: 'story_view') {
    updateTable = StoryViewRecordUpdateTable(this);
    storyId = _i1.ColumnUuid(
      'storyId',
      this,
    );
    viewerAuthUserId = _i1.ColumnUuid(
      'viewerAuthUserId',
      this,
    );
    viewedAt = _i1.ColumnDateTime(
      'viewedAt',
      this,
    );
  }

  late final StoryViewRecordUpdateTable updateTable;

  late final _i1.ColumnUuid storyId;

  late final _i1.ColumnUuid viewerAuthUserId;

  late final _i1.ColumnDateTime viewedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    storyId,
    viewerAuthUserId,
    viewedAt,
  ];
}

class StoryViewRecordInclude extends _i1.IncludeObject {
  StoryViewRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => StoryViewRecord.t;
}

class StoryViewRecordIncludeList extends _i1.IncludeList {
  StoryViewRecordIncludeList._({
    _i1.WhereExpressionBuilder<StoryViewRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StoryViewRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => StoryViewRecord.t;
}

class StoryViewRecordRepository {
  const StoryViewRecordRepository._();

  /// Returns a list of [StoryViewRecord]s matching the given query parameters.
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
  Future<List<StoryViewRecord>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StoryViewRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StoryViewRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StoryViewRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StoryViewRecord>(
      where: where?.call(StoryViewRecord.t),
      orderBy: orderBy?.call(StoryViewRecord.t),
      orderByList: orderByList?.call(StoryViewRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [StoryViewRecord] matching the given query parameters.
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
  Future<StoryViewRecord?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StoryViewRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<StoryViewRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StoryViewRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StoryViewRecord>(
      where: where?.call(StoryViewRecord.t),
      orderBy: orderBy?.call(StoryViewRecord.t),
      orderByList: orderByList?.call(StoryViewRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StoryViewRecord] by its [id] or null if no such row exists.
  Future<StoryViewRecord?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StoryViewRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StoryViewRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [StoryViewRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<StoryViewRecord>> insert(
    _i1.DatabaseSession session,
    List<StoryViewRecord> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<StoryViewRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [StoryViewRecord] and returns the inserted row.
  ///
  /// The returned [StoryViewRecord] will have its `id` field set.
  Future<StoryViewRecord> insertRow(
    _i1.DatabaseSession session,
    StoryViewRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<StoryViewRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [StoryViewRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<StoryViewRecord>> update(
    _i1.DatabaseSession session,
    List<StoryViewRecord> rows, {
    _i1.ColumnSelections<StoryViewRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<StoryViewRecord>(
      rows,
      columns: columns?.call(StoryViewRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StoryViewRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StoryViewRecord> updateRow(
    _i1.DatabaseSession session,
    StoryViewRecord row, {
    _i1.ColumnSelections<StoryViewRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<StoryViewRecord>(
      row,
      columns: columns?.call(StoryViewRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StoryViewRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StoryViewRecord?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<StoryViewRecordUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<StoryViewRecord>(
      id,
      columnValues: columnValues(StoryViewRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StoryViewRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<StoryViewRecord>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<StoryViewRecordUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<StoryViewRecordTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StoryViewRecordTable>? orderBy,
    _i1.OrderByListBuilder<StoryViewRecordTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<StoryViewRecord>(
      columnValues: columnValues(StoryViewRecord.t.updateTable),
      where: where(StoryViewRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StoryViewRecord.t),
      orderByList: orderByList?.call(StoryViewRecord.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [StoryViewRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<StoryViewRecord>> delete(
    _i1.DatabaseSession session,
    List<StoryViewRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<StoryViewRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [StoryViewRecord].
  Future<StoryViewRecord> deleteRow(
    _i1.DatabaseSession session,
    StoryViewRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StoryViewRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<StoryViewRecord>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<StoryViewRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<StoryViewRecord>(
      where: where(StoryViewRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StoryViewRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<StoryViewRecord>(
      where: where?.call(StoryViewRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StoryViewRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<StoryViewRecordTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StoryViewRecord>(
      where: where(StoryViewRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
