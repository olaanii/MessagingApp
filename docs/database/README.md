# PostgreSQL Database Schema Documentation

## Overview

This directory contains the complete PostgreSQL database schema for the Production-Ready Privacy-Focused Chat Platform. The schema is designed to support:

- **End-to-End Encryption (E2EE)**: Server stores only ciphertext, never plaintext
- **Multi-Device Support**: Multiple devices per user with independent key pairs
- **Offline-First Architecture**: Idempotency constraints for reliable message delivery
- **High Performance**: Strategic indexes for frequently queried columns
- **Scalability**: Designed for horizontal scaling and partitioning

## Files

- **schema.sql**: Complete SQL schema with tables, indexes, constraints, and triggers
- **erd.md**: Entity Relationship Diagram with Mermaid visualization
- **POSTGRESQL_SETUP.md**: PostgreSQL setup guide (Docker, connection pooling, backups)
- **QUICK_REFERENCE.md**: Common queries and commands
- **README.md**: This file - schema design documentation

## Schema Design Principles

### 1. Privacy-First Design

**Ciphertext Storage**
- The `messages.ciphertext` column stores encrypted message content
- The server never has access to plaintext messages
- Media files in `media_objects` are encrypted before upload (`encrypted` column always true)
- Stories are encrypted in `stories.ciphertext`

**Key Separation**
- Public keys stored in `device_keys` and `one_time_prekeys` tables
- Private keys never transmitted to server (stored in flutter_secure_storage on client)
- Each device has independent key pairs for multi-device E2EE

### 2. Idempotency and Reliability

**Duplicate Prevention**
- `UNIQUE (sender_id, client_msg_id)` constraint on `messages` table
- Prevents duplicate message processing when clients retry
- Supports offline message queuing with guaranteed delivery

**Soft Deletes**
- `messages.deleted_at`: Tombstone for deleted messages
- `devices.revoked_at`: Soft delete for device revocation
- `sessions.revoked_at`: Soft delete for session invalidation
- Enables sync reconciliation and audit trails

### 3. Performance Optimization

**Strategic Indexes (Requirement 22.4)**

High-traffic query patterns:
```sql
-- Chat message history (most common query)
CREATE INDEX idx_messages_chat_seq ON messages(chat_id, server_seq DESC);

-- Recent messages across all chats
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- Idempotency checks on message send
CREATE INDEX idx_messages_client_msg ON messages(sender_id, client_msg_id);

-- User authentication
CREATE INDEX idx_users_firebase_uid ON users(firebase_uid);

-- Contact discovery
CREATE INDEX idx_users_phone_number ON users(phone_number);

-- Active devices only
CREATE INDEX idx_devices_active ON devices(user_id, revoked_at) 
  WHERE revoked_at IS NULL;

-- Available prekeys for session establishment
CREATE INDEX idx_prekeys_device_unused ON one_time_prekeys(device_id) 
  WHERE used_at IS NULL;
```

**Partial Indexes**
- Used for active records only (WHERE revoked_at IS NULL)
- Reduces index size and improves query performance
- Particularly effective for sessions, devices, and prekeys

### 4. Scalability

**Partitioning Opportunities**
- `messages`: Partition by `chat_id` or `created_at` for horizontal scaling
- `stories`: Partition by `created_at` (time-series data with 24h TTL)
- `one_time_prekeys`: Partition by `device_id` for large user bases

**Archival Strategy**
- Messages older than 1 year can be archived to cold storage
- Stories auto-delete after 24 hours (enforced by application logic)
- Expired sessions can be purged periodically

**Read Replicas**
- Read-heavy tables: `users`, `devices`, `chat_members`
- Write-heavy tables: `messages`, `one_time_prekeys`
- Streaming replication for real-time read replicas

## Table Descriptions

### Users and Authentication

#### users
Stores user profile information and authentication metadata.

**Key Columns:**
- `firebase_uid`: Unique Firebase Auth UID (indexed)
- `phone_number`: User's phone number for contact discovery (indexed)
- `presence_status`: Online/away/offline status
- `status_message`: User-defined status text

