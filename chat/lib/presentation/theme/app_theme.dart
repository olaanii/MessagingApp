import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_design_tokens.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppDesignTokens.accent,
      primary: AppDesignTokens.accent,
      surface: AppDesignTokens.surface,
      onSurface: AppDesignTokens.textPrimary,
      onSurfaceVariant: AppDesignTokens.textSecondary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          Colors.transparent, // Allow ShadowBackground to show
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppDesignTokens.textPrimary,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppDesignTokens.textPrimary,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          color: AppDesignTokens.textPrimary,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: AppDesignTokens.textSecondary,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppDesignTokens.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppDesignTokens.accent,
          foregroundColor: AppDesignTokens.background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppDesignTokens.surface.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(
            color: AppDesignTokens.accent,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      extensions: [
        VelvetShadowsExtension(
          glassBlur: AppDesignTokens.blurSigma,
          surfaceTransparent: AppDesignTokens.surfaceTransparent,
          primaryGlow: AppDesignTokens.softGlow.first.color,
        ),
      ],
    );
  }

  static ThemeData get lightTheme => darkTheme;
}

class VelvetShadowsExtension extends ThemeExtension<VelvetShadowsExtension> {
  final double glassBlur;
  final Color surfaceTransparent;
  final Color primaryGlow;

  VelvetShadowsExtension({
    required this.glassBlur,
    required this.surfaceTransparent,
    required this.primaryGlow,
  });

  @override
  VelvetShadowsExtension copyWith({
    double? glassBlur,
    Color? surfaceTransparent,
    Color? primaryGlow,
  }) {
    return VelvetShadowsExtension(
      glassBlur: glassBlur ?? this.glassBlur,
      surfaceTransparent: surfaceTransparent ?? this.surfaceTransparent,
      primaryGlow: primaryGlow ?? this.primaryGlow,
    );
  }

  @override
  VelvetShadowsExtension lerp(
    ThemeExtension<VelvetShadowsExtension>? other,
    double t,
  ) {
    if (other is! VelvetShadowsExtension) return this;
    return VelvetShadowsExtension(
      glassBlur: lerpDouble(glassBlur, other.glassBlur, t) ?? glassBlur,
      surfaceTransparent:
          Color.lerp(surfaceTransparent, other.surfaceTransparent, t) ??
          surfaceTransparent,
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t) ?? primaryGlow,
    );
  }

  double? lerpDouble(num? a, num? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }
}
