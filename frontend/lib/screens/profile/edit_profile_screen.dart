import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';
import '../../config/colors.dart';
import '../home/home_screen.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final AuthService authService = AuthService();

  final FirestoreService firestoreService = FirestoreService();

  bool isLoading = false;

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('User not logged in.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userData =
          await firestoreService.getUserData(user.uid);

      if (userData != null) {
        nameController.text = userData['name'] ?? '';
        phoneController.text = userData['phone'] ?? '';
        emailController.text = userData['email'] ?? '';
      }
    } catch (e) {
      showMessage('Could not load profile.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  bool validateInputs() {

    if (nameController.text.trim().isEmpty) {
      showMessage("Please enter name.");
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      showMessage("Please enter phone number.");
      return false;
    }

    if (phoneController.text.trim().length != 10) {
      showMessage("Phone number must be 10 digits.");
      return false;
    }

    if (emailController.text.trim().isEmpty ||
        !emailController.text.contains("@")) {
      showMessage("Please enter a valid email address.");
      return false;
    }

    return true;
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

                      const SizedBox(height: 120),

                      const Text(
                        'Edit Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),

                      const SizedBox(height: 45),

                      GlassCard(
                        child: Column(
                          children: [

                            CustomTextField(
                              controller: nameController,
                            ),

                            const SizedBox(height: 20),

                            CustomTextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: 20),

                            CustomTextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 20),

                            PrimaryButton(
                              text: isLoading ? "..." : "Edit Profile",
                              width: 220,
                              onPressed: () async {
                                if (!validateInputs()) {
                                  return;
                                }

                                final user = FirebaseAuth.instance.currentUser;

                                if (user == null) {
                                  showMessage('User not logged in.');
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  await firestoreService.updateUserData(
                                    uid: user.uid,
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    email: emailController.text.trim(),
                                  );

                                  if (!mounted) return;

                                  showMessage('Profile updated successfully! 💗');

                                  Navigator.pop(context);

                                } catch (e) {
                                  showMessage('Failed to update profile.');
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              },
                            ),

                          ],
                        ),
                      ),

                      const SizedBox(height: 80),

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