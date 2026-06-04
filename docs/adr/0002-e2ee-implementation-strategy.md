# ADR-0002: E2EE Implementation Strategy (X25519 + ChaCha20-Poly1305)

**Status:** Accepted  
**Date:** 2024  
**Deciders:** Security Team, Backend Team, Frontend Team  
**Technical Story:** Production-Ready Privacy-Focused Chat Platform

## Context

The chat platform requires end-to-end encryption (E2EE) for all communications to ensure that only intended recipients can read messages, and the server cannot access plaintext content. The E2EE system must support:

1. Strong cryptographic primitives with proven security
2. Forward secrecy to protect past messages if keys are compromised
3. Multi-device support with per-device encryption keys
4. Efficient key exchange and session establishment
5. Group chat encryption without exponential overhead
6. Media file encryption with the same security guarantees
7. Compatibility with Flutter's cryptography ecosystem
8. Performance suitable for mobile devices

## Decision

We will implement **E2EE using X25519 key exchange and ChaCha20-Poly1305 AEAD encryption** with the following architecture:

### 1. Cryptographic Primitives

**Key Exchange:**
- **X25519** (Elliptic Curve Diffie-Hellman on Curve25519)
- Provides 128-bit security level
- Fast and constant-time implementation
- Widely supported and audited

**Encryption:**
- **ChaCha20-Poly1305** (AEAD - Authenticated Encryption with Associated Data)
- Provides confidentiality and authenticity
- Fast on mobile devices without hardware AES
- Resistant to timing attacks
- 256-bit keys, 96-bit nonces

**Hashing:**
- **SHA-256** for key derivation (HKDF)
- **HMAC-SHA256** for message authentication

**Signing:**
- **Ed25519** for identity key signatures
- Same curve family as X25519 for efficiency

### 2. Key Hierarchy

```
Identity Key Pair (Ed25519)
├── Signed Prekey Pair (X25519) - rotated every 30 days
└── One-Time Prekeys (X25519) - single-use, batch of 100

Session Key (derived from ECDH)
└── Message Keys (derived per message)
```

**Identity Key Pair (IK):**
- Long-term Ed25519 key pair
- Generated once per device during registration
- Public key uploaded to server
- Private key stored in flutter_secure_storage
- Used to sign prekeys for authenticity

**Signed Prekey Pair (SPK):**
- Medium-term X25519 key pair
- Rotated every 30 days for security hygiene
- Signed by identity key to prevent impersonation
- Public key + signature uploaded to server

**One-Time Prekeys (OPK):**
- Short-term X25519 key pairs
- Generated in batches of 100
- Each consumed once during session establishment
- Provides forward secrecy
- Server replenishes when count < 20

**Session Key:**
- Derived from multiple ECDH operations using HKDF
- Unique per conversation pair (Alice ↔ Bob)
- Used to derive per-message keys

**Message Keys:**
- Derived from session key + message counter
- Unique per message
- Provides forward secrecy at message level

### 3. Session Establishment (X3DH Protocol)

When Alice wants to message Bob for the first time:

1. **Fetch Key Bundle**: Alice retrieves Bob's public keys from server
   - Identity key (IK_B)
   - Signed prekey (SPK_B) + signature
   - One one-time prekey (OPK_B)

2. **Verify Signature**: Alice verifies SPK_B signature using IK_B

3. **Compute Shared Secret**: Alice performs 4 ECDH operations
   ```
   DH1 = ECDH(IK_A, SPK_B)
   DH2 = ECDH(SPK_A, IK_B)
   DH3 = ECDH(SPK_A, SPK_B)
   DH4 = ECDH(SPK_A, OPK_B)  // Only if OPK available
   ```

4. **Derive Session Key**: Use HKDF to derive session key
   ```
   SK = HKDF(DH1 || DH2 || DH3 || DH4, salt, info)
   ```

5. **Encrypt Message**: Use SK to derive message key and encrypt

6. **Send Initial Message**: Include Alice's identity key and ephemeral key

Bob can compute the same shared secret using his private keys and Alice's public keys.

### 4. Message Encryption Flow

For each message:

1. **Derive Message Key**: 
   ```
   message_key = HKDF(session_key, message_counter, "message_key")
   nonce = HKDF(session_key, message_counter, "nonce")[0:12]
   ```

2. **Encrypt with ChaCha20-Poly1305**:
   ```
   ciphertext = ChaCha20-Poly1305.encrypt(
     key: message_key,
     nonce: nonce,
     plaintext: message_content,
     associated_data: message_metadata
   )
   ```

3. **Store Ciphertext**: Server stores only ciphertext, never plaintext

4. **Increment Counter**: Increment message counter for next message

### 5. Group Chat Encryption (Sender Keys)

For group chats, we use the **Sender Keys** pattern to avoid encrypting the message N times:

1. **Sender generates symmetric key**: Random 256-bit key for this message
2. **Encrypt message once**: Using ChaCha20-Poly1305 with symmetric key
3. **Encrypt key for each recipient**: Encrypt symmetric key using each recipient device's session key
4. **Server stores**: One ciphertext + N encrypted key copies
5. **Recipients decrypt**: Each recipient decrypts their key copy, then decrypts message

