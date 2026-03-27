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

/// Block list: blocker cannot receive social graph delivery from blocked (enforce in fan-out). ADR-0007.
abstract class SafetyBlock
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  SafetyBlock._({
    this.id,
    required this.blockerAuthUserId,
    required this.blockedAuthUserId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SafetyBlock({
    _i1.UuidValue? id,
    required _i1.UuidValue blockerAuthUserId,
    required _i1.UuidValue blockedAuthUserId,
    DateTime? createdAt,
  }) = _SafetyBlockImpl;

  factory SafetyBlock.fromJson(Map<String, dynamic> jsonSerialization) {
    return SafetyBlock(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      blockerAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['blockerAuthUserId'],
      ),
      blockedAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['blockedAuthUserId'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = SafetyBlockTable();

  static const db = SafetyBlockRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue blockerAuthUserId;

  _i1.UuidValue blockedAuthUserId;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [SafetyBlock]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SafetyBlock copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? blockerAuthUserId,
    _i1.UuidValue? blockedAuthUserId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SafetyBlock',
      if (id != null) 'id': id?.toJson(),
      'blockerAuthUserId': blockerAuthUserId.toJson(),
      'blockedAuthUserId': blockedAuthUserId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SafetyBlock',
      if (id != null) 'id': id?.toJson(),
      'blockerAuthUserId': blockerAuthUserId.toJson(),
      'blockedAuthUserId': blockedAuthUserId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static SafetyBlockInclude include() {
    return SafetyBlockInclude._();
  }

  static SafetyBlockIncludeList includeList({
    _i1.WhereExpressionBuilder<SafetyBlockTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SafetyBlockTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SafetyBlockTable>? orderByList,
    SafetyBlockInclude? include,
  }) {
    return SafetyBlockIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SafetyBlock.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SafetyBlock.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SafetyBlockImpl extends SafetyBlock {
  _SafetyBlockImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue blockerAuthUserId,
    required _i1.UuidValue blockedAuthUserId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         blockerAuthUserId: blockerAuthUserId,
         blockedAuthUserId: blockedAuthUserId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SafetyBlock]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SafetyBlock copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? blockerAuthUserId,
    _i1.UuidValue? blockedAuthUserId,
    DateTime? createdAt,
  }) {
    return SafetyBlock(
      id: id is _i1.UuidValue? ? id : this.id,
      blockerAuthUserId: blockerAuthUserId ?? this.blockerAuthUserId,
      blockedAuthUserId: blockedAuthUserId ?? this.blockedAuthUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SafetyBlockUpdateTable extends _i1.UpdateTable<SafetyBlockTable> {
  SafetyBlockUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> blockerAuthUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.blockerAuthUserId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> blockedAuthUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.blockedAuthUserId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class SafetyBlockTable extends _i1.Table<_i1.UuidValue?> {
  SafetyBlockTable({super.tableRelation}) : super(tableName: 'safety_block') {
    updateTable = SafetyBlockUpdateTable(this);
    blockerAuthUserId = _i1.ColumnUuid(
      'blockerAuthUserId',
      this,
    );
    blockedAuthUserId = _i1.ColumnUuid(
      'blockedAuthUserId',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final SafetyBlockUpdateTable updateTable;

  late final _i1.ColumnUuid blockerAuthUserId;

  late final _i1.ColumnUuid blockedAuthUserId;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    blockerAuthUserId,
    blockedAuthUserId,
    createdAt,
  ];
}

class SafetyBlockInclude extends _i1.IncludeObject {
  SafetyBlockInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SafetyBlock.t;
}

class SafetyBlockIncludeList extends _i1.IncludeList {
  SafetyBlockIncludeList._({
    _i1.WhereExpressionBuilder<SafetyBlockTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SafetyBlock.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SafetyBlock.t;
}

class SafetyBlockRepository {
  const SafetyBlockRepository._();

  /// Returns a list of [SafetyBlock]s matching the given query parameters.
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
  Future<List<SafetyBlock>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SafetyBlockTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SafetyBlockTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SafetyBlockTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SafetyBlock>(
      where: where?.call(SafetyBlock.t),
      orderBy: orderBy?.call(SafetyBlock.t),
      orderByList: orderByList?.call(SafetyBlock.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SafetyBlock] matching the given query parameters.
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
  Future<SafetyBlock?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SafetyBlockTable>? where,
    int? offset,
    _i1.OrderByBuilder<SafetyBlockTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SafetyBlockTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SafetyBlock>(
      where: where?.call(SafetyBlock.t),
      orderBy: orderBy?.call(SafetyBlock.t),
      orderByList: orderByList?.call(SafetyBlock.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SafetyBlock] by its [id] or null if no such row exists.
  Future<SafetyBlock?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SafetyBlock>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SafetyBlock]s in the list and returns the inserted rows.
  ///
  /// The returned [SafetyBlock]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<SafetyBlock>> insert(
    _i1.DatabaseSession session,
    List<SafetyBlock> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<SafetyBlock>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [SafetyBlock] and returns the inserted row.
  ///
  /// The returned [SafetyBlock] will have its `id` field set.
  Future<SafetyBlock> insertRow(
    _i1.DatabaseSession session,
    SafetyBlock row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SafetyBlock>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SafetyBlock]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SafetyBlock>> update(
    _i1.DatabaseSession session,
    List<SafetyBlock> rows, {
    _i1.ColumnSelections<SafetyBlockTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SafetyBlock>(
      rows,
      columns: columns?.call(SafetyBlock.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SafetyBlock]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SafetyBlock> updateRow(
    _i1.DatabaseSession session,
    SafetyBlock row, {
    _i1.ColumnSelections<SafetyBlockTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<SafetyBlock>(
      row,
      columns: columns?.call(SafetyBlock.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SafetyBlock] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SafetyBlock?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<SafetyBlockUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<SafetyBlock>(
      id,
      columnValues: columnValues(SafetyBlock.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SafetyBlock]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<SafetyBlock>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<SafetyBlockUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SafetyBlockTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SafetyBlockTable>? orderBy,
    _i1.OrderByListBuilder<SafetyBlockTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<SafetyBlock>(
      columnValues: columnValues(SafetyBlock.t.updateTable),
      where: where(SafetyBlock.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SafetyBlock.t),
      orderByList: orderByList?.call(SafetyBlock.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [SafetyBlock]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SafetyBlock>> delete(
    _i1.DatabaseSession session,
    List<SafetyBlock> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SafetyBlock>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SafetyBlock].
  Future<SafetyBlock> deleteRow(
    _i1.DatabaseSession session,
    SafetyBlock row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SafetyBlock>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SafetyBlock>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SafetyBlockTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SafetyBlock>(
      where: where(SafetyBlock.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SafetyBlockTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SafetyBlock>(
      where: where?.call(SafetyBlock.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SafetyBlock] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SafetyBlockTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SafetyBlock>(
      where: where(SafetyBlock.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
