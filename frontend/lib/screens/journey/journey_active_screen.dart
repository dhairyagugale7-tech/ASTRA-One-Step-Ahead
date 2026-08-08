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

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/route_service.dart';

class JourneyActiveScreen extends StatefulWidget {

  final JourneyModel journey;

  const JourneyActiveScreen({
    super.key,
    required this.journey,
  });

  @override
  State<JourneyActiveScreen> createState() => _JourneyActiveScreenState();
}

class _JourneyActiveScreenState extends State<JourneyActiveScreen> {
  GoogleMapController? mapController;

  final LocationService locationService = LocationService();

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

  @override
  void initState() {
    super.initState();
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