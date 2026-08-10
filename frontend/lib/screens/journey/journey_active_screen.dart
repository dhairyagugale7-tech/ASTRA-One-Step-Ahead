import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/sos_button.dart';
import '../../services/journey_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../models/journey_model.dart';

import 'dart:async';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/route_service.dart';

import '../../services/whatsapp_service.dart';

import '../../services/guardian_service.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../journey/journey_completed_screen.dart';
import '../home/home_screen.dart';

class JourneyActiveScreen extends StatefulWidget {

  final JourneyModel journey;
  final String journeyId;

  const JourneyActiveScreen({
    super.key,
    required this.journey,
    required this.journeyId
  });

  @override
  State<JourneyActiveScreen> createState() => _JourneyActiveScreenState();
}

class _JourneyActiveScreenState extends State<JourneyActiveScreen> {
  GoogleMapController? mapController;

  final LocationService locationService = LocationService();

  final JourneyService journeyService = JourneyService();

  final GuardianService guardianService = GuardianService();

  StreamSubscription<Position>? positionSubscription;

  final RouteService routeService = RouteService();

  Position? currentPosition;
  
  Set<Marker> markers = {};

  Set<Polyline> polylines = {};

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(18.5204, 73.8567), // Pune
    zoom: 14,
  );
  // Temporary values
  String eta = 'Calculating...';

  String distance = 'Calculating...';

  final int aiScore = 92;

  final String aiStatus = 'Safe';

  Future<void> getCurrentLocation() async {

    try {

      currentPosition =
          await locationService.getCurrentLocation();

      final bounds = LatLngBounds(
        southwest: LatLng(
          currentPosition!.latitude < widget.journey.destinationLatitude
              ? currentPosition!.latitude
              : widget.journey.destinationLatitude,
          currentPosition!.longitude < widget.journey.destinationLongitude
              ? currentPosition!.longitude
              : widget.journey.destinationLongitude,
        ),
        northeast: LatLng(
          currentPosition!.latitude > widget.journey.destinationLatitude
              ? currentPosition!.latitude
              : widget.journey.destinationLatitude,
          currentPosition!.longitude > widget.journey.destinationLongitude
              ? currentPosition!.longitude
              : widget.journey.destinationLongitude,
        ),
      );

      mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );

      print(widget.journey.destination);
      print(widget.journey.destinationLatitude);
      print(widget.journey.destinationLongitude);

      print(currentPosition!.latitude);
      print(currentPosition!.longitude);
      markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: LatLng(
            widget.journey.destinationLatitude,
            widget.journey.destinationLongitude,
          ),
          infoWindow: InfoWindow(
            title: widget.journey.destination,
          ),
        ),
      );

      final route = await routeService.getRoute(
        originLat: currentPosition!.latitude,
        originLng: currentPosition!.longitude,
        destinationLat: widget.journey.destinationLatitude,
        destinationLng: widget.journey.destinationLongitude,
      );

      if (route == null) {
        return;
      }

      final points = route["points"] as List<PointLatLng>;
      final duration = route["duration"] as String;
      final routedistance = route["distance"] as String;

      print("ETA: $duration");
      print("Distance: $routedistance");
      print("Route points: ${points.length}");

      setState(() {
        eta = duration;
        distance = routedistance;
      });

      polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          width: 6,
          points: points
              .map(
                (point) => LatLng(
                  point.latitude,
                  point.longitude,
                ),
              )
              .toList(),
        ),
      );

      setState(() {});

    } catch (e) {

      print(e);

    }

  }

  Future<void> updateRoute(Position position) async {
    try {
      final route = await routeService.getRoute(
        originLat: position.latitude,
        originLng: position.longitude,
        destinationLat: widget.journey.destinationLatitude,
        destinationLng: widget.journey.destinationLongitude,
      );

      if (route == null) {
        return;
      }

      final points = route["points"] as List<PointLatLng>;
      final duration = route["duration"] as String;
      final routeDistance = route["distance"] as String;

      print("REROUTING...");
      print("New ETA: $duration");
      print("New Distance: $routeDistance");
      print("New Route points: ${points.length}");

      setState(() {
        eta = duration;
        distance = routeDistance;

        polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            width: 6,
            points: points
                .map(
                  (point) => LatLng(
                    point.latitude,
                    point.longitude,
                  ),
                )
                .toList(),
          ),
        };
      });

      await _fitCameraToRoute(
        points
            .map(
              (point) => LatLng(
                point.latitude,
                point.longitude,
              ),
            )
            .toList(),
      );
    } catch (e) {
      print("Rerouting error: $e");
    }
  }

  Future<void> shareJourneyWithGuardians() async {
    try {
      for (final guardianName in widget.journey.guardians) {
        final guardian =
            await guardianService.getGuardianByName(guardianName);

        if (guardian == null) {
          debugPrint(
            'Guardian not found: $guardianName',
          );
          continue;
        }

        final trackingLink =
          'https://astra-one-step-ahead.web.app/?uid=${FirebaseAuth.instance.currentUser!.uid}&journeyId=${widget.journeyId}';

        await WhatsAppService.sendGuardianJourneyMessage(
          phone: guardian.phone,
          guardianName: guardian.name,
          destination: widget.journey.destination,
          trackingLink: trackingLink,
        );
      }
    } catch (e) {
      debugPrint(
        'Guardian WhatsApp sharing error: $e',
      );
    }
  }

  Future<void> _fitCameraToRoute(List<LatLng> routePoints) async {
    if (mapController == null || routePoints.isEmpty) return;

    double minLat = routePoints.first.latitude;
    double maxLat = routePoints.first.latitude;
    double minLng = routePoints.first.longitude;
    double maxLng = routePoints.first.longitude;

    for (final point in routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        80,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    positionSubscription =
        locationService.getLocationStream().listen((Position position) async {
      currentPosition = position;

      await journeyService.updateLiveLocation(
        journeyId: widget.journeyId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      print(
        "LIVE GPS: ${currentPosition!.latitude}, ${currentPosition!.longitude}",
      );

      updateRoute(position);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      shareJourneyWithGuardians();
    });
  }

  @override
  void dispose() {
    positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> stopJourneyTracking() async {
    await positionSubscription?.cancel();
    positionSubscription = null;

    debugPrint('🛑 Journey GPS tracking stopped.');
  }

  Future<void> completeJourney() async {
    try {
      // Stop live GPS tracking first
      await stopJourneyTracking();

      // Make sure we have the user's final location
      if (currentPosition == null) {
        throw Exception('Current location is not available.');
      }

      // Send journey completed message with final location
      final finalLocationLink =
          'https://www.google.com/maps/search/?api=1&query='
          '${currentPosition!.latitude},${currentPosition!.longitude}';

      for (final guardianName in widget.journey.guardians) {
        try {
          final guardian =
              await guardianService.getGuardianByName(guardianName);

          if (guardian == null) {
            debugPrint('Guardian not found: $guardianName');
            continue;
          }

          await WhatsAppService.sendJourneyCompletedMessage(
            phone: guardian.phone,
            guardianName: guardian.name,
            destination: widget.journey.destination,
            latitude: currentPosition!.latitude,
            longitude: currentPosition!.longitude,
          );

          debugPrint(
            '✅ Journey completed message sent to ${guardian.name}',
          );
        } catch (e) {
          debugPrint(
            '❌ Completion WhatsApp failed for $guardianName: $e',
          );
        }
      }

      // Mark journey as completed in Firestore
      await journeyService.endJourney(
        journeyId: widget.journeyId,
      );

      debugPrint('✅ Journey completed successfully.');
    } catch (e) {
      debugPrint('❌ Error completing journey: $e');
    }
  }

  Future<void> _confirmCompleteJourney({
    required VoidCallback onConfirmed,
  }) async {
    final bool? shouldComplete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF211B3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Complete Journey?',
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to complete your journey?\n\n'
            'Live location tracking will stop and your guardians will be notified.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'PlusJakartaSans',
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8F7BFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Complete Journey',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldComplete == true) {
      await completeJourney();

      if (!mounted) return;

      onConfirmed();
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
                            markers: markers,
                            polylines: polylines,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: true,
                            onMapCreated: (GoogleMapController controller) {
                              mapController = controller;
                              getCurrentLocation();
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

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
                          child: Center(
                            child: Text(
                              'Distance : $distance',
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
                                'Destination : ${widget.journey.destination}',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 18),

                              Text(
                                'Selected Guardians : ${widget.journey.guardians.join(", ")}',
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
                        fontSize: 18,
                        onPressed: () async {
                          await completeJourney();

                          if (!mounted) return;

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JourneyCompletedScreen(),
                            ),
                          );
                        },
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
                _confirmCompleteJourney(
                  onConfirmed: () {
                    Navigator.pop(context);
                  },
                );
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
                _confirmCompleteJourney(
                  onConfirmed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
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