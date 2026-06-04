# Serverpod Migrations Guide

## Overview

This document provides comprehensive guidance on creating, managing, and applying Serverpod database migrations for the production-ready privacy-focused chat platform. Serverpod uses a protocol-first approach where YAML model definitions drive database schema generation.

**Related Requirements:** 2.2 (Decentralized Architecture), 2.10 (Database Schema Management)

## Table of Contents

1. [Migration Strategy](#migration-strategy)
2. [Protocol YAML to Database Schema](#protocol-yaml-to-database-schema)
3. [Creating Migrations](#creating-migrations)
4. [Migration File Structure](#migration-file-structure)
5. [Applying Migrations](#applying-migrations)
6. [Schema Verification](#schema-verification)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

---

## Migration Strategy

### Protocol-First Approach

Serverpod follows a **protocol-first** development model:

```
Protocol YAML → Serverpod Generator → Database Migration → PostgreSQL Schema
```

**Workflow:**

1. Define or update models in `docs/protocol/v1/models.yaml`
2. Run Serverpod code generator to create Dart classes
3. Generate migration files from protocol changes
4. Review and apply migrations to database
5. Verify schema matches expectations

### Migration Phases

The chat platform uses incremental migration phases:

- **Phase M0**: Initial Serverpod setup with auth tables
- **Phase M1**: Core chat tables (users, devices, sessions, chats, messages)
- **Phase M2**: E2EE key management tables (device_keys, one_time_prekeys)
- **Phase M3**: Media and safety tables (media_objects, blocks, reports, stories)
- **Phase M4**: Performance optimization (indexes, triggers, functions)

---

## Protocol YAML to Database Schema

### YAML Model Definition

Protocol models are defined in `docs/protocol/v1/models.yaml`:

```yaml
# User Model Example
class: User
fields:
  id: String
  firebaseUid: String
  displayName: String
  photoUrl: String?
  phoneNumber: String
  statusMessage: String?
  presenceStatus: String
  createdAt: DateTime
  updatedAt: DateTime
```

### Generated Database Schema

Serverpod translates YAML models to PostgreSQL tables:

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_uid VARCHAR(128) UNIQUE NOT NULL,
  display_name VARCHAR(255) NOT NULL,
  photo_url TEXT,
  phone_number VARCHAR(20) NOT NULL,
  status_message TEXT,
  presence_status VARCHAR(20) DEFAULT 'offline',
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

### Type Mapping

| YAML Type | PostgreSQL Type | Notes |
|-----------|----------------|-------|
| `String` | `TEXT` or `VARCHAR` | Use VARCHAR for indexed fields |
| `int` | `BIGINT` | 64-bit integer |
| `double` | `DOUBLE PRECISION` | Floating point |
| `bool` | `BOOLEAN` | True/false |
| `DateTime` | `TIMESTAMP WITHOUT TIME ZONE` | UTC timestamps |
| `String?` | `TEXT NULL` | Nullable field |
| `List<T>` | `JSON` or separate table | Depends on relationship |
| `Map<String, dynamic>` | `JSON` | Unstructured data |

### Naming Conventions

- **YAML**: camelCase (e.g., `firebaseUid`, `displayName`)
- **SQL**: snake_case (e.g., `firebase_uid`, `display_name`)
- **Dart**: camelCase (e.g., `firebaseUid`, `displayName`)

Serverpod automatically handles case conversion between layers.

---

## Creating Migrations

### Step 1: Update Protocol YAML

Edit `docs/protocol/v1/models.yaml` to add or modify models:

```yaml
# New Device Model
class: Device
fields:
  id: String
  userId: String
  deviceId: String
  name: String
  platform: String
  publicKeyRef: String
  lastSeenAt: DateTime
  createdAt: DateTime
  revokedAt: DateTime?
```

### Step 2: Generate Serverpod Code

Navigate to the server directory and run the generator:

```bash
cd chat/chat_server
dart run serverpod_cli generate
```

This command:
- Parses `protocol/*.yaml` files
- Generates Dart model classes in `lib/src/generated/`
- Updates client library in `chat_client/lib/src/protocol/`
- Prepares migration metadata

### Step 3: Create Migration

Generate a new migration from protocol changes:

```bash
cd chat/chat_server
dart run serverpod_cli create-migration
```

**Output:**
```
Creating migration...
Migration created: 20260327161831530
Migration files:
  - migrations/20260327161831530/migration.json
  - migrations/20260327161831530/definition.sql
  - migrations/20260327161831530/definition_project.json
```

The migration timestamp (e.g., `20260327161831530`) is automatically generated.

### Step 4: Review Migration Files

**Always review generated migrations before applying!**

Check `migrations/<timestamp>/definition.sql` for:
- Correct table names and column types
- Proper indexes on foreign keys and frequently queried columns
- Appropriate constraints (NOT NULL, UNIQUE, CHECK)
- Foreign key relationships with correct ON DELETE behavior

---

## Migration File Structure

Each migration consists of three files in `chat/chat_server/migrations/<timestamp>/`:

### 1. `migration.json`

Contains structured migration metadata in JSON format:

```json
{
  "__className__": "serverpod.DatabaseMigration",
  "actions": [
    {
      "__className__": "serverpod.DatabaseMigrationAction",
      "type": "createTable",
      "createTable": {
        "__className__": "serverpod.TableDefinition",
        "name": "users",
        "dartName": "User",
        "module": "chat",
        "schema": "public",
        "columns": [
          {
            "__className__": "serverpod.ColumnDefinition",
            "name": "id",
            "columnType": 0,
            "isNullable": false,
            "dartType": "String"
          }
        ],
        "foreignKeys": [],
        "indexes": []
      }
    }
  ]
}
```

**Purpose:** Machine-readable migration definition for Serverpod tooling.

### 2. `definition.sql`

Contains the actual SQL DDL statements:

```sql
BEGIN;

-- Create users table
CREATE TABLE "users" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "firebase_uid" text UNIQUE NOT NULL,
    "display_name" text NOT NULL,
    "photo_url" text,
    "phone_number" text NOT NULL,
    "status_message" text,
    "presence_status" text DEFAULT 'offline',
    "created_at" timestamp without time zone NOT NULL DEFAULT NOW(),
    "updated_at" timestamp without time zone NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX "idx_users_firebase_uid" ON "users" USING btree ("firebase_uid");
CREATE INDEX "idx_users_phone_number" ON "users" USING btree ("phone_number");

-- Update migration version
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('chat', '20260327161831530', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260327161831530', "timestamp" = now();

COMMIT;
```

**Purpose:** Human-readable SQL that can be reviewed and executed directly.

### 3. `definition_project.json`

Contains project-specific metadata (generated automatically).

### Migration Registry

The file `migrations/migration_registry.txt` tracks all migrations:

```
### AUTOMATICALLY GENERATED DO NOT MODIFY
###
### This file is generated by Serverpod when creating a migration, do not modify it
### manually. If a collision is detected in this file when doing a code merge, resolve
### the conflict by removing and recreating the conflicting migration.

20260327114657105
20260327161831530
```

**Important:** Do not manually edit this file. Serverpod uses it to track migration order.

---

## Applying Migrations

### Development Environment

#### Option 1: Using Serverpod CLI (Recommended)

```bash
cd chat/chat_server
dart run serverpod_cli create-migration --apply
```

This command:
1. Generates the migration
2. Immediately applies it to the configured database
3. Updates the `serverpod_migrations` table

#### Option 2: Manual Application

```bash
# Generate migration first
dart run serverpod_cli create-migration

# Apply manually using psql
psql -h localhost -U postgres -d chat_dev -f migrations/<timestamp>/definition.sql
```

### Staging/Production Environment

**Never use `--apply` in production!** Follow this process:

#### Step 1: Export Migration SQL

```bash
cd chat/chat_server
cp migrations/<timestamp>/definition.sql ~/migration_<timestamp>.sql
```

#### Step 2: Review Migration

- Conduct peer review of SQL changes
- Test migration on a staging database copy
- Verify rollback procedures
- Check for blocking operations (e.g., adding NOT NULL columns)

#### Step 3: Apply with Backup

```bash
# Backup database
pg_dump -h <prod-host> -U <user> -d chat_prod > backup_pre_migration_$(date +%Y%m%d_%H%M%S).sql

# Apply migration in a transaction
psql -h <prod-host> -U <user> -d chat_prod -f migration_<timestamp>.sql

# Verify migration
psql -h <prod-host> -U <user> -d chat_prod -c "SELECT * FROM serverpod_migrations WHERE module = 'chat';"
```

#### Step 4: Verify Schema

Run schema verification queries (see [Schema Verification](#schema-verification) section).

### Rollback Procedure

Serverpod does not generate automatic rollback scripts. For critical migrations:

1. **Create manual rollback SQL** before applying:
   ```sql
   -- Rollback for migration 20260327161831530
   BEGIN;
   
   DROP TABLE IF EXISTS users CASCADE;
   
   DELETE FROM serverpod_migrations 
   WHERE module = 'chat' AND version = '20260327161831530';
   
   COMMIT;
   ```

2. **Test rollback** on staging before production deployment

3. **Document rollback steps** in migration commit message

---

## Schema Verification

### Automated Verification Script

Create `scripts/verify_schema.sql`:

```sql
-- Verify all expected tables exist
SELECT 
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_name IN (
        'users', 'devices', 'sessions', 'chats', 'chat_members',
        'messages', 'media_objects', 'device_keys', 'one_time_prekeys',
        'push_tokens', 'blocks', 'reports', 'stories', 'story_views'
    )
ORDER BY table_name;

-- Verify indexes on critical tables
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
    AND tablename IN ('messages', 'chats', 'users', 'devices')
ORDER BY tablename, indexname;

-- Verify foreign key constraints
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name, tc.constraint_name;

-- Check migration version
SELECT module, version, timestamp
FROM serverpod_migrations
WHERE module = 'chat'
ORDER BY timestamp DESC
LIMIT 1;
```

Run verification:

```bash
psql -h localhost -U postgres -d chat_dev -f scripts/verify_schema.sql
```

### Manual Verification Checklist

After applying a migration, verify:

- [ ] All expected tables exist
- [ ] Column types match protocol definitions
- [ ] Indexes exist on foreign keys and frequently queried columns
- [ ] Foreign key constraints are properly defined
- [ ] NOT NULL constraints are correct
- [ ] Default values are set appropriately
- [ ] Triggers and functions are created (if applicable)
- [ ] Migration version is recorded in `serverpod_migrations` table

### Compare Schema with Expected

Use `pg_dump` to export schema and compare with `docs/database/schema.sql`:

```bash
# Export current schema
pg_dump -h localhost -U postgres -d chat_dev --schema-only > current_schema.sql

# Compare with expected schema
diff docs/database/schema.sql current_schema.sql
```

---

## Best Practices

### 1. Protocol Design

- **Use explicit types**: Avoid `dynamic` or `Object` in protocol definitions
- **Document fields**: Add comments in YAML for complex fields
- **Version protocols**: Use `docs/protocol/v1/`, `v2/`, etc. for breaking changes
- **Nullable fields**: Use `?` suffix for optional fields (e.g., `photoUrl: String?`)

### 2. Migration Safety

- **Small migrations**: Create focused migrations for single features
- **Test locally**: Always test migrations on local database first
- **Backup before apply**: Take database backups before production migrations
- **Avoid data loss**: Use `ALTER TABLE` carefully; prefer additive changes
- **Index strategy**: Add indexes in separate migrations for large tables

### 3. Performance Considerations

- **Index foreign keys**: Always index columns used in JOIN operations
- **Partial indexes**: Use `WHERE` clauses for conditional indexes
  ```sql
  CREATE INDEX idx_sessions_active 
  ON sessions(user_id, device_id) 
  WHERE revoked_at IS NULL;
  ```
- **Avoid blocking operations**: Use `CONCURRENTLY` for index creation on large tables
  ```sql
  CREATE INDEX CONCURRENTLY idx_messages_chat_seq 
  ON messages(chat_id, server_seq DESC);
  ```

### 4. Data Integrity

- **Foreign key constraints**: Always define relationships with proper ON DELETE behavior
  ```sql
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
  ```
- **Check constraints**: Validate enum-like fields
  ```sql
  CHECK (presence_status IN ('online', 'away', 'offline'))
  ```
- **Unique constraints**: Prevent duplicate data
  ```sql
  UNIQUE (sender_id, client_msg_id)  -- Idempotency
  ```

### 5. Naming Conventions

- **Tables**: Plural nouns (e.g., `users`, `messages`, `devices`)
- **Columns**: snake_case (e.g., `firebase_uid`, `created_at`)
- **Indexes**: `idx_<table>_<columns>` (e.g., `idx_users_firebase_uid`)
- **Foreign keys**: `<table>_fk_<n>` (auto-generated by Serverpod)
- **Constraints**: `<table>_<column>_<type>` (e.g., `users_email_unique`)

### 6. Documentation

- **Comment migrations**: Add comments to complex SQL in `definition.sql`
- **Update schema docs**: Keep `docs/database/schema.sql` in sync
- **Document breaking changes**: Note incompatible changes in commit messages
- **Maintain ERD**: Update `docs/database/erd.md` when relationships change

---

## Troubleshooting

### Issue: Migration Fails with "relation already exists"

**Cause:** Migration was partially applied or database is out of sync.

**Solution:**
```sql
-- Check existing tables
\dt

-- Drop conflicting table (CAUTION: data loss)
DROP TABLE IF EXISTS <table_name> CASCADE;

-- Reapply migration
\i migrations/<timestamp>/definition.sql
```

### Issue: "column does not exist" after migration

**Cause:** Dart code was regenerated but migration wasn't applied.

**Solution:**
```bash
# Apply pending migrations
cd chat/chat_server
dart run serverpod_cli create-migration --apply
```

### Issue: Foreign key constraint violation

**Cause:** Attempting to create foreign key to non-existent table or data.

**Solution:**
1. Ensure referenced table exists before creating foreign key
2. Check migration order in `migration_registry.txt`
3. Manually reorder migrations if needed (advanced)

### Issue: Migration version conflict

**Cause:** Multiple developers created migrations simultaneously.

**Solution:**
```bash
# Remove conflicting migration
rm -rf chat/chat_server/migrations/<timestamp>

# Recreate migration after pulling latest
git pull
cd chat/chat_server
dart run serverpod_cli create-migration
```

### Issue: Performance degradation after migration

**Cause:** Missing indexes or inefficient schema design.

**Solution:**
1. Run `EXPLAIN ANALYZE` on slow queries
2. Add indexes for frequently queried columns
3. Consider partial indexes for filtered queries
4. Use `VACUUM ANALYZE` to update statistics

### Issue: Cannot connect to database during migration

**Cause:** Database connection settings incorrect.

**Solution:**
Check `chat/chat_server/config/development.yaml`:
```yaml
database:
  host: localhost
  port: 5432
  name: chat_dev
  user: postgres
  password: your_password
```

---

## Migration Examples

### Example 1: Adding a New Table

**Protocol YAML:**
```yaml
class: PushToken
fields:
  id: String
  deviceId: String
  userId: String
  token: String
  platform: String
  createdAt: DateTime
  updatedAt: DateTime
```

**Generated SQL:**
```sql
CREATE TABLE "push_tokens" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "device_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "token" text NOT NULL UNIQUE,
    "platform" text NOT NULL,
    "created_at" timestamp without time zone NOT NULL DEFAULT NOW(),
    "updated_at" timestamp without time zone NOT NULL DEFAULT NOW()
);

CREATE INDEX "idx_push_tokens_device" ON "push_tokens" ("device_id");
CREATE INDEX "idx_push_tokens_user" ON "push_tokens" ("user_id");

ALTER TABLE "push_tokens"
    ADD CONSTRAINT "push_tokens_fk_0"
    FOREIGN KEY("device_id")
    REFERENCES "devices"("id")
    ON DELETE CASCADE;

ALTER TABLE "push_tokens"
    ADD CONSTRAINT "push_tokens_fk_1"
    FOREIGN KEY("user_id")
    REFERENCES "users"("id")
    ON DELETE CASCADE;
```

### Example 2: Adding a Column

**Protocol YAML Change:**
```yaml
class: User
fields:
  id: String
  firebaseUid: String
  displayName: String
  photoUrl: String?
  phoneNumber: String
  statusMessage: String?
  presenceStatus: String
  lastSeenAt: DateTime?  # NEW FIELD
  createdAt: DateTime
  updatedAt: DateTime
```

**Generated SQL:**
```sql
ALTER TABLE "users"
    ADD COLUMN "last_seen_at" timestamp without time zone;

CREATE INDEX "idx_users_last_seen" ON "users" ("last_seen_at");
```

### Example 3: Adding an Index

**Manual SQL (add to migration):**
```sql
-- Optimize message queries by chat and sequence
CREATE INDEX CONCURRENTLY "idx_messages_chat_seq" 
ON "messages" ("chat_id", "server_seq" DESC);

-- Optimize unread message counts
CREATE INDEX "idx_chat_members_unread" 
ON "chat_members" ("user_id", "last_read_seq");
```

---

## Additional Resources

- **Serverpod Documentation**: https://docs.serverpod.dev/
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/
- **Project Schema Reference**: `docs/database/schema.sql`
- **Protocol Definitions**: `docs/protocol/v1/models.yaml`
- **ERD Diagram**: `docs/database/erd.md`

---

## Summary

Serverpod migrations follow a protocol-first approach where YAML model definitions drive database schema generation. Key steps:

1. Define models in `docs/protocol/v1/models.yaml`
2. Run `dart run serverpod_cli generate` to create Dart classes
3. Run `dart run serverpod_cli create-migration` to generate migration files
4. Review `definition.sql` for correctness
5. Apply migration with `--apply` flag or manually via `psql`
6. Verify schema matches expectations

Always test migrations locally, backup production databases, and follow incremental migration practices for safe schema evolution.
