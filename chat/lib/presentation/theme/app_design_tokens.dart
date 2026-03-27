import 'package:flutter/material.dart';

class AppDesignTokens {
  // Colors (Velvet Shadows Palette)
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceTransparent = Color(0xCC1A1A1A); // 80% Opacity
  static const Color accentGlow = Color(0xFF2D1F16); // Warmer brown glow
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E8E);
  static const Color accent = Color(0xFFFFFFFF);
  static const Color bronzeAccent = Color(
    0xFFCD7F32,
  ); // Seen in alternate inbox

  /// Onboarding / marketing amber–orange glow (reference UI).
  static const Color onboardingAmber = Color(0xFFE8A54B);
  static const Color onboardingOrange = Color(0xFFE07020);
  static const Color onboardingGlowDeep = Color(0xFF2A1810);
  static const double onboardingGlassRadius = 28.0;
  static const double onboardingPillHeight = 56.0;

  // Glassmorphism
  static const double blurSigma = 10.0;

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  /// Web / tablet: primary content column and optional secondary pane (MVP plan).
  static const double breakpointCompact = 600;
  static const double breakpointMedium = 900;
  static const double contentMaxWidth = 560;
  static const double wideLayoutMinWidth = 960;
  static const double sidePaneMinWidth = 320;

  // Effects
  static final List<BoxShadow> softGlow = [
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.1),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
}
