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

abstract class DeviceKeyBundle
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  DeviceKeyBundle._({
    this.id,
    required this.authUserId,
    required this.deviceId,
    required this.bundleJson,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DeviceKeyBundle({
    int? id,
    required _i1.UuidValue authUserId,
    required String deviceId,
    required String bundleJson,
    DateTime? createdAt,
  }) = _DeviceKeyBundleImpl;

  factory DeviceKeyBundle.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeviceKeyBundle(
      id: jsonSerialization['id'] as int?,
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      deviceId: jsonSerialization['deviceId'] as String,
      bundleJson: jsonSerialization['bundleJson'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = DeviceKeyBundleTable();

  static const db = DeviceKeyBundleRepository._();

  @override
  int? id;

  _i1.UuidValue authUserId;

  String deviceId;

  String bundleJson;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [DeviceKeyBundle]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DeviceKeyBundle copyWith({
    int? id,
    _i1.UuidValue? authUserId,
    String? deviceId,
    String? bundleJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeviceKeyBundle',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'deviceId': deviceId,
      'bundleJson': bundleJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DeviceKeyBundle',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'deviceId': deviceId,
      'bundleJson': bundleJson,
      'createdAt': createdAt.toJson(),
    };
  }

  static DeviceKeyBundleInclude include() {
    return DeviceKeyBundleInclude._();
  }

  static DeviceKeyBundleIncludeList includeList({
    _i1.WhereExpressionBuilder<DeviceKeyBundleTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DeviceKeyBundleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DeviceKeyBundleTable>? orderByList,
    DeviceKeyBundleInclude? include,
  }) {
    return DeviceKeyBundleIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DeviceKeyBundle.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(DeviceKeyBundle.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeviceKeyBundleImpl extends DeviceKeyBundle {
  _DeviceKeyBundleImpl({
    int? id,
    required _i1.UuidValue authUserId,
    required String deviceId,
    required String bundleJson,
    DateTime? createdAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         deviceId: deviceId,
         bundleJson: bundleJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DeviceKeyBundle]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DeviceKeyBundle copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? authUserId,
    String? deviceId,
    String? bundleJson,
    DateTime? createdAt,
  }) {
    return DeviceKeyBundle(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      deviceId: deviceId ?? this.deviceId,
      bundleJson: bundleJson ?? this.bundleJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DeviceKeyBundleUpdateTable extends _i1.UpdateTable<DeviceKeyBundleTable> {
  DeviceKeyBundleUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> authUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.authUserId,
    value,
  );

  _i1.ColumnValue<String, String> deviceId(String value) => _i1.ColumnValue(
    table.deviceId,
    value,
  );

  _i1.ColumnValue<String, String> bundleJson(String value) => _i1.ColumnValue(
    table.bundleJson,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class DeviceKeyBundleTable extends _i1.Table<int?> {
  DeviceKeyBundleTable({super.tableRelation})
    : super(tableName: 'device_keys') {
    updateTable = DeviceKeyBundleUpdateTable(this);
    authUserId = _i1.ColumnUuid(
      'authUserId',
      this,
    );
    deviceId = _i1.ColumnString(
      'deviceId',
      this,
    );
    bundleJson = _i1.ColumnString(
      'bundleJson',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final DeviceKeyBundleUpdateTable updateTable;

  late final _i1.ColumnUuid authUserId;

  late final _i1.ColumnString deviceId;

  late final _i1.ColumnString bundleJson;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    authUserId,
    deviceId,
    bundleJson,
    createdAt,
  ];
}

class DeviceKeyBundleInclude extends _i1.IncludeObject {
  DeviceKeyBundleInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => DeviceKeyBundle.t;
}

class DeviceKeyBundleIncludeList extends _i1.IncludeList {
  DeviceKeyBundleIncludeList._({
    _i1.WhereExpressionBuilder<DeviceKeyBundleTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DeviceKeyBundle.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => DeviceKeyBundle.t;
}

class DeviceKeyBundleRepository {
  const DeviceKeyBundleRepository._();

  /// Returns a list of [DeviceKeyBundle]s matching the given query parameters.
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
  Future<List<DeviceKeyBundle>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DeviceKeyBundleTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DeviceKeyBundleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DeviceKeyBundleTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DeviceKeyBundle>(
      where: where?.call(DeviceKeyBundle.t),
      orderBy: orderBy?.call(DeviceKeyBundle.t),
      orderByList: orderByList?.call(DeviceKeyBundle.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DeviceKeyBundle] matching the given query parameters.
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
  Future<DeviceKeyBundle?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DeviceKeyBundleTable>? where,
    int? offset,
    _i1.OrderByBuilder<DeviceKeyBundleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DeviceKeyBundleTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DeviceKeyBundle>(
      where: where?.call(DeviceKeyBundle.t),
      orderBy: orderBy?.call(DeviceKeyBundle.t),
      orderByList: orderByList?.call(DeviceKeyBundle.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DeviceKeyBundle] by its [id] or null if no such row exists.
  Future<DeviceKeyBundle?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DeviceKeyBundle>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DeviceKeyBundle]s in the list and returns the inserted rows.
  ///
  /// The returned [DeviceKeyBundle]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<DeviceKeyBundle>> insert(
    _i1.DatabaseSession session,
    List<DeviceKeyBundle> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<DeviceKeyBundle>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [DeviceKeyBundle] and returns the inserted row.
  ///
  /// The returned [DeviceKeyBundle] will have its `id` field set.
  Future<DeviceKeyBundle> insertRow(
    _i1.DatabaseSession session,
    DeviceKeyBundle row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DeviceKeyBundle>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DeviceKeyBundle]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DeviceKeyBundle>> update(
    _i1.DatabaseSession session,
    List<DeviceKeyBundle> rows, {
    _i1.ColumnSelections<DeviceKeyBundleTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DeviceKeyBundle>(
      rows,
      columns: columns?.call(DeviceKeyBundle.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DeviceKeyBundle]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DeviceKeyBundle> updateRow(
    _i1.DatabaseSession session,
    DeviceKeyBundle row, {
    _i1.ColumnSelections<DeviceKeyBundleTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DeviceKeyBundle>(
      row,
      columns: columns?.call(DeviceKeyBundle.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DeviceKeyBundle] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DeviceKeyBundle?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<DeviceKeyBundleUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<DeviceKeyBundle>(
      id,
      columnValues: columnValues(DeviceKeyBundle.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DeviceKeyBundle]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<DeviceKeyBundle>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<DeviceKeyBundleUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<DeviceKeyBundleTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DeviceKeyBundleTable>? orderBy,
    _i1.OrderByListBuilder<DeviceKeyBundleTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<DeviceKeyBundle>(
      columnValues: columnValues(DeviceKeyBundle.t.updateTable),
      where: where(DeviceKeyBundle.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DeviceKeyBundle.t),
      orderByList: orderByList?.call(DeviceKeyBundle.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [DeviceKeyBundle]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DeviceKeyBundle>> delete(
    _i1.DatabaseSession session,
    List<DeviceKeyBundle> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DeviceKeyBundle>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DeviceKeyBundle].
  Future<DeviceKeyBundle> deleteRow(
    _i1.DatabaseSession session,
    DeviceKeyBundle row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DeviceKeyBundle>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DeviceKeyBundle>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<DeviceKeyBundleTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DeviceKeyBundle>(
      where: where(DeviceKeyBundle.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DeviceKeyBundleTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DeviceKeyBundle>(
      where: where?.call(DeviceKeyBundle.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DeviceKeyBundle] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<DeviceKeyBundleTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DeviceKeyBundle>(
      where: where(DeviceKeyBundle.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
