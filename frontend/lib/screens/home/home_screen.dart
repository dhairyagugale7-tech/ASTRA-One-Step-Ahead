import 'package:flutter/material.dart';
import 'package:frontend/screens/guardian/guardian_management_screen.dart';
import 'package:frontend/screens/sos/sos_active_screen.dart';

import '../../config/colors.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/sos_button.dart';

import '../../screens/profile/profile_screen.dart';
import '../journey/journey_setup_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../services/firestore_service.dart';

import '../../services/location_service.dart';

import '../../services/guardian_service.dart';

import '../../services/sos_service.dart';

import '../notifications/notifications_screen.dart';

import '../inbox/inbox_screen.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  



  final LocationService locationService = LocationService();

  String userName = '';

  final SOSService sosService = SOSService();

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  Future<void> loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userData =
        await FirestoreService().getUserData(user.uid);

    if (!mounted) return;

    setState(() {
      userName = userData?['name'] ?? '';
    });
  }

  Future<void> _activateSOS() async {
    try {
      final locationEnabled = await checkLocationService();

      if (!locationEnabled) {
        return;
      }

      debugPrint('ASTRA: SOS ACTIVATED!');

      final result = await sosService.activateSOS();

      debugPrint(
        'ASTRA: SOS ID = ${result['sosId']}',
      );

      debugPrint(
        'ASTRA: SOS Location = '
        '${result['latitude']}, ${result['longitude']}',
      );

      debugPrint(
        'ASTRA: Guardians notified = '
        '${result['guardiansNotified']}',
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SosActiveScreen(),
        ),
      );
    } catch (e) {
      debugPrint(
        'ASTRA: SOS Error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to activate SOS: $e',
          ),
        ),
      );
    }
  }

  Future<bool> checkLocationService() async {
    bool isEnabled =
        await locationService.isLocationServiceEnabled();

    if (!isEnabled) {
      final openSettings = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1D1A35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Location Required",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              "Please turn on your device location to activate SOS.",
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
                child: const Text("Open Settings"),
              ),
            ],
          );
        },
      );

      if (openSettings == true) {
        await locationService.openLocationSettings();
      }

      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    String getGreeting() {
      final hour = DateTime.now().hour;

      if (hour >= 5 && hour < 12) {
        return 'Good Morning';
      } else if (hour >= 12 && hour < 17) {
        return 'Good Afternoon';
      } else if (hour >= 17 && hour < 21) {
        return 'Good Evening';
      } else {
        return 'Hello';
      }
    }
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

                      Text(
                        userName.isEmpty
                            ? '${getGreeting()}!'
                            : '${getGreeting()}, $userName!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Every Journey deserves a Guardian',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 40),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JourneySetupScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 85,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFC56CE8),
                                Color(0xFF734170),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Start Guardian Journey!',
                              style: TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.heading,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      const SizedBox(height: 35),

                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 30),

                      SOSButton(
                        onSOS: () {
                          _activateSOS();
                        },
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Hold it for 3 seconds!',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 35),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GuardianManagementScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 150,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFC56CE8),
                                Color(0xFF734170),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Guardians',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ----------------------------------------------------------
          // NOTIFICATIONS BUTTON
          // ----------------------------------------------------------

          Positioned(
            top: 80,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const NotificationsScreen(),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF8EB6D8),
                child: Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          // ----------------------------------------------------------
          // PROFILE BUTTON
          // ----------------------------------------------------------

          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF8EB6D8),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          // ----------------------------------------------------------
          // MESSAGE INBOX BUTTON
          // ----------------------------------------------------------

          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const InboxScreen(),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF8EB6D8),
                child: Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}