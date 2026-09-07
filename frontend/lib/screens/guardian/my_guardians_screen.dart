import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../services/guardian_request_service.dart';
import '../../models/guardian_relationship_model.dart';
import '../home/home_screen.dart';
import 'add_guardian_screen.dart';

class MyGuardiansScreen extends StatefulWidget {
  const MyGuardiansScreen({super.key});

  @override
  State<MyGuardiansScreen> createState() => _MyGuardiansScreenState();
}

class _MyGuardiansScreenState extends State<MyGuardiansScreen> {
  final GuardianRequestService _requestService =
      GuardianRequestService();

  List<GuardianRelationshipModel> _guardians = [];
  Map<String, Map<String, dynamic>> _userDetails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuardians();
  }

  Future<void> _loadGuardians() async {
    try {
      final guardians =
          await _requestService.getMyGuardians();

      final Map<String, Map<String, dynamic>> details = {};

      for (final guardian in guardians) {
        final user =
            await _requestService.getUserDetails(
          guardian.guardianId,
        );

        if (user != null) {
          details[guardian.guardianId] = user;
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
        'ASTRA: Error loading guardians: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to load your guardians.',
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

    Future<void> _showRemoveConfirmation(
      GuardianRelationshipModel guardian,
    ) async {
      final shouldRemove = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Remove Guardian?',
            ),
            content: const Text(
              'This person will no longer be your guardian.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('Remove'),
              ),
            ],
          );
        },
      );

      if (shouldRemove != true) return;

      try {
        await _requestService.removeRelationship(
          guardian.id,
        );

        if (!mounted) return;

        setState(() {
          _guardians.removeWhere(
            (item) => item.id == guardian.id,
          );
        });

        _showMessage(
          'Guardian removed successfully.',
        );
      } catch (e) {
        if (!mounted) return;

        _showMessage(
          'Unable to remove guardian.',
        );
      }
    }

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

      final String email =
          details?['email']?.toString() ??
          '';
    return GlassCard(
      child: Row(
        children: [
          // ----------------------------------------------------------
          // PROFILE ICON
          // ----------------------------------------------------------

          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          // ----------------------------------------------------------
          // GUARDIAN INFO
          // ----------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  phone.isNotEmpty
                      ? phone
                      : email,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // ----------------------------------------------------------
          // VIEW BUTTON
          // ----------------------------------------------------------

          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
            onSelected: (value) {
              if (value == 'remove') {
                _showRemoveConfirmation(
                  guardian,
                );
              }

              if (value == 'view') {
                _showMessage(
                  'Guardian details screen coming next.',
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility_rounded),
                    SizedBox(width: 10),
                    Text('View'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove_rounded),
                    SizedBox(width: 10),
                    Text('Remove'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const NightSky(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                28,
                55,
                28,
                100,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  // --------------------------------------------------
                  // TITLE
                  // --------------------------------------------------

                  Text(
                    'My Guardians',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.heading,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'People who protect and guard you',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // --------------------------------------------------
                  // LOADING
                  // --------------------------------------------------

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 70),
                      child: CircularProgressIndicator(),
                    )

                  // --------------------------------------------------
                  // EMPTY
                  // --------------------------------------------------

                  else if (_guardians.isEmpty)
                    GlassCard(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          Icon(
                            Icons.shield_outlined,
                            size: 65,
                            color: AppColors.heading,
                          ),

                          const SizedBox(height: 18),

                          Text(
                            'No Guardians Yet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: AppColors.heading,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Once someone accepts your '
                            'guardian request, they will '
                            'appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 15),
                        ],
                      ),
                    )

                  // --------------------------------------------------
                  // GUARDIANS
                  // --------------------------------------------------

                  else
                    Column(
                      children: [
                        for (final guardian in _guardians) ...[
                          _buildGuardianCard(guardian),
                          const SizedBox(height: 18),
                        ],
                      ],
                    ),

                  const SizedBox(height: 20),

                  // ADD GUARDIAN BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddGuardianScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Add Guardian',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonGradientStart,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
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