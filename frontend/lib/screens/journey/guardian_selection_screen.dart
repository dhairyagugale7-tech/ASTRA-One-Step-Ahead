import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/guardian_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';
import '../../services/guardian_service.dart';
import '../../models/guardian_model.dart';
import '../guardian/guardian_management_screen.dart';
import '../home/home_screen.dart';
class GuardianSelectionScreen extends StatefulWidget {
  const GuardianSelectionScreen({super.key});

  @override
  State<GuardianSelectionScreen> createState() => _GuardianSelectionScreenState();
}

class _GuardianSelectionScreenState extends State<GuardianSelectionScreen> {

  final GuardianService guardianService = GuardianService();

  List<GuardianModel> guardians = [];

  List<GuardianModel> selectedGuardians = [];

  bool isLoading = true;

  Future<void> loadGuardians() async {

    guardians = await guardianService.getGuardians();

    print("Guardians fetched: ${guardians.length}");

    for (final guardian in guardians) {
      print("${guardian.name} - ${guardian.phone}");
    }

    selectedGuardians =
        guardians.where((guardian) => guardian.isPrimary).toList();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> selectPrimaryGuardian(GuardianModel guardian) async {
    try {
      setState(() {
        isLoading = true;
      });

      await guardianService.setPrimaryGuardian(guardian.id);

      // Reload guardians so the UI reflects the new primary guardian.
      await loadGuardians();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${guardian.name} is now your primary guardian.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not change primary guardian.',
          ),
        ),
      );
    }
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

                      const SizedBox(height: 20),

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
                                buttonText: selectedGuardians.contains(guardian)
                                  ? "Unselect"
                                  : "Select",
                                onPressed: () {
                                  if (!selectedGuardians.contains(guardian)) {
                                    selectPrimaryGuardian(guardian);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 20),       

                      Center(
                        child: PrimaryButton(
                          text: 'Done',
                          width: 190,
                          fontSize: 18,
                          onPressed: () {
                            Navigator.pop(
                              context,
                              selectedGuardians
                                  .map((guardian) => guardian.name)
                                  .toList(),
                            );

                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: PrimaryButton(
                          text: 'Manage Guardians',
                          width: 190,
                          fontSize: 18,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GuardianManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      
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