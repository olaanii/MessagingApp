# PostgreSQL Schema Quick Reference

## Table Summary

| Table | Purpose | Key Indexes | Relationships |
|-------|---------|-------------|---------------|
| **users** | User profiles | firebase_uid, phone_number | → devices, sessions, messages |
| **devices** | Multi-device support | user_id, device_id, active | → device_keys, prekeys, sessions |
| **sessions** | Auth sessions | user_device, expires, token_hash | ← users, devices |
| **chats** | Conversations | type, updated_at | → chat_members, messages |
| **chat_members** | Chat membership | user_id, chat_id | ← chats, users |
| **messages** | Encrypted messages | chat_seq, created_at, client_msg | ← chats, users, devices |
| **media_objects** | File metadata | uploader, sha256, created_at | ← users |
| **device_keys** | Public keys | device_id (PK) | ← devices |
| **one_time_prekeys** | Forward secrecy | device_unused | ← devices |
| **push_tokens** | FCM tokens | device, user, token | ← devices, users |
| **blocks** | User blocking | blocker, blocked | ← users |
| **reports** | Abuse reports | status, reported_user, created_at | ← users, messages |
| **stories** | Ephemeral content | user, expires, created_at | ← users, media_objects |
| **story_views** | View tracking | story, viewer | ← stories, users |

## Critical Indexes (Performance)

### Messages (Most Queried)
```sql
idx_messages_chat_seq       -- (chat_id, server_seq DESC)
idx_messages_created_at     -- (created_at DESC)
idx_messages_client_msg     -- (sender_id, client_msg_id)
```

### Users (Authentication)
```sql
idx_users_firebase_uid      -- (firebase_uid)
idx_users_phone_number      -- (phone_number)
```

### Devices (Multi-Device)
```sql
idx_devices_active          -- (user_id, revoked_at) WHERE revoked_at IS NULL
idx_devices_device_id       -- (device_id)
```

### Prekeys (E2EE)
```sql
idx_prekeys_device_unused   -- (device_id) WHERE used_at IS NULL
```

## Common Queries

### Get Chat History
```sql
SELECT * FROM messages
WHERE chat_id = $1 AND deleted_at IS NULL
ORDER BY server_seq DESC
LIMIT 50;
```

### Check Message Idempotency
```sql
SELECT id FROM messages
WHERE sender_id = $1 AND client_msg_id = $2;
```

### Get User's Active Devices
```sql
SELECT * FROM devices
WHERE user_id = $1 AND revoked_at IS NULL;
```

### Get Available Prekeys
```sql
SELECT * FROM one_time_prekeys
WHERE device_id = $1 AND used_at IS NULL
LIMIT 1;
```

### Get User's Chats
```sql
SELECT c.* FROM chats c
JOIN chat_members cm ON c.id = cm.chat_id
WHERE cm.user_id = $1
ORDER BY c.updated_at DESC;
```

### Get Unread Message Count
```sql
SELECT COUNT(*) FROM messages m
JOIN chat_members cm ON m.chat_id = cm.chat_id
WHERE cm.user_id = $1 
  AND m.server_seq > cm.last_read_seq
  AND m.deleted_at IS NULL;
```

### Get Expired Stories
```sql
SELECT * FROM stories
WHERE expires_at < NOW();
```

### Check if User is Blocked
```sql
SELECT 1 FROM blocks
WHERE blocker_id = $1 AND blocked_id = $2;
```

## Unique Constraints

| Table | Constraint | Purpose |
|-------|-----------|---------|
| users | firebase_uid | One user per Firebase account |
| devices | device_id | Unique device identifiers |
| messages | (sender_id, client_msg_id) | Idempotency - prevent duplicates |
| push_tokens | token | Unique FCM tokens |
| one_time_prekeys | (device_id, key_id) | Unique prekey IDs per device |
| chat_members | (chat_id, user_id) | One membership per user per chat |
| blocks | (blocker_id, blocked_id) | One block per user pair |
| story_views | (story_id, viewer_id) | One view per user per story |

## Check Constraints

| Table | Column | Valid Values |
|-------|--------|--------------|
| users | presence_status | 'online', 'away', 'offline' |
| devices | platform | 'android', 'ios', 'web' |
| chats | type | 'direct', 'group' |
| chat_members | role | 'admin', 'member' |
| messages | content_type | 'text', 'image', 'video', 'audio', 'file' |
| push_tokens | platform | 'android', 'ios', 'web' |
| reports | reason | 'spam', 'harassment', 'inappropriate', 'other' |
| reports | status | 'pending', 'reviewed', 'resolved' |
| stories | content_type | 'photo', 'video', 'text' |

## Soft Delete Columns

| Table | Column | Purpose |
|-------|--------|---------|
| messages | deleted_at | Tombstone for deleted messages |
| devices | revoked_at | Soft delete for device revocation |
| sessions | revoked_at | Soft delete for session invalidation |

## Auto-Updated Columns

Tables with automatic `updated_at` triggers:
- users
- chats
- messages
- device_keys
- push_tokens

## Foreign Key Cascade Rules

### ON DELETE CASCADE
- devices → users (delete devices when user deleted)
- sessions → users, devices (delete sessions when user/device deleted)
- chat_members → chats, users (delete memberships when chat/user deleted)
- messages → chats (delete messages when chat deleted)
- one_time_prekeys → devices (delete prekeys when device deleted)
- push_tokens → devices, users (delete tokens when device/user deleted)
- blocks → users (delete blocks when user deleted)
- stories → users (delete stories when user deleted)
- story_views → stories, users (delete views when story/user deleted)

### NO CASCADE (Preserve Data)
- messages → users (sender_id) - preserve messages even if sender deleted
- messages → devices (sender_device_id) - preserve messages even if device deleted
- media_objects → users (uploader_id) - preserve media even if uploader deleted

## Data Types

### UUIDs
- All primary keys use UUID (gen_random_uuid())
- Provides global uniqueness for distributed systems

### Timestamps
- All timestamps use TIMESTAMP (without timezone)
- Store in UTC, convert in application layer

### Text vs VARCHAR
- TEXT: Unlimited length (ciphertext, storage_key, context)
- VARCHAR: Limited length with validation (firebase_uid, platform, status)

## Maintenance Queries

### Find Tables Needing Vacuum
```sql
SELECT schemaname, tablename, 
       n_dead_tup, n_live_tup,
       ROUND(n_dead_tup * 100.0 / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_pct
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY dead_pct DESC;
```

### Check Index Usage
```sql
SELECT schemaname, tablename, indexname, 
       idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;
```

### Find Slow Queries
```sql
SELECT query, calls, total_time, mean_time, max_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 20;
```

### Check Table Sizes
```sql
SELECT tablename,
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

## Security Best Practices

1. **Never store plaintext messages** - Always use ciphertext column
2. **Hash sensitive data** - refresh_token_hash, not plaintext tokens
3. **Use parameterized queries** - Prevent SQL injection
4. **Limit permissions** - Application user should have minimal privileges
5. **Enable SSL/TLS** - Encrypt connections to database
6. **Audit logging** - Track all DDL and sensitive operations
7. **Regular backups** - Daily full backups with PITR
8. **Monitor access** - Alert on unusual query patterns

## Performance Tips

1. **Use EXPLAIN ANALYZE** - Understand query execution plans
2. **Batch inserts** - Use COPY or multi-row INSERT for bulk data
3. **Connection pooling** - Reuse database connections (PgBouncer)
4. **Partial indexes** - Index only active records (WHERE revoked_at IS NULL)
5. **Covering indexes** - Include frequently selected columns in index
6. **Avoid SELECT *** - Select only needed columns
7. **Use LIMIT** - Paginate large result sets
8. **Monitor slow queries** - Use pg_stat_statements extension

## Troubleshooting

### Message Not Appearing
1. Check if message exists: `SELECT * FROM messages WHERE id = $1`
2. Check if deleted: `SELECT deleted_at FROM messages WHERE id = $1`
3. Check chat membership: `SELECT * FROM chat_members WHERE chat_id = $1 AND user_id = $2`
4. Check if sender blocked: `SELECT * FROM blocks WHERE blocker_id = $1 AND blocked_id = $2`

### Prekey Exhaustion
1. Check available prekeys: `SELECT COUNT(*) FROM one_time_prekeys WHERE device_id = $1 AND used_at IS NULL`
2. Replenish if count < 20
3. Monitor prekey consumption rate

### Session Expired
1. Check session status: `SELECT expires_at, revoked_at FROM sessions WHERE id = $1`
2. Use refresh token to get new session
3. Clean up expired sessions periodically

### Slow Queries
1. Run EXPLAIN ANALYZE on slow query
2. Check if indexes are being used
3. Consider adding covering index
4. Check table statistics are up to date (ANALYZE)

## Quick Setup

For detailed setup instructions including Docker, connection pooling, and backups, see [POSTGRESQL_SETUP.md](./POSTGRESQL_SETUP.md).

### Create Database
```bash
createdb privacy_chat
psql privacy_chat < docs/database/schema.sql
```

### Enable Extensions
```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
```

### Grant Permissions
```sql
CREATE USER serverpod_app WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE privacy_chat TO serverpod_app;
GRANT USAGE ON SCHEMA public TO serverpod_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO serverpod_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO serverpod_app;
```

## References

- Full Schema: `docs/database/schema.sql`
- ERD Diagram: `docs/database/erd.md`
- Setup Guide: `docs/database/POSTGRESQL_SETUP.md`
- Detailed Documentation: `docs/database/README.md`
- Protocol Models: `docs/protocol/v1/models.yaml`
