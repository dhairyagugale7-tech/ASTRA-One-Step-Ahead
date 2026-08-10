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

import '../../services/location_service.dart';
import '../../services/place_service.dart';

import '../../services/tracking_service.dart';

import '../../services/guardian_service.dart';
import '../home/home_screen.dart';
class JourneySetupScreen extends StatefulWidget {
  const JourneySetupScreen({super.key});

  @override
  State<JourneySetupScreen> createState() => _JourneySetupScreenState();
}

class _JourneySetupScreenState extends State<JourneySetupScreen> with WidgetsBindingObserver{

  final JourneyService journeyService = JourneyService();
  final LocationService locationService = LocationService();
  final GuardianService guardianService = GuardianService();
  final PlaceService placeService = PlaceService();

  List<dynamic> placeSuggestions = [];

  dynamic selectedPlace;

  final TextEditingController destinationController =
    TextEditingController();

  List<String> selectedGuardians = [];

  bool shareLiveLocation = true;

  bool smartCheckins = true;

  bool waitingForLocation = false;

  bool isSelectingPlace = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> loadPrimaryGuardian() async {
    try {
      final guardians = await guardianService.getGuardians();

      final primaryGuardians =
          guardians.where((guardian) => guardian.isPrimary).toList();

      if (primaryGuardians.isNotEmpty) {
        setState(() {
          selectedGuardians = [primaryGuardians.first.name];
        });
      }
    } catch (e) {
      debugPrint("Error loading primary guardian: $e");
    }
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

    if (selectedPlace == null) {
      showMessage("Please select a destination from the suggestions.");
      return false;
    }

    if (selectedGuardians.isEmpty) {
      showMessage("Please select at least one guardian.");
      return false;
    }

    return true;
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
              "Please turn on your device location to start your Guardian Journey.",
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

        bool waitingForLocation = true;

        await locationService.openLocationSettings();

      }

      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    loadPrimaryGuardian();

    destinationController.addListener(() async {

      if (isSelectingPlace) return;

      print("Typed: ${destinationController.text}");

      placeSuggestions = await placeService.searchPlaces(
        destinationController.text,
      );

      setState(() {});

    });

  }

  @override
  void dispose() {

    WidgetsBinding.instance.removeObserver(this);

    destinationController.dispose();

    super.dispose();

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {

    print("State: $state");
    print("waitingForLocation = $waitingForLocation");

    if (state == AppLifecycleState.resumed && waitingForLocation) {

      print("Checking GPS...");

      bool isEnabled =
          await locationService.isLocationServiceEnabled();

      print("GPS Enabled: $isEnabled");

      if (isEnabled) {

        waitingForLocation = false;

        print("Starting Journey...");

        await startJourney();

      }

    }

  }

  Future<void> startJourney() async {

    try {

      JourneyModel journey = JourneyModel(
        id: '',
        destination: destinationController.text.trim(),

        destinationLatitude:
            selectedPlace["geometry"]["location"]["lat"],

        destinationLongitude:
            selectedPlace["geometry"]["location"]["lng"],

        guardians: selectedGuardians,
        shareLiveLocation: shareLiveLocation,
        smartCheckins: smartCheckins,
        isActive: true,
        startedAt: Timestamp.now(),
      );

      final journeyId = await journeyService.startJourney(journey);

      if (!mounted) return;

      showMessage("Guardian Journey Started Successfully!");

      waitingForLocation = false;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => JourneyActiveScreen(journey: journey, journeyId: journeyId),
        ),
      );

    } catch (e) {

      showMessage("Something went wrong.");

    }

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

                            Column(
                              children: [

                                CustomTextField(
                                  controller: destinationController,
                                  hintText: 'Where Are You Going?',
                                ),

                                if (placeSuggestions.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2A2448),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    constraints: const BoxConstraints(
                                      maxHeight: 220,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: placeSuggestions.length,
                                      itemBuilder: (context, index) {

                                        final place = placeSuggestions[index];

                                        return ListTile(
                                          leading: const Icon(
                                            Icons.location_on,
                                            color: Colors.white70,
                                          ),

                                          title: Text(
                                            place["description"],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),

                                          onTap: () async {

                                            isSelectingPlace = true;

                                            final details = await placeService.getPlaceDetails(
                                              place["place_id"],
                                            );

                                            if (details != null) {

                                              destinationController.text =
                                                  details["formatted_address"];

                                              selectedPlace = details;

                                              placeSuggestions.clear();

                                              setState(() {});

                                            }

                                            isSelectingPlace = false;

                                          }
                                        );
                                      },
                                    ),
                                  ),

                              ],
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

                                if (!await checkLocationService()) return;

                                await startJourney();

                              }
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