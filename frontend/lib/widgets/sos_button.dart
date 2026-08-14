import 'dart:async';

import 'package:flutter/material.dart';

class SOSButton extends StatefulWidget {
  final VoidCallback? onSOS;

  const SOSButton({
    super.key,
    this.onSOS,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> {
  Timer? _sosTimer;

  bool _isHolding = false;

  void _startHolding() {
    setState(() {
      _isHolding = true;
    });

    _sosTimer = Timer(const Duration(seconds: 3), () {
      if (!_isHolding) return;

      widget.onSOS?.call();

      setState(() {
        _isHolding = false;
      });
    });
  }

  void _stopHolding() {
    _sosTimer?.cancel();
    _sosTimer = null;

    if (mounted) {
      setState(() {
        _isHolding = false;
      });
    }
  }

  @override
  void dispose() {
    _sosTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _startHolding();
      },
      onTapUp: (_) {
        _stopHolding();
      },
      onTapCancel: () {
        _stopHolding();
      },
      child: AnimatedScale(
        scale: _isHolding ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 150),
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
          child: Center(
            child: Text(
              _isHolding ? 'HOLD...' : 'SoS',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}