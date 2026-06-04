# PostgreSQL Setup Guide

Complete guide for PostgreSQL database setup including Docker, connection pooling, and backups.

## Quick Start (Docker)

### Start Development Database

```bash
cd chat/chat_server
docker-compose up -d postgres
```

**Configuration:**
- Port: `8090` → PostgreSQL 5432
- Database: `chat`
- User: `postgres`
- Password: `WWBkrcYZjA5qD2UKo0m_CbQb6fhdIoln`

### Start Test Database

```bash
docker-compose up -d postgres_test
```

**Configuration:**
- Port: `9090`
- Database: `chat_test`
- Password: `d4x_A-1trBbq0lE8zfS00fe4bEtxP0T2`

### Connect to Database

```bash
# Via Docker
docker exec -it chat_server-postgres-1 psql -U postgres -d chat

# Via psql client
psql -h localhost -p 8090 -U postgres -d chat
```

### Apply Schema

```bash
# From project root
psql -h localhost -p 8090 -U postgres -d chat -f docs/database/schema.sql

# Or use Serverpod migrations
cd chat/chat_server
dart bin/main.dart --apply-migrations
```

## Database and User Creation

### Development Setup

```sql
-- Create additional database
CREATE DATABASE chat_staging;

-- Create application user
CREATE USER chat_app WITH PASSWORD 'your_secure_password';

-- Grant privileges
GRANT CONNECT ON DATABASE chat TO chat_app;
GRANT USAGE ON SCHEMA public TO chat_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO chat_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO chat_app;

-- Grant on future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO chat_app;
```

### Production Setup

```sql
-- Create production user
CREATE USER chat_prod WITH PASSWORD 'strong_random_password';
CREATE DATABASE chat_production OWNER chat_prod;

\c chat_production

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
GRANT ALL PRIVILEGES ON SCHEMA public TO chat_prod;
```

## Connection Pooling

### Serverpod Built-in Pooling

Configure in `config/development.yaml` or `config/production.yaml`:

```yaml
database:
  host: localhost
  port: 8090
  name: chat
  user: postgres
  requireSsl: false
  maxConnectionCount: 10  # Adjust based on load
```

**Recommended Settings:**

| Environment | maxConnectionCount |
|-------------|-------------------|
| Development | 5-10 |
| Staging | 20-30 |
| Production | 50-100 |

### PgBouncer (Production)

For multiple Serverpod instances, use PgBouncer:

```yaml
# docker-compose.yml
services:
  pgbouncer:
    image: pgbouncer/pgbouncer:latest
    ports:
      - "6432:6432"
    environment:
      DATABASES_HOST: postgres
      DATABASES_PORT: 5432
      DATABASES_USER: postgres
      DATABASES_PASSWORD: ${DB_PASSWORD}
      DATABASES_DBNAME: chat
      PGBOUNCER_POOL_MODE: transaction
      PGBOUNCER_MAX_CLIENT_CONN: 1000
      PGBOUNCER_DEFAULT_POOL_SIZE: 25
```

Update Serverpod config:

```yaml
database:
  host: pgbouncer
  port: 6432
  maxConnectionCount: 25
```

### Monitor Connections

```sql
-- Active connections
SELECT datname, count(*) as connections
FROM pg_stat_activity
WHERE datname = 'chat'
GROUP BY datname;

-- Long-running queries
SELECT pid, now() - query_start as duration, state, query
FROM pg_stat_activity
WHERE state != 'idle'
  AND now() - query_start > interval '5 seconds'
ORDER BY duration DESC;
```

## Backup Setup

### Development Backup Script

```bash
#!/bin/bash
# backup-dev-db.sh

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CONTAINER="chat_server-postgres-1"

mkdir -p $BACKUP_DIR

docker exec $CONTAINER pg_dump -U postgres -d chat -F c -f /tmp/backup.dump
docker cp $CONTAINER:/tmp/backup.dump $BACKUP_DIR/chat_backup_$TIMESTAMP.dump

# Keep last 7 days
find $BACKUP_DIR -name "chat_backup_*.dump" -mtime +7 -delete

echo "Backup: $BACKUP_DIR/chat_backup_$TIMESTAMP.dump"
```

### Production Backup Script

```bash
#!/bin/bash
# backup-prod-db.sh

set -e

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-chat}"
DB_USER="${DB_USER:-postgres}"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/postgresql}"
S3_BUCKET="${S3_BUCKET}"
RETENTION_DAYS=30

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/chat_backup_$TIMESTAMP.dump"

mkdir -p $BACKUP_DIR

pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -F c -f $BACKUP_FILE
gzip $BACKUP_FILE

# Upload to S3 if configured
if [ -n "$S3_BUCKET" ]; then
  aws s3 cp $BACKUP_FILE.gz $S3_BUCKET/$(basename $BACKUP_FILE.gz)
fi

# Cleanup old backups
find $BACKUP_DIR -name "chat_backup_*.dump.gz" -mtime +$RETENTION_DAYS -delete
```

### Restore from Backup

```bash
# Development
docker exec -i chat_server-postgres-1 pg_restore -U postgres -d chat -c < backup.dump

# Production
pg_restore -h localhost -p 5432 -U postgres -d chat -c -v backup.dump.gz
```

### WAL Archiving (Point-in-Time Recovery)

Add to `postgresql.conf`:

```conf
wal_level = replica
archive_mode = on
archive_command = 'test ! -f /wal_archive/%f && cp %p /wal_archive/%f'
archive_timeout = 300
wal_keep_size = 1GB
```

## Production Deployment

### AWS RDS

```yaml
# config/production.yaml
database:
  host: chat-prod.abc123.us-east-1.rds.amazonaws.com
  port: 5432
  name: chat
  user: chat_app
  requireSsl: true
  maxConnectionCount: 50
```

**Checklist:**
- ✅ Enable automated backups (7-35 days)
- ✅ Enable Multi-AZ
- ✅ Use db.t3.medium or larger
- ✅ Enable Performance Insights
- ✅ Enable encryption at rest
- ✅ Configure security groups

### Google Cloud SQL

```yaml
database:
  host: 10.0.0.3  # Private IP
  port: 5432
  name: chat
  user: chat_app
  requireSsl: true
  maxConnectionCount: 50
```

**Checklist:**
- ✅ Enable automatic backups and PITR
- ✅ Use private IP
- ✅ Enable high availability
- ✅ Use db-custom-2-7680 or larger
- ✅ Enable query insights

### Performance Tuning

```conf
# postgresql.conf
max_connections = 200
shared_buffers = 2GB                    # 25% of RAM
effective_cache_size = 6GB              # 75% of RAM
maintenance_work_mem = 512MB
work_mem = 10MB
checkpoint_completion_target = 0.9
random_page_cost = 1.1                  # For SSD
effective_io_concurrency = 200
log_min_duration_statement = 1000       # Log slow queries
autovacuum = on
```

### Index Optimization

```sql
-- Analyze query performance
EXPLAIN ANALYZE 
SELECT * FROM messages 
WHERE chat_id = 'uuid' 
ORDER BY server_seq DESC 
LIMIT 50;

-- Monitor index usage
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan ASC;

-- Remove unused indexes
SELECT schemaname, tablename, indexname
FROM pg_stat_user_indexes
WHERE idx_scan = 0 AND schemaname = 'public';
```

## Troubleshooting

### Connection Refused

```bash
docker ps | grep postgres
docker logs chat_server-postgres-1
docker port chat_server-postgres-1
telnet localhost 8090
```

### Out of Connections

```sql
-- Check connections
SELECT count(*) FROM pg_stat_activity;

-- Kill idle connections
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE state = 'idle'
  AND state_change < now() - interval '10 minutes';
```

### Slow Queries

```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

SELECT query, calls, mean_exec_time, max_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

### Disk Space

```bash
# Database sizes
docker exec chat_server-postgres-1 psql -U postgres -c "
  SELECT datname, pg_size_pretty(pg_database_size(datname)) AS size
  FROM pg_database
  ORDER BY pg_database_size(datname) DESC;
"

# Table sizes
docker exec chat_server-postgres-1 psql -U postgres -d chat -c "
  SELECT tablename, pg_size_pretty(pg_total_relation_size('public.'||tablename)) AS size
  FROM pg_tables
  WHERE schemaname = 'public'
  ORDER BY pg_total_relation_size('public.'||tablename) DESC;
"

# Vacuum to reclaim space
docker exec chat_server-postgres-1 psql -U postgres -d chat -c "VACUUM FULL ANALYZE;"
```

### Health Check Script

```bash
#!/bin/bash
# health-check.sh

DB_HOST="localhost"
DB_PORT="8090"
DB_NAME="chat"
DB_USER="postgres"

if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1" > /dev/null 2>&1; then
  echo "✅ Database connection: OK"
else
  echo "❌ Database connection: FAILED"
  exit 1
fi

CONN_COUNT=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
  SELECT count(*) FROM pg_stat_activity WHERE datname = '$DB_NAME';
")
echo "📊 Active connections: $CONN_COUNT"

LONG_QUERIES=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
  SELECT count(*) FROM pg_stat_activity 
  WHERE state != 'idle' AND now() - query_start > interval '30 seconds';
")

if [ "$LONG_QUERIES" -gt 0 ]; then
  echo "⚠️  Long-running queries: $LONG_QUERIES"
else
  echo "✅ Long-running queries: 0"
fi
```

## Security Best Practices

1. **Use strong passwords** - Generate random passwords for production
2. **Enable SSL/TLS** - Set `requireSsl: true` in production
3. **Limit permissions** - Application user should have minimal privileges
4. **Audit logging** - Enable PostgreSQL audit extension
5. **Regular backups** - Daily backups with 30-day retention
6. **Monitor access** - Alert on unusual patterns
7. **Encrypt at rest** - Enable database encryption
8. **Network isolation** - Use private networks/VPCs

## Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Serverpod Database Docs](https://docs.serverpod.dev/concepts/database)
- [PgBouncer Documentation](https://www.pgbouncer.org/)
- [AWS RDS Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)

## Related Documentation

- [Database Schema](./schema.sql) - Complete SQL schema
- [ERD](./erd.md) - Entity relationship diagram
- [Quick Reference](./QUICK_REFERENCE.md) - Common queries
- [Database README](./README.md) - Architecture overview
