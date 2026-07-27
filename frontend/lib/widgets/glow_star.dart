import 'package:flutter/material.dart';

class GlowStar extends StatelessWidget {
  final double top;
  final double? left;
  final double? right;
  final double size;

  const GlowStar({
    super.key,
    required this.top,
    this.left,
    this.right,
    this.size = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: size * 3,
              spreadRadius: size * 0.4,
            ),
          ],
        ),
      ),
    );
  }
}