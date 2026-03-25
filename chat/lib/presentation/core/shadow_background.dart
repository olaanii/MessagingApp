import 'package:flutter/material.dart';
import '../theme/app_design_tokens.dart';

class ShadowBackground extends StatelessWidget {
  final Widget child;

  const ShadowBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppDesignTokens.background,
        gradient: RadialGradient(
          center: Alignment(0, -0.8),
          radius: 1.5,
          colors: [AppDesignTokens.accentGlow, AppDesignTokens.background],
          stops: [0.0, 0.6],
        ),
      ),
      child: child,
    );
  }
}
