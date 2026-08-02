import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';
import 'add_guardian_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class GuardianSetupScreen extends StatelessWidget {
  const GuardianSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          const NightSky(),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [

                    const SizedBox(height: 90),

                    Text(
                      'Choose Guardian',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Choose someone you trust. They'll be\nnotified if you ever need help.\nYou can change this anytime !",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Image.asset(
                      'assets/images/guardian_screen.png',
                      height: 260,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 20),

                    GlassCard(
                      child: Column(
                        children: [

                          const SizedBox(height: 20),

                          PrimaryButton(
                            text: 'Add Guardians',
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddGuardianScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 36),

                          const Text(
                            'Only your Guardian receives\njourney alerts.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          TextButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HomeScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Not Now',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.heading,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(),
                    ),
                  );
              },
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF8EB6D8),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}