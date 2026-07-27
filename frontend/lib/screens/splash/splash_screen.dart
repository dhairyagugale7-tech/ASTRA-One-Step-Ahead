import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../widgets/nightsky.dart';

import 'dart:async';

import '../auth/auth_wrapper.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthWrapper(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          const NightSky(),

          Center(
            child : Padding(
              padding: const EdgeInsets.only(top: 250),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ASTRA',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stay  One  Step  Ahead',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 170),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            ),
          ),

        ],
      ),
    );
  }
}