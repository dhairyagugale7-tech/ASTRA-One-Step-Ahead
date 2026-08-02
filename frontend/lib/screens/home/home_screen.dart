import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/sos_button.dart';

import '../../screens/profile/profile_screen.dart';
import '../journey/journey_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  final int safetyScore = 100;
  final String safetyMessage = 'Safe to Travel...!';
  const HomeScreen({super.key});

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
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      const SizedBox(height: 110),

                      const Text(
                        'Good Evening, User!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Every Journey deserves a Guardian',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 40),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JourneySetupScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 85,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFC56CE8),
                                Color(0xFF734170),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Start Guardian Journey!',
                              style: TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.heading,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      GlassCard(
                        child: Column(
                          children: [

                            Text(
                              'AI Safety Score : $safetyScore',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(height: 18),

                            Text(
                              safetyMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),

                          ],
                        ),
                      ),

                      const SizedBox(height: 35),

                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 30),

                      const SOSButton(),

                      const SizedBox(height: 20),

                      const Text(
                        'Hold it for 3 seconds!',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 35),

                      GestureDetector(
                        onTap: () {
                          // Navigate to Guardian Management Screen
                        },
                        child: Container(
                          width: 150,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFC56CE8),
                                Color(0xFF734170),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Guardians',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF8EB6D8),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
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
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

        ],
      ),
    );
  }
}