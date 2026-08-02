import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';
import '../../services/permission_service.dart';
import 'notification_screen.dart';

class LocationPermissionScreen extends StatelessWidget {
  LocationPermissionScreen({super.key});

  final PermissionService permissionService = PermissionService();

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
                      'Location',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'To guide you safely, ASTRA needs\naccess to your location during Guardian\nJourneys.',
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
                      'assets/images/location_screen.png',
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
                            'We only use your location while a Guardian Journey is active to keep you safe.',
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
                            text: 'Allow Location',
                            onPressed: () async {
                              bool granted =
                                await permissionService.requestLocationPermission();

                            if (granted) {
                              print("Location permission granted");
                            } else {
                              print("Location permission denied");
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NotificationScreen(),
                              ),
                            );

                            },
                          ),

                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NotificationScreen(),
                                ),
                              );
                            },
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