**Relationships:**
- One user → Many devices
- One user → Many sessions
- One user → Many chat memberships
- One user → Many messages sent

#### devices
Tracks registered devices for multi-device support.

**Key Columns:**
- `device_id`: Unique device identifier (indexed)
- `platform`: android/ios/web
- `public_key_ref`: Reference to public key in device_keys
- `revoked_at`: Soft delete timestamp

**Relationships:**
- Many devices → One user
- One device → One key bundle (device_keys)
- One device → Many one-time prekeys
- One device → Many sessions

#### sessions
Manages authenticated sessions tied to devices.

**Key Columns:**
- `refresh_token_hash`: Hashed refresh token for security
- `expires_at`: Session expiration timestamp (indexed)
- `revoked_at`: Soft delete for logout

**Relationships:**
- Many sessions → One user
- Many sessions → One device

### Chats and Messaging

#### chats
Represents conversations (1:1 or group).

**Key Columns:**
- `type`: 'direct' or 'group'
- `title`: Group name (null for direct chats)
- `created_by`: User who created the chat

**Relationships:**
- One chat → Many members (chat_members)
- One chat → Many messages

#### chat_members
Tracks membership in chats with roles and read state.

**Key Columns:**
- `role`: 'admin' or 'member'
- `last_read_seq`: Last message sequence number read by this user
- `muted_until`: Notification mute expiration

**Composite Primary Key:** (chat_id, user_id)

**Relationships:**
- Many members → One chat
- Many memberships → One user

#### messages
Stores encrypted messages with idempotency constraints.

**Key Columns:**
- `client_msg_id`: Client-generated idempotency key
- `server_seq`: Server-assigned sequence number for ordering (auto-increment)
- `ciphertext`: Encrypted message content (server never sees plaintext)
- `content_type`: text/image/video/audio/file
- `deleted_at`: Tombstone for deleted messages

**Unique Constraint:** (sender_id, client_msg_id) - Prevents duplicates

**Relationships:**
- Many messages → One chat
- Many messages → One sender (user)
- Many messages → One sender device
- Many messages → One media object (optional)

### Media and Files

#### media_objects
Stores metadata for encrypted media files.

**Key Columns:**
- `storage_key`: S3 or storage backend key
- `sha256_hash`: Hash of encrypted file (for deduplication)
- `encrypted`: Always true for E2EE
- `size_bytes`: File size for quota management

**Relationships:**
- Many media objects → One uploader (user)
- One media object → Many messages (referenced by media_id)
- One media object → Many stories (referenced by media_id)

### End-to-End Encryption Keys

#### device_keys
Stores public key material for E2EE session establishment.

**Key Columns:**
- `identity_key`: Ed25519 public identity key
- `signed_prekey`: X25519 signed prekey
- `signed_prekey_signature`: Ed25519 signature of signed prekey

**Relationships:**
- One key bundle → One device (1:1)

#### one_time_prekeys
Stores single-use prekeys for forward secrecy.

**Key Columns:**
- `key_id`: Sequential key identifier per device
- `public_key`: X25519 public key
- `used_at`: NULL if unused, timestamp when consumed

**Unique Constraint:** (device_id, key_id)

**Relationships:**
- Many prekeys → One device

**Usage Pattern:**
1. Client generates 100 prekeys on device registration
2. Server consumes one prekey per session establishment
3. Client replenishes when count < 20

### Push Notifications

#### push_tokens
Stores FCM tokens for push notification delivery.

**Key Columns:**
- `token`: FCM token (unique)
- `platform`: android/ios/web

**Relationships:**
- Many tokens → One device
- Many tokens → One user

### Safety and Moderation

#### blocks
Tracks user blocking relationships.

**Composite Primary Key:** (blocker_id, blocked_id)

**Check Constraint:** blocker_id != blocked_id (cannot block self)

**Relationships:**
- Many blocks → One blocker (user)
- Many blocks → One blocked user

#### reports
Stores abuse reports for moderation.

**Key Columns:**
- `reason`: spam/harassment/inappropriate/other
- `status`: pending/reviewed/resolved
- `context`: Additional details from reporter

**Check Constraint:** Must have either reported_user_id or reported_message_id

