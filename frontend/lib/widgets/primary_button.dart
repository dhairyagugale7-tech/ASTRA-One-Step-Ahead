import 'package:flutter/material.dart';

import '../config/colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double fontSize;
  final double width;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize = 22,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 50,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),

        child: Ink(
                decoration: BoxDecoration(
                  gradient: onPressed == null
                      ? LinearGradient(
                          colors: [
                            AppColors.buttonGradientStart.withValues(alpha: 0.5),
                            AppColors.buttonGradientEnd.withValues(alpha: 0.5),
                          ],
                        )
                      : const LinearGradient(
                          colors: [
                            AppColors.buttonGradientStart,
                            AppColors.buttonGradientEnd,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Container(
                  alignment: Alignment.center,

                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}