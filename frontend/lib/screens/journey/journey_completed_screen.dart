import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';

class JourneyCompletedScreen extends StatelessWidget {
  const JourneyCompletedScreen({super.key});

  // Temporary values
  // Later these will come from Firebase.

  final String guardianMessage = 'Mom has been notified.';

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
                    children: [

                      const SizedBox(height: 95),

                      const Text(
                        'Yay.! Journey Completed!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'You Reached your Destination Safely !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 45),

                      Image.asset(
                        'assets/images/journey_completed.png',
                        height: 280,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 45),

                      GlassCard(
                        child: Column(
                          children: [

                            const Text(
                              'Guardians Notified',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Text(
                              guardianMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              '"Every safe journey is a step\n'
                              'towards a safer tomorrow."',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),

                          ],
                        ),
                      ),

                      const SizedBox(height: 35),

                      PrimaryButton(
                        text: 'Return Home',
                        width: 220,
                        onPressed: () {},
                      ),

                      const SizedBox(height: 100),

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
                // Navigate to Profile
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

        ],
      ),
    );
  }
}