**Relationships:**
- Many reports → One reporter (user)
- Many reports → One reported user (optional)
- Many reports → One reported message (optional)

### Stories (Ephemeral Content)

#### stories
Stores ephemeral stories with 24-hour expiration.

**Key Columns:**
- `ciphertext`: Encrypted story content
- `content_type`: photo/video/text
- `expires_at`: 24 hours from creation (indexed for cleanup)

**Relationships:**
- Many stories → One user
- Many stories → One media object
- One story → Many views (story_views)

#### story_views
Tracks who viewed each story.

**Composite Primary Key:** (story_id, viewer_id)

**Relationships:**
- Many views → One story
- Many views → One viewer (user)

## Protocol Model Mapping

The PostgreSQL schema directly implements the protocol models defined in `docs/protocol/v1/models.yaml`:

| Protocol Model | PostgreSQL Table | Notes |
|----------------|------------------|-------|
| User | users | Direct mapping |
| Device | devices | Direct mapping |
| Session | sessions | Direct mapping |
| Chat | chats | Direct mapping |
| ChatMember | chat_members | Direct mapping |
| Message | messages | Direct mapping |
| Media | media_objects | Renamed for clarity |
| KeyBundle | device_keys | Flattened structure |
| OneTimePrekey | one_time_prekeys | Direct mapping |
| PushToken | push_tokens | Direct mapping |
| Block | blocks | Direct mapping |
| Report | reports | Direct mapping |
| Story | stories | Direct mapping |
| StoryView | story_views | Direct mapping |

**Note:** The following protocol models are not stored in the database:
- `StreamEvent`: Real-time event envelope (not persisted)
- `SendMessageRequest`: Request payload (not persisted)
- `MediaUploadRequest`: Request payload (not persisted)
- `PushPreferences`: Stored in `chat_members.muted_until` and client settings
- `SyncCursor`: Stored in client-side Drift database
- `ChangeSet`: Response payload (not persisted)

## Triggers and Automation

### Automatic Timestamp Updates

The schema includes triggers to automatically update `updated_at` columns:

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Applied to: users, chats, messages, device_keys, push_tokens
```

### Future Automation Opportunities

**Story Expiration Cleanup:**
```sql
-- Scheduled job to delete expired stories
DELETE FROM stories WHERE expires_at < NOW();
```

**Session Cleanup:**
```sql
-- Scheduled job to purge expired sessions
DELETE FROM sessions 
WHERE expires_at < NOW() - INTERVAL '30 days' 
  AND revoked_at IS NOT NULL;
```

**Prekey Replenishment Alerts:**
```sql
-- Query to identify devices needing prekey replenishment
SELECT device_id, COUNT(*) as available_prekeys
FROM one_time_prekeys
WHERE used_at IS NULL
GROUP BY device_id
HAVING COUNT(*) < 20;
```

## Migration from Firebase Firestore

### Migration Strategy

The schema supports incremental migration from Firebase Firestore:

**Phase M0: Dual-Read Mode**
- Read from both Firestore and Serverpod
- Write to Firestore only
- Validate data consistency

**Phase M1: Dual-Write Mode**
- Write to both Firestore and Serverpod
- Read from Serverpod (authoritative)
- Backfill historical data

**Phase M2: Serverpod-Only**
- Write to Serverpod only
- Feature flag controls backend selection
- Firestore in read-only mode

**Phase M3: Remove Firestore**
- Delete Firestore messaging code paths
- Archive Firestore data
- Full Serverpod operation

### Data Migration Script

Key migration tasks:

1. **User Migration:**
   - Map Firebase UIDs to PostgreSQL user records
   - Preserve user profiles and phone numbers

2. **Message Migration:**
   - Decrypt Firestore messages (if encrypted differently)
   - Re-encrypt for new E2EE scheme
   - Preserve message ordering with server_seq

3. **Device Registration:**
   - Register existing devices with new device_id format
   - Generate E2EE key pairs for all devices

4. **Chat Migration:**
   - Map Firestore chat documents to chats table
   - Preserve chat members and roles

## Performance Benchmarks

### Target Performance (Requirement 22.4)

- **Message Insertion:** < 10ms per message
- **Chat History Query:** < 50ms for 50 messages
- **User Authentication:** < 20ms for Firebase UID lookup
- **Prekey Fetch:** < 30ms for key bundle retrieval
- **Concurrent Connections:** 10,000+ simultaneous users

### Query Optimization Examples

**Efficient Chat History Query:**
```sql
-- Uses idx_messages_chat_seq index
SELECT * FROM messages
WHERE chat_id = $1 AND deleted_at IS NULL
ORDER BY server_seq DESC
LIMIT 50;
```

**Efficient Idempotency Check:**
```sql
-- Uses idx_messages_client_msg index
SELECT id FROM messages
WHERE sender_id = $1 AND client_msg_id = $2;
```

**Efficient Active Device Lookup:**
```sql
-- Uses idx_devices_active partial index
SELECT * FROM devices
WHERE user_id = $1 AND revoked_at IS NULL;
```

## Security Considerations

### SQL Injection Prevention
- Use parameterized queries in Serverpod endpoints
- Never concatenate user input into SQL strings
- Serverpod ORM provides automatic protection

### Data Encryption at Rest
- Enable PostgreSQL transparent data encryption (TDE)
- Encrypt database backups
- Use encrypted EBS volumes on AWS

### Access Control
- Serverpod application user has limited permissions
- No direct database access for clients
- Row-level security (RLS) for multi-tenancy (future)

### Audit Logging
- Enable PostgreSQL audit logging for compliance
- Log all DDL changes
- Monitor for suspicious query patterns

## Maintenance and Operations

For detailed setup instructions, see [POSTGRESQL_SETUP.md](./POSTGRESQL_SETUP.md).

### Backup Strategy
- Daily full backups with point-in-time recovery (PITR)
- Backup retention: 30 days
- Test restore procedures monthly
- See [Backup Setup](./POSTGRESQL_SETUP.md#backup-setup) for scripts and procedures

### Monitoring
- Query performance monitoring (pg_stat_statements)
- Index usage monitoring (pg_stat_user_indexes)
- Connection pool monitoring
- Disk space alerts
- See [Troubleshooting](./POSTGRESQL_SETUP.md#troubleshooting) for health check scripts

### Vacuum and Analyze
- Autovacuum enabled for all tables
- Manual VACUUM ANALYZE after bulk operations
- Monitor table bloat

### Index Maintenance
- Rebuild indexes quarterly or after major data changes
- Monitor index bloat with pg_stat_user_indexes
- Consider REINDEX CONCURRENTLY for production

## Requirements Traceability

This schema fulfills the following requirements:

- **Requirement 2.2:** PostgreSQL for persistent storage of ciphertext, user profiles, device registrations, and sync state
- **Requirement 22.4:** Indexes on frequently queried columns (chat_id, server_seq DESC), (user_id), (firebase_uid)
- **Idempotency Constraints:** (sender_id, client_msg_id) prevents duplicate message processing
- **E2EE Support:** Ciphertext-only storage, public key management, forward secrecy
- **Multi-Device Support:** Device registry, per-device keys, session management
- **Safety Features:** Blocks, reports, moderation support
- **Stories:** Ephemeral content with 24-hour expiration

## Future Enhancements

### Planned Features
- **Read Receipts Table:** Track per-user read status for messages
- **Typing Indicators:** Ephemeral state (Redis, not PostgreSQL)
- **Call History:** Store call metadata (duration, participants)
- **Message Reactions:** Emoji reactions to messages
- **Message Edits:** Track edit history with timestamps

### Scalability Enhancements
- **Sharding:** Partition messages by chat_id hash
- **Time-Series Optimization:** Use TimescaleDB for messages table
- **Caching Layer:** Redis for hot data (online users, typing indicators)
- **Read Replicas:** Geographic distribution for global users

## References

- Protocol Models: `docs/protocol/v1/models.yaml`
- Design Document: `.kiro/specs/production-ready-privacy-chat/design.md`
- Requirements: `.kiro/specs/production-ready-privacy-chat/requirements.md`
- ADR-0001: `docs/adr/0001-serverpod-protocol-v1.md`
