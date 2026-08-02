import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 7,
          sigmaY: 7,
        ),
        child: Container(
          width: double.infinity,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08), // <-- White glass
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: const Color(0xFFA78BFA).withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}