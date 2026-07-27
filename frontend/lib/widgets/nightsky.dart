import 'package:flutter/material.dart';

import 'app_background.dart';
import 'moon.dart';
import 'star_field.dart';

class NightSky extends StatelessWidget {
  final double moonTop;
  final double moonRight;

  const NightSky({
    super.key,
    this.moonTop = 75,
    this.moonRight = 55,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AppBackground(),

        Positioned(
          top: moonTop,
          right: moonRight,
          child: const Moon(),
        ),

        const StarField(),
      ],
    );
  }
}