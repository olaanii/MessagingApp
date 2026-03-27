# ADR-0006: E2EE — MVP scope vs Phase 2

## Status

Accepted

## Decision

### Server trust boundary

- Server stores **ciphertext**, routing metadata, and **public** key bundles only.
- Server **never** stores usable private keys or decrypted plaintext.

### MVP

- **Per-chat symmetric key** or **simplified X25519/HKDF** session establishment + AEAD — **concrete algorithms and wire layout:** [ADR-0008](0008-e2ee-crypto-suite-key-lifecycle.md). **Not** full Signal Double Ratchet for MVP unless schedule allows.
- **Forward secrecy:** partial by design until Phase 2; document honestly in app copy.

### Phase 2

- **Double Ratchet** (or equivalent) for stronger PCS/FS; cross-device key sync / recovery UX.

### Client storage

- Private keys and session state in **`flutter_secure_storage`**.

### Testing

- Staging tests **fail** if plaintext appears in DB columns or structured logs for message content.

## Consequences

- Product must avoid “Signal-class” claims until Phase 2 deliverables land.
