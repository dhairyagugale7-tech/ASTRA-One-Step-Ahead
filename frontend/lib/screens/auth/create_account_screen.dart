import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/or_divider.dart';
import '../../widgets/outline_button.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home/home_screen.dart';
import 'login_screen.dart';
import '../auth/location_permission_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {

  final TextEditingController nameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final AuthService authService = AuthService();

  final FirestoreService firestoreService = FirestoreService();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool validateInputs() {
    // Check Full Name
    if (nameController.text.trim().isEmpty) {
      showMessage("Please enter your full name.");
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      showMessage("Please enter your Phone Number.");
      return false;
    }

    // Check Phone Number
    if (phoneController.text.trim().length != 10) {
      showMessage("Phone number must contain exactly 10 digits.");
      return false;
    }

    // Check Email
    if (emailController.text.trim().isEmpty ||
        !emailController.text.contains("@")) {
      showMessage("Please enter a valid email address.");
      return false;
    }

    // Check Password
    if (passwordController.text.length < 6) {
      showMessage("Password must be at least 6 characters.");
      return false;
    }

    // Check Confirm Password
    if (passwordController.text != confirmPasswordController.text) {
      showMessage("Passwords do not match.");
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
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const SizedBox(height: 105),

                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Join ASTRA and Stay Protected!',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: nameController,
                      hintText: 'Full Name',
                      keyboardType: TextInputType.text,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: phoneController,
                      hintText: 'Phone Number',
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                    ),

                    const SizedBox(height: 20),

                    PrimaryButton(
                      text: isLoading ? "Creating Account..." : "Create Account",
                      onPressed: isLoading
                      ? null 
                      : ()async {

                        if (!validateInputs()) {
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });

                        try {
                          final userCredential = await authService.registerUser(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          await firestoreService.saveUserData(
                            uid: userCredential.user!.uid,
                            name: nameController.text.trim(),
                            phone: phoneController.text.trim(),
                            email: emailController.text.trim(),
                          );

                          setState(() {
                            isLoading = false;
                          });

                          showMessage("Account Created Successfully!");

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LocationPermissionScreen(),
                            ),
                          );

                        } on FirebaseAuthException catch (e) {
                          setState(() {
                            isLoading = false;
                          });

                          if (e.code == 'email-already-in-use') {
                            showMessage("This email is already registered.");
                          } else if (e.code == 'weak-password') {
                            showMessage("Please choose a stronger password.");
                          } else if (e.code == 'invalid-email') {
                            showMessage("Please enter a valid email address.");
                          } else {
                            showMessage(e.message ?? "Something went wrong.");
                          }
                        } catch (e) {
                          showMessage("Something went wrong.");
                        }
                      }
                    ),

                    const SizedBox(height: 15),

                    const OrDivider(),

                    const SizedBox(height: 15),

                    OutlineButton(
                      text: 'Continue with Google',
                      onPressed: () async {

                        setState(() {
                          isLoading = true;
                        });

                        try {

                          final userCredential =
                              await authService.signInWithGoogle();

                          if (userCredential != null) {

                            final user = userCredential.user!;

                            final userDoc = FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid);

                            final docSnapshot = await userDoc.get();

                            if (!docSnapshot.exists) {
                              await firestoreService.saveUserData(
                                uid: user.uid,
                                name: user.displayName ?? "",
                                phone: user.phoneNumber ?? "",
                                email: user.email ?? "",
                              );
                            }

                            showMessage("Google Sign-In Successful!");

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );

                          }

                        } catch (e) {

                          showMessage("Google Sign-In Failed.");

                        }

                        setState(() {
                          isLoading = false;
                        });

                      },
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 17,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    PrimaryButton(
                      text: 'Login',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}