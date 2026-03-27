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

abstract class ChatMemberRow
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ChatMemberRow._({
    this.id,
    required this.chatId,
    required this.memberAuthUserId,
    required this.role,
    DateTime? joinedAt,
    int? lastReadSeq,
  }) : joinedAt = joinedAt ?? DateTime.now(),
       lastReadSeq = lastReadSeq ?? 0;

  factory ChatMemberRow({
    int? id,
    required _i1.UuidValue chatId,
    required _i1.UuidValue memberAuthUserId,
    required String role,
    DateTime? joinedAt,
    int? lastReadSeq,
  }) = _ChatMemberRowImpl;

  factory ChatMemberRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMemberRow(
      id: jsonSerialization['id'] as int?,
      chatId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['chatId']),
      memberAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['memberAuthUserId'],
      ),
      role: jsonSerialization['role'] as String,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      lastReadSeq: jsonSerialization['lastReadSeq'] as int?,
    );
  }

  static final t = ChatMemberRowTable();

  static const db = ChatMemberRowRepository._();

  @override
  int? id;

  _i1.UuidValue chatId;

  _i1.UuidValue memberAuthUserId;

  String role;

  DateTime joinedAt;

  int lastReadSeq;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChatMemberRow]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatMemberRow copyWith({
    int? id,
    _i1.UuidValue? chatId,
    _i1.UuidValue? memberAuthUserId,
    String? role,
    DateTime? joinedAt,
    int? lastReadSeq,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatMemberRow',
      if (id != null) 'id': id,
      'chatId': chatId.toJson(),
      'memberAuthUserId': memberAuthUserId.toJson(),
      'role': role,
      'joinedAt': joinedAt.toJson(),
      'lastReadSeq': lastReadSeq,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatMemberRow',
      if (id != null) 'id': id,
      'chatId': chatId.toJson(),
      'memberAuthUserId': memberAuthUserId.toJson(),
      'role': role,
      'joinedAt': joinedAt.toJson(),
      'lastReadSeq': lastReadSeq,
    };
  }

  static ChatMemberRowInclude include() {
    return ChatMemberRowInclude._();
  }

  static ChatMemberRowIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatMemberRowTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatMemberRowTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatMemberRowTable>? orderByList,
    ChatMemberRowInclude? include,
  }) {
    return ChatMemberRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatMemberRow.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatMemberRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMemberRowImpl extends ChatMemberRow {
  _ChatMemberRowImpl({
    int? id,
    required _i1.UuidValue chatId,
    required _i1.UuidValue memberAuthUserId,
    required String role,
    DateTime? joinedAt,
    int? lastReadSeq,
  }) : super._(
         id: id,
         chatId: chatId,
         memberAuthUserId: memberAuthUserId,
         role: role,
         joinedAt: joinedAt,
         lastReadSeq: lastReadSeq,
       );

  /// Returns a shallow copy of this [ChatMemberRow]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatMemberRow copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? chatId,
    _i1.UuidValue? memberAuthUserId,
    String? role,
    DateTime? joinedAt,
    int? lastReadSeq,
  }) {
    return ChatMemberRow(
      id: id is int? ? id : this.id,
      chatId: chatId ?? this.chatId,
      memberAuthUserId: memberAuthUserId ?? this.memberAuthUserId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      lastReadSeq: lastReadSeq ?? this.lastReadSeq,
    );
  }
}

class ChatMemberRowUpdateTable extends _i1.UpdateTable<ChatMemberRowTable> {
  ChatMemberRowUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> chatId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.chatId,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> memberAuthUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.memberAuthUserId,
    value,
  );

  _i1.ColumnValue<String, String> role(String value) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> joinedAt(DateTime value) =>
      _i1.ColumnValue(
        table.joinedAt,
        value,
      );

  _i1.ColumnValue<int, int> lastReadSeq(int value) => _i1.ColumnValue(
    table.lastReadSeq,
    value,
  );
}

class ChatMemberRowTable extends _i1.Table<int?> {
  ChatMemberRowTable({super.tableRelation}) : super(tableName: 'chat_member') {
    updateTable = ChatMemberRowUpdateTable(this);
    chatId = _i1.ColumnUuid(
      'chatId',
      this,
    );
    memberAuthUserId = _i1.ColumnUuid(
      'memberAuthUserId',
      this,
    );
    role = _i1.ColumnString(
      'role',
      this,
    );
    joinedAt = _i1.ColumnDateTime(
      'joinedAt',
      this,
      hasDefault: true,
    );
    lastReadSeq = _i1.ColumnInt(
      'lastReadSeq',
      this,
      hasDefault: true,
    );
  }

  late final ChatMemberRowUpdateTable updateTable;

  late final _i1.ColumnUuid chatId;

  late final _i1.ColumnUuid memberAuthUserId;

  late final _i1.ColumnString role;

  late final _i1.ColumnDateTime joinedAt;

  late final _i1.ColumnInt lastReadSeq;

  @override
  List<_i1.Column> get columns => [
    id,
    chatId,
    memberAuthUserId,
    role,
    joinedAt,
    lastReadSeq,
  ];
}

class ChatMemberRowInclude extends _i1.IncludeObject {
  ChatMemberRowInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ChatMemberRow.t;
}

class ChatMemberRowIncludeList extends _i1.IncludeList {
  ChatMemberRowIncludeList._({
    _i1.WhereExpressionBuilder<ChatMemberRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatMemberRow.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ChatMemberRow.t;
}

class ChatMemberRowRepository {
  const ChatMemberRowRepository._();

  /// Returns a list of [ChatMemberRow]s matching the given query parameters.
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
  Future<List<ChatMemberRow>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatMemberRowTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatMemberRowTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatMemberRowTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChatMemberRow>(
      where: where?.call(ChatMemberRow.t),
      orderBy: orderBy?.call(ChatMemberRow.t),
      orderByList: orderByList?.call(ChatMemberRow.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ChatMemberRow] matching the given query parameters.
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
  Future<ChatMemberRow?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatMemberRowTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatMemberRowTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatMemberRowTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChatMemberRow>(
      where: where?.call(ChatMemberRow.t),
      orderBy: orderBy?.call(ChatMemberRow.t),
      orderByList: orderByList?.call(ChatMemberRow.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChatMemberRow] by its [id] or null if no such row exists.
  Future<ChatMemberRow?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChatMemberRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChatMemberRow]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatMemberRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ChatMemberRow>> insert(
    _i1.DatabaseSession session,
    List<ChatMemberRow> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ChatMemberRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ChatMemberRow] and returns the inserted row.
  ///
  /// The returned [ChatMemberRow] will have its `id` field set.
  Future<ChatMemberRow> insertRow(
    _i1.DatabaseSession session,
    ChatMemberRow row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatMemberRow>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatMemberRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatMemberRow>> update(
    _i1.DatabaseSession session,
    List<ChatMemberRow> rows, {
    _i1.ColumnSelections<ChatMemberRowTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatMemberRow>(
      rows,
      columns: columns?.call(ChatMemberRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatMemberRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatMemberRow> updateRow(
    _i1.DatabaseSession session,
    ChatMemberRow row, {
    _i1.ColumnSelections<ChatMemberRowTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatMemberRow>(
      row,
      columns: columns?.call(ChatMemberRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatMemberRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatMemberRow?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ChatMemberRowUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatMemberRow>(
      id,
      columnValues: columnValues(ChatMemberRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatMemberRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ChatMemberRow>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ChatMemberRowUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ChatMemberRowTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatMemberRowTable>? orderBy,
    _i1.OrderByListBuilder<ChatMemberRowTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ChatMemberRow>(
      columnValues: columnValues(ChatMemberRow.t.updateTable),
      where: where(ChatMemberRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatMemberRow.t),
      orderByList: orderByList?.call(ChatMemberRow.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ChatMemberRow]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatMemberRow>> delete(
    _i1.DatabaseSession session,
    List<ChatMemberRow> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatMemberRow>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatMemberRow].
  Future<ChatMemberRow> deleteRow(
    _i1.DatabaseSession session,
    ChatMemberRow row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatMemberRow>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatMemberRow>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatMemberRowTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatMemberRow>(
      where: where(ChatMemberRow.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatMemberRowTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatMemberRow>(
      where: where?.call(ChatMemberRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChatMemberRow] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatMemberRowTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChatMemberRow>(
      where: where(ChatMemberRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