This reduces bandwidth from O(N × message_size) to O(message_size + N × key_size).

### 6. Media File Encryption

Media files are encrypted before upload:

1. **Generate random key**: 256-bit symmetric key
2. **Encrypt file**: ChaCha20-Poly1305 with random key
3. **Upload encrypted file**: To S3 or storage backend
4. **Send message**: Include encrypted key in message ciphertext
5. **Recipient decrypts**: Decrypt message to get key, download file, decrypt file

### 7. Key Storage

**Client-Side (flutter_secure_storage):**
- Identity key pair (private key only)
- Signed prekey pair (private key only)
- One-time prekey pairs (private keys only)
- Session keys (indexed by conversation ID)

**Server-Side (PostgreSQL):**
- Identity key (public key only)
- Signed prekey (public key + signature)
- One-time prekeys (public keys only)
- No private keys or session keys ever stored on server

### 8. Key Rotation

**Signed Prekey Rotation:**
- Every 30 days, generate new SPK
- Sign with identity key
- Upload to server
- Keep old SPK for 7 days for in-flight messages

**One-Time Prekey Replenishment:**
- Monitor OPK count on server
- When count < 20, generate 100 new OPKs
- Upload batch to server

**Identity Key Rotation:**
- Only on device revocation or security incident
- Requires re-establishing all sessions

### 9. Forward Secrecy

Forward secrecy is achieved through:

1. **One-Time Prekeys**: Each session uses a unique OPK that is deleted after use
2. **Message Key Derivation**: Each message uses a unique derived key
3. **Key Deletion**: Old message keys are deleted after use
4. **Session Ratcheting**: Future enhancement for Double Ratchet algorithm

If an attacker compromises current keys, they cannot decrypt past messages because:
- OPKs used for past sessions are deleted
- Message keys are derived and deleted per message
- Session keys are not stored long-term

### 10. Implementation Libraries

**Flutter/Dart:**
- `cryptography` package (Dart-native, well-maintained)
  - X25519 key exchange
  - ChaCha20-Poly1305 AEAD
  - Ed25519 signatures
  - HKDF key derivation
- `flutter_secure_storage` for key storage
- `pointycastle` as fallback for additional primitives

**Serverpod:**
- `cryptography` package for signature verification
- No encryption/decryption on server (only stores ciphertext)

## Consequences

### Positive

1. **Strong Security**: X25519 and ChaCha20-Poly1305 are modern, audited, and recommended by cryptographers
2. **Forward Secrecy**: One-time prekeys ensure past messages remain secure even if current keys are compromised
3. **Mobile Performance**: ChaCha20 is faster than AES on devices without hardware acceleration
4. **Constant-Time**: Curve25519 operations are constant-time, resistant to timing attacks
5. **Multi-Device Support**: Per-device keys enable seamless multi-device encryption
6. **Group Efficiency**: Sender Keys pattern reduces bandwidth for group chats
7. **Dart Ecosystem**: `cryptography` package is pure Dart, works on all platforms
8. **Server Blindness**: Server never sees plaintext, only ciphertext and public keys

### Negative

1. **Complexity**: E2EE adds significant complexity to message flow
2. **Key Management**: Requires careful handling of key lifecycle and rotation
3. **Debugging**: Encrypted messages are harder to debug in production
4. **Initial Latency**: First message requires key bundle fetch and ECDH computation
5. **Storage Overhead**: Each device stores session keys for all conversations
6. **Group Overhead**: Group messages require N key encryptions (though message is encrypted once)

### Neutral

1. **No Hardware AES**: ChaCha20 doesn't benefit from AES-NI, but performs well without it
2. **Key Rotation**: Requires periodic background tasks for prekey rotation
3. **Compatibility**: X25519/ChaCha20 are widely supported but not universal (e.g., older systems)

## Implementation Notes

### Key Generation Example

```dart
import 'package:cryptography/cryptography.dart';

class CryptoService {
  final algorithm = Chacha20.poly1305Aead();
  
  // Generate identity key pair (Ed25519)
  Future<SimpleKeyPair> generateIdentityKeyPair() async {
    final ed25519 = Ed25519();
    return await ed25519.newKeyPair();
  }
  
  // Generate signed prekey pair (X25519)
  Future<SimpleKeyPair> generateSignedPrekeyPair() async {
    final x25519 = X25519();
    return await x25519.newKeyPair();
  }
  
  // Generate one-time prekey
  Future<SimpleKeyPair> generateOneTimePrekey() async {
    final x25519 = X25519();
    return await x25519.newKeyPair();
  }
  
  // Sign prekey with identity key
  Future<Signature> signPrekey(
    SimplePublicKey prekeyPublic,
    SimpleKeyPair identityKeyPair,
  ) async {
    final ed25519 = Ed25519();
    final prekeyBytes = await prekeyPublic.extractBytes();
    return await ed25519.sign(prekeyBytes, keyPair: identityKeyPair);
  }
}
```

### Message Encryption Example

```dart
// Encrypt message
Future<String> encryptMessage(
  String plaintext,
  SecretKey sessionKey,
  int messageCounter,
) async {
  // Derive message key and nonce
  final hkdf = Hkdf(hmac: Hmac(Sha256()), outputLength: 32);
  final messageKey = await hkdf.deriveKey(
    secretKey: sessionKey,
    nonce: [messageCounter],
    info: utf8.encode('message_key'),
  );
  
  final nonceBytes = await hkdf.deriveKey(
    secretKey: sessionKey,
    nonce: [messageCounter],
    info: utf8.encode('nonce'),
  );
  final nonce = (await nonceBytes.extractBytes()).sublist(0, 12);
  
  // Encrypt with ChaCha20-Poly1305
  final secretBox = await algorithm.encrypt(
    utf8.encode(plaintext),
    secretKey: messageKey,
    nonce: nonce,
  );
  
  // Return base64-encoded ciphertext
  return base64.encode(secretBox.concatenation());
}
```

### Key Storage Example

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyManager {
  final storage = FlutterSecureStorage();
  
  // Store identity key pair
  Future<void> storeIdentityKeyPair(SimpleKeyPair keyPair) async {
    final privateKey = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    final publicKeyBytes = await publicKey.extractBytes();
    
    await storage.write(
      key: 'identity_private_key',
      value: base64.encode(privateKey),
    );
    await storage.write(
      key: 'identity_public_key',
      value: base64.encode(publicKeyBytes),
    );
  }
  
  // Retrieve identity key pair
  Future<SimpleKeyPair?> getIdentityKeyPair() async {
    final privateKeyStr = await storage.read(key: 'identity_private_key');
    if (privateKeyStr == null) return null;
    
    final privateKeyBytes = base64.decode(privateKeyStr);
    return SimpleKeyPairData(
      privateKeyBytes,
      publicKey: SimplePublicKey(
        base64.decode(await storage.read(key: 'identity_public_key') ?? ''),
        type: KeyPairType.ed25519,
      ),
      type: KeyPairType.ed25519,
    );
  }
}
```

## Security Considerations

### Threat Model

**Protected Against:**
- Server compromise (server never sees plaintext)
- Network eavesdropping (TLS + E2EE)
- Man-in-the-middle (identity key verification)
- Replay attacks (nonces and message counters)
- Message tampering (Poly1305 authentication)
- Forward compromise (one-time prekeys)

**Not Protected Against:**
- Client device compromise (malware with root access)
- User sharing plaintext screenshots
- Compromised client application
- Social engineering attacks

### Key Verification

Users should verify identity keys out-of-band (e.g., QR code scanning, safety numbers) to prevent man-in-the-middle attacks. This is a future enhancement.

### Quantum Resistance

X25519 and ChaCha20 are not quantum-resistant. Future migration to post-quantum algorithms (e.g., Kyber, Dilithium) may be necessary when quantum computers become practical.

## Alternatives Considered

### 1. Signal Protocol (Double Ratchet)

**Pros:**
- Industry standard (used by Signal, WhatsApp)
- Provides post-compromise security
- Continuous key ratcheting

**Cons:**
- More complex implementation
- Requires state synchronization across devices
- Overkill for initial MVP

**Decision:** Deferred to future enhancement. Current X3DH provides strong security with simpler implementation.

### 2. AES-GCM Instead of ChaCha20-Poly1305

**Pros:**
- Hardware acceleration on devices with AES-NI
- Widely supported standard

**Cons:**
- Slower on mobile devices without AES-NI
- Vulnerable to timing attacks without constant-time implementation
- Nonce reuse is catastrophic

**Decision:** Rejected. ChaCha20-Poly1305 is faster on mobile and more resistant to implementation errors.

### 3. RSA Key Exchange

**Pros:**
- Well-known and widely deployed
- Simple conceptual model

**Cons:**
- Slower than elliptic curve cryptography
- Larger key sizes (2048-bit minimum)
- No forward secrecy without additional mechanisms
- Vulnerable to quantum computers

**Decision:** Rejected. X25519 is faster, smaller, and provides better security properties.

### 4. Matrix/Olm Protocol

**Pros:**
- Designed for decentralized systems
- Supports group encryption
- Open standard

**Cons:**
- Complex implementation
- Requires Megolm for group chats
- Less mature Dart ecosystem

**Decision:** Rejected. X3DH + Sender Keys is simpler and sufficient for our needs.

## Related Decisions

- ADR-0001: Serverpod Protocol v1 Definition
- ADR-0003: Firebase ID Token to Serverpod Session Exchange Flow
- ADR-0006: Multi-Device Key Distribution

## References

- [X25519 Specification (RFC 7748)](https://datatracker.ietf.org/doc/html/rfc7748)
- [ChaCha20-Poly1305 (RFC 8439)](https://datatracker.ietf.org/doc/html/rfc8439)
- [X3DH Key Agreement Protocol](https://signal.org/docs/specifications/x3dh/)
- [Dart cryptography Package](https://pub.dev/packages/cryptography)
- Requirements 1.1-1.10, 6.2, 6.4 in `requirements.md`

---

**Approved by:** Security Team, Backend Team, Frontend Team  
**Implementation Status:** In Progress  
**Next Review:** After security audit
