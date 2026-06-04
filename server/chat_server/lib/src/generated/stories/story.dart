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

/// Ephemeral story / post (encrypted content; 24 h TTL per ADR-0002).
abstract class Story
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  Story._({
    _i1.UuidValue? id,
    required this.authorAuthUserId,
    required this.mediaType,
    required this.encryptedPayload,
    required this.nonce,
    this.thumbnailCiphertext,
    required this.privacy,
    this.selectedViewerIds,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       expiresAt = expiresAt ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now();

  factory Story({
    _i1.UuidValue? id,
    required _i1.UuidValue authorAuthUserId,
    required String mediaType,
    required String encryptedPayload,
    required String nonce,
    String? thumbnailCiphertext,
    required String privacy,
    String? selectedViewerIds,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) = _StoryImpl;

  factory Story.fromJson(Map<String, dynamic> jsonSerialization) {
    return Story(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authorAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authorAuthUserId'],
      ),
      mediaType: jsonSerialization['mediaType'] as String,
      encryptedPayload: jsonSerialization['encryptedPayload'] as String,
      nonce: jsonSerialization['nonce'] as String,
      thumbnailCiphertext: jsonSerialization['thumbnailCiphertext'] as String?,
      privacy: jsonSerialization['privacy'] as String,
      selectedViewerIds: jsonSerialization['selectedViewerIds'] as String?,
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = StoryTable();

  static const db = StoryRepository._();

  @override
  _i1.UuidValue id;

  _i1.UuidValue authorAuthUserId;

  String mediaType;

  String encryptedPayload;

  String nonce;

  String? thumbnailCiphertext;

  String privacy;

  String? selectedViewerIds;

  DateTime expiresAt;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [Story]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Story copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authorAuthUserId,
    String? mediaType,
    String? encryptedPayload,
    String? nonce,
    String? thumbnailCiphertext,
    String? privacy,
    String? selectedViewerIds,
    DateTime? expiresAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Story',
      'id': id.toJson(),
      'authorAuthUserId': authorAuthUserId.toJson(),
      'mediaType': mediaType,
      'encryptedPayload': encryptedPayload,
      'nonce': nonce,
      if (thumbnailCiphertext != null)
        'thumbnailCiphertext': thumbnailCiphertext,
      'privacy': privacy,
      if (selectedViewerIds != null) 'selectedViewerIds': selectedViewerIds,
      'expiresAt': expiresAt.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Story',
      'id': id.toJson(),
      'authorAuthUserId': authorAuthUserId.toJson(),
      'mediaType': mediaType,
      'encryptedPayload': encryptedPayload,
      'nonce': nonce,
      if (thumbnailCiphertext != null)
        'thumbnailCiphertext': thumbnailCiphertext,
      'privacy': privacy,
      if (selectedViewerIds != null) 'selectedViewerIds': selectedViewerIds,
      'expiresAt': expiresAt.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static StoryInclude include() {
    return StoryInclude._();
  }

  static StoryIncludeList includeList({
    _i1.WhereExpressionBuilder<StoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StoryTable>? orderByList,
    StoryInclude? include,
  }) {
    return StoryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Story.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Story.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoryImpl extends Story {
  _StoryImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue authorAuthUserId,
    required String mediaType,
    required String encryptedPayload,
    required String nonce,
    String? thumbnailCiphertext,
    required String privacy,
    String? selectedViewerIds,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         authorAuthUserId: authorAuthUserId,
         mediaType: mediaType,
         encryptedPayload: encryptedPayload,
         nonce: nonce,
         thumbnailCiphertext: thumbnailCiphertext,
         privacy: privacy,
         selectedViewerIds: selectedViewerIds,
         expiresAt: expiresAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Story]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Story copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authorAuthUserId,
    String? mediaType,
    String? encryptedPayload,
    String? nonce,
    Object? thumbnailCiphertext = _Undefined,
    String? privacy,
    Object? selectedViewerIds = _Undefined,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return Story(
      id: id ?? this.id,
      authorAuthUserId: authorAuthUserId ?? this.authorAuthUserId,
      mediaType: mediaType ?? this.mediaType,
      encryptedPayload: encryptedPayload ?? this.encryptedPayload,
      nonce: nonce ?? this.nonce,
      thumbnailCiphertext: thumbnailCiphertext is String?
          ? thumbnailCiphertext
          : this.thumbnailCiphertext,
      privacy: privacy ?? this.privacy,
      selectedViewerIds: selectedViewerIds is String?
          ? selectedViewerIds
          : this.selectedViewerIds,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class StoryUpdateTable extends _i1.UpdateTable<StoryTable> {
  StoryUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> authorAuthUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.authorAuthUserId,
    value,
  );

  _i1.ColumnValue<String, String> mediaType(String value) => _i1.ColumnValue(
    table.mediaType,
    value,
  );

  _i1.ColumnValue<String, String> encryptedPayload(String value) =>
      _i1.ColumnValue(
        table.encryptedPayload,
        value,
      );

  _i1.ColumnValue<String, String> nonce(String value) => _i1.ColumnValue(
    table.nonce,
    value,
  );

  _i1.ColumnValue<String, String> thumbnailCiphertext(String? value) =>
      _i1.ColumnValue(
        table.thumbnailCiphertext,
        value,
      );

  _i1.ColumnValue<String, String> privacy(String value) => _i1.ColumnValue(
    table.privacy,
    value,
  );

  _i1.ColumnValue<String, String> selectedViewerIds(String? value) =>
      _i1.ColumnValue(
        table.selectedViewerIds,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _i1.ColumnValue(
        table.expiresAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class StoryTable extends _i1.Table<_i1.UuidValue> {
  StoryTable({super.tableRelation}) : super(tableName: 'story') {
    updateTable = StoryUpdateTable(this);
    authorAuthUserId = _i1.ColumnUuid(
      'authorAuthUserId',
      this,
    );
    mediaType = _i1.ColumnString(
      'mediaType',
      this,
    );
    encryptedPayload = _i1.ColumnString(
      'encryptedPayload',
      this,
    );
    nonce = _i1.ColumnString(
      'nonce',
      this,
    );
    thumbnailCiphertext = _i1.ColumnString(
      'thumbnailCiphertext',
      this,
    );
    privacy = _i1.ColumnString(
      'privacy',
      this,
    );
    selectedViewerIds = _i1.ColumnString(
      'selectedViewerIds',
      this,
    );
    expiresAt = _i1.ColumnDateTime(
      'expiresAt',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final StoryUpdateTable updateTable;

  late final _i1.ColumnUuid authorAuthUserId;

  late final _i1.ColumnString mediaType;

  late final _i1.ColumnString encryptedPayload;

  late final _i1.ColumnString nonce;

  late final _i1.ColumnString thumbnailCiphertext;

  late final _i1.ColumnString privacy;

  late final _i1.ColumnString selectedViewerIds;

  late final _i1.ColumnDateTime expiresAt;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    authorAuthUserId,
    mediaType,
    encryptedPayload,
    nonce,
    thumbnailCiphertext,
    privacy,
    selectedViewerIds,
    expiresAt,
    createdAt,
  ];
}

class StoryInclude extends _i1.IncludeObject {
  StoryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => Story.t;
}

class StoryIncludeList extends _i1.IncludeList {
  StoryIncludeList._({
    _i1.WhereExpressionBuilder<StoryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Story.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => Story.t;
}

class StoryRepository {
  const StoryRepository._();

  /// Returns a list of [Story]s matching the given query parameters.
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
  Future<List<Story>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StoryTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Story>(
      where: where?.call(Story.t),
      orderBy: orderBy?.call(Story.t),
      orderByList: orderByList?.call(Story.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Story] matching the given query parameters.
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
  Future<Story?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StoryTable>? where,
    int? offset,
    _i1.OrderByBuilder<StoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StoryTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Story>(
      where: where?.call(Story.t),
      orderBy: orderBy?.call(Story.t),
      orderByList: orderByList?.call(Story.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Story] by its [id] or null if no such row exists.
  Future<Story?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Story>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Story]s in the list and returns the inserted rows.
  ///
  /// The returned [Story]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Story>> insert(
    _i1.DatabaseSession session,
    List<Story> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Story>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Story] and returns the inserted row.
  ///
  /// The returned [Story] will have its `id` field set.
  Future<Story> insertRow(
    _i1.DatabaseSession session,
    Story row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Story>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Story]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Story>> update(
    _i1.DatabaseSession session,
    List<Story> rows, {
    _i1.ColumnSelections<StoryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Story>(
      rows,
      columns: columns?.call(Story.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Story]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Story> updateRow(
    _i1.DatabaseSession session,
    Story row, {
    _i1.ColumnSelections<StoryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Story>(
      row,
      columns: columns?.call(Story.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Story] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Story?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<StoryUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Story>(
      id,
      columnValues: columnValues(Story.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Story]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Story>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<StoryUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<StoryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StoryTable>? orderBy,
    _i1.OrderByListBuilder<StoryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Story>(
      columnValues: columnValues(Story.t.updateTable),
      where: where(Story.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Story.t),
      orderByList: orderByList?.call(Story.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Story]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Story>> delete(
    _i1.DatabaseSession session,
    List<Story> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Story>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Story].
  Future<Story> deleteRow(
    _i1.DatabaseSession session,
    Story row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Story>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Story>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<StoryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Story>(
      where: where(Story.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StoryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Story>(
      where: where?.call(Story.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Story] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<StoryTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Story>(
      where: where(Story.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
