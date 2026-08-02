import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';

class SosActiveScreen extends StatelessWidget {
  const SosActiveScreen({super.key});

  // Temporary values
  // Later these will come from backend.

  final String status = "SOS Activated";

  final int guardiansNotified = 3;

  final String locationStatus = "Live Location Shared";

  final String emergencyServices = "Notified";

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

                    const Text(
                      "Emergency SOS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "PlayfairDisplay",
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                      ),
                    ),

                    const SizedBox(height: 35),

                    Image.asset(
                      "assets/images/sos_screen.png",
                      height: 220,
                    ),

                    const SizedBox(height: 30),

                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Status : $status",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            "Guardians Notified : $guardiansNotified",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            "Location : $locationStatus",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            "Emergency Services : $emergencyServices",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 30),

                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 1.5,
                                ),
                              ),
                              child: const Text(
                                "SOS Sent Successfully",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          Center(
                            child: PrimaryButton(
                              text: "Back to Home",
                              width: 220,
                              onPressed: () {
                                // Navigate to Home Screen
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),

                  ],
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