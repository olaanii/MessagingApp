# ADR-0008: E2EE crypto suite, key lifecycle, forward secrecy (MVP), recovery

## Status

Accepted

## Context

ADR-0006 sets MVP vs Phase 2 scope. This ADR pins **algorithms**, **wire shapes**, **client storage**, and honest **forward secrecy** properties so Serverpod endpoints, Flutter repositories, and QA can align.

## Decision

### Algorithms (MVP)

| Use | Suite |
|-----|--------|
| Identity DH | **X25519** (`package:cryptography`) |
| KDF | **HKDF-SHA256** (empty salt, domain-specific `info` UTF-8 strings — see `lib/core/crypto/e2ee_constants.dart`) |
| Message / key-wrap AEAD | **ChaCha20-Poly1305** |
| Per-chat secret | **32-byte** key, random (`Cipher.newSecretKey` for ChaCha20-Poly1305) |

### Key roles

1. **Device identity (X25519)** — long-lived per device; **private** seed in `flutter_secure_storage` (`kSecureStorageIdentityX25519Seed`). **Public** 32 bytes in `PublicKeyBundle` via `KeyEndpoint.uploadBundle` (see `docs/protocol/v1/endpoints.md`).
2. **Chat symmetric key** — random 32 bytes; distributed to members by **wrap**: ephemeral X25519 + HKDF + AEAD over the chat key (`E2eeEngine.wrapChatKey` / `unwrapChatKey`). Server stores only wrapped blobs addressed by `chat_id` / membership rows (schema with architect).
3. **Message payload** — encrypt plaintext with chat key + random 12-byte nonce; RPC sends `ciphertext` (cipher **concat** Poly1305 tag), `nonce`, `schemaVersion` per protocol doc.

### Wire shapes (schema v1)

- **`MessageCryptoEnvelope`**: `schemaVersion == 1`, `nonce` (12 bytes), `ciphertextWithMac` (variable, ciphertext || 16-byte MAC).
- **`WrappedChatKeyEnvelope`**: `schemaVersion == 1`, `ephemeralPublic` (32 bytes), `nonce` (12 bytes), `ciphertextWithMac` (encrypted 32-byte chat key + MAC).
- **`PublicKeyBundle`**: `schemaVersion == 1`, `x25519Public` (32 bytes). Signed prekeys / one-time prekeys are **Phase 2** unless schedule pulls them into MVP.

### Forward secrecy (honest MVP statement)

- **Per-message forward secrecy:** **not** guaranteed in MVP (no Double Ratchet). Compromise of a chat symmetric key reveals all messages encrypted under that key until rotation.
- **Partial mitigation:** ephemeral X25519 for **wrapping** chat keys gives **forward secrecy for past wraps** only relative to static identity compromise (old wraps do not reveal chat keys to a passive archive of wraps if ephemeral private keys are destroyed — stored wraps remain, but new rotations use new ephemerals). Product copy must **not** claim Signal-class FS for message traffic until ADR Phase 2.

### Recovery / multi-device

- **MVP:** New device registers a new identity; existing members (or server-assisted “add device” flow) must deliver **fresh wrapped chat keys** to the new public key. No magic cross-device sync of private keys without user action.
- **Phase 2:** Optional encrypted backup, Double Ratchet, cross-device session continuity — separate ADR.

### Server trust boundary

Unchanged from ADR-0006: server sees ciphertext, routing metadata, and public keys only. **No** plaintext message logging in staging/prod; automated tests **fail** if message plaintext appears in DB or structured logs (policy in `docs/infra/staging-and-production.md`).

### Implementation map

- Client primitives: `lib/core/crypto/` (`E2eeEngine`, `E2eeIdentityStore`).
- Server: `KeyEndpoint`, message columns holding ciphertext + nonce + `schema_version` (Serverpod models per architect).

## Consequences

- Flutter **data layer** must call `E2eeEngine` **before** `MessageEndpoint.send`; no ciphertext construction in widgets.
- Rotation strategy for chat keys (membership change, periodic) is product + backend; share rotation uses the same wrap primitive.
- Updating `kE2eeSchemaVersion` or HKDF `info` strings is a **breaking** protocol change — bump schema / ADR and coordinate client + server.

## References

- ADR-0006 (MVP vs Phase 2)
- `docs/protocol/v1/endpoints.md` — `KeyEndpoint`, `MessageEndpoint`
- `test/e2ee_engine_test.dart` — roundtrip + auth failure coverage
