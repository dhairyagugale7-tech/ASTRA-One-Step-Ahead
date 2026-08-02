import 'package:flutter/material.dart';

class SOSButton extends StatelessWidget {
  final VoidCallback? onTap;

  const SOSButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD79AE8),
              Color(0xFFB978D4),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD79AE8).withValues(alpha: 0.45),
              blurRadius: 35,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'SoS',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}