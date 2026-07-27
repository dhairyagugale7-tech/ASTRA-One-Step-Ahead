import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';

class JourneySetupScreen extends StatelessWidget {
  JourneySetupScreen({super.key});

  final String selectedGuardians = 'No Guardians Selected';

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
                        'Prepare Guardian Journey',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Before we begin....',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 40),

                      GlassCard(
                        child: Column(
                          children: [

                            const CustomTextField(
                              hintText: 'Where Are You Going?',
                            ),

                            const SizedBox(height: 20),

                            GestureDetector(
                              onTap: () {
                                // Navigate to Guardian Selection Screen
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white24,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Select Guardians',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                children: [

                                  const Text(
                                    'Selected Guardians',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  Text(
                                    selectedGuardians,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 18,
                                      color: Colors.white70,
                                    ),
                                  ),

                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            CheckboxListTile(
                              value: true,
                              onChanged: (_) {},
                              activeColor: Colors.white,
                              checkColor: AppColors.buttonGradientStart,
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Share Live Location',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            CheckboxListTile(
                              value: true,
                              onChanged: (_) {},
                              activeColor: Colors.white,
                              checkColor: AppColors.buttonGradientStart,
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Enable Smart Check-ins',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            PrimaryButton(
                              text: 'Start Guardian Journey',
                              width: 260,
                              onPressed: () {},
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

          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // Navigate to Profile Screen
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

        ],
      ),
    );
  }
}