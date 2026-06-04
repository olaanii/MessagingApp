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

abstract class RegisteredDevice
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  RegisteredDevice._({
    this.id,
    required this.deviceId,
    required this.ownerAuthUserId,
    required this.platform,
    this.name,
    DateTime? createdAt,
    DateTime? lastSeenAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastSeenAt = lastSeenAt ?? DateTime.now();

  factory RegisteredDevice({
    int? id,
    required String deviceId,
    required String ownerAuthUserId,
    required String platform,
    String? name,
    DateTime? createdAt,
    DateTime? lastSeenAt,
  }) = _RegisteredDeviceImpl;

  factory RegisteredDevice.fromJson(Map<String, dynamic> jsonSerialization) {
    return RegisteredDevice(
      id: jsonSerialization['id'] as int?,
      deviceId: jsonSerialization['deviceId'] as String,
      ownerAuthUserId: jsonSerialization['ownerAuthUserId'] as String,
      platform: jsonSerialization['platform'] as String,
      name: jsonSerialization['name'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      lastSeenAt: jsonSerialization['lastSeenAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastSeenAt']),
    );
  }

  static final t = RegisteredDeviceTable();

  static const db = RegisteredDeviceRepository._();

  @override
  int? id;

  String deviceId;

  String ownerAuthUserId;

  String platform;

  String? name;

  DateTime createdAt;

  DateTime? lastSeenAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [RegisteredDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RegisteredDevice copyWith({
    int? id,
    String? deviceId,
    String? ownerAuthUserId,
    String? platform,
    String? name,
    DateTime? createdAt,
    DateTime? lastSeenAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RegisteredDevice',
      if (id != null) 'id': id,
      'deviceId': deviceId,
      'ownerAuthUserId': ownerAuthUserId,
      'platform': platform,
      if (name != null) 'name': name,
      'createdAt': createdAt.toJson(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RegisteredDevice',
      if (id != null) 'id': id,
      'deviceId': deviceId,
      'ownerAuthUserId': ownerAuthUserId,
      'platform': platform,
      if (name != null) 'name': name,
      'createdAt': createdAt.toJson(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
    };
  }

  static RegisteredDeviceInclude include() {
    return RegisteredDeviceInclude._();
  }

  static RegisteredDeviceIncludeList includeList({
    _i1.WhereExpressionBuilder<RegisteredDeviceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RegisteredDeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RegisteredDeviceTable>? orderByList,
    RegisteredDeviceInclude? include,
  }) {
    return RegisteredDeviceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RegisteredDevice.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(RegisteredDevice.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RegisteredDeviceImpl extends RegisteredDevice {
  _RegisteredDeviceImpl({
    int? id,
    required String deviceId,
    required String ownerAuthUserId,
    required String platform,
    String? name,
    DateTime? createdAt,
    DateTime? lastSeenAt,
  }) : super._(
         id: id,
         deviceId: deviceId,
         ownerAuthUserId: ownerAuthUserId,
         platform: platform,
         name: name,
         createdAt: createdAt,
         lastSeenAt: lastSeenAt,
       );

  /// Returns a shallow copy of this [RegisteredDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RegisteredDevice copyWith({
    Object? id = _Undefined,
    String? deviceId,
    String? ownerAuthUserId,
    String? platform,
    Object? name = _Undefined,
    DateTime? createdAt,
    Object? lastSeenAt = _Undefined,
  }) {
    return RegisteredDevice(
      id: id is int? ? id : this.id,
      deviceId: deviceId ?? this.deviceId,
      ownerAuthUserId: ownerAuthUserId ?? this.ownerAuthUserId,
      platform: platform ?? this.platform,
      name: name is String? ? name : this.name,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt is DateTime? ? lastSeenAt : this.lastSeenAt,
    );
  }
}

class RegisteredDeviceUpdateTable
    extends _i1.UpdateTable<RegisteredDeviceTable> {
  RegisteredDeviceUpdateTable(super.table);

  _i1.ColumnValue<String, String> deviceId(String value) => _i1.ColumnValue(
    table.deviceId,
    value,
  );

  _i1.ColumnValue<String, String> ownerAuthUserId(String value) =>
      _i1.ColumnValue(
        table.ownerAuthUserId,
        value,
      );

  _i1.ColumnValue<String, String> platform(String value) => _i1.ColumnValue(
    table.platform,
    value,
  );

  _i1.ColumnValue<String, String> name(String? value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> lastSeenAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastSeenAt,
        value,
      );
}

class RegisteredDeviceTable extends _i1.Table<int?> {
  RegisteredDeviceTable({super.tableRelation})
    : super(tableName: 'registered_device') {
    updateTable = RegisteredDeviceUpdateTable(this);
    deviceId = _i1.ColumnString(
      'deviceId',
      this,
    );
    ownerAuthUserId = _i1.ColumnString(
      'ownerAuthUserId',
      this,
    );
    platform = _i1.ColumnString(
      'platform',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    lastSeenAt = _i1.ColumnDateTime(
      'lastSeenAt',
      this,
      hasDefault: true,
    );
  }

  late final RegisteredDeviceUpdateTable updateTable;

  late final _i1.ColumnString deviceId;

  late final _i1.ColumnString ownerAuthUserId;

  late final _i1.ColumnString platform;

  late final _i1.ColumnString name;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime lastSeenAt;

  @override
  List<_i1.Column> get columns => [
    id,
    deviceId,
    ownerAuthUserId,
    platform,
    name,
    createdAt,
    lastSeenAt,
  ];
}

class RegisteredDeviceInclude extends _i1.IncludeObject {
  RegisteredDeviceInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => RegisteredDevice.t;
}

class RegisteredDeviceIncludeList extends _i1.IncludeList {
  RegisteredDeviceIncludeList._({
    _i1.WhereExpressionBuilder<RegisteredDeviceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RegisteredDevice.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => RegisteredDevice.t;
}

class RegisteredDeviceRepository {
  const RegisteredDeviceRepository._();

  /// Returns a list of [RegisteredDevice]s matching the given query parameters.
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
  Future<List<RegisteredDevice>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RegisteredDeviceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RegisteredDeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RegisteredDeviceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RegisteredDevice>(
      where: where?.call(RegisteredDevice.t),
      orderBy: orderBy?.call(RegisteredDevice.t),
      orderByList: orderByList?.call(RegisteredDevice.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RegisteredDevice] matching the given query parameters.
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
  Future<RegisteredDevice?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RegisteredDeviceTable>? where,
    int? offset,
    _i1.OrderByBuilder<RegisteredDeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RegisteredDeviceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RegisteredDevice>(
      where: where?.call(RegisteredDevice.t),
      orderBy: orderBy?.call(RegisteredDevice.t),
      orderByList: orderByList?.call(RegisteredDevice.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RegisteredDevice] by its [id] or null if no such row exists.
  Future<RegisteredDevice?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RegisteredDevice>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RegisteredDevice]s in the list and returns the inserted rows.
  ///
  /// The returned [RegisteredDevice]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<RegisteredDevice>> insert(
    _i1.DatabaseSession session,
    List<RegisteredDevice> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<RegisteredDevice>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [RegisteredDevice] and returns the inserted row.
  ///
  /// The returned [RegisteredDevice] will have its `id` field set.
  Future<RegisteredDevice> insertRow(
    _i1.DatabaseSession session,
    RegisteredDevice row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<RegisteredDevice>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [RegisteredDevice]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<RegisteredDevice>> update(
    _i1.DatabaseSession session,
    List<RegisteredDevice> rows, {
    _i1.ColumnSelections<RegisteredDeviceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<RegisteredDevice>(
      rows,
      columns: columns?.call(RegisteredDevice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RegisteredDevice]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RegisteredDevice> updateRow(
    _i1.DatabaseSession session,
    RegisteredDevice row, {
    _i1.ColumnSelections<RegisteredDeviceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<RegisteredDevice>(
      row,
      columns: columns?.call(RegisteredDevice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RegisteredDevice] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RegisteredDevice?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<RegisteredDeviceUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<RegisteredDevice>(
      id,
      columnValues: columnValues(RegisteredDevice.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RegisteredDevice]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<RegisteredDevice>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<RegisteredDeviceUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<RegisteredDeviceTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RegisteredDeviceTable>? orderBy,
    _i1.OrderByListBuilder<RegisteredDeviceTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<RegisteredDevice>(
      columnValues: columnValues(RegisteredDevice.t.updateTable),
      where: where(RegisteredDevice.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RegisteredDevice.t),
      orderByList: orderByList?.call(RegisteredDevice.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [RegisteredDevice]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<RegisteredDevice>> delete(
    _i1.DatabaseSession session,
    List<RegisteredDevice> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<RegisteredDevice>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [RegisteredDevice].
  Future<RegisteredDevice> deleteRow(
    _i1.DatabaseSession session,
    RegisteredDevice row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RegisteredDevice>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<RegisteredDevice>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<RegisteredDeviceTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<RegisteredDevice>(
      where: where(RegisteredDevice.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RegisteredDeviceTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<RegisteredDevice>(
      where: where?.call(RegisteredDevice.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RegisteredDevice] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<RegisteredDeviceTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RegisteredDevice>(
      where: where(RegisteredDevice.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
