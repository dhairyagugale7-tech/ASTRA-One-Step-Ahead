import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';

class SosSettingsScreen extends StatefulWidget {
  const SosSettingsScreen({super.key});

  @override
  State<SosSettingsScreen> createState() => _SosSettingsScreenState();
}

class _SosSettingsScreenState extends State<SosSettingsScreen> {

  bool callGuardians = true;
  bool sendSms = true;
  bool shareLocation = true;
  bool liveTracking = false;
  bool alarm = true;
  bool flashlight = false;

  int holdDuration = 3;

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

                    const Text(
                      'SoS Setting',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                      ),
                    ),

                    const SizedBox(height: 35),

                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            'Emergency Actions',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 20),

                          CheckboxListTile(
                            value: callGuardians,
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            title: const Text(
                              'Call Guardians',
                              style: TextStyle(color: Colors.white),
                            ),
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() {
                                callGuardians = value!;
                              });
                            },
                          ),

                          CheckboxListTile(
                            value: sendSms,
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            title: const Text(
                              'Send SMS',
                              style: TextStyle(color: Colors.white),
                            ),
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() {
                                sendSms = value!;
                              });
                            },
                          ),

                          CheckboxListTile(
                            value: shareLocation,
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            title: const Text(
                              'Share Live Location',
                              style: TextStyle(color: Colors.white),
                            ),
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() {
                                shareLocation = value!;
                              });
                            },
                          ),

                          CheckboxListTile(
                            value: liveTracking,
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            title: const Text(
                              'Enable Live Tracking',
                              style: TextStyle(color: Colors.white),
                            ),
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() {
                                liveTracking = value!;
                              });
                            },
                          ),

                          CheckboxListTile(
                            value: alarm,
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            title: const Text(
                              'Play Alarm',
                              style: TextStyle(color: Colors.white),
                            ),
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() {
                                alarm = value!;
                              });
                            },
                          ),

                          CheckboxListTile(
                            value: flashlight,
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            title: const Text(
                              'Turn On Flashlight',
                              style: TextStyle(color: Colors.white),
                            ),
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() {
                                flashlight = value!;
                              });
                            },
                          ),

                          const SizedBox(height: 15),

                          const Divider(color: Colors.white24),

                          const SizedBox(height: 15),

                          const Text(
                            'Hold Duration',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 15),

                          RadioListTile<int>(
                            value: 2,
                            groupValue: holdDuration,
                            activeColor: Colors.green,
                            title: const Text(
                              '2 Seconds',
                              style: TextStyle(color: Colors.white),
                            ),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() {
                                holdDuration = value!;
                              });
                            },
                          ),

                          RadioListTile<int>(
                            value: 3,
                            groupValue: holdDuration,
                            activeColor: Colors.green,
                            title: const Text(
                              '3 Seconds',
                              style: TextStyle(color: Colors.white),
                            ),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() {
                                holdDuration = value!;
                              });
                            },
                          ),

                          RadioListTile<int>(
                            value: 5,
                            groupValue: holdDuration,
                            activeColor: Colors.green,
                            title: const Text(
                              '5 Seconds',
                              style: TextStyle(color: Colors.white),
                            ),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() {
                                holdDuration = value!;
                              });
                            },
                          ),

                          const SizedBox(height: 30),

                          Center(
                            child: PrimaryButton(
                              text: 'Save Settings',
                              width: 230,
                              onPressed: () {
                                // Save settings later
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
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