import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/create_account_screen.dart';

import '../../config/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/or_divider.dart';
import '../../widgets/outline_button.dart';

import '../../services/auth_service.dart';

import '../home/home_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
    if (emailController.text.trim().isEmpty ||
        !emailController.text.contains("@")) {
      showMessage("Please enter a valid email.");
      return false;
    }

    if (passwordController.text.length < 6) {
      showMessage("Password must be at least 6 characters.");
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      showMessage("Please enter the password.");
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

                    const SizedBox(height: 150),

                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Continue your safer journey',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 40),

                    CustomTextField(
                      controller: emailController,
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            color: AppColors.heading,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    PrimaryButton(
                      text: 'Login',
                      onPressed: isLoading
                        ? null
                        : () async {
                            if (!validateInputs()) {
                              return;
                            }

                            setState(() {
                              isLoading = true;
                            });

                            try {
                              await authService.signInWithEmailPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );

                              setState(() {
                                isLoading = false;
                              });

                              showMessage("Login Successful!");

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                isLoading = false;
                              });

                              if (e.code == "user-not-found") {
                                showMessage("No account found with this email.");
                              } else if (e.code == "wrong-password") {
                                showMessage("Incorrect password.");
                              } else if (e.code == "invalid-email") {
                                showMessage("Please enter a valid email.");
                              } else if (e.code == "invalid-credential") {
                                showMessage("Invalid email or password.");
                              } else {
                                showMessage(e.message ?? "Something went wrong.");
                              }
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });

                              showMessage("Something went wrong.");
                            }
                          },
                    ),

                    const SizedBox(height: 20),

                    const OrDivider(),

                    const SizedBox(height: 24),

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

                            showMessage("Login Successful!");

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

                    const OrDivider(),

                    const SizedBox(height: 22),

                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 17,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    OutlineButton(
                      text: 'Create an Account',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAccountScreen(),
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