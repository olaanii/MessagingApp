import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? blur;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.blur,
    this.color,
    this.borderColor,
    this.borderWidth = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final velvet = Theme.of(context).extension<VelvetShadowsExtension>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blur ?? velvet?.glassBlur ?? 10.0,
          sigmaY: blur ?? velvet?.glassBlur ?? 10.0,
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color:
                color ??
                velvet?.surfaceTransparent ??
                Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(borderRadius ?? 16.0),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.1),
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlossyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? color;

  const GlossyButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: (color ?? Colors.white).withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
