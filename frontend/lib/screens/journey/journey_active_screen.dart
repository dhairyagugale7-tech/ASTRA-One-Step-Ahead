import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/sos_button.dart';
import '../../services/journey_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class JourneyActiveScreen extends StatefulWidget {
  const JourneyActiveScreen({super.key});

  @override
  State<JourneyActiveScreen> createState() => _JourneyActiveScreenState();
}

class _JourneyActiveScreenState extends State<JourneyActiveScreen> {
  GoogleMapController? mapController;

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(18.5204, 73.8567), // Pune
    zoom: 14,
  );
  // Temporary values
  final String eta = '18 mins';

  final JourneyService journeyService = JourneyService();

  String destination = "";

  List<String> guardians = [];

  bool isLoading = true;

  final int aiScore = 92;

  final String aiStatus = 'Safe';

  Future<void> loadLatestJourney() async {

    final journeys = await journeyService.getJourneys();

    if (journeys.isNotEmpty) {

      final latestJourney = journeys.first;

      setState(() {

        destination = latestJourney.destination;

        guardians = latestJourney.guardians;

        isLoading = false;

      });

    } else {

      setState(() {

        isLoading = false;

      });

    }

  }

  @override
  void initState() {
    super.initState();
    loadLatestJourney();
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
                    children: [

                      const SizedBox(height: 90),

                      const Text(
                        'Journey Active',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),

                      const SizedBox(height: 25),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 250,
                          child: GoogleMap(
                            initialCameraPosition: initialPosition,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: false,
                            onMapCreated: (GoogleMapController controller) {
                              mapController = controller;
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      if (isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else

                        GlassCard(
                          child: Center(
                            child: Text(
                              'ETA : $eta',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                'Destination : $destination',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 18),

                              Text(
                                'Selected Guardians : ${guardians.join(", ")}',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 18),

                              Text(
                                'AI Safety Analysis : $aiScore/100 ($aiStatus)',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),

                            ],
                          ),
                        ),

                      const SizedBox(height: 25),

                      PrimaryButton(
                        text: 'Journey Completed',
                        width: 220,
                        onPressed: () {},
                        fontSize: 18,
                      ),

                      const SizedBox(height: 30),

                      const SOSButton(),

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