import 'package:flutter/material.dart';
import '../config/colors.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontFamily: 'PlusJakartaSans',
        ),
        decoration: InputDecoration(
          hintText: hintText,

          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 17,
            fontFamily: 'PlusJakartaSans',
          ),

          filled: true,
          fillColor: AppColors.glassWhite.withValues(alpha: 0.05),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: BorderSide(
              color: AppColors.purpleBorder.withValues(alpha: 0.25),
              width: 1,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: BorderSide(
              color: AppColors.purpleBorder.withValues(alpha: 0.55),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}