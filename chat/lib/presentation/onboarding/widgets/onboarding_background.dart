import 'package:flutter/material.dart';

import '../../theme/app_design_tokens.dart';

/// Layered dark base + amber radial glows (procedural, responsive).
class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppDesignTokens.background),
        // Upper-center warm nebula
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.55),
              radius: 1.15,
              colors: [
                Color(0x664D2A12),
                Color(0x332A1810),
                Colors.transparent,
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),
        // Amber orb behind headlines
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.35),
              radius: 0.85,
              colors: [
                Color(0x55E8A54B),
                Color(0x22E07020),
                Colors.transparent,
              ],
              stops: [0.0, 0.35, 1.0],
            ),
          ),
        ),
        // Bottom-right secondary glow
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.85, 0.75),
              radius: 1.0,
              colors: [
                Color(0x40CC6633),
                Color(0x101A0A06),
                Colors.transparent,
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
