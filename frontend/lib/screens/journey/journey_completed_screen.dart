import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';
import '../home/home_screen.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/guardian_service.dart';

class JourneyCompletedScreen extends StatefulWidget {
  const JourneyCompletedScreen({super.key});

  @override
  State<JourneyCompletedScreen> createState() => _JourneyCompletedScreenState();
}

class _JourneyCompletedScreenState extends State<JourneyCompletedScreen> {
  // Temporary values
  // Primary guardian name
  String primaryGuardianName = '';

  String get guardianMessage {
    if (primaryGuardianName.isEmpty) {
      return 'Your primary guardian has been notified.';
    }

    return '$primaryGuardianName has been notified.';
  }

  @override
  void initState() {
    super.initState();
    loadPrimaryGuardian();
  }


  Future<void> loadPrimaryGuardian() async {
  try {
    final guardians = await GuardianService().getGuardians();

    final primaryGuardian = guardians.firstWhere(
      (guardian) => guardian.isPrimary == true,
    );

    if (!mounted) return;

    setState(() {
      primaryGuardianName = primaryGuardian.name;
    });
  } catch (e) {
    debugPrint('Error loading primary guardian: $e');
  }
}

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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
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