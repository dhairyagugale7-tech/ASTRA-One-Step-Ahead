import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

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

                    Text(
                      'Stay Informed',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Enable notifications to receive \njourney updates, safety alerts, \nand Guardian messages instantly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Image.asset(
                      'assets/images/notification_screen.png',
                      height: 250,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 20),

                    GlassCard(
                      child: Column(
                        children: [

                          const Text(
                            'Your Privacy Matters',
                            style: TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.heading,
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'We only use your contacts \nto send your journey updates \nto keep you safe.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 28),

                          PrimaryButton(
                            text: 'Enable Notifications',
                            fontSize: 17,
                            onPressed: () {},
                          ),

                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Not Now',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                color: AppColors.heading,
                              ),
                            ),
                          ),
                        ],
                      ),
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