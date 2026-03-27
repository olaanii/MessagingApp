/// Phase 2 only: opt-in AI surfaces (translation, summaries).
///
/// ADR-0010 (`docs/adr/0010-phase2-ai-privacy-opt-in.md`): no production
/// implementation until legal/product sign-off. Inject [NoOpPhase2AiService] in Phase 1.
abstract class Phase2AiService {
  /// Server-backed preference, e.g. `users.ai_translation_enabled`.
  Future<bool> isTranslationEnabled();

  /// User toggles translation; persists via app data layer when Phase 2 ships.
  Future<void> setTranslationEnabled(bool enabled);

  /// Preview translation before send (plaintext only on client; never in Phase 1 impl).
  Future<Phase2TranslationResult?> previewTranslate({
    required String text,
    required String targetLocale,
  });

  /// Optional thread summary on explicit user action.
  Future<Phase2SummaryResult?> summarizeThread({
    required String chatId,
    required List<String> plaintextExcerpts,
  });
}

class Phase2TranslationResult {
  const Phase2TranslationResult({
    required this.sourceText,
    required this.translatedText,
    required this.targetLocale,
  });

  final String sourceText;
  final String translatedText;
  final String targetLocale;
}

class Phase2SummaryResult {
  const Phase2SummaryResult({required this.summary, required this.chatId});

  final String summary;
  final String chatId;
}

/// Default Phase 1 implementation: AI disabled, no I/O.
class NoOpPhase2AiService implements Phase2AiService {
  const NoOpPhase2AiService();

  @override
  Future<bool> isTranslationEnabled() async => false;

  @override
  Future<void> setTranslationEnabled(bool enabled) async {}

  @override
  Future<Phase2TranslationResult?> previewTranslate({
    required String text,
    required String targetLocale,
  }) async =>
      null;

  @override
  Future<Phase2SummaryResult?> summarizeThread({
    required String chatId,
    required List<String> plaintextExcerpts,
  }) async =>
      null;
}
