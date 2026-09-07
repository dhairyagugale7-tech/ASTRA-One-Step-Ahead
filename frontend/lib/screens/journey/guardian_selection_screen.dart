import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/guardian_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';

import '../../services/guardian_request_service.dart';
import '../../models/guardian_relationship_model.dart';

import '../guardian/guardian_management_screen.dart';
import '../home/home_screen.dart';

class GuardianSelectionScreen extends StatefulWidget {
  const GuardianSelectionScreen({super.key});

  @override
  State<GuardianSelectionScreen> createState() =>
      _GuardianSelectionScreenState();
}

class _GuardianSelectionScreenState
    extends State<GuardianSelectionScreen> {

  // ------------------------------------------------------------
  // SERVICE
  // ------------------------------------------------------------

  final GuardianRequestService _requestService =
      GuardianRequestService();

  // ------------------------------------------------------------
  // DATA
  // ------------------------------------------------------------

  List<GuardianRelationshipModel> _guardians = [];

  Map<String, Map<String, dynamic>> _userDetails = {};

  bool _isLoading = true;

  // ------------------------------------------------------------
  // LOAD ACTIVE MY GUARDIANS
  // ------------------------------------------------------------

  Future<void> _loadGuardians() async {
    try {
      final guardians =
          await _requestService.getMyGuardians();

      debugPrint(
        'ASTRA: Active My Guardians = ${guardians.length}',
      );

      final Map<String, Map<String, dynamic>> details = {};

      for (final guardian in guardians) {
        debugPrint(
          'ASTRA: Loading guardian user: '
          '${guardian.guardianId}',
        );

        try {
          final user =
              await _requestService.getUserDetails(
            guardian.guardianId,
          );

          if (user != null) {
            details[guardian.guardianId] = user;

            debugPrint(
              'ASTRA: Guardian found: '
              '${user['name']} - ${user['phone']}',
            );
          } else {
            debugPrint(
              'ASTRA: No user profile found for '
              '${guardian.guardianId}',
            );
          }
        } catch (e) {
          debugPrint(
            'ASTRA: Could not load guardian details: $e',
          );
        }
      }

      if (!mounted) return;

      setState(() {
        _guardians = guardians;
        _userDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'ASTRA: Error loading My Guardians: $e',
      );

      if (!mounted) return;

      setState(() {
        _guardians = [];
        _userDetails = {};
        _isLoading = false;
      });

      _showMessage(
        'Unable to load your guardians.',
      );
    }
  }

  // ------------------------------------------------------------
  // TOGGLE PRIMARY GUARDIAN
  // ------------------------------------------------------------

  Future<void> _togglePrimary(
    GuardianRelationshipModel guardian,
  ) async {
    try {
      await _requestService.setPrimaryStatus(
        guardian.id,
        !guardian.isPrimary,
      );

      await _loadGuardians();

      if (!mounted) return;

      final details =
          _userDetails[guardian.guardianId];

      final String name =
          details?['name']?.toString() ??
          'Guardian';

      _showMessage(
        guardian.isPrimary
            ? '$name is no longer a primary guardian.'
            : '$name is now a primary guardian.',
      );
    } catch (e) {
      debugPrint(
        'ASTRA: Error changing primary status: $e',
      );

      if (!mounted) return;

      _showMessage(
        'Unable to change primary guardian.',
      );
    }
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ------------------------------------------------------------
  // GUARDIAN CARD
  // ------------------------------------------------------------

  Widget _buildGuardianCard(
    GuardianRelationshipModel guardian,
  ) {
    final details =
        _userDetails[guardian.guardianId];

    final String name =
        details?['name']?.toString() ??
        'ASTRA User';

    final String phone =
        details?['phone']?.toString() ??
        '';

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: GuardianCard(
        name: name,
        phoneNumber: phone,
        buttonText: guardian.isPrimary
            ? 'Unselect as Primary'
            : 'Select as Primary',
        onPressed: () {
          _togglePrimary(guardian);
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _loadGuardians();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // --------------------------------------------------------
          // NIGHT SKY
          // --------------------------------------------------------

          const NightSky(),

          // --------------------------------------------------------
          // MAIN CONTENT
          // --------------------------------------------------------

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [

                      const SizedBox(
                        height: 110,
                      ),

                      // ------------------------------------------------
                      // TITLE
                      // ------------------------------------------------

                      const Text(
                        'Select Primary Guardians',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily:
                              'PlayfairDisplay',
                          fontSize: 36,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              AppColors.heading,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // ------------------------------------------------
                      // DESCRIPTION
                      // ------------------------------------------------

                      const Text(
                        'Choose the guardians who should '
                        'receive your journey updates.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily:
                              'PlusJakartaSans',
                          fontSize: 15,
                          color:
                              AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      // ------------------------------------------------
                      // LOADING
                      // ------------------------------------------------

                      if (_isLoading)

                        const Padding(
                          padding: EdgeInsets.only(
                            top: 70,
                          ),
                          child:
                              CircularProgressIndicator(),
                        )

                      // ------------------------------------------------
                      // NO GUARDIANS
                      // ------------------------------------------------

                      else if (_guardians.isEmpty)

                        const Padding(
                          padding: EdgeInsets.only(
                            top: 50,
                          ),
                          child: Text(
                            'No Active Guardians Yet',
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              color:
                                  AppColors.heading,
                              fontSize: 18,
                              fontFamily:
                                  'PlusJakartaSans',
                            ),
                          ),
                        )

                      // ------------------------------------------------
                      // GUARDIANS
                      // ------------------------------------------------

                      else

                        Column(
                          children: _guardians
                              .map(
                                _buildGuardianCard,
                              )
                              .toList(),
                        ),

                      const SizedBox(
                        height: 10,
                      ),

                      // ------------------------------------------------
                      // DONE BUTTON
                      // ------------------------------------------------

                      Center(
                        child: PrimaryButton(
                          text: 'Done',
                          width: 190,
                          fontSize: 18,
                          onPressed: () {
                            final primaryGuardianNames = _guardians
                                .where((guardian) => guardian.isPrimary)
                                .map((guardian) {
                                  final details = _userDetails[guardian.guardianId];

                                  return details?['name']?.toString() ?? '';
                                })
                                .where((name) => name.isNotEmpty)
                                .toList();

                            Navigator.pop(
                              context,
                              primaryGuardianNames,
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // ------------------------------------------------
                      // MANAGE GUARDIANS
                      // ------------------------------------------------

                      Center(
                        child: PrimaryButton(
                          text: 'Manage Guardians',
                          width: 190,
                          fontSize: 18,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const GuardianManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ----------------------------------------------------------
          // BACK BUTTON
          // ----------------------------------------------------------

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

          // ----------------------------------------------------------
          // HOME BUTTON
          // ----------------------------------------------------------

          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const HomeScreen(),
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