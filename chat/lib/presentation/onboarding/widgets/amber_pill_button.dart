import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_design_tokens.dart';

class AmberGradientPillButton extends StatelessWidget {
  const AmberGradientPillButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(100),
        child: Ink(
          height: AppDesignTokens.onboardingPillHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppDesignTokens.onboardingAmber,
                AppDesignTokens.onboardingOrange,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppDesignTokens.onboardingAmber.withValues(alpha: 0.45),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppDesignTokens.onboardingOrange.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
