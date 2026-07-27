import 'package:flutter/material.dart';

import '../config/colors.dart';
import 'glass_card.dart';
import 'primary_button.dart';

class GuardianCard extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final String buttonText;
  final VoidCallback onPressed;

  const GuardianCard({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
       padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 10,
       ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            name,
            style: const TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.heading,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            phoneNumber,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 7),

          Center(
            child: PrimaryButton(
              text: buttonText,
              width: 120,
              fontSize: 18,
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}