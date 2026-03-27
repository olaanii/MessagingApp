# ADR-0010: Phase 2 AI (translation / summaries) — opt-in, privacy boundary, flags

## Status

Accepted (preparation only — **no production AI in Phase 1**)

## Context

Product vision includes **opt-in** translation and thread summaries. Message bodies are **E2EE** ([ADR-0006](0006-e2ee-mvp-vs-phase2.md)); any server-assisted AI changes the trust model. Legal/product must sign off before implementation ships.

## Decision

### Default posture

- **No training on user message content** for model improvement unless explicitly disclosed, consented, and contractually allowed with the chosen provider.
- **No silent AI**: features are off until the user explicitly enables them and understands what data may leave the device.
- Phase 1 code may include **interfaces and flags only**; implementations remain behind gates (legal + feature flag).

### DPIA-style summary (engineering draft — not legal advice)

| Topic | Phase 2 target behavior |
|--------|-------------------------|
| **Purpose** | Optional translation of messages the user chooses to send or read; optional summaries of threads **the user explicitly requests** (not background mining). |
| **What may leave the device** | Only text processed **after** user opt-in and **per action** (e.g. “translate this message”, “summarize this chat”). For E2EE chats, plaintext exists only **client-side** until the user invokes AI; then decrypted plaintext (or a derived excerpt) is passed to the chosen processing path. | 
| **On-device vs server** | **Preferred path:** on-device inference when quality and size allow (platform ML / bundled model) — **no** message content to third parties. **Server path:** optional gateway to a vetted API; **only** with DPA, region, and retention terms documented. Hybrid: small excerpt client-side only; never log full threads in plaintext server-side. |
| **Metadata** | Request IDs, latency, error codes, **aggregated** usage counts may be logged; **not** message bodies in application logs. |
| **Retention** | Provider/API: **minimum** necessary for the request; config default **no storage** where API supports it. Internal: no long-term archive of AI inputs unless product explicitly requires and discloses. |
| **Provider choice** | Product selects one or more providers; settings should allow **provider visibility** (name, region) where feasible. |
| **Subprocessors** | Listed in privacy policy before GA of AI features. |

### Feature flags (design)

| Layer | Flag / field | Default | Notes |
|--------|----------------|---------|--------|
| **User preference (authoritative)** | `ai_translation_enabled` (boolean on `users` or `user_preferences` when Serverpod schema exists) | `false` | Synced to clients after login; drives UI visibility. |
| **Client guard** | Same value cached locally (e.g. Drift mirror) | `false` | Must match server; deny AI calls if mismatch. |
| **Build / rollout** | Optional remote config kill-switch (e.g. “ai_assistant_globally_disabled”) | off in Phase 1 | Emergency off without app release. |

Naming: use **`ai_translation_enabled`** as the primary per-user toggle for the first shipped AI surface; add **`ai_summaries_enabled`** (or a single `ai_assistant_enabled` with sub-toggles) when product defines UX.

### Stub API (Flutter)

- Contract lives in [`lib/core/ai/phase2_ai_service.dart`](../../lib/core/ai/phase2_ai_service.dart): `Phase2AiService` and `NoOpPhase2AiService` (always disabled).
- **No** network calls from this stub. Replace with a real implementation only after legal review and server/schema readiness.

### Serverpod (Phase 2+)

- Optional RPC e.g. `AiGateway.*` only if server-assisted path is chosen; requests carry **minimal** text, **no** bulk export of history.
- Rate limits and abuse controls align with [ADR-0007](0007-backend-security-rate-limits-abuse-audit.md).

## Consequences

- Product, legal, and security must approve provider, regions, and privacy copy before enabling non-no-op implementations.
- E2EE UX must clarify that **opt-in AI** requires decrypting content for that action wherever processing is not fully on-device.
- Telemetry for AI must go through the same redaction rules as messaging.

## Non-goals (Phase 1)

- Production translation/summarization models, prompts, or paid API wiring.
- Storing plaintext message bodies for “helpfulness” or training.
