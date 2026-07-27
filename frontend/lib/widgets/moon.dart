import 'package:flutter/material.dart';
import '../config/colors.dart';

class Moon extends StatelessWidget {
  const Moon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.moon,
                shape: BoxShape.circle,
              ),
            ),
          );
  }
}