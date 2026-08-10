import 'package:flutter/material.dart';
import 'package:frontend/screens/guardian/guardian_management_screen.dart';
import 'package:frontend/screens/profile/edit_profile_screen.dart';
import 'package:frontend/screens/sos/sos_setting_screen.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Temporary Data
  final FirestoreService firestoreService = FirestoreService();

  String name = "";
  String phoneNumber = "";
  String email = "";

  bool isLoading = true;

  Future<void> loadUserData() async {

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final userData =
        await firestoreService.getUserData(currentUser.uid);

    if (userData != null) {

      setState(() {

        name = userData['name'] ?? '';

        phoneNumber = userData['phone'] ?? '';

        email = userData['email'] ?? '';

        isLoading = false;

      });

    } else {
      setState(() {
        isLoading = false;
      });
    }

  }

  @override
  void initState() {
    super.initState();
    loadUserData();
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

                      if (isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name : $name'),
                              Text('Phone Number : $phoneNumber'),
                              Text('Email : $email')
                            ],
                          ),
                        ),

                      const SizedBox(height: 28),

                      PrimaryButton(
                        text: 'Manage Guardians',
                        width: 300,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GuardianManagementScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      PrimaryButton(
                        text: 'Edit Profile',
                        width: 220,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      PrimaryButton(
                        text: 'SOS Settings',
                        width: 220,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SosSettingsScreen(),
                            ),
                          );
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
                Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
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