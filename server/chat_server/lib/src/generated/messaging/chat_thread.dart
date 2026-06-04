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

abstract class ChatThread
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  ChatThread._({
    _i1.UuidValue? id,
    required this.type,
    this.title,
    this.createdByAuthUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory ChatThread({
    _i1.UuidValue? id,
    required String type,
    String? title,
    _i1.UuidValue? createdByAuthUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ChatThreadImpl;

  factory ChatThread.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatThread(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      type: jsonSerialization['type'] as String,
      title: jsonSerialization['title'] as String?,
      createdByAuthUserId: jsonSerialization['createdByAuthUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['createdByAuthUserId'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = ChatThreadTable();

  static const db = ChatThreadRepository._();

  @override
  _i1.UuidValue id;

  String type;

  String? title;

  _i1.UuidValue? createdByAuthUserId;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [ChatThread]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatThread copyWith({
    _i1.UuidValue? id,
    String? type,
    String? title,
    _i1.UuidValue? createdByAuthUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatThread',
      'id': id.toJson(),
      'type': type,
      if (title != null) 'title': title,
      if (createdByAuthUserId != null)
        'createdByAuthUserId': createdByAuthUserId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatThread',
      'id': id.toJson(),
      'type': type,
      if (title != null) 'title': title,
      if (createdByAuthUserId != null)
        'createdByAuthUserId': createdByAuthUserId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static ChatThreadInclude include() {
    return ChatThreadInclude._();
  }

  static ChatThreadIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatThreadTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatThreadTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatThreadTable>? orderByList,
    ChatThreadInclude? include,
  }) {
    return ChatThreadIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatThread.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatThread.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatThreadImpl extends ChatThread {
  _ChatThreadImpl({
    _i1.UuidValue? id,
    required String type,
    String? title,
    _i1.UuidValue? createdByAuthUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         type: type,
         title: title,
         createdByAuthUserId: createdByAuthUserId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [ChatThread]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatThread copyWith({
    _i1.UuidValue? id,
    String? type,
    Object? title = _Undefined,
    Object? createdByAuthUserId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatThread(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title is String? ? title : this.title,
      createdByAuthUserId: createdByAuthUserId is _i1.UuidValue?
          ? createdByAuthUserId
          : this.createdByAuthUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ChatThreadUpdateTable extends _i1.UpdateTable<ChatThreadTable> {
  ChatThreadUpdateTable(super.table);

  _i1.ColumnValue<String, String> type(String value) => _i1.ColumnValue(
    table.type,
    value,
  );

  _i1.ColumnValue<String, String> title(String? value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> createdByAuthUserId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.createdByAuthUserId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class ChatThreadTable extends _i1.Table<_i1.UuidValue> {
  ChatThreadTable({super.tableRelation}) : super(tableName: 'chat_thread') {
    updateTable = ChatThreadUpdateTable(this);
    type = _i1.ColumnString(
      'type',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    createdByAuthUserId = _i1.ColumnUuid(
      'createdByAuthUserId',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final ChatThreadUpdateTable updateTable;

  late final _i1.ColumnString type;

  late final _i1.ColumnString title;

  late final _i1.ColumnUuid createdByAuthUserId;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    type,
    title,
    createdByAuthUserId,
    createdAt,
    updatedAt,
  ];
}

class ChatThreadInclude extends _i1.IncludeObject {
  ChatThreadInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => ChatThread.t;
}

class ChatThreadIncludeList extends _i1.IncludeList {
  ChatThreadIncludeList._({
    _i1.WhereExpressionBuilder<ChatThreadTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatThread.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => ChatThread.t;
}

class ChatThreadRepository {
  const ChatThreadRepository._();

  /// Returns a list of [ChatThread]s matching the given query parameters.
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
  Future<List<ChatThread>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatThreadTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatThreadTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatThreadTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChatThread>(
      where: where?.call(ChatThread.t),
      orderBy: orderBy?.call(ChatThread.t),
      orderByList: orderByList?.call(ChatThread.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ChatThread] matching the given query parameters.
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
  Future<ChatThread?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatThreadTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatThreadTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatThreadTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChatThread>(
      where: where?.call(ChatThread.t),
      orderBy: orderBy?.call(ChatThread.t),
      orderByList: orderByList?.call(ChatThread.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChatThread] by its [id] or null if no such row exists.
  Future<ChatThread?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChatThread>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChatThread]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatThread]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ChatThread>> insert(
    _i1.DatabaseSession session,
    List<ChatThread> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ChatThread>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ChatThread] and returns the inserted row.
  ///
  /// The returned [ChatThread] will have its `id` field set.
  Future<ChatThread> insertRow(
    _i1.DatabaseSession session,
    ChatThread row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatThread>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatThread]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatThread>> update(
    _i1.DatabaseSession session,
    List<ChatThread> rows, {
    _i1.ColumnSelections<ChatThreadTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatThread>(
      rows,
      columns: columns?.call(ChatThread.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatThread]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatThread> updateRow(
    _i1.DatabaseSession session,
    ChatThread row, {
    _i1.ColumnSelections<ChatThreadTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatThread>(
      row,
      columns: columns?.call(ChatThread.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatThread] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatThread?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<ChatThreadUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatThread>(
      id,
      columnValues: columnValues(ChatThread.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatThread]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ChatThread>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ChatThreadUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ChatThreadTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatThreadTable>? orderBy,
    _i1.OrderByListBuilder<ChatThreadTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ChatThread>(
      columnValues: columnValues(ChatThread.t.updateTable),
      where: where(ChatThread.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatThread.t),
      orderByList: orderByList?.call(ChatThread.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ChatThread]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatThread>> delete(
    _i1.DatabaseSession session,
    List<ChatThread> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatThread>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatThread].
  Future<ChatThread> deleteRow(
    _i1.DatabaseSession session,
    ChatThread row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatThread>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatThread>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatThreadTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatThread>(
      where: where(ChatThread.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatThreadTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatThread>(
      where: where?.call(ChatThread.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChatThread] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatThreadTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChatThread>(
      where: where(ChatThread.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
