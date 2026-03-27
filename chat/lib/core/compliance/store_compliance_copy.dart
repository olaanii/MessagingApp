/// User-facing strings for block / report (App Store Guideline 1.2, Google Play UGC).
/// Optional: `--dart-define=MODERATION_CONTACT_EMAIL=support@example.com`
abstract final class StoreComplianceCopy {
  static const String moderationContactEmail = String.fromEnvironment(
    'MODERATION_CONTACT_EMAIL',
    defaultValue: '',
  );

  static const String blockActionTitle = 'Block';
  static const String reportActionTitle = 'Report';

  static const String blockDialogTitle = 'Block this user?';
  static const String blockDialogBody =
      'They won’t be able to message you. You can manage blocks in your account settings when available.';
  static const String blockConfirmButton = 'Block';
  static const String blockSuccessMessage =
      'You won’t receive new messages from this user.';

  static const String reportDialogTitle = 'Report this user';
  static const String reportReasonHint =
      'Briefly describe what happened (required).';
  static const String reportSubmitButton = 'Submit report';
  static const String cancelButton = 'Cancel';
  static const String reportSuccessMessage =
      'Thanks — we’ve received your report and will review it.';
  static const String reportValidationEmptyReason =
      'Please add a short reason so we can review.';

  static const String settingsSafetyTileTitle = 'Safety: report & block';
  static const String settingsSafetyTileSubtitle =
      'From a chat, open the menu (···) to block or report.';

  static const String settingsSafetyExplainerTitle = 'Report or block';
  static String get settingsSafetyExplainerBody {
    final buffer = StringBuffer(
      'You can block someone to stop them from contacting you, or report '
      'behavior that breaks our rules. Reports may include your account '
      'identifiers and recent context so our team can investigate.',
    );
    final email = moderationContactEmail.trim();
    if (email.isNotEmpty) {
      buffer.write(' For appeals or safety questions, contact: $email.');
    }
    return buffer.toString();
  }

  static const String settingsSafetyExplainerOk = 'OK';
}
