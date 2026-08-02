import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  bool validateInputs() {
    if (emailController.text.trim().isEmpty) {
      showMessage("Please enter your email.");
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
                padding: const EdgeInsets.all(24),
                child: Column(

                  children: [
                    const SizedBox(height: 200),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Center(
                            child: Text(
                              "Forgot Password",
                              style: TextStyle(
                                fontFamily: "PlayfairDisplay",
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.heading,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Center(
                            child: Text(
                              "Enter your registered email address.\nWe'll send you a password reset link.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "PlusJakartaSans",
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          CustomTextField(
                            controller: emailController,
                            hintText: "Email",
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 24),

                          Center(
                            child : PrimaryButton(
                            text: "Send Reset Link",
                            onPressed: () async {
                                if (!validateInputs()) return;

                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  await authService.resetPassword(
                                    email: emailController.text.trim(),
                                  );

                                  showMessage("Password reset link sent successfully!");

                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'user-not-found') {
                                    showMessage("No user found with this email.");
                                  } else if (e.code == 'invalid-email') {
                                    showMessage("Please enter a valid email.");
                                  } else {
                                    showMessage(e.message ?? "Something went wrong.");
                                  }
                                } catch (_) {
                                  showMessage("Something went wrong.");
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Back to Login",
                                style: TextStyle(
                                  fontFamily: "PlusJakartaSans",
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.heading,
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
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