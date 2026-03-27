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

abstract class ChatMessage
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  ChatMessage._({
    _i1.UuidValue? id,
    required this.chatId,
    required this.senderAuthUserId,
    this.senderDeviceId,
    required this.serverSeq,
    required this.clientMsgId,
    required this.ciphertext,
    required this.nonce,
    required this.schemaVersion,
    DateTime? createdAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now();

  factory ChatMessage({
    _i1.UuidValue? id,
    required _i1.UuidValue chatId,
    required _i1.UuidValue senderAuthUserId,
    _i1.UuidValue? senderDeviceId,
    required int serverSeq,
    required String clientMsgId,
    required String ciphertext,
    required String nonce,
    required int schemaVersion,
    DateTime? createdAt,
  }) = _ChatMessageImpl;

  factory ChatMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMessage(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      chatId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['chatId']),
      senderAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['senderAuthUserId'],
      ),
      senderDeviceId: jsonSerialization['senderDeviceId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['senderDeviceId'],
            ),
      serverSeq: jsonSerialization['serverSeq'] as int,
      clientMsgId: jsonSerialization['clientMsgId'] as String,
      ciphertext: jsonSerialization['ciphertext'] as String,
      nonce: jsonSerialization['nonce'] as String,
      schemaVersion: jsonSerialization['schemaVersion'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = ChatMessageTable();

  static const db = ChatMessageRepository._();

  @override
  _i1.UuidValue id;

  _i1.UuidValue chatId;

  _i1.UuidValue senderAuthUserId;

  _i1.UuidValue? senderDeviceId;

  int serverSeq;

  String clientMsgId;

  String ciphertext;

  String nonce;

  int schemaVersion;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatMessage copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? chatId,
    _i1.UuidValue? senderAuthUserId,
    _i1.UuidValue? senderDeviceId,
    int? serverSeq,
    String? clientMsgId,
    String? ciphertext,
    String? nonce,
    int? schemaVersion,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatMessage',
      'id': id.toJson(),
      'chatId': chatId.toJson(),
      'senderAuthUserId': senderAuthUserId.toJson(),
      if (senderDeviceId != null) 'senderDeviceId': senderDeviceId?.toJson(),
      'serverSeq': serverSeq,
      'clientMsgId': clientMsgId,
      'ciphertext': ciphertext,
      'nonce': nonce,
      'schemaVersion': schemaVersion,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatMessage',
      'id': id.toJson(),
      'chatId': chatId.toJson(),
      'senderAuthUserId': senderAuthUserId.toJson(),
      if (senderDeviceId != null) 'senderDeviceId': senderDeviceId?.toJson(),
      'serverSeq': serverSeq,
      'clientMsgId': clientMsgId,
      'ciphertext': ciphertext,
      'nonce': nonce,
      'schemaVersion': schemaVersion,
      'createdAt': createdAt.toJson(),
    };
  }

  static ChatMessageInclude include() {
    return ChatMessageInclude._();
  }

  static ChatMessageIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatMessageTable>? orderByList,
    ChatMessageInclude? include,
  }) {
    return ChatMessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatMessage.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatMessage.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMessageImpl extends ChatMessage {
  _ChatMessageImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue chatId,
    required _i1.UuidValue senderAuthUserId,
    _i1.UuidValue? senderDeviceId,
    required int serverSeq,
    required String clientMsgId,
    required String ciphertext,
    required String nonce,
    required int schemaVersion,
    DateTime? createdAt,
  }) : super._(
         id: id,
         chatId: chatId,
         senderAuthUserId: senderAuthUserId,
         senderDeviceId: senderDeviceId,
         serverSeq: serverSeq,
         clientMsgId: clientMsgId,
         ciphertext: ciphertext,
         nonce: nonce,
         schemaVersion: schemaVersion,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatMessage copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? chatId,
    _i1.UuidValue? senderAuthUserId,
    Object? senderDeviceId = _Undefined,
    int? serverSeq,
    String? clientMsgId,
    String? ciphertext,
    String? nonce,
    int? schemaVersion,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderAuthUserId: senderAuthUserId ?? this.senderAuthUserId,
      senderDeviceId: senderDeviceId is _i1.UuidValue?
          ? senderDeviceId
          : this.senderDeviceId,
      serverSeq: serverSeq ?? this.serverSeq,
      clientMsgId: clientMsgId ?? this.clientMsgId,
      ciphertext: ciphertext ?? this.ciphertext,
      nonce: nonce ?? this.nonce,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ChatMessageUpdateTable extends _i1.UpdateTable<ChatMessageTable> {
  ChatMessageUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> chatId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.chatId,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> senderAuthUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.senderAuthUserId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> senderDeviceId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.senderDeviceId,
    value,
  );

  _i1.ColumnValue<int, int> serverSeq(int value) => _i1.ColumnValue(
    table.serverSeq,
    value,
  );

  _i1.ColumnValue<String, String> clientMsgId(String value) => _i1.ColumnValue(
    table.clientMsgId,
    value,
  );

  _i1.ColumnValue<String, String> ciphertext(String value) => _i1.ColumnValue(
    table.ciphertext,
    value,
  );

  _i1.ColumnValue<String, String> nonce(String value) => _i1.ColumnValue(
    table.nonce,
    value,
  );

  _i1.ColumnValue<int, int> schemaVersion(int value) => _i1.ColumnValue(
    table.schemaVersion,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class ChatMessageTable extends _i1.Table<_i1.UuidValue> {
  ChatMessageTable({super.tableRelation}) : super(tableName: 'chat_message') {
    updateTable = ChatMessageUpdateTable(this);
    chatId = _i1.ColumnUuid(
      'chatId',
      this,
    );
    senderAuthUserId = _i1.ColumnUuid(
      'senderAuthUserId',
      this,
    );
    senderDeviceId = _i1.ColumnUuid(
      'senderDeviceId',
      this,
    );
    serverSeq = _i1.ColumnInt(
      'serverSeq',
      this,
    );
    clientMsgId = _i1.ColumnString(
      'clientMsgId',
      this,
    );
    ciphertext = _i1.ColumnString(
      'ciphertext',
      this,
    );
    nonce = _i1.ColumnString(
      'nonce',
      this,
    );
    schemaVersion = _i1.ColumnInt(
      'schemaVersion',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final ChatMessageUpdateTable updateTable;

  late final _i1.ColumnUuid chatId;

  late final _i1.ColumnUuid senderAuthUserId;

  late final _i1.ColumnUuid senderDeviceId;

  late final _i1.ColumnInt serverSeq;

  late final _i1.ColumnString clientMsgId;

  late final _i1.ColumnString ciphertext;

  late final _i1.ColumnString nonce;

  late final _i1.ColumnInt schemaVersion;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    chatId,
    senderAuthUserId,
    senderDeviceId,
    serverSeq,
    clientMsgId,
    ciphertext,
    nonce,
    schemaVersion,
    createdAt,
  ];
}

class ChatMessageInclude extends _i1.IncludeObject {
  ChatMessageInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => ChatMessage.t;
}

class ChatMessageIncludeList extends _i1.IncludeList {
  ChatMessageIncludeList._({
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatMessage.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => ChatMessage.t;
}

class ChatMessageRepository {
  const ChatMessageRepository._();

  /// Returns a list of [ChatMessage]s matching the given query parameters.
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
  Future<List<ChatMessage>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatMessageTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChatMessage>(
      where: where?.call(ChatMessage.t),
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ChatMessage] matching the given query parameters.
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
  Future<ChatMessage?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatMessageTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChatMessage>(
      where: where?.call(ChatMessage.t),
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChatMessage] by its [id] or null if no such row exists.
  Future<ChatMessage?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChatMessage>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChatMessage]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatMessage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ChatMessage>> insert(
    _i1.DatabaseSession session,
    List<ChatMessage> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ChatMessage>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ChatMessage] and returns the inserted row.
  ///
  /// The returned [ChatMessage] will have its `id` field set.
  Future<ChatMessage> insertRow(
    _i1.DatabaseSession session,
    ChatMessage row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatMessage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatMessage>> update(
    _i1.DatabaseSession session,
    List<ChatMessage> rows, {
    _i1.ColumnSelections<ChatMessageTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatMessage>(
      rows,
      columns: columns?.call(ChatMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatMessage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatMessage> updateRow(
    _i1.DatabaseSession session,
    ChatMessage row, {
    _i1.ColumnSelections<ChatMessageTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatMessage>(
      row,
      columns: columns?.call(ChatMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatMessage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatMessage?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<ChatMessageUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatMessage>(
      id,
      columnValues: columnValues(ChatMessage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatMessage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ChatMessage>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ChatMessageUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ChatMessageTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatMessageTable>? orderBy,
    _i1.OrderByListBuilder<ChatMessageTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ChatMessage>(
      columnValues: columnValues(ChatMessage.t.updateTable),
      where: where(ChatMessage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ChatMessage]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatMessage>> delete(
    _i1.DatabaseSession session,
    List<ChatMessage> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatMessage>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatMessage].
  Future<ChatMessage> deleteRow(
    _i1.DatabaseSession session,
    ChatMessage row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatMessage>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatMessageTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatMessage>(
      where: where(ChatMessage.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatMessage>(
      where: where?.call(ChatMessage.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChatMessage] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatMessageTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChatMessage>(
      where: where(ChatMessage.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
