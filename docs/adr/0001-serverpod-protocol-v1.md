# ADR-0001: Serverpod Protocol v1 Definition

**Status:** Accepted  
**Date:** 2024  
**Deciders:** Backend Team, Frontend Team  
**Technical Story:** Production-Ready Privacy-Focused Chat Platform

## Context

The chat platform requires a well-defined, versioned API contract between the Flutter client and Serverpod backend. The protocol must support:

1. End-to-end encrypted messaging with server storing only ciphertext
2. Multi-device synchronization with per-device encryption keys
3. Real-time communication via WebSocket streaming
4. Offline-first architecture with cursor-based incremental sync
5. Media sharing with encrypted file storage
6. Type-safe communication using generated Serverpod clients
7. Future extensibility without breaking existing clients

## Decision

We will define **Protocol v1** using Serverpod's YAML-based protocol definitions, consisting of:

### 1. Data Models (`docs/protocol/v1/models.yaml`)

All core data models are defined in YAML and generate type-safe Dart classes:

- **User**: User profiles with Firebase Auth integration
- **Device**: Multi-device support with per-device keys
- **Session**: Authentication sessions tied to devices
- **Chat**: Conversations (direct and group)
- **Message**: Encrypted messages with server-assigned sequence numbers
- **Media**: Encrypted media files with storage references
- **KeyBundle**: Public key material for E2EE session establishment
- **StreamEvent**: Envelope structure for real-time events

### 2. REST Endpoints (`docs/protocol/v1/endpoints.md`)

Comprehensive REST API covering:

- Authentication (Firebase token exchange, session management)
- Device management (registration, listing, revocation)
- Key management (key bundle upload, retrieval, prekey replenishment)
- Chat operations (create, list, member management)
- Message operations (send, list, delete, edit, acknowledge)
- Sync operations (incremental sync with cursors)
- Media operations (presigned upload/download URLs)
- Push notifications (token registration, preferences)
- Safety features (reporting, blocking)
- Stories (ephemeral content)

### 3. Streaming Endpoints

WebSocket-based real-time communication with bidirectional events:

**Client → Server:**
- `send_message`: Send encrypted message
- `ack`: Acknowledge message delivery/read
- `typing`: Broadcast typing indicator
- `presence`: Update online status

**Server → Client:**
- `message`: New message notification
- `message_ack`: Delivery/read acknowledgment
- `typing`: Typing indicator from other users
- `presence`: Presence status updates
- `sync_hint`: Nudge to pull changes
- `error`: Error notifications

### 4. Event Envelope Structure

All streaming events use a consistent `StreamEvent` envelope:

```dart
class StreamEvent {
  String type;                    // Event type identifier
  String? chatId;                 // Chat context
  String? deviceId;               // Device context
  DateTime timestamp;             // Event timestamp
  String? idempotencyKey;         // Deduplication key
  Map<String, dynamic> payload;   // Event-specific data
}
```

### 5. Versioning Strategy

- Protocol version: **v1.0.0** (semantic versioning)
- All endpoints prefixed with `/v1/` in production
- Clients specify version in `Accept` header: `application/vnd.chatapp.v1+json`
- Breaking changes require new major version (v2)
- Non-breaking additions can increment minor version
- Bug fixes increment patch version

### 6. Code Generation

- Serverpod generates type-safe Dart client from YAML definitions
- Build system regenerates client on protocol changes
- Version documentation updated automatically
- CI/CD validates protocol compatibility

## Consequences

### Positive

1. **Type Safety**: Generated clients eliminate runtime type errors
2. **Documentation**: Protocol definitions serve as living documentation
3. **Versioning**: Clear versioning prevents breaking changes
4. **Consistency**: Envelope structure standardizes event handling
5. **Extensibility**: New endpoints/events can be added without breaking existing clients
6. **Privacy**: Protocol enforces E2EE by design (server never sees plaintext)
7. **Offline Support**: Cursor-based sync enables efficient offline-first architecture
8. **Multi-Device**: Protocol natively supports per-device encryption and sync

### Negative

1. **Migration Overhead**: Protocol changes require client updates
2. **Versioning Complexity**: Multiple protocol versions increase maintenance burden
3. **Code Generation Dependency**: Build process depends on Serverpod tooling
4. **Backward Compatibility**: Must maintain old versions during transition periods

### Neutral

1. **Learning Curve**: Team must learn Serverpod protocol definition syntax
2. **Tooling**: Requires Serverpod CLI for code generation
3. **Testing**: Protocol changes require comprehensive integration testing

## Implementation Notes

### Protocol Definition Location

```
docs/
├── protocol/
│   └── v1/
│       ├── models.yaml       # Data model definitions
│       └── endpoints.md      # Endpoint contracts
└── adr/
    └── 0001-serverpod-protocol-v1.md  # This document
```

### Code Generation Command

```bash
serverpod generate
```

This generates:
- `server/lib/src/protocol/` - Server-side protocol classes
- `client/lib/src/protocol/` - Client-side protocol classes

### Version Header

Clients should include version in requests:

```
Accept: application/vnd.chatapp.v1+json
```

Server validates version and returns `406 Not Acceptable` for unsupported versions.

### Deprecation Policy

When introducing breaking changes:

1. Announce deprecation in v1.x with warnings
2. Maintain v1 for at least 6 months after v2 release
3. Provide migration guide in documentation
4. Use feature flags to enable gradual rollout

## Alternatives Considered

### 1. GraphQL

**Pros:**
- Flexible querying
- Strong typing with schema
- Single endpoint

**Cons:**
- Overhead for simple operations
- Complexity for real-time subscriptions
- Less idiomatic for Serverpod

**Decision:** Rejected - REST + WebSocket is simpler and more aligned with Serverpod's strengths.

### 2. gRPC

**Pros:**
- High performance
- Strong typing with Protocol Buffers
- Bidirectional streaming

**Cons:**
- Limited browser support (requires gRPC-Web)
- More complex tooling
- Less human-readable

**Decision:** Rejected - WebSocket provides sufficient performance with better browser compatibility.

### 3. Custom JSON API (No Code Generation)

**Pros:**
- Maximum flexibility
- No build-time dependencies

**Cons:**
- Runtime type errors
- Manual serialization/deserialization
- No compile-time validation

**Decision:** Rejected - Type safety is critical for production quality.

## Related Decisions

- ADR-0002: End-to-End Encryption Architecture (planned)
- ADR-0003: Offline-First Sync Strategy (planned)
- ADR-0004: Multi-Device Key Management (planned)

## References

- [Serverpod Documentation](https://docs.serverpod.dev/)
- [Protocol Definition Guide](https://docs.serverpod.dev/concepts/protocol)
- [Semantic Versioning](https://semver.org/)
- Requirements 2.4, 2.10, 24.7 in `requirements.md`

---

**Approved by:** Backend Team, Frontend Team  
**Implementation Status:** Complete  
**Next Review:** Upon protocol v2 planning
