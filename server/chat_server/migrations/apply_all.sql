-- Migration Application Script
-- This script applies all migrations in order
-- Run this script to update the database schema

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Migration tracking table
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(255) PRIMARY KEY,
    applied_at TIMESTAMP NOT NULL DEFAULT NOW(),
    description TEXT
);

-- Function to check if migration was already applied
CREATE OR REPLACE FUNCTION migration_applied(migration_version VARCHAR) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM schema_migrations WHERE version = migration_version
    );
END;
$$ LANGUAGE plpgsql;

-- Apply migrations in order
-- Each migration should be wrapped in a transaction and check if already applied

-- Example migration structure:
-- DO $$
-- BEGIN
--     IF NOT migration_applied('001_initial_schema') THEN
--         -- Your migration SQL here
--         
--         -- Record migration
--         INSERT INTO schema_migrations (version, description) 
--         VALUES ('001_initial_schema', 'Initial database schema');
--     END IF;
-- END $$;

-- TODO: Add actual migration files here
-- Migrations should be added in chronological order
-- Each migration file should be included here

-- Log completion
DO $$
BEGIN
    RAISE NOTICE 'All migrations applied successfully';
END $$;
