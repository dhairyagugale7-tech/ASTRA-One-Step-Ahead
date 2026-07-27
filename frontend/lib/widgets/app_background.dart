import 'package:flutter/material.dart';
import '../config/colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        gradient: RadialGradient(
          center: const Alignment(0.55, -0.95),
          radius: 2,
          colors: [
            AppColors.headerBackground,
            AppColors.background,
          ],
          stops: const [
            0.0,
            0.7,
          ],
        ),
      ),
    );
  }
}