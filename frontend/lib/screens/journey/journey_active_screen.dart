import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/sos_button.dart';

class JourneyActiveScreen extends StatelessWidget {
  JourneyActiveScreen({super.key});

  // Temporary values
  // Later these will come from Firebase, Google Maps & AI.

  final String eta = '18 mins';
  final String destination = 'Phoenix Mall';
  final String selectedGuardian = 'Mom';
  final int aiScore = 92;
  final String aiStatus = 'Safe';

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

                      const SizedBox(height: 90),

                      const Text(
                        'Journey Active',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),

                      const SizedBox(height: 25),

                      Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA874C4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            'Live Map',
                            style: TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      GlassCard(
                        child: Center(
                          child: Text(
                            'ETA : $eta',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              'Destination : $destination',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 18),

                            Text(
                              'Selected Guardian : $selectedGuardian',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 18),

                            Text(
                              'AI Safety Analysis : $aiScore/100 ($aiStatus)',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),

                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      PrimaryButton(
                        text: 'Journey Completed',
                        width: 220,
                        onPressed: () {},
                        fontSize: 18,
                      ),

                      const SizedBox(height: 30),

                      const SOSButton(),

                      const SizedBox(height: 100),

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
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 32,
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