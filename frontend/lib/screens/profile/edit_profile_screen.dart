import 'package:flutter/material.dart';

import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';
import '../../config/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final TextEditingController nameController =
      TextEditingController(text: 'Dhairya Gugale');

  final TextEditingController phoneController =
      TextEditingController(text: '+91 9876543210');

  final TextEditingController emailController =
      TextEditingController(text: 'dhairya@gmail.com');

  final TextEditingController passwordController =
      TextEditingController(text: 'password123');

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

                            CustomTextField(
                              controller: passwordController,
                              obscureText: true,
                            ),

                            const SizedBox(height: 28),

                            PrimaryButton(
                              text: 'Edit Profile',
                              width: 220,
                              onPressed: () {},
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

        ],
      ),
    );
  }
}