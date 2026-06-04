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

abstract class FirebaseAuthUser
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  FirebaseAuthUser._({
    this.id,
    required this.firebaseUid,
    required this.authUserId,
  });

  factory FirebaseAuthUser({
    int? id,
    required String firebaseUid,
    required _i1.UuidValue authUserId,
  }) = _FirebaseAuthUserImpl;

  factory FirebaseAuthUser.fromJson(Map<String, dynamic> jsonSerialization) {
    return FirebaseAuthUser(
      id: jsonSerialization['id'] as int?,
      firebaseUid: jsonSerialization['firebaseUid'] as String,
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
    );
  }

  static final t = FirebaseAuthUserTable();

  static const db = FirebaseAuthUserRepository._();

  @override
  int? id;

  String firebaseUid;

  _i1.UuidValue authUserId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [FirebaseAuthUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FirebaseAuthUser copyWith({
    int? id,
    String? firebaseUid,
    _i1.UuidValue? authUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FirebaseAuthUser',
      if (id != null) 'id': id,
      'firebaseUid': firebaseUid,
      'authUserId': authUserId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FirebaseAuthUser',
      if (id != null) 'id': id,
      'firebaseUid': firebaseUid,
      'authUserId': authUserId.toJson(),
    };
  }

  static FirebaseAuthUserInclude include() {
    return FirebaseAuthUserInclude._();
  }

  static FirebaseAuthUserIncludeList includeList({
    _i1.WhereExpressionBuilder<FirebaseAuthUserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FirebaseAuthUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FirebaseAuthUserTable>? orderByList,
    FirebaseAuthUserInclude? include,
  }) {
    return FirebaseAuthUserIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FirebaseAuthUser.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(FirebaseAuthUser.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FirebaseAuthUserImpl extends FirebaseAuthUser {
  _FirebaseAuthUserImpl({
    int? id,
    required String firebaseUid,
    required _i1.UuidValue authUserId,
  }) : super._(
         id: id,
         firebaseUid: firebaseUid,
         authUserId: authUserId,
       );

  /// Returns a shallow copy of this [FirebaseAuthUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FirebaseAuthUser copyWith({
    Object? id = _Undefined,
    String? firebaseUid,
    _i1.UuidValue? authUserId,
  }) {
    return FirebaseAuthUser(
      id: id is int? ? id : this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      authUserId: authUserId ?? this.authUserId,
    );
  }
}

class FirebaseAuthUserUpdateTable
    extends _i1.UpdateTable<FirebaseAuthUserTable> {
  FirebaseAuthUserUpdateTable(super.table);

  _i1.ColumnValue<String, String> firebaseUid(String value) => _i1.ColumnValue(
    table.firebaseUid,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> authUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.authUserId,
    value,
  );
}

class FirebaseAuthUserTable extends _i1.Table<int?> {
  FirebaseAuthUserTable({super.tableRelation})
    : super(tableName: 'firebase_auth_user') {
    updateTable = FirebaseAuthUserUpdateTable(this);
    firebaseUid = _i1.ColumnString(
      'firebaseUid',
      this,
    );
    authUserId = _i1.ColumnUuid(
      'authUserId',
      this,
    );
  }

  late final FirebaseAuthUserUpdateTable updateTable;

  late final _i1.ColumnString firebaseUid;

  late final _i1.ColumnUuid authUserId;

  @override
  List<_i1.Column> get columns => [
    id,
    firebaseUid,
    authUserId,
  ];
}

class FirebaseAuthUserInclude extends _i1.IncludeObject {
  FirebaseAuthUserInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => FirebaseAuthUser.t;
}

class FirebaseAuthUserIncludeList extends _i1.IncludeList {
  FirebaseAuthUserIncludeList._({
    _i1.WhereExpressionBuilder<FirebaseAuthUserTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FirebaseAuthUser.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => FirebaseAuthUser.t;
}

class FirebaseAuthUserRepository {
  const FirebaseAuthUserRepository._();

  /// Returns a list of [FirebaseAuthUser]s matching the given query parameters.
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
  Future<List<FirebaseAuthUser>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<FirebaseAuthUserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FirebaseAuthUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FirebaseAuthUserTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FirebaseAuthUser>(
      where: where?.call(FirebaseAuthUser.t),
      orderBy: orderBy?.call(FirebaseAuthUser.t),
      orderByList: orderByList?.call(FirebaseAuthUser.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FirebaseAuthUser] matching the given query parameters.
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
  Future<FirebaseAuthUser?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<FirebaseAuthUserTable>? where,
    int? offset,
    _i1.OrderByBuilder<FirebaseAuthUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FirebaseAuthUserTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FirebaseAuthUser>(
      where: where?.call(FirebaseAuthUser.t),
      orderBy: orderBy?.call(FirebaseAuthUser.t),
      orderByList: orderByList?.call(FirebaseAuthUser.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FirebaseAuthUser] by its [id] or null if no such row exists.
  Future<FirebaseAuthUser?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FirebaseAuthUser>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FirebaseAuthUser]s in the list and returns the inserted rows.
  ///
  /// The returned [FirebaseAuthUser]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<FirebaseAuthUser>> insert(
    _i1.DatabaseSession session,
    List<FirebaseAuthUser> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<FirebaseAuthUser>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [FirebaseAuthUser] and returns the inserted row.
  ///
  /// The returned [FirebaseAuthUser] will have its `id` field set.
  Future<FirebaseAuthUser> insertRow(
    _i1.DatabaseSession session,
    FirebaseAuthUser row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<FirebaseAuthUser>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [FirebaseAuthUser]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<FirebaseAuthUser>> update(
    _i1.DatabaseSession session,
    List<FirebaseAuthUser> rows, {
    _i1.ColumnSelections<FirebaseAuthUserTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<FirebaseAuthUser>(
      rows,
      columns: columns?.call(FirebaseAuthUser.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FirebaseAuthUser]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FirebaseAuthUser> updateRow(
    _i1.DatabaseSession session,
    FirebaseAuthUser row, {
    _i1.ColumnSelections<FirebaseAuthUserTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<FirebaseAuthUser>(
      row,
      columns: columns?.call(FirebaseAuthUser.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FirebaseAuthUser] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FirebaseAuthUser?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<FirebaseAuthUserUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<FirebaseAuthUser>(
      id,
      columnValues: columnValues(FirebaseAuthUser.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FirebaseAuthUser]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<FirebaseAuthUser>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<FirebaseAuthUserUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<FirebaseAuthUserTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FirebaseAuthUserTable>? orderBy,
    _i1.OrderByListBuilder<FirebaseAuthUserTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<FirebaseAuthUser>(
      columnValues: columnValues(FirebaseAuthUser.t.updateTable),
      where: where(FirebaseAuthUser.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FirebaseAuthUser.t),
      orderByList: orderByList?.call(FirebaseAuthUser.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [FirebaseAuthUser]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<FirebaseAuthUser>> delete(
    _i1.DatabaseSession session,
    List<FirebaseAuthUser> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<FirebaseAuthUser>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [FirebaseAuthUser].
  Future<FirebaseAuthUser> deleteRow(
    _i1.DatabaseSession session,
    FirebaseAuthUser row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FirebaseAuthUser>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<FirebaseAuthUser>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<FirebaseAuthUserTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<FirebaseAuthUser>(
      where: where(FirebaseAuthUser.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<FirebaseAuthUserTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<FirebaseAuthUser>(
      where: where?.call(FirebaseAuthUser.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FirebaseAuthUser] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<FirebaseAuthUserTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FirebaseAuthUser>(
      where: where(FirebaseAuthUser.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
