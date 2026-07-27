import 'package:flutter/material.dart';
import 'package:frontend/screens/profile/profile_screen.dart';

import '../../config/colors.dart';
import '../../widgets/guardian_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';

import '../../models/guardian_model.dart';
import '../../services/guardian_service.dart';
import 'add_guardian_screen.dart';

import 'edit_guardian_screen.dart';
import '../home/home_screen.dart';

class GuardianManagementScreen extends StatefulWidget {
  const GuardianManagementScreen({super.key});

  @override
  State<GuardianManagementScreen> createState() => _GuardianManagementScreenState();
}

class _GuardianManagementScreenState extends State<GuardianManagementScreen> {

  final GuardianService _guardianService = GuardianService();

  List<GuardianModel> guardians = [];

  bool isLoading = true;

  Future<void> loadGuardians() async {
    guardians = await _guardianService.getGuardians();

    setState(() {
      isLoading = false;
    });
  }

  @override
    void initState() {
      super.initState();
      loadGuardians();
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
                child: Column(
                  children: [

                    const SizedBox(height: 80),

                    const Text(
                      'Your Guardians',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                      ),
                    ),

                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else if (guardians.isEmpty)
                      const Center(
                        child: Text(
                          "No Guardians Added Yet",
                          style: TextStyle(
                            color: AppColors.heading,
                            fontSize: 18,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: guardians.map((guardian) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: GuardianCard(
                              name: guardian.name,
                              phoneNumber: guardian.phone,
                              buttonText: "Edit",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditGuardianScreen(
                                      guardian: guardian,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),

                    Center(
                      child: PrimaryButton(
                        text: 'Add Guardian',
                        width: 190,
                        fontSize: 18,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddGuardianScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                  ],
                ),
              ),
            ),
          ),
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
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
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