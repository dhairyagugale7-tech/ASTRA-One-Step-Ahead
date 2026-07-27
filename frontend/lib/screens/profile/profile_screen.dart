import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';

import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  // Temporary Data
  // Later these values will come from Firebase.

  final String name = 'Dhairya Gugale';
  final String phoneNumber = '+91 9876543210';
  final String email = 'dhairya@gmail.com';
  final String primaryGuardian = 'Mom';

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
                        'My Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),

                      const SizedBox(height: 25),

                      Image.asset(
                        'assets/images/profile_screen.png',
                        height: 220,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 25),

                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              'Name : $name',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 18),

                            Text(
                              'Phone Number : $phoneNumber',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 18),

                            Text(
                              'Email : $email',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 18),

                            Text(
                              'Primary Guardian : $primaryGuardian',
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

                      const SizedBox(height: 28),

                      PrimaryButton(
                        text: 'Manage Guardians',
                        width: 300,
                        onPressed: () {
                          // Navigate to Guardian Management
                        },
                      ),

                      const SizedBox(height: 18),

                      PrimaryButton(
                        text: 'Edit Profile',
                        width: 220,
                        onPressed: () {
                          // Navigate to Edit Profile
                        },
                      ),

                      const SizedBox(height: 18),

                      PrimaryButton(
                        text: 'SOS Settings',
                        width: 220,
                        onPressed: () {
                          // Navigate to SOS Settings
                        },
                      ),

                      const SizedBox(height: 18),

                      PrimaryButton(
                        text: 'Log Out',
                        width: 220,
                        onPressed: () async {

                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: const Color(0xFF1D1A35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: const Text(
                                  "Are you sure you want to logout?",
                                  style: TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                actions: [

                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text("Logout"),
                                  ),

                                ],
                              );
                            },
                          );

                          if (shouldLogout == true) {

                            final authService = AuthService();

                            await authService.signOut();

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );

                          }

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
            right : 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
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