import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/guardian_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';

class GuardianSelectionScreen extends StatelessWidget {
  const GuardianSelectionScreen({super.key});

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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      const SizedBox(height: 110),

                      const Text(
                        'Select Guardian',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),

                      const SizedBox(height: 45),

                      GuardianCard(
                        name: 'Mom',
                        phoneNumber :  '+91 9876543210',
                        buttonText: 'Unselect',
                        onPressed: () {},
                      ),

                      const SizedBox(height: 25),

                      GuardianCard(
                        name: 'Dad',
                        phoneNumber: '+91 9876543211',
                        buttonText: 'Select',
                        onPressed: () {},
                      ),

                      const SizedBox(height: 25),

                      GuardianCard(
                        name: 'Brother',
                        phoneNumber: '+91 9876543212',
                        buttonText: 'Select',
                        onPressed: () {},
                      ),

                      const SizedBox(height: 25),

                      GuardianCard(
                        name: 'Anjali',
                        phoneNumber: '+91 9876543213',
                        buttonText: 'Unselect',
                        onPressed: () {},
                      ),

                      const SizedBox(height: 25),

                      GuardianCard(
                        name: 'Police',
                        phoneNumber: '+91 9876543214',
                        buttonText: 'Select',
                        onPressed: () {},
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