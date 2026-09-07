import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

import '../../services/message_service.dart';
import '../../services/guardian_service.dart';

import '../../services/guardian_request_service.dart';


import 'package:firebase_auth/firebase_auth.dart';

import '../journey/journey_completed_screen.dart';
import '../home/home_screen.dart';
import '../../services/sos_service.dart';

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

  final MessageService messageService = MessageService();
  

  final GuardianRequestService requestService =
    GuardianRequestService();

  final SOSService sosService = SOSService();


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

  Future<void> activateSOS() async {
    try {
      debugPrint('🚨 ASTRA: SOS activated from Active Journey screen.');

      await sosService.activateSOS();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🚨 SOS activated. Your guardians have been notified.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
            ),
          ),
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      debugPrint(
        '❌ ASTRA: Failed to activate SOS: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'SOS could not be activated: $e',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
            ),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
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

  Future<void> sendJourneyStartedMessage() async {
    try {
      final relationships =
          await requestService.getMyGuardians();

      // Only active primary guardians receive
      // the Journey Started message.
      final primaryGuardians = relationships
          .where(
            (guardian) =>
                guardian.status == 'active' &&
                guardian.isPrimary,
          )
          .toList();

      debugPrint(
        'ASTRA: Primary guardians for journey message = '
        '${primaryGuardians.length}',
      );

      if (primaryGuardians.isEmpty) {
        debugPrint(
          'ASTRA: No primary guardians found.',
        );
        return;
      }

      final trackingLink =
          'https://astra-one-step-ahead.web.app/'
          '?uid=${FirebaseAuth.instance.currentUser!.uid}'
          '&journeyId=${widget.journeyId}';

      final message =
          '🛡️ Journey Started\n\n'
          'Your guardian has started a journey.\n\n'
          '📍 Destination: ${widget.journey.destination}\n\n'
          '🗺️ Live Location:\n'
          '$trackingLink';

      // Send the message to EVERY primary guardian.
      for (final guardian in primaryGuardians) {
        try {
          await messageService.sendMessage(
            receiverId: guardian.guardianId,
            message: message,
          );

          debugPrint(
            '✅ Journey Started message sent to '
            '${guardian.guardianId}',
          );
        } catch (e) {
          debugPrint(
            '❌ Failed to send Journey Started message to '
            '${guardian.guardianId}: $e',
          );
        }
      }
    } catch (e) {
      debugPrint(
        '❌ Unable to send Journey Started message: $e',
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
      sendJourneyStartedMessage();
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
      // ----------------------------------------------------------
      // STOP LIVE GPS TRACKING
      // ----------------------------------------------------------

      await stopJourneyTracking();

      // ----------------------------------------------------------
      // CHECK FINAL LOCATION
      // ----------------------------------------------------------

      if (currentPosition == null) {
        throw Exception(
          'Current location is not available.',
        );
      }

      // ----------------------------------------------------------
      // GET ACTIVE PRIMARY GUARDIANS
      // ----------------------------------------------------------

      final relationships =
          await requestService.getMyGuardians();

      final primaryGuardians = relationships
          .where(
            (guardian) =>
                guardian.status == 'active' &&
                guardian.isPrimary,
          )
          .toList();

      debugPrint(
        'ASTRA: Primary guardians for completion message = '
        '${primaryGuardians.length}',
      );

      // ----------------------------------------------------------
      // FINAL LOCATION LINK
      // ----------------------------------------------------------

      final finalLocationLink =
          'https://www.google.com/maps/search/?api=1'
          '&query=${currentPosition!.latitude},'
          '${currentPosition!.longitude}';

      // ----------------------------------------------------------
      // COMPLETION MESSAGE
      // ----------------------------------------------------------

      final message =
          '✅ Journey Completed\n\n'
          'The journey to '
          '${widget.journey.destination} '
          'has been completed safely.\n\n'
          '📍 Final Location:\n'
          '$finalLocationLink';

      // ----------------------------------------------------------
      // SEND TO EVERY PRIMARY GUARDIAN
      // ----------------------------------------------------------

      for (final guardian in primaryGuardians) {
        try {
          await messageService.sendMessage(
            receiverId: guardian.guardianId,
            message: message,
          );

          debugPrint(
            '✅ Journey completed message sent to '
            '${guardian.guardianId}',
          );
        } catch (e) {
          debugPrint(
            '❌ Completion message failed for '
            '${guardian.guardianId}: $e',
          );
        }
      }

      // ----------------------------------------------------------
      // MARK JOURNEY AS COMPLETED
      // ----------------------------------------------------------

      await journeyService.endJourney(
        journeyId: widget.journeyId,
      );

      debugPrint(
        '✅ Journey completed successfully.',
      );
    } catch (e) {
      debugPrint(
        '❌ Error completing journey: $e',
      );
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

                      SOSButton(
                        onSOS: () {
                          activateSOS();
                        },
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