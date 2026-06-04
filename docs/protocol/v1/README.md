# Serverpod Protocol v1

**Version:** 1.0.0  
**Status:** Active  
**Last Updated:** 2024

## Overview

This directory contains the complete Protocol v1 definition for the Production-Ready Privacy-Focused Chat Platform. The protocol defines type-safe contracts between Flutter clients and the Serverpod backend.

## Files

### [`models.yaml`](./models.yaml)

YAML definitions for all data models used in the protocol. Serverpod generates type-safe Dart classes from these definitions.

**Key Models:**
- **User, Device, Session**: Authentication and multi-device support
- **Chat, ChatMember, Message**: Core messaging functionality
- **Media**: Encrypted file storage
- **KeyBundle, OneTimePrekey**: End-to-end encryption key material
- **Story, StoryView**: Ephemeral content
- **StreamEvent**: Real-time event envelope
- **Request/Response Models**: API operation payloads

### [`endpoints.md`](./endpoints.md)

Comprehensive documentation of all REST and streaming endpoints.

**Endpoint Categories:**
1. Authentication - Firebase token exchange, session management
2. Device Management - Multi-device registration and control
3. Key Management - E2EE key bundle operations
4. Chat Operations - Create, list, manage conversations
5. Message Operations - Send, retrieve, acknowledge messages
6. Sync Operations - Cursor-based incremental synchronization
7. Media Operations - Encrypted file upload/download
8. Push Notifications - FCM token and preference management
9. Safety & Moderation - Reporting and blocking
10. Story Operations - Ephemeral content management
11. Streaming - Real-time WebSocket events

## Streaming Event Catalog

All real-time events use the `StreamEvent` envelope structure:

```dart
class StreamEvent {
  String type;                    // Event type identifier
  String? chatId;                 // Chat context (if applicable)
  String? deviceId;               // Device context (if applicable)
  DateTime timestamp;             // Event timestamp
  String? idempotencyKey;         // For deduplication
  Map<String, dynamic> payload;   // Event-specific data
}
```

### Client → Server Events

| Event Type | Description | Payload |
|------------|-------------|---------|
| `send_message` | Send encrypted message | `SendMessageRequest` |
| `ack` | Acknowledge message delivery/read | `messageId`, `ackType` |
| `typing` | Broadcast typing indicator | `chatId`, `isTyping` |
| `presence` | Update online status | `status` |

### Server → Client Events

| Event Type | Description | Payload |
|------------|-------------|---------|
| `message` | New message notification | `message: Message` |
| `message_ack` | Delivery/read acknowledgment | `ackType`, `userId`, `deviceId` |
| `typing` | User typing indicator | `userId`, `isTyping` |
| `presence` | Presence status update | `userId`, `status` |
| `sync_hint` | Nudge to pull changes | `reason` |
| `error` | Error notification | `code`, `message`, `details` |

## Code Generation

Generate type-safe Dart classes from protocol definitions:

```bash
# From server directory
serverpod generate
```

This creates:
- `server/lib/src/protocol/` - Server-side classes
- `client/lib/src/protocol/` - Client-side classes

## Versioning

Protocol follows semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Breaking changes requiring client updates
- **MINOR**: Backward-compatible additions (new endpoints, optional fields)
- **PATCH**: Bug fixes and documentation updates

Current version: **1.0.0**

## Usage in Flutter Client

```dart
import 'package:chat_client/chat_client.dart';

// Initialize client
final client = Client('https://api.chatapp.com/v1');

// Authenticate
final session = await client.auth.exchangeFirebaseToken(
  idToken: firebaseToken,
  deviceId: deviceId,
);

// Send message
final message = await client.message.send(
  SendMessageRequest(
    chatId: chatId,
    clientMsgId: uuid.v4(),
    ciphertext: encryptedContent,
    contentType: 'text',
  ),
);

// Connect to streaming
final stream = client.stream.realtime(sessionToken: session.sessionToken);
stream.listen((event) {
  switch (event.type) {
    case 'message':
      handleNewMessage(event);
      break;
    case 'typing':
      handleTypingIndicator(event);
      break;
    // ... handle other events
  }
});
```

## Security Considerations

1. **End-to-End Encryption**: Server stores only ciphertext, never plaintext
2. **Private Keys**: Never transmitted to server, stored in flutter_secure_storage
3. **TLS**: All communication over HTTPS/WSS
4. **Session Tokens**: Expire after 7 days, refresh tokens after 30 days
5. **Rate Limiting**: Prevents abuse and resource exhaustion
6. **Idempotency**: `clientMsgId` prevents duplicate message processing

## Rate Limits

| Operation | Limit |
|-----------|-------|
| Authentication | 5 attempts/hour/IP |
| Message sending | 100 messages/minute/user |
| Group operations | 10 operations/minute/user |
| Media uploads | 20 uploads/hour/user |
| API requests | 1000 requests/hour/user |

## Error Handling

All endpoints return consistent error responses:

```dart
{
  "error": {
    "code": String,
    "message": String,
    "details": Map<String, dynamic>?
  }
}
```

Common error codes:
- `UNAUTHORIZED`: Authentication required
- `FORBIDDEN`: Insufficient permissions
- `NOT_FOUND`: Resource not found
- `CONFLICT`: Resource conflict
- `RATE_LIMITED`: Rate limit exceeded
- `VALIDATION_ERROR`: Invalid parameters
- `INTERNAL_ERROR`: Server error

## Migration from v1 to v2 (Future)

When v2 is released:

1. v1 will be maintained for at least 6 months
2. Clients can specify version in `Accept` header
3. Migration guide will be provided
4. Feature flags enable gradual rollout

## Related Documentation

- [Architecture Decision Record](../../adr/0001-serverpod-protocol-v1.md)
- [Requirements Document](../../../.kiro/specs/production-ready-privacy-chat/requirements.md)
- [Design Document](../../../.kiro/specs/production-ready-privacy-chat/design.md)

## Support

For questions or issues with the protocol:
- Review the [endpoints documentation](./endpoints.md)
- Check the [ADR](../../adr/0001-serverpod-protocol-v1.md) for design rationale
- Consult the [Serverpod documentation](https://docs.serverpod.dev/)

---

**Maintained by:** Backend Team  
**Last Updated:** 2024  
**Protocol Version:** 1.0.0
