import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../services/guardian_request_service.dart';
import '../../models/guardian_relationship_model.dart';
import '../home/home_screen.dart';

class UsersIGuardScreen extends StatefulWidget {
  const UsersIGuardScreen({super.key});

  @override
  State<UsersIGuardScreen> createState() =>
      _UsersIGuardScreenState();
}

class _UsersIGuardScreenState
    extends State<UsersIGuardScreen> {
  final GuardianRequestService _guardianService =
      GuardianRequestService();

  bool _isLoading = true;

  List<GuardianRelationshipModel> _users = [];

  final Map<String, Map<String, dynamic>?> _userDetails = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // ------------------------------------------------------------
  // LOAD USERS I GUARD
  // ------------------------------------------------------------

  Future<void> _loadUsers() async {
    try {
      final users =
          await _guardianService.getUsersIGuard();

      final Map<String, Map<String, dynamic>?>
          details = {};

      for (final relationship in users) {
        final user =
            await _guardianService.getUserDetails(
          relationship.userId,
        );

        details[relationship.userId] = user;
      }

      if (!mounted) return;

      setState(() {
        _users = users;
        _userDetails
          ..clear()
          ..addAll(details);

        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'ASTRA: Error loading users I guard: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to load users you guard.',
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
  // USER CARD
  // ------------------------------------------------------------

  Widget _buildUserCard(
    GuardianRelationshipModel relationship,
  ) {
    final details =
        _userDetails[relationship.userId];

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
          // ------------------------------------------------------
          // PROFILE ICON
          // ------------------------------------------------------

          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          // ------------------------------------------------------
          // USER INFORMATION
          // ------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                      : email.isNotEmpty
                          ? email
                          : 'ASTRA User',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Active Guardian Relationship',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    color: AppColors.textPrimary
                        .withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),

          // ------------------------------------------------------
          // OPTIONS
          // ------------------------------------------------------

          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
            onSelected: (value) {
              if (value == 'remove') {
                _showRemoveConfirmation(
                  relationship,
                  name,
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(
                      Icons.person_remove_rounded,
                    ),
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

  // ------------------------------------------------------------
  // REMOVE CONFIRMATION
  // ------------------------------------------------------------

  void _showRemoveConfirmation(
    GuardianRelationshipModel relationship,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Remove User?',
          ),
          content: Text(
            'Do you want to stop guarding $name?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                try {
                  await _guardianService.removeRelationship(
                    relationship.id,
                  );

                  if (!mounted) return;

                  setState(() {
                    _users.removeWhere(
                      (item) => item.id == relationship.id,
                    );
                  });

                  _showMessage(
                    '$name is no longer under your protection.',
                  );
                } catch (e) {
                  if (!mounted) return;

                  _showMessage(
                    'Unable to remove relationship.',
                  );
                }
              },
              child: const Text(
                'Remove',
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ------------------------------------------------------
          // NIGHT SKY
          // ------------------------------------------------------

          const NightSky(),

          // ------------------------------------------------------
          // MAIN CONTENT
          // ------------------------------------------------------

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadUsers,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
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
                    // ------------------------------------------------
                    // TITLE
                    // ------------------------------------------------

                    Text(
                      'Users I Guard',
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
                      'People you protect and guard',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // ------------------------------------------------
                    // LOADING
                    // ------------------------------------------------

                    if (_isLoading)
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 70),
                        child:
                            CircularProgressIndicator(),
                      )

                    // ------------------------------------------------
                    // EMPTY
                    // ------------------------------------------------

                    else if (_users.isEmpty)
                      GlassCard(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),

                            Icon(
                              Icons.shield_outlined,
                              size: 65,
                              color:
                                  AppColors.heading,
                            ),

                            const SizedBox(height: 18),

                            Text(
                              'No Users Yet',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                fontFamily:
                                    'PlusJakartaSans',
                                fontSize: 21,
                                fontWeight:
                                    FontWeight.w700,
                                color:
                                    AppColors.heading,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'When someone accepts '
                              'your guardian request, '
                              'they will appear here.',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                fontFamily:
                                    'PlusJakartaSans',
                                fontSize: 14,
                                color:
                                    AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 15),
                          ],
                        ),
                      )

                    // ------------------------------------------------
                    // USERS
                    // ------------------------------------------------

                    else
                      Column(
                        children: [
                          for (final user
                              in _users) ...[
                            _buildUserCard(user),
                            const SizedBox(
                              height: 18,
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),

          // --------------------------------------------------------
          // BACK BUTTON
          // --------------------------------------------------------

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

          // --------------------------------------------------------
          // HOME BUTTON
          // --------------------------------------------------------

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