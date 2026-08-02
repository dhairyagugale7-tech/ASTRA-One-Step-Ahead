import 'package:flutter/material.dart';
import 'package:frontend/screens/guardian/guardian_management_screen.dart';
import 'package:frontend/screens/journey/guardian_selection_screen.dart';

import '../../config/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';
import '../../services/journey_service.dart';
import '../../models/journey_model.dart';
import '../journey/journey_active_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JourneySetupScreen extends StatefulWidget {
  const JourneySetupScreen({super.key});

  @override
  State<JourneySetupScreen> createState() => _JourneySetupScreenState();
}

class _JourneySetupScreenState extends State<JourneySetupScreen> {

  final JourneyService journeyService = JourneyService();

  final TextEditingController destinationController =
    TextEditingController();

  List<String> selectedGuardians = [];

  bool shareLiveLocation = true;

  bool smartCheckins = true;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  bool validateInputs() {

    if (destinationController.text.trim().isEmpty) {
      showMessage("Please enter your destination.");
      return false;
    }

    if (selectedGuardians.isEmpty) {
      showMessage("Please select at least one guardian.");
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
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      const SizedBox(height: 110),

                      const Text(
                        'Prepare Guardian Journey',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Before we begin....',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 40),

                      GlassCard(
                        child: Column(
                          children: [

                            CustomTextField(
                              controller: destinationController,
                              hintText: 'Where Are You Going?',
                            ),

                            const SizedBox(height: 20),

                            GestureDetector(
                              onTap: () async {
                                final List<String>? guardians = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GuardianSelectionScreen(),
                                  ),
                                );

                                if (guardians != null) {
                                  setState(() {
                                    selectedGuardians = guardians;
                                  });
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white24,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Select Guardians',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                children: [

                                  const Text(
                                    'Selected Guardians',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  Text(
                                    selectedGuardians.isEmpty
                                        ? 'No Guardians Selected'
                                        : selectedGuardians.join(', '),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 18,
                                      color: Colors.white70,
                                    ),
                                  ),

                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            CheckboxListTile(
                              value: shareLiveLocation,
                              onChanged: (value) {
                                setState(() {
                                  shareLiveLocation = value!;
                                });
                              },
                              activeColor: Colors.white,
                              checkColor: AppColors.buttonGradientStart,
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Share Live Location',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            CheckboxListTile(
                              value: smartCheckins,
                              onChanged: (value) {
                                setState(() {
                                  smartCheckins = value!;
                                });
                              },
                              activeColor: Colors.white,
                              checkColor: AppColors.buttonGradientStart,
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Enable Smart Check-ins',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            PrimaryButton(
                              text: 'Start Guardian Journey',
                              width: 260,
                              onPressed: () async {

                                if (!validateInputs()) return;

                                try {

                                  JourneyModel journey = JourneyModel(
                                    id: '',
                                    destination: destinationController.text.trim(),
                                    guardians: selectedGuardians,
                                    shareLiveLocation: shareLiveLocation,
                                    smartCheckins: smartCheckins,
                                    isActive: true,
                                    startedAt: Timestamp.now(),
                                  );
  
                                  await journeyService.startJourney(journey);

                                  if (!mounted) return;

                                  showMessage("Guardian Journey Started Successfully!");

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JourneyActiveScreen(),
                                    ),
                                  );

                                } catch (e) {

                                  showMessage("Something went wrong.");

                                }

                              },
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
          ),

          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // Navigate to Profile Screen
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

        ],
      ),
    );
  }
}