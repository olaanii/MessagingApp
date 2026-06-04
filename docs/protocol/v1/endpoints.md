# Serverpod Protocol v1 - Endpoint Contracts

**Version:** 1.0.0  
**Status:** Active  
**Last Updated:** 2024

## Overview

This document defines all REST and streaming endpoints for the Production-Ready Privacy-Focused Chat Platform. All endpoints are versioned as v1 and follow the architecture defined in ADR-0001.

For complete data model definitions, see [models.yaml](./models.yaml).

## Base URL

```
Production: https://api.chatapp.com/v1
Development: http://localhost:8080/v1
```

## Authentication

All endpoints (except authentication endpoints) require a valid session token:

```
Authorization: Bearer <session_token>
```

Session tokens expire after 7 days. Use refresh token to renew.

## Streaming Event Envelope Structure

All real-time events use the `StreamEvent` envelope (defined in models.yaml):

```yaml
class: StreamEvent
fields:
  type: String                    # Event type identifier
  chatId: String?                 # Chat context
  deviceId: String?               # Device context
  timestamp: DateTime             # Event timestamp
  idempotencyKey: String?         # Deduplication key
  payload: Map<String, dynamic>   # Event-specific data
```

This provides type safety, context, idempotency, and extensibility.

## Error Responses

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": {}
  }
}
```

**Error Codes:** UNAUTHORIZED, FORBIDDEN, NOT_FOUND, CONFLICT, RATE_LIMITED, VALIDATION_ERROR, INTERNAL_ERROR



---

## 1. Authentication Endpoints

| Endpoint | Method | Description | Rate Limit |
|----------|--------|-------------|------------|
| `/auth/exchange-token` | POST | Exchange Firebase ID token for Serverpod session | 5/hour/IP |
| `/auth/refresh` | POST | Renew session with refresh token | - |
| `/auth/logout` | POST | Revoke session and device access | - |

**Models:** Session, User

---

## 2. Device Management Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/devices/register` | POST | Register new device |
| `/devices` | GET | List user's devices |
| `/devices/{deviceId}/revoke` | POST | Revoke device access |
| `/devices/{deviceId}` | PATCH | Update device metadata |

**Models:** Device

---

## 3. Key Management Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/keys/upload-bundle` | POST | Upload public key bundle |
| `/keys/user/{userId}` | GET | Fetch user's key bundles (consumes OneTimePrekey) |
| `/keys/replenish-prekeys` | POST | Add new one-time prekeys |

**Models:** KeyBundle, OneTimePrekey

---

## 4. Chat Management Endpoints

| Endpoint | Method | Description | Rate Limit |
|----------|--------|-------------|------------|
| `/chats/direct` | POST | Create 1:1 chat | - |
| `/chats/group` | POST | Create group chat | 10/min/user |
| `/chats` | GET | List chats (pagination) | - |
| `/chats/{chatId}` | GET | Get chat details | - |
| `/chats/{chatId}/members` | POST | Add group members (admin) | 10/min/user |
| `/chats/{chatId}/members/{userId}` | DELETE | Remove member (admin) | 10/min/user |
| `/chats/{chatId}/leave` | POST | Leave group | - |
| `/chats/{chatId}` | PATCH | Update group settings (admin) | - |

**Models:** Chat, ChatMember

---

## 5. Message Operations Endpoints

| Endpoint | Method | Description | Rate Limit |
|----------|--------|-------------|------------|
| `/messages/send` | POST | Send encrypted message (idempotent via clientMsgId) | 100/min/user |
| `/messages` | GET | List messages (query: chatId, limit, cursor) | - |
| `/messages/{messageId}` | DELETE | Delete message (tombstone) | - |
| `/messages/{messageId}` | PATCH | Edit message content | - |
| `/messages/{messageId}/ack` | POST | Acknowledge delivery/read | - |

**Models:** Message, SendMessageRequest

---

## 6. Sync Operations Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/sync/changes` | GET | Get incremental changes (query: cursor, limit) |
| `/sync/chat/{chatId}/changes` | GET | Get chat-specific changes |
| `/sync/acknowledge` | POST | Confirm client processed changes |

**Models:** ChangeSet, SyncCursor

---

## 7. Media Operations Endpoints

| Endpoint | Method | Description | Rate Limit |
|----------|--------|-------------|------------|
| `/media/prepare-upload` | POST | Generate presigned S3 URL | 20/hour/user |
| `/media/{mediaId}/finalize` | POST | Confirm upload completion | - |
| `/media/{mediaId}/url` | GET | Get presigned download URL | - |

**Models:** Media, MediaUploadRequest

**Note:** Client encrypts files before upload; server stores only encrypted media.

---

## 8. Push Notification Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/push/register-token` | POST | Store FCM token |
| `/push/preferences` | POST | Update notification settings |
| `/chats/{chatId}/mute` | POST | Mute chat notifications |
| `/chats/{chatId}/unmute` | POST | Unmute chat |

**Models:** PushToken, PushPreferences

---

## 9. Safety and Moderation Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/safety/report-user` | POST | Report user for abuse |
| `/safety/report-message` | POST | Report specific message |
| `/safety/block-user` | POST | Block user bidirectionally |
| `/safety/unblock-user` | POST | Remove block |
| `/safety/blocked-users` | GET | List blocked users |

**Models:** Report, Block

---

## 10. Story Operations Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/stories` | POST | Create ephemeral story (24h expiration) |
| `/stories` | GET | List stories (pagination) |
| `/stories/{storyId}/view` | POST | Mark story as viewed |
| `/stories/{storyId}/viewers` | GET | Get viewer list (creator only) |
| `/stories/{storyId}` | DELETE | Delete story before expiration |

**Models:** Story, StoryView

---

## 11. User Profile Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/users/{userId}` | GET | Get user profile |
| `/users/me` | PATCH | Update current user's profile |
| `/users/me/presence` | POST | Update presence (online/away/offline) |
| `/users/search` | GET | Search users (query: phone hash or username) |

**Models:** User

---

## 12. Contact Management Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/contacts/sync` | POST | Match phone contacts (hashed) |
| `/contacts` | GET | Get contact list |

**Note:** Client hashes phone numbers (SHA-256) before sending.

---

## 13. WebRTC Call Signaling Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/calls/initiate` | POST | Start voice/video call |
| `/calls/{callId}/answer` | POST | Accept incoming call |
| `/calls/{callId}/reject` | POST | Decline call |
| `/calls/{callId}/end` | POST | Terminate active call |
| `/calls/{callId}/ice-candidate` | POST | Exchange ICE candidates |

**Note:** Signaling only; audio/video streams are P2P encrypted via WebRTC.

---



## 14. Streaming Endpoint and Event Catalog

### 14.1 Real-time Event Stream

**Endpoint:** `WS /stream/realtime`

**Headers:** `Authorization: Bearer <session_token>`

All events use the `StreamEvent` envelope structure.

---

### 14.2 Client → Server Events

| Event Type | Description | Payload Fields |
|------------|-------------|----------------|
| `send_message` | Send encrypted message | SendMessageRequest model |
| `ack` | Acknowledge delivery/read | messageId, ackType ('delivered'/'read') |
| `typing` | Broadcast typing (5s TTL) | isTyping (boolean) |
| `presence` | Update online status | status ('online'/'away'/'offline') |

**Example - send_message:**
```json
{
  "type": "send_message",
  "chatId": "string",
  "deviceId": "string",
  "timestamp": "2024-01-01T00:00:00Z",
  "idempotencyKey": "string",
  "payload": {
    "chatId": "string",
    "clientMsgId": "string",
    "ciphertext": "string",
    "contentType": "text",
    "mediaId": null,
    "recipientDeviceIds": ["string"]
  }
}
```

---

### 14.3 Server → Client Events

| Event Type | Description | Payload Fields |
|------------|-------------|----------------|
| `message` | New message notification | message (Message model) |
| `message_ack` | Delivery/read acknowledgment | messageId, ackType, userId, deviceId |
| `typing` | User typing indicator | userId, isTyping |
| `presence` | Presence status update | userId, status |
| `sync_hint` | Nudge to pull changes | reason |
| `error` | Error notification | code, message, details |
| `call_offer` | Incoming call notification | callId, callerId, callType ('voice'/'video') |
| `call_answered` | Call accepted | callId |
| `ice_candidate` | WebRTC ICE candidate | callId, candidate, sdpMid, sdpMLineIndex |

**Example - message:**
```json
{
  "type": "message",
  "chatId": "string",
  "timestamp": "2024-01-01T00:00:00Z",
  "idempotencyKey": "string",
  "payload": {
    "message": {
      "id": "string",
      "chatId": "string",
      "senderId": "string",
      "senderDeviceId": "string",
      "clientMsgId": "string",
      "serverSeq": 42,
      "ciphertext": "string",
      "contentType": "text",
      "mediaId": null,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z",
      "deletedAt": null
    }
  }
}
```

**Example - call_offer:**
```json
{
  "type": "call_offer",
  "timestamp": "2024-01-01T00:00:00Z",
  "payload": {
    "callId": "string",
    "callerId": "string",
    "callType": "voice"
  }
}
```

---



## 15. Rate Limits Summary

| Operation | Limit | Scope |
|-----------|-------|-------|
| Authentication | 5 attempts/hour | Per IP |
| Message sending | 100 messages/minute | Per user |
| Group operations | 10 operations/minute | Per user |
| Media uploads | 20 uploads/hour | Per user |
| API requests | 1000 requests/hour | Per user |
| WebSocket connections | 5 concurrent | Per user |

**Rate Limit Headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1704067200
```

**429 Response:**
```json
{
  "error": {
    "code": "RATE_LIMITED",
    "message": "Rate limit exceeded",
    "details": {
      "retryAfter": 60,
      "limit": 100,
      "window": "1 minute"
    }
  }
}
```

---

## 16. Idempotency

**Idempotent Operations:**
- `POST /messages/send` - Uses `clientMsgId`
- Streaming `send_message` event - Uses `idempotencyKey`

**Behavior:**
- Duplicate requests return existing result (200 OK)
- No error for duplicates
- Keys expire after 24 hours

---

## 17. Pagination

**Cursor-Based Pagination:**

All list endpoints use cursor-based pagination.

**Request:** `GET /chats?limit=50&cursor=<cursor>`

**Response:**
```json
{
  "items": [...],
  "cursor": "string?",
  "hasMore": true
}
```

- `cursor` is null when no more pages
- Cursors are opaque strings
- Cursors expire after 1 hour

---

## 18. Versioning

**API Version:** All endpoints prefixed with `/v1/`

**Version Header:**
```
Accept: application/vnd.chatapp.v1+json
```

**Unsupported Version:**
```json
{
  "error": {
    "code": "UNSUPPORTED_VERSION",
    "message": "API version v2 is not supported",
    "details": {
      "supportedVersions": ["v1"]
    }
  }
}
```

---

## 19. Security Considerations

### TLS/HTTPS
- All communication over TLS 1.3
- Certificate pinning recommended
- WebSocket uses WSS

### Authentication
- Session tokens expire after 7 days
- Refresh tokens expire after 30 days
- Tokens in flutter_secure_storage
- Firebase Admin SDK validates tokens

### End-to-End Encryption
- Server stores only ciphertext
- Private keys never transmitted
- Media encrypted before upload
- Push notifications contain no content

### Rate Limiting
- Prevents abuse
- Sliding window algorithm
- Device reputation affects limits

---

## 20. Testing Endpoints

### Health Check

**Endpoint:** `GET /health`

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

---

## Related Documentation

- [Protocol Models](./models.yaml) - YAML data model definitions
- [Protocol README](./README.md) - Protocol overview and usage
- [ADR-0001](../../adr/0001-serverpod-protocol-v1.md) - Protocol design decisions
- [Requirements](../../../.kiro/specs/production-ready-privacy-chat/requirements.md) - System requirements
- [Design Document](../../../.kiro/specs/production-ready-privacy-chat/design.md) - Architecture design

---

**Maintained by:** Backend Team  
**Last Updated:** 2024  
**Protocol Version:** 1.0.0

