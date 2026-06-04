-- PostgreSQL Schema for Production-Ready Privacy-Focused Chat Platform
-- Protocol Version: v1
-- Generated from: docs/protocol/v1/models.yaml
-- Requirements: 2.2, 22.4

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- USERS AND AUTHENTICATION
-- ============================================================================

-- Users Table
-- Stores user profile information and authentication metadata
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_uid VARCHAR(128) UNIQUE NOT NULL,
  display_name VARCHAR(255) NOT NULL,
  photo_url TEXT,
  phone_number VARCHAR(20) NOT NULL,
  status_message TEXT,
  presence_status VARCHAR(20) DEFAULT 'offline' CHECK (presence_status IN ('online', 'away', 'offline')),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for user lookups
CREATE INDEX idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX idx_users_phone_number ON users(phone_number);

-- Devices Table
-- Tracks registered devices for multi-device support
CREATE TABLE devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  platform VARCHAR(50) NOT NULL CHECK (platform IN ('android', 'ios', 'web')),
  public_key_ref TEXT NOT NULL,
  last_seen_at TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  revoked_at TIMESTAMP
);

-- Indexes for device lookups
CREATE INDEX idx_devices_user_id ON devices(user_id);
CREATE INDEX idx_devices_device_id ON devices(device_id);
CREATE INDEX idx_devices_active ON devices(user_id, revoked_at) WHERE revoked_at IS NULL;

-- Sessions Table
-- Manages authenticated sessions tied to devices
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  refresh_token_hash VARCHAR(255) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  revoked_at TIMESTAMP
);

-- Indexes for session management
CREATE INDEX idx_sessions_user_device ON sessions(user_id, device_id);
CREATE INDEX idx_sessions_expires ON sessions(expires_at) WHERE revoked_at IS NULL;
CREATE INDEX idx_sessions_token_hash ON sessions(refresh_token_hash) WHERE revoked_at IS NULL;

-- ============================================================================
-- CHATS AND MESSAGING
-- ============================================================================

-- Chats Table
-- Represents conversations (1:1 or group)
CREATE TABLE chats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type VARCHAR(20) NOT NULL CHECK (type IN ('direct', 'group')),
  title VARCHAR(255),
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for chat queries
CREATE INDEX idx_chats_type ON chats(type);
CREATE INDEX idx_chats_updated_at ON chats(updated_at DESC);
CREATE INDEX idx_chats_created_by ON chats(created_by);

-- Chat Members Table
-- Tracks membership in chats with roles and read state
CREATE TABLE chat_members (
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role VARCHAR(20) NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member')),
  joined_at TIMESTAMP NOT NULL DEFAULT NOW(),
  last_read_seq BIGINT DEFAULT 0,
  muted_until TIMESTAMP,
  PRIMARY KEY (chat_id, user_id)
);

-- Indexes for membership queries
CREATE INDEX idx_chat_members_user_id ON chat_members(user_id);
CREATE INDEX idx_chat_members_chat_id ON chat_members(chat_id);

-- Messages Table
-- Stores encrypted messages with idempotency constraints
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id),
  sender_device_id UUID NOT NULL REFERENCES devices(id),
  client_msg_id VARCHAR(255) NOT NULL,
  server_seq BIGSERIAL NOT NULL,
  ciphertext TEXT NOT NULL,
  content_type VARCHAR(50) NOT NULL CHECK (content_type IN ('text', 'image', 'video', 'audio', 'file')),
  media_id UUID,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP,
  -- Idempotency constraint: prevent duplicate messages from same sender
  UNIQUE (sender_id, client_msg_id)
);

-- Performance indexes for message queries (Requirement 22.4)
CREATE INDEX idx_messages_chat_seq ON messages(chat_id, server_seq DESC);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX idx_messages_client_msg ON messages(sender_id, client_msg_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);

-- ============================================================================
-- MEDIA AND FILES
-- ============================================================================

-- Media Objects Table
-- Stores metadata for encrypted media files
CREATE TABLE media_objects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  uploader_id UUID NOT NULL REFERENCES users(id),
  storage_key TEXT NOT NULL,
  mime_type VARCHAR(100) NOT NULL,
  size_bytes BIGINT NOT NULL,
  sha256_hash VARCHAR(64) NOT NULL,
  encrypted BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for media lookups
CREATE INDEX idx_media_uploader ON media_objects(uploader_id);
CREATE INDEX idx_media_sha256 ON media_objects(sha256_hash);
CREATE INDEX idx_media_created_at ON media_objects(created_at DESC);

-- ============================================================================
-- END-TO-END ENCRYPTION KEYS
-- ============================================================================

-- Device Keys Table
-- Stores public key material for E2EE session establishment
CREATE TABLE device_keys (
  device_id UUID PRIMARY KEY REFERENCES devices(id) ON DELETE CASCADE,
  identity_key TEXT NOT NULL,
  signed_prekey TEXT NOT NULL,
  signed_prekey_signature TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- One-Time Prekeys Table
-- Stores single-use prekeys for forward secrecy
CREATE TABLE one_time_prekeys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  key_id INT NOT NULL,
  public_key TEXT NOT NULL,
  used_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE (device_id, key_id)
);

-- Indexes for prekey management
CREATE INDEX idx_prekeys_device_unused ON one_time_prekeys(device_id) 
  WHERE used_at IS NULL;
CREATE INDEX idx_prekeys_used_at ON one_time_prekeys(used_at);

-- ============================================================================
-- PUSH NOTIFICATIONS
-- ============================================================================

-- Push Tokens Table
-- Stores FCM tokens for push notification delivery
CREATE TABLE push_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  platform VARCHAR(20) NOT NULL CHECK (platform IN ('android', 'ios', 'web')),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for push token lookups
CREATE INDEX idx_push_tokens_device ON push_tokens(device_id);
CREATE INDEX idx_push_tokens_user ON push_tokens(user_id);
CREATE INDEX idx_push_tokens_token ON push_tokens(token);

-- ============================================================================
-- SAFETY AND MODERATION
-- ============================================================================

-- Blocks Table
-- Tracks user blocking relationships
CREATE TABLE blocks (
  blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY (blocker_id, blocked_id),
  CHECK (blocker_id != blocked_id)
);

-- Indexes for block lookups
CREATE INDEX idx_blocks_blocker ON blocks(blocker_id);
CREATE INDEX idx_blocks_blocked ON blocks(blocked_id);

-- Reports Table
-- Stores abuse reports for moderation
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES users(id),
  reported_user_id UUID REFERENCES users(id),
  reported_message_id UUID REFERENCES messages(id),
  reason VARCHAR(100) NOT NULL CHECK (reason IN ('spam', 'harassment', 'inappropriate', 'other')),
  context TEXT,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved')),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  resolved_at TIMESTAMP,
  CHECK (reported_user_id IS NOT NULL OR reported_message_id IS NOT NULL)
);

-- Indexes for moderation queries
CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_reported_user ON reports(reported_user_id);
CREATE INDEX idx_reports_created_at ON reports(created_at DESC);

-- ============================================================================
-- STORIES (EPHEMERAL CONTENT)
-- ============================================================================

-- Stories Table
-- Stores ephemeral stories with 24-hour expiration
CREATE TABLE stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  media_id UUID NOT NULL REFERENCES media_objects(id),
  ciphertext TEXT NOT NULL,
  content_type VARCHAR(50) NOT NULL CHECK (content_type IN ('photo', 'video', 'text')),
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for story queries
CREATE INDEX idx_stories_user ON stories(user_id);
CREATE INDEX idx_stories_expires ON stories(expires_at);
CREATE INDEX idx_stories_created_at ON stories(created_at DESC);

-- Story Views Table
-- Tracks who viewed each story
CREATE TABLE story_views (
  story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  viewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  viewed_at TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY (story_id, viewer_id)
);

-- Indexes for view tracking
CREATE INDEX idx_story_views_story ON story_views(story_id);
CREATE INDEX idx_story_views_viewer ON story_views(viewer_id);

-- ============================================================================
-- TRIGGERS AND FUNCTIONS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for automatic updated_at management
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chats_updated_at BEFORE UPDATE ON chats
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_device_keys_updated_at BEFORE UPDATE ON device_keys
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_push_tokens_updated_at BEFORE UPDATE ON push_tokens
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE users IS 'User profiles and authentication metadata';
COMMENT ON TABLE devices IS 'Registered devices for multi-device support';
COMMENT ON TABLE sessions IS 'Authenticated sessions tied to devices';
COMMENT ON TABLE chats IS 'Conversations (1:1 or group)';
COMMENT ON TABLE chat_members IS 'Chat membership with roles and read state';
COMMENT ON TABLE messages IS 'Encrypted messages with idempotency constraints';
COMMENT ON TABLE media_objects IS 'Metadata for encrypted media files';
COMMENT ON TABLE device_keys IS 'Public key material for E2EE';
COMMENT ON TABLE one_time_prekeys IS 'Single-use prekeys for forward secrecy';
COMMENT ON TABLE push_tokens IS 'FCM tokens for push notifications';
COMMENT ON TABLE blocks IS 'User blocking relationships';
COMMENT ON TABLE reports IS 'Abuse reports for moderation';
COMMENT ON TABLE stories IS 'Ephemeral stories with 24-hour expiration';
COMMENT ON TABLE story_views IS 'Story view tracking';

COMMENT ON COLUMN messages.ciphertext IS 'Encrypted message content - server never stores plaintext';
COMMENT ON COLUMN messages.client_msg_id IS 'Client-generated idempotency key';
COMMENT ON COLUMN messages.server_seq IS 'Server-assigned sequence number for ordering';
COMMENT ON COLUMN media_objects.encrypted IS 'Always true for E2EE - server stores only encrypted files';
COMMENT ON COLUMN device_keys.identity_key IS 'Ed25519 public identity key';
COMMENT ON COLUMN device_keys.signed_prekey IS 'X25519 signed prekey';
COMMENT ON COLUMN one_time_prekeys.used_at IS 'NULL if unused, timestamp when consumed';
