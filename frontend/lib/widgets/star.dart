import 'package:flutter/material.dart';

class Star extends StatelessWidget {
  final double top;
  final double? left;
  final double? right;
  final double size;

  const Star({
    super.key,
    required this.top,
    this.left,
    this.right,
    this.size = 4,
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
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}