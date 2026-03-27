// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalChatsTable extends LocalChats
    with TableInfo<$LocalChatsTable, LocalChat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPreviewMeta = const VerificationMeta(
    'lastPreview',
  );
  @override
  late final GeneratedColumn<String> lastPreview = GeneratedColumn<String>(
    'last_preview',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageAtMeta = const VerificationMeta(
    'lastMessageAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastMessageAt =
      GeneratedColumn<DateTime>(
        'last_message_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    title,
    lastPreview,
    lastMessageAt,
    unreadCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_chats';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalChat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('last_preview')) {
      context.handle(
        _lastPreviewMeta,
        lastPreview.isAcceptableOrUnknown(
          data['last_preview']!,
          _lastPreviewMeta,
        ),
      );
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
        _lastMessageAtMeta,
        lastMessageAt.isAcceptableOrUnknown(
          data['last_message_at']!,
          _lastMessageAtMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalChat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalChat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      lastPreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_preview'],
      ),
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_at'],
      ),
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalChatsTable createAlias(String alias) {
    return $LocalChatsTable(attachedDatabase, alias);
  }
}

class LocalChat extends DataClass implements Insertable<LocalChat> {
  final String id;
  final String type;
  final String? title;
  final String? lastPreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime updatedAt;
  const LocalChat({
    required this.id,
    required this.type,
    this.title,
    this.lastPreview,
    this.lastMessageAt,
    required this.unreadCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || lastPreview != null) {
      map['last_preview'] = Variable<String>(lastPreview);
    }
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalChatsCompanion toCompanion(bool nullToAbsent) {
    return LocalChatsCompanion(
      id: Value(id),
      type: Value(type),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      lastPreview: lastPreview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPreview),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
      unreadCount: Value(unreadCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalChat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalChat(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String?>(json['title']),
      lastPreview: serializer.fromJson<String?>(json['lastPreview']),
      lastMessageAt: serializer.fromJson<DateTime?>(json['lastMessageAt']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String?>(title),
      'lastPreview': serializer.toJson<String?>(lastPreview),
      'lastMessageAt': serializer.toJson<DateTime?>(lastMessageAt),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalChat copyWith({
    String? id,
    String? type,
    Value<String?> title = const Value.absent(),
    Value<String?> lastPreview = const Value.absent(),
    Value<DateTime?> lastMessageAt = const Value.absent(),
    int? unreadCount,
    DateTime? updatedAt,
  }) => LocalChat(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title.present ? title.value : this.title,
    lastPreview: lastPreview.present ? lastPreview.value : this.lastPreview,
    lastMessageAt: lastMessageAt.present
        ? lastMessageAt.value
        : this.lastMessageAt,
    unreadCount: unreadCount ?? this.unreadCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalChat copyWithCompanion(LocalChatsCompanion data) {
    return LocalChat(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      lastPreview: data.lastPreview.present
          ? data.lastPreview.value
          : this.lastPreview,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalChat(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('lastPreview: $lastPreview, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    title,
    lastPreview,
    lastMessageAt,
    unreadCount,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalChat &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.lastPreview == this.lastPreview &&
          other.lastMessageAt == this.lastMessageAt &&
          other.unreadCount == this.unreadCount &&
          other.updatedAt == this.updatedAt);
}

class LocalChatsCompanion extends UpdateCompanion<LocalChat> {
  final Value<String> id;
  final Value<String> type;
  final Value<String?> title;
  final Value<String?> lastPreview;
  final Value<DateTime?> lastMessageAt;
  final Value<int> unreadCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalChatsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.lastPreview = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalChatsCompanion.insert({
    required String id,
    required String type,
    this.title = const Value.absent(),
    this.lastPreview = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       updatedAt = Value(updatedAt);
  static Insertable<LocalChat> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? lastPreview,
    Expression<DateTime>? lastMessageAt,
    Expression<int>? unreadCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (lastPreview != null) 'last_preview': lastPreview,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalChatsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String?>? title,
    Value<String?>? lastPreview,
    Value<DateTime?>? lastMessageAt,
    Value<int>? unreadCount,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalChatsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      lastPreview: lastPreview ?? this.lastPreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (lastPreview.present) {
      map['last_preview'] = Variable<String>(lastPreview.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalChatsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('lastPreview: $lastPreview, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMessagesTable extends LocalMessages
    with TableInfo<$LocalMessagesTable, LocalMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receiverIdMeta = const VerificationMeta(
    'receiverId',
  );
  @override
  late final GeneratedColumn<String> receiverId = GeneratedColumn<String>(
    'receiver_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sent'),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientMsgIdMeta = const VerificationMeta(
    'clientMsgId',
  );
  @override
  late final GeneratedColumn<String> clientMsgId = GeneratedColumn<String>(
    'client_msg_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPendingDeliveryMeta = const VerificationMeta(
    'isPendingDelivery',
  );
  @override
  late final GeneratedColumn<bool> isPendingDelivery = GeneratedColumn<bool>(
    'is_pending_delivery',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pending_delivery" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chatId,
    senderId,
    receiverId,
    body,
    contentType,
    imageUrl,
    status,
    serverSeq,
    clientMsgId,
    createdAt,
    deletedAt,
    isPendingDelivery,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('receiver_id')) {
      context.handle(
        _receiverIdMeta,
        receiverId.isAcceptableOrUnknown(data['receiver_id']!, _receiverIdMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('client_msg_id')) {
      context.handle(
        _clientMsgIdMeta,
        clientMsgId.isAcceptableOrUnknown(
          data['client_msg_id']!,
          _clientMsgIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_pending_delivery')) {
      context.handle(
        _isPendingDeliveryMeta,
        isPendingDelivery.isAcceptableOrUnknown(
          data['is_pending_delivery']!,
          _isPendingDeliveryMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      receiverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receiver_id'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      clientMsgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_msg_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      isPendingDelivery: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pending_delivery'],
      )!,
    );
  }

  @override
  $LocalMessagesTable createAlias(String alias) {
    return $LocalMessagesTable(attachedDatabase, alias);
  }
}

class LocalMessage extends DataClass implements Insertable<LocalMessage> {
  /// Row id (matches [MessageModel.id] / client id).
  final String id;
  final String chatId;
  final String senderId;
  final String? receiverId;

  /// Plaintext during transition; ciphertext UTF-8 once E2EE is enforced at repo boundary.
  final String body;
  final String contentType;
  final String? imageUrl;
  final String status;
  final int? serverSeq;
  final String? clientMsgId;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final bool isPendingDelivery;
  const LocalMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.receiverId,
    required this.body,
    required this.contentType,
    this.imageUrl,
    required this.status,
    this.serverSeq,
    this.clientMsgId,
    required this.createdAt,
    this.deletedAt,
    required this.isPendingDelivery,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chat_id'] = Variable<String>(chatId);
    map['sender_id'] = Variable<String>(senderId);
    if (!nullToAbsent || receiverId != null) {
      map['receiver_id'] = Variable<String>(receiverId);
    }
    map['body'] = Variable<String>(body);
    map['content_type'] = Variable<String>(contentType);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || clientMsgId != null) {
      map['client_msg_id'] = Variable<String>(clientMsgId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_pending_delivery'] = Variable<bool>(isPendingDelivery);
    return map;
  }

  LocalMessagesCompanion toCompanion(bool nullToAbsent) {
    return LocalMessagesCompanion(
      id: Value(id),
      chatId: Value(chatId),
      senderId: Value(senderId),
      receiverId: receiverId == null && nullToAbsent
          ? const Value.absent()
          : Value(receiverId),
      body: Value(body),
      contentType: Value(contentType),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      status: Value(status),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      clientMsgId: clientMsgId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientMsgId),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isPendingDelivery: Value(isPendingDelivery),
    );
  }

  factory LocalMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMessage(
      id: serializer.fromJson<String>(json['id']),
      chatId: serializer.fromJson<String>(json['chatId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      receiverId: serializer.fromJson<String?>(json['receiverId']),
      body: serializer.fromJson<String>(json['body']),
      contentType: serializer.fromJson<String>(json['contentType']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      status: serializer.fromJson<String>(json['status']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      clientMsgId: serializer.fromJson<String?>(json['clientMsgId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isPendingDelivery: serializer.fromJson<bool>(json['isPendingDelivery']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chatId': serializer.toJson<String>(chatId),
      'senderId': serializer.toJson<String>(senderId),
      'receiverId': serializer.toJson<String?>(receiverId),
      'body': serializer.toJson<String>(body),
      'contentType': serializer.toJson<String>(contentType),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'status': serializer.toJson<String>(status),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'clientMsgId': serializer.toJson<String?>(clientMsgId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isPendingDelivery': serializer.toJson<bool>(isPendingDelivery),
    };
  }

  LocalMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    Value<String?> receiverId = const Value.absent(),
    String? body,
    String? contentType,
    Value<String?> imageUrl = const Value.absent(),
    String? status,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> clientMsgId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? isPendingDelivery,
  }) => LocalMessage(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    senderId: senderId ?? this.senderId,
    receiverId: receiverId.present ? receiverId.value : this.receiverId,
    body: body ?? this.body,
    contentType: contentType ?? this.contentType,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    status: status ?? this.status,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    clientMsgId: clientMsgId.present ? clientMsgId.value : this.clientMsgId,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isPendingDelivery: isPendingDelivery ?? this.isPendingDelivery,
  );
  LocalMessage copyWithCompanion(LocalMessagesCompanion data) {
    return LocalMessage(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      receiverId: data.receiverId.present
          ? data.receiverId.value
          : this.receiverId,
      body: data.body.present ? data.body.value : this.body,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      status: data.status.present ? data.status.value : this.status,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      clientMsgId: data.clientMsgId.present
          ? data.clientMsgId.value
          : this.clientMsgId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isPendingDelivery: data.isPendingDelivery.present
          ? data.isPendingDelivery.value
          : this.isPendingDelivery,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessage(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('receiverId: $receiverId, ')
          ..write('body: $body, ')
          ..write('contentType: $contentType, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('status: $status, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('clientMsgId: $clientMsgId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isPendingDelivery: $isPendingDelivery')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chatId,
    senderId,
    receiverId,
    body,
    contentType,
    imageUrl,
    status,
    serverSeq,
    clientMsgId,
    createdAt,
    deletedAt,
    isPendingDelivery,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMessage &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.senderId == this.senderId &&
          other.receiverId == this.receiverId &&
          other.body == this.body &&
          other.contentType == this.contentType &&
          other.imageUrl == this.imageUrl &&
          other.status == this.status &&
          other.serverSeq == this.serverSeq &&
          other.clientMsgId == this.clientMsgId &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt &&
          other.isPendingDelivery == this.isPendingDelivery);
}

class LocalMessagesCompanion extends UpdateCompanion<LocalMessage> {
  final Value<String> id;
  final Value<String> chatId;
  final Value<String> senderId;
  final Value<String?> receiverId;
  final Value<String> body;
  final Value<String> contentType;
  final Value<String?> imageUrl;
  final Value<String> status;
  final Value<int?> serverSeq;
  final Value<String?> clientMsgId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isPendingDelivery;
  final Value<int> rowid;
  const LocalMessagesCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.receiverId = const Value.absent(),
    this.body = const Value.absent(),
    this.contentType = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.status = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.clientMsgId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isPendingDelivery = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMessagesCompanion.insert({
    required String id,
    required String chatId,
    required String senderId,
    this.receiverId = const Value.absent(),
    required String body,
    this.contentType = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.status = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.clientMsgId = const Value.absent(),
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    this.isPendingDelivery = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       chatId = Value(chatId),
       senderId = Value(senderId),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<LocalMessage> custom({
    Expression<String>? id,
    Expression<String>? chatId,
    Expression<String>? senderId,
    Expression<String>? receiverId,
    Expression<String>? body,
    Expression<String>? contentType,
    Expression<String>? imageUrl,
    Expression<String>? status,
    Expression<int>? serverSeq,
    Expression<String>? clientMsgId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isPendingDelivery,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (senderId != null) 'sender_id': senderId,
      if (receiverId != null) 'receiver_id': receiverId,
      if (body != null) 'body': body,
      if (contentType != null) 'content_type': contentType,
      if (imageUrl != null) 'image_url': imageUrl,
      if (status != null) 'status': status,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (clientMsgId != null) 'client_msg_id': clientMsgId,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isPendingDelivery != null) 'is_pending_delivery': isPendingDelivery,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? chatId,
    Value<String>? senderId,
    Value<String?>? receiverId,
    Value<String>? body,
    Value<String>? contentType,
    Value<String?>? imageUrl,
    Value<String>? status,
    Value<int?>? serverSeq,
    Value<String?>? clientMsgId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? isPendingDelivery,
    Value<int>? rowid,
  }) {
    return LocalMessagesCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      body: body ?? this.body,
      contentType: contentType ?? this.contentType,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      serverSeq: serverSeq ?? this.serverSeq,
      clientMsgId: clientMsgId ?? this.clientMsgId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isPendingDelivery: isPendingDelivery ?? this.isPendingDelivery,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (receiverId.present) {
      map['receiver_id'] = Variable<String>(receiverId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (clientMsgId.present) {
      map['client_msg_id'] = Variable<String>(clientMsgId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isPendingDelivery.present) {
      map['is_pending_delivery'] = Variable<bool>(isPendingDelivery.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessagesCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('receiverId: $receiverId, ')
          ..write('body: $body, ')
          ..write('contentType: $contentType, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('status: $status, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('clientMsgId: $clientMsgId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isPendingDelivery: $isPendingDelivery, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMembersTable extends ChatMembers
    with TableInfo<$ChatMembersTable, ChatMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('member'),
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [chatId, userId, role, joinedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId, userId};
  @override
  ChatMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMember(
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      )!,
    );
  }

  @override
  $ChatMembersTable createAlias(String alias) {
    return $ChatMembersTable(attachedDatabase, alias);
  }
}

class ChatMember extends DataClass implements Insertable<ChatMember> {
  final String chatId;
  final String userId;
  final String role;
  final DateTime joinedAt;
  const ChatMember({
    required this.chatId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<String>(chatId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    return map;
  }

  ChatMembersCompanion toCompanion(bool nullToAbsent) {
    return ChatMembersCompanion(
      chatId: Value(chatId),
      userId: Value(userId),
      role: Value(role),
      joinedAt: Value(joinedAt),
    );
  }

  factory ChatMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMember(
      chatId: serializer.fromJson<String>(json['chatId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<String>(chatId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
    };
  }

  ChatMember copyWith({
    String? chatId,
    String? userId,
    String? role,
    DateTime? joinedAt,
  }) => ChatMember(
    chatId: chatId ?? this.chatId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    joinedAt: joinedAt ?? this.joinedAt,
  );
  ChatMember copyWithCompanion(ChatMembersCompanion data) {
    return ChatMember(
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMember(')
          ..write('chatId: $chatId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chatId, userId, role, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMember &&
          other.chatId == this.chatId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.joinedAt == this.joinedAt);
}

class ChatMembersCompanion extends UpdateCompanion<ChatMember> {
  final Value<String> chatId;
  final Value<String> userId;
  final Value<String> role;
  final Value<DateTime> joinedAt;
  final Value<int> rowid;
  const ChatMembersCompanion({
    this.chatId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMembersCompanion.insert({
    required String chatId,
    required String userId,
    this.role = const Value.absent(),
    required DateTime joinedAt,
    this.rowid = const Value.absent(),
  }) : chatId = Value(chatId),
       userId = Value(userId),
       joinedAt = Value(joinedAt);
  static Insertable<ChatMember> custom({
    Expression<String>? chatId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<DateTime>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMembersCompanion copyWith({
    Value<String>? chatId,
    Value<String>? userId,
    Value<String>? role,
    Value<DateTime>? joinedAt,
    Value<int>? rowid,
  }) {
    return ChatMembersCompanion(
      chatId: chatId ?? this.chatId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMembersCompanion(')
          ..write('chatId: $chatId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxEntriesTable extends OutboxEntries
    with TableInfo<$OutboxEntriesTable, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clientMsgIdMeta = const VerificationMeta(
    'clientMsgId',
  );
  @override
  late final GeneratedColumn<String> clientMsgId = GeneratedColumn<String>(
    'client_msg_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sendMessage'),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    clientMsgId,
    chatId,
    operation,
    payloadJson,
    attemptCount,
    nextRetryAt,
    state,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('client_msg_id')) {
      context.handle(
        _clientMsgIdMeta,
        clientMsgId.isAcceptableOrUnknown(
          data['client_msg_id']!,
          _clientMsgIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientMsgIdMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      clientMsgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_msg_id'],
      )!,
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxEntriesTable createAlias(String alias) {
    return $OutboxEntriesTable(attachedDatabase, alias);
  }
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  final int localId;
  final String clientMsgId;
  final String chatId;
  final String operation;

  /// Serialized payload for Serverpod/Firestore adapters (versioned informally).
  final String payloadJson;
  final int attemptCount;
  final DateTime? nextRetryAt;
  final String state;
  final DateTime createdAt;
  const OutboxEntry({
    required this.localId,
    required this.clientMsgId,
    required this.chatId,
    required this.operation,
    required this.payloadJson,
    required this.attemptCount,
    this.nextRetryAt,
    required this.state,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['client_msg_id'] = Variable<String>(clientMsgId);
    map['chat_id'] = Variable<String>(chatId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    map['state'] = Variable<String>(state);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesCompanion(
      localId: Value(localId),
      clientMsgId: Value(clientMsgId),
      chatId: Value(chatId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      attemptCount: Value(attemptCount),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      state: Value(state),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      localId: serializer.fromJson<int>(json['localId']),
      clientMsgId: serializer.fromJson<String>(json['clientMsgId']),
      chatId: serializer.fromJson<String>(json['chatId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      state: serializer.fromJson<String>(json['state']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'clientMsgId': serializer.toJson<String>(clientMsgId),
      'chatId': serializer.toJson<String>(chatId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'state': serializer.toJson<String>(state),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxEntry copyWith({
    int? localId,
    String? clientMsgId,
    String? chatId,
    String? operation,
    String? payloadJson,
    int? attemptCount,
    Value<DateTime?> nextRetryAt = const Value.absent(),
    String? state,
    DateTime? createdAt,
  }) => OutboxEntry(
    localId: localId ?? this.localId,
    clientMsgId: clientMsgId ?? this.clientMsgId,
    chatId: chatId ?? this.chatId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    attemptCount: attemptCount ?? this.attemptCount,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    state: state ?? this.state,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxEntry copyWithCompanion(OutboxEntriesCompanion data) {
    return OutboxEntry(
      localId: data.localId.present ? data.localId.value : this.localId,
      clientMsgId: data.clientMsgId.present
          ? data.clientMsgId.value
          : this.clientMsgId,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      state: data.state.present ? data.state.value : this.state,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('localId: $localId, ')
          ..write('clientMsgId: $clientMsgId, ')
          ..write('chatId: $chatId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    clientMsgId,
    chatId,
    operation,
    payloadJson,
    attemptCount,
    nextRetryAt,
    state,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.localId == this.localId &&
          other.clientMsgId == this.clientMsgId &&
          other.chatId == this.chatId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.attemptCount == this.attemptCount &&
          other.nextRetryAt == this.nextRetryAt &&
          other.state == this.state &&
          other.createdAt == this.createdAt);
}

class OutboxEntriesCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<int> localId;
  final Value<String> clientMsgId;
  final Value<String> chatId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<int> attemptCount;
  final Value<DateTime?> nextRetryAt;
  final Value<String> state;
  final Value<DateTime> createdAt;
  const OutboxEntriesCompanion({
    this.localId = const Value.absent(),
    this.clientMsgId = const Value.absent(),
    this.chatId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.state = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxEntriesCompanion.insert({
    this.localId = const Value.absent(),
    required String clientMsgId,
    required String chatId,
    this.operation = const Value.absent(),
    required String payloadJson,
    this.attemptCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.state = const Value.absent(),
    required DateTime createdAt,
  }) : clientMsgId = Value(clientMsgId),
       chatId = Value(chatId),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<OutboxEntry> custom({
    Expression<int>? localId,
    Expression<String>? clientMsgId,
    Expression<String>? chatId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<int>? attemptCount,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? state,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (clientMsgId != null) 'client_msg_id': clientMsgId,
      if (chatId != null) 'chat_id': chatId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (state != null) 'state': state,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxEntriesCompanion copyWith({
    Value<int>? localId,
    Value<String>? clientMsgId,
    Value<String>? chatId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<int>? attemptCount,
    Value<DateTime?>? nextRetryAt,
    Value<String>? state,
    Value<DateTime>? createdAt,
  }) {
    return OutboxEntriesCompanion(
      localId: localId ?? this.localId,
      clientMsgId: clientMsgId ?? this.clientMsgId,
      chatId: chatId ?? this.chatId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      attemptCount: attemptCount ?? this.attemptCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (clientMsgId.present) {
      map['client_msg_id'] = Variable<String>(clientMsgId.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntriesCompanion(')
          ..write('localId: $localId, ')
          ..write('clientMsgId: $clientMsgId, ')
          ..write('chatId: $chatId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scopeKeyMeta = const VerificationMeta(
    'scopeKey',
  );
  @override
  late final GeneratedColumn<String> scopeKey = GeneratedColumn<String>(
    'scope_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [scopeKey, cursor, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scope_key')) {
      context.handle(
        _scopeKeyMeta,
        scopeKey.isAcceptableOrUnknown(data['scope_key']!, _scopeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeKeyMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scopeKey};
  @override
  SyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncState(
      scopeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_key'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncState extends DataClass implements Insertable<SyncState> {
  final String scopeKey;
  final String? cursor;
  final DateTime? lastSyncedAt;
  const SyncState({required this.scopeKey, this.cursor, this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scope_key'] = Variable<String>(scopeKey);
    if (!nullToAbsent || cursor != null) {
      map['cursor'] = Variable<String>(cursor);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      scopeKey: Value(scopeKey),
      cursor: cursor == null && nullToAbsent
          ? const Value.absent()
          : Value(cursor),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory SyncState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncState(
      scopeKey: serializer.fromJson<String>(json['scopeKey']),
      cursor: serializer.fromJson<String?>(json['cursor']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scopeKey': serializer.toJson<String>(scopeKey),
      'cursor': serializer.toJson<String?>(cursor),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  SyncState copyWith({
    String? scopeKey,
    Value<String?> cursor = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => SyncState(
    scopeKey: scopeKey ?? this.scopeKey,
    cursor: cursor.present ? cursor.value : this.cursor,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  SyncState copyWithCompanion(SyncStatesCompanion data) {
    return SyncState(
      scopeKey: data.scopeKey.present ? data.scopeKey.value : this.scopeKey,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncState(')
          ..write('scopeKey: $scopeKey, ')
          ..write('cursor: $cursor, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(scopeKey, cursor, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncState &&
          other.scopeKey == this.scopeKey &&
          other.cursor == this.cursor &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncStatesCompanion extends UpdateCompanion<SyncState> {
  final Value<String> scopeKey;
  final Value<String?> cursor;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const SyncStatesCompanion({
    this.scopeKey = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    required String scopeKey,
    this.cursor = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : scopeKey = Value(scopeKey);
  static Insertable<SyncState> custom({
    Expression<String>? scopeKey,
    Expression<String>? cursor,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scopeKey != null) 'scope_key': scopeKey,
      if (cursor != null) 'cursor': cursor,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatesCompanion copyWith({
    Value<String>? scopeKey,
    Value<String?>? cursor,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return SyncStatesCompanion(
      scopeKey: scopeKey ?? this.scopeKey,
      cursor: cursor ?? this.cursor,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scopeKey.present) {
      map['scope_key'] = Variable<String>(scopeKey.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('scopeKey: $scopeKey, ')
          ..write('cursor: $cursor, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingMediaTable extends PendingMedia
    with TableInfo<$PendingMediaTable, PendingMediaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingMediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesUploadedMeta = const VerificationMeta(
    'bytesUploaded',
  );
  @override
  late final GeneratedColumn<int> bytesUploaded = GeneratedColumn<int>(
    'bytes_uploaded',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chatId,
    localPath,
    bytesUploaded,
    totalBytes,
    state,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_media';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingMediaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('bytes_uploaded')) {
      context.handle(
        _bytesUploadedMeta,
        bytesUploaded.isAcceptableOrUnknown(
          data['bytes_uploaded']!,
          _bytesUploadedMeta,
        ),
      );
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingMediaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingMediaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      bytesUploaded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_uploaded'],
      )!,
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingMediaTable createAlias(String alias) {
    return $PendingMediaTable(attachedDatabase, alias);
  }
}

class PendingMediaData extends DataClass
    implements Insertable<PendingMediaData> {
  final String id;
  final String chatId;
  final String localPath;
  final int bytesUploaded;
  final int? totalBytes;
  final String state;
  final DateTime createdAt;
  const PendingMediaData({
    required this.id,
    required this.chatId,
    required this.localPath,
    required this.bytesUploaded,
    this.totalBytes,
    required this.state,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chat_id'] = Variable<String>(chatId);
    map['local_path'] = Variable<String>(localPath);
    map['bytes_uploaded'] = Variable<int>(bytesUploaded);
    if (!nullToAbsent || totalBytes != null) {
      map['total_bytes'] = Variable<int>(totalBytes);
    }
    map['state'] = Variable<String>(state);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingMediaCompanion toCompanion(bool nullToAbsent) {
    return PendingMediaCompanion(
      id: Value(id),
      chatId: Value(chatId),
      localPath: Value(localPath),
      bytesUploaded: Value(bytesUploaded),
      totalBytes: totalBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(totalBytes),
      state: Value(state),
      createdAt: Value(createdAt),
    );
  }

  factory PendingMediaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingMediaData(
      id: serializer.fromJson<String>(json['id']),
      chatId: serializer.fromJson<String>(json['chatId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      bytesUploaded: serializer.fromJson<int>(json['bytesUploaded']),
      totalBytes: serializer.fromJson<int?>(json['totalBytes']),
      state: serializer.fromJson<String>(json['state']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chatId': serializer.toJson<String>(chatId),
      'localPath': serializer.toJson<String>(localPath),
      'bytesUploaded': serializer.toJson<int>(bytesUploaded),
      'totalBytes': serializer.toJson<int?>(totalBytes),
      'state': serializer.toJson<String>(state),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingMediaData copyWith({
    String? id,
    String? chatId,
    String? localPath,
    int? bytesUploaded,
    Value<int?> totalBytes = const Value.absent(),
    String? state,
    DateTime? createdAt,
  }) => PendingMediaData(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    localPath: localPath ?? this.localPath,
    bytesUploaded: bytesUploaded ?? this.bytesUploaded,
    totalBytes: totalBytes.present ? totalBytes.value : this.totalBytes,
    state: state ?? this.state,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingMediaData copyWithCompanion(PendingMediaCompanion data) {
    return PendingMediaData(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      bytesUploaded: data.bytesUploaded.present
          ? data.bytesUploaded.value
          : this.bytesUploaded,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      state: data.state.present ? data.state.value : this.state,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingMediaData(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('localPath: $localPath, ')
          ..write('bytesUploaded: $bytesUploaded, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chatId,
    localPath,
    bytesUploaded,
    totalBytes,
    state,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingMediaData &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.localPath == this.localPath &&
          other.bytesUploaded == this.bytesUploaded &&
          other.totalBytes == this.totalBytes &&
          other.state == this.state &&
          other.createdAt == this.createdAt);
}

class PendingMediaCompanion extends UpdateCompanion<PendingMediaData> {
  final Value<String> id;
  final Value<String> chatId;
  final Value<String> localPath;
  final Value<int> bytesUploaded;
  final Value<int?> totalBytes;
  final Value<String> state;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PendingMediaCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.bytesUploaded = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.state = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingMediaCompanion.insert({
    required String id,
    required String chatId,
    required String localPath,
    this.bytesUploaded = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.state = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       chatId = Value(chatId),
       localPath = Value(localPath),
       createdAt = Value(createdAt);
  static Insertable<PendingMediaData> custom({
    Expression<String>? id,
    Expression<String>? chatId,
    Expression<String>? localPath,
    Expression<int>? bytesUploaded,
    Expression<int>? totalBytes,
    Expression<String>? state,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (localPath != null) 'local_path': localPath,
      if (bytesUploaded != null) 'bytes_uploaded': bytesUploaded,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (state != null) 'state': state,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingMediaCompanion copyWith({
    Value<String>? id,
    Value<String>? chatId,
    Value<String>? localPath,
    Value<int>? bytesUploaded,
    Value<int?>? totalBytes,
    Value<String>? state,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PendingMediaCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      localPath: localPath ?? this.localPath,
      bytesUploaded: bytesUploaded ?? this.bytesUploaded,
      totalBytes: totalBytes ?? this.totalBytes,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (bytesUploaded.present) {
      map['bytes_uploaded'] = Variable<int>(bytesUploaded.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingMediaCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('localPath: $localPath, ')
          ..write('bytesUploaded: $bytesUploaded, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalChatsTable localChats = $LocalChatsTable(this);
  late final $LocalMessagesTable localMessages = $LocalMessagesTable(this);
  late final $ChatMembersTable chatMembers = $ChatMembersTable(this);
  late final $OutboxEntriesTable outboxEntries = $OutboxEntriesTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  late final $PendingMediaTable pendingMedia = $PendingMediaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localChats,
    localMessages,
    chatMembers,
    outboxEntries,
    syncStates,
    pendingMedia,
  ];
}

typedef $$LocalChatsTableCreateCompanionBuilder =
    LocalChatsCompanion Function({
      required String id,
      required String type,
      Value<String?> title,
      Value<String?> lastPreview,
      Value<DateTime?> lastMessageAt,
      Value<int> unreadCount,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalChatsTableUpdateCompanionBuilder =
    LocalChatsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String?> title,
      Value<String?> lastPreview,
      Value<DateTime?> lastMessageAt,
      Value<int> unreadCount,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalChatsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalChatsTable> {
  $$LocalChatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastPreview => $composableBuilder(
    column: $table.lastPreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalChatsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalChatsTable> {
  $$LocalChatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPreview => $composableBuilder(
    column: $table.lastPreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalChatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalChatsTable> {
  $$LocalChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get lastPreview => $composableBuilder(
    column: $table.lastPreview,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalChatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalChatsTable,
          LocalChat,
          $$LocalChatsTableFilterComposer,
          $$LocalChatsTableOrderingComposer,
          $$LocalChatsTableAnnotationComposer,
          $$LocalChatsTableCreateCompanionBuilder,
          $$LocalChatsTableUpdateCompanionBuilder,
          (
            LocalChat,
            BaseReferences<_$AppDatabase, $LocalChatsTable, LocalChat>,
          ),
          LocalChat,
          PrefetchHooks Function()
        > {
  $$LocalChatsTableTableManager(_$AppDatabase db, $LocalChatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> lastPreview = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalChatsCompanion(
                id: id,
                type: type,
                title: title,
                lastPreview: lastPreview,
                lastMessageAt: lastMessageAt,
                unreadCount: unreadCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                Value<String?> title = const Value.absent(),
                Value<String?> lastPreview = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalChatsCompanion.insert(
                id: id,
                type: type,
                title: title,
                lastPreview: lastPreview,
                lastMessageAt: lastMessageAt,
                unreadCount: unreadCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalChatsTable,
      LocalChat,
      $$LocalChatsTableFilterComposer,
      $$LocalChatsTableOrderingComposer,
      $$LocalChatsTableAnnotationComposer,
      $$LocalChatsTableCreateCompanionBuilder,
      $$LocalChatsTableUpdateCompanionBuilder,
      (LocalChat, BaseReferences<_$AppDatabase, $LocalChatsTable, LocalChat>),
      LocalChat,
      PrefetchHooks Function()
    >;
typedef $$LocalMessagesTableCreateCompanionBuilder =
    LocalMessagesCompanion Function({
      required String id,
      required String chatId,
      required String senderId,
      Value<String?> receiverId,
      required String body,
      Value<String> contentType,
      Value<String?> imageUrl,
      Value<String> status,
      Value<int?> serverSeq,
      Value<String?> clientMsgId,
      required DateTime createdAt,
      Value<DateTime?> deletedAt,
      Value<bool> isPendingDelivery,
      Value<int> rowid,
    });
typedef $$LocalMessagesTableUpdateCompanionBuilder =
    LocalMessagesCompanion Function({
      Value<String> id,
      Value<String> chatId,
      Value<String> senderId,
      Value<String?> receiverId,
      Value<String> body,
      Value<String> contentType,
      Value<String?> imageUrl,
      Value<String> status,
      Value<int?> serverSeq,
      Value<String?> clientMsgId,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
      Value<bool> isPendingDelivery,
      Value<int> rowid,
    });

class $$LocalMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiverId => $composableBuilder(
    column: $table.receiverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPendingDelivery => $composableBuilder(
    column: $table.isPendingDelivery,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiverId => $composableBuilder(
    column: $table.receiverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPendingDelivery => $composableBuilder(
    column: $table.isPendingDelivery,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get receiverId => $composableBuilder(
    column: $table.receiverId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isPendingDelivery => $composableBuilder(
    column: $table.isPendingDelivery,
    builder: (column) => column,
  );
}

class $$LocalMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMessagesTable,
          LocalMessage,
          $$LocalMessagesTableFilterComposer,
          $$LocalMessagesTableOrderingComposer,
          $$LocalMessagesTableAnnotationComposer,
          $$LocalMessagesTableCreateCompanionBuilder,
          $$LocalMessagesTableUpdateCompanionBuilder,
          (
            LocalMessage,
            BaseReferences<_$AppDatabase, $LocalMessagesTable, LocalMessage>,
          ),
          LocalMessage,
          PrefetchHooks Function()
        > {
  $$LocalMessagesTableTableManager(_$AppDatabase db, $LocalMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> chatId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String?> receiverId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> clientMsgId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isPendingDelivery = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMessagesCompanion(
                id: id,
                chatId: chatId,
                senderId: senderId,
                receiverId: receiverId,
                body: body,
                contentType: contentType,
                imageUrl: imageUrl,
                status: status,
                serverSeq: serverSeq,
                clientMsgId: clientMsgId,
                createdAt: createdAt,
                deletedAt: deletedAt,
                isPendingDelivery: isPendingDelivery,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String chatId,
                required String senderId,
                Value<String?> receiverId = const Value.absent(),
                required String body,
                Value<String> contentType = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> clientMsgId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isPendingDelivery = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMessagesCompanion.insert(
                id: id,
                chatId: chatId,
                senderId: senderId,
                receiverId: receiverId,
                body: body,
                contentType: contentType,
                imageUrl: imageUrl,
                status: status,
                serverSeq: serverSeq,
                clientMsgId: clientMsgId,
                createdAt: createdAt,
                deletedAt: deletedAt,
                isPendingDelivery: isPendingDelivery,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMessagesTable,
      LocalMessage,
      $$LocalMessagesTableFilterComposer,
      $$LocalMessagesTableOrderingComposer,
      $$LocalMessagesTableAnnotationComposer,
      $$LocalMessagesTableCreateCompanionBuilder,
      $$LocalMessagesTableUpdateCompanionBuilder,
      (
        LocalMessage,
        BaseReferences<_$AppDatabase, $LocalMessagesTable, LocalMessage>,
      ),
      LocalMessage,
      PrefetchHooks Function()
    >;
typedef $$ChatMembersTableCreateCompanionBuilder =
    ChatMembersCompanion Function({
      required String chatId,
      required String userId,
      Value<String> role,
      required DateTime joinedAt,
      Value<int> rowid,
    });
typedef $$ChatMembersTableUpdateCompanionBuilder =
    ChatMembersCompanion Function({
      Value<String> chatId,
      Value<String> userId,
      Value<String> role,
      Value<DateTime> joinedAt,
      Value<int> rowid,
    });

class $$ChatMembersTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMembersTable> {
  $$ChatMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMembersTable> {
  $$ChatMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMembersTable> {
  $$ChatMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);
}

class $$ChatMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMembersTable,
          ChatMember,
          $$ChatMembersTableFilterComposer,
          $$ChatMembersTableOrderingComposer,
          $$ChatMembersTableAnnotationComposer,
          $$ChatMembersTableCreateCompanionBuilder,
          $$ChatMembersTableUpdateCompanionBuilder,
          (
            ChatMember,
            BaseReferences<_$AppDatabase, $ChatMembersTable, ChatMember>,
          ),
          ChatMember,
          PrefetchHooks Function()
        > {
  $$ChatMembersTableTableManager(_$AppDatabase db, $ChatMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chatId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMembersCompanion(
                chatId: chatId,
                userId: userId,
                role: role,
                joinedAt: joinedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chatId,
                required String userId,
                Value<String> role = const Value.absent(),
                required DateTime joinedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChatMembersCompanion.insert(
                chatId: chatId,
                userId: userId,
                role: role,
                joinedAt: joinedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMembersTable,
      ChatMember,
      $$ChatMembersTableFilterComposer,
      $$ChatMembersTableOrderingComposer,
      $$ChatMembersTableAnnotationComposer,
      $$ChatMembersTableCreateCompanionBuilder,
      $$ChatMembersTableUpdateCompanionBuilder,
      (
        ChatMember,
        BaseReferences<_$AppDatabase, $ChatMembersTable, ChatMember>,
      ),
      ChatMember,
      PrefetchHooks Function()
    >;
typedef $$OutboxEntriesTableCreateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> localId,
      required String clientMsgId,
      required String chatId,
      Value<String> operation,
      required String payloadJson,
      Value<int> attemptCount,
      Value<DateTime?> nextRetryAt,
      Value<String> state,
      required DateTime createdAt,
    });
typedef $$OutboxEntriesTableUpdateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> localId,
      Value<String> clientMsgId,
      Value<String> chatId,
      Value<String> operation,
      Value<String> payloadJson,
      Value<int> attemptCount,
      Value<DateTime?> nextRetryAt,
      Value<String> state,
      Value<DateTime> createdAt,
    });

class $$OutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxEntriesTable,
          OutboxEntry,
          $$OutboxEntriesTableFilterComposer,
          $$OutboxEntriesTableOrderingComposer,
          $$OutboxEntriesTableAnnotationComposer,
          $$OutboxEntriesTableCreateCompanionBuilder,
          $$OutboxEntriesTableUpdateCompanionBuilder,
          (
            OutboxEntry,
            BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>,
          ),
          OutboxEntry,
          PrefetchHooks Function()
        > {
  $$OutboxEntriesTableTableManager(_$AppDatabase db, $OutboxEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> clientMsgId = const Value.absent(),
                Value<String> chatId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutboxEntriesCompanion(
                localId: localId,
                clientMsgId: clientMsgId,
                chatId: chatId,
                operation: operation,
                payloadJson: payloadJson,
                attemptCount: attemptCount,
                nextRetryAt: nextRetryAt,
                state: state,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required String clientMsgId,
                required String chatId,
                Value<String> operation = const Value.absent(),
                required String payloadJson,
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String> state = const Value.absent(),
                required DateTime createdAt,
              }) => OutboxEntriesCompanion.insert(
                localId: localId,
                clientMsgId: clientMsgId,
                chatId: chatId,
                operation: operation,
                payloadJson: payloadJson,
                attemptCount: attemptCount,
                nextRetryAt: nextRetryAt,
                state: state,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxEntriesTable,
      OutboxEntry,
      $$OutboxEntriesTableFilterComposer,
      $$OutboxEntriesTableOrderingComposer,
      $$OutboxEntriesTableAnnotationComposer,
      $$OutboxEntriesTableCreateCompanionBuilder,
      $$OutboxEntriesTableUpdateCompanionBuilder,
      (
        OutboxEntry,
        BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>,
      ),
      OutboxEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncStatesTableCreateCompanionBuilder =
    SyncStatesCompanion Function({
      required String scopeKey,
      Value<String?> cursor,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$SyncStatesTableUpdateCompanionBuilder =
    SyncStatesCompanion Function({
      Value<String> scopeKey,
      Value<String?> cursor,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

class $$SyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scopeKey => $composableBuilder(
    column: $table.scopeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scopeKey => $composableBuilder(
    column: $table.scopeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scopeKey =>
      $composableBuilder(column: $table.scopeKey, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$SyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStatesTable,
          SyncState,
          $$SyncStatesTableFilterComposer,
          $$SyncStatesTableOrderingComposer,
          $$SyncStatesTableAnnotationComposer,
          $$SyncStatesTableCreateCompanionBuilder,
          $$SyncStatesTableUpdateCompanionBuilder,
          (
            SyncState,
            BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>,
          ),
          SyncState,
          PrefetchHooks Function()
        > {
  $$SyncStatesTableTableManager(_$AppDatabase db, $SyncStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> scopeKey = const Value.absent(),
                Value<String?> cursor = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion(
                scopeKey: scopeKey,
                cursor: cursor,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scopeKey,
                Value<String?> cursor = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion.insert(
                scopeKey: scopeKey,
                cursor: cursor,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStatesTable,
      SyncState,
      $$SyncStatesTableFilterComposer,
      $$SyncStatesTableOrderingComposer,
      $$SyncStatesTableAnnotationComposer,
      $$SyncStatesTableCreateCompanionBuilder,
      $$SyncStatesTableUpdateCompanionBuilder,
      (SyncState, BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>),
      SyncState,
      PrefetchHooks Function()
    >;
typedef $$PendingMediaTableCreateCompanionBuilder =
    PendingMediaCompanion Function({
      required String id,
      required String chatId,
      required String localPath,
      Value<int> bytesUploaded,
      Value<int?> totalBytes,
      Value<String> state,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PendingMediaTableUpdateCompanionBuilder =
    PendingMediaCompanion Function({
      Value<String> id,
      Value<String> chatId,
      Value<String> localPath,
      Value<int> bytesUploaded,
      Value<int?> totalBytes,
      Value<String> state,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PendingMediaTableFilterComposer
    extends Composer<_$AppDatabase, $PendingMediaTable> {
  $$PendingMediaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesUploaded => $composableBuilder(
    column: $table.bytesUploaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingMediaTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingMediaTable> {
  $$PendingMediaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesUploaded => $composableBuilder(
    column: $table.bytesUploaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingMediaTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingMediaTable> {
  $$PendingMediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get bytesUploaded => $composableBuilder(
    column: $table.bytesUploaded,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingMediaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingMediaTable,
          PendingMediaData,
          $$PendingMediaTableFilterComposer,
          $$PendingMediaTableOrderingComposer,
          $$PendingMediaTableAnnotationComposer,
          $$PendingMediaTableCreateCompanionBuilder,
          $$PendingMediaTableUpdateCompanionBuilder,
          (
            PendingMediaData,
            BaseReferences<_$AppDatabase, $PendingMediaTable, PendingMediaData>,
          ),
          PendingMediaData,
          PrefetchHooks Function()
        > {
  $$PendingMediaTableTableManager(_$AppDatabase db, $PendingMediaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingMediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingMediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingMediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> chatId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<int> bytesUploaded = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingMediaCompanion(
                id: id,
                chatId: chatId,
                localPath: localPath,
                bytesUploaded: bytesUploaded,
                totalBytes: totalBytes,
                state: state,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String chatId,
                required String localPath,
                Value<int> bytesUploaded = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<String> state = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PendingMediaCompanion.insert(
                id: id,
                chatId: chatId,
                localPath: localPath,
                bytesUploaded: bytesUploaded,
                totalBytes: totalBytes,
                state: state,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingMediaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingMediaTable,
      PendingMediaData,
      $$PendingMediaTableFilterComposer,
      $$PendingMediaTableOrderingComposer,
      $$PendingMediaTableAnnotationComposer,
      $$PendingMediaTableCreateCompanionBuilder,
      $$PendingMediaTableUpdateCompanionBuilder,
      (
        PendingMediaData,
        BaseReferences<_$AppDatabase, $PendingMediaTable, PendingMediaData>,
      ),
      PendingMediaData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalChatsTableTableManager get localChats =>
      $$LocalChatsTableTableManager(_db, _db.localChats);
  $$LocalMessagesTableTableManager get localMessages =>
      $$LocalMessagesTableTableManager(_db, _db.localMessages);
  $$ChatMembersTableTableManager get chatMembers =>
      $$ChatMembersTableTableManager(_db, _db.chatMembers);
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
  $$PendingMediaTableTableManager get pendingMedia =>
      $$PendingMediaTableTableManager(_db, _db.pendingMedia);
}
