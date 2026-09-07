import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../services/guardian_request_service.dart';
import '../../models/guardian_request_model.dart';
import '../home/home_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final GuardianRequestService _requestService =
      GuardianRequestService();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  List<GuardianRequestModel> _requests = [];

  List<Map<String, dynamic>> _sosNotifications = [];

  Map<String, Map<String, dynamic>> _userDetails = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ============================================================
  // LOAD ALL NOTIFICATIONS
  // ============================================================

  Future<void> _loadNotifications() async {
    try {
      final requests =
          await _requestService.getReceivedRequests();

      final Map<String, Map<String, dynamic>> details = {};

      for (final request in requests) {
        final user =
            await _requestService.getUserDetails(
          request.senderId,
        );

        if (user != null) {
          details[request.senderId] = user;
        }
      }

      final user = _auth.currentUser;

      List<Map<String, dynamic>> sosNotifications = [];

      if (user != null) {
        final snapshot = await _firestore
            .collection('notifications')
            .where(
              'receiverId',
              isEqualTo: user.uid,
            )
            .where(
              'type',
              isEqualTo: 'SOS',
            )
            .get();

        sosNotifications = snapshot.docs
            .map((doc) {
              return {
                'id': doc.id,
                ...doc.data(),
              };
            })
            .toList();

        sosNotifications.sort((a, b) {
          final Timestamp aTime =
              a['createdAt'] ?? Timestamp.now();

          final Timestamp bTime =
              b['createdAt'] ?? Timestamp.now();

          return bTime.compareTo(aTime);
        });
      }

      if (!mounted) return;

      setState(() {
        _requests = requests;
        _userDetails = details;
        _sosNotifications = sosNotifications;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'ASTRA: Error loading notifications: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to load notifications.',
      );
    }
  }

  // ============================================================
  // OPEN LOCATION
  // ============================================================

  Future<void> _openLocation(String url) async {
    try {
      final uri = Uri.parse(url);

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showMessage(
          'Unable to open location.',
        );
      }
    } catch (e) {
      _showMessage(
        'Unable to open location.',
      );
    }
  }

  // ============================================================
  // ACCEPT GUARDIAN REQUEST
  // ============================================================

  Future<void> _acceptRequest(
    GuardianRequestModel request,
  ) async {
    try {
      await _requestService.acceptRequest(request.id);

      if (!mounted) return;

      setState(() {
        _requests.removeWhere(
          (item) => item.id == request.id,
        );
      });

      _showMessage(
        'Guardian request accepted.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to accept the request.',
      );
    }
  }

  // ============================================================
  // DECLINE GUARDIAN REQUEST
  // ============================================================

  Future<void> _declineRequest(
    GuardianRequestModel request,
  ) async {
    try {
      await _requestService.declineRequest(request.id);

      if (!mounted) return;

      setState(() {
        _requests.removeWhere(
          (item) => item.id == request.id,
        );
      });

      _showMessage(
        'Guardian request declined.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to decline the request.',
      );
    }
  }

  // ============================================================
  // DELETE GUARDIAN REQUEST
  // ============================================================

  Future<void> _deleteRequest(
    GuardianRequestModel request,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Notification?'),
          content: const Text(
            'This will remove this guardian request '
            'from your notifications.',
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _requestService.deleteRequest(request.id);

      if (!mounted) return;

      setState(() {
        _requests.removeWhere(
          (item) => item.id == request.id,
        );
      });

      _showMessage(
        'Notification deleted.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to delete notification.',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // SOS CARD
  // ============================================================

  Widget _buildSOSCard(
    Map<String, dynamic> notification,
  ) {
    final String title =
        notification['title']?.toString() ??
        '🚨 Emergency SOS';

    final String body =
        notification['body']?.toString() ??
        'An emergency SOS has been activated.';

    final String locationUrl =
        notification['locationUrl']?.toString() ??
        '';

    final Timestamp createdAt =
        notification['createdAt'] ??
        Timestamp.now();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.redAccent,
                  size: 30,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            body,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          if (locationUrl.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _openLocation(locationUrl);
                },
                icon: const Icon(
                  Icons.location_on_rounded,
                ),
                label: const Text(
                  'View Current Location',
                ),
              ),
            ),

          const SizedBox(height: 12),

          Text(
            _formatTime(createdAt),
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              color: AppColors.textPrimary.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GUARDIAN REQUEST CARD
  // ============================================================

  Widget _buildRequestCard(
    GuardianRequestModel request,
  ) {
    final details =
        _userDetails[request.senderId];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

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
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {
                  _deleteRequest(request);
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _declineRequest(request);
                  },
                  child: const Text('Decline'),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _acceptRequest(request);
                  },
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TIME FORMAT
  // ============================================================

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();

    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool hasNotifications =
        _requests.isNotEmpty ||
        _sosNotifications.isNotEmpty;

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
                  Text(
                    'Notifications',
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
                    'Stay updated with your ASTRA activity',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 35),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: CircularProgressIndicator(),
                    )

                  else if (!hasNotifications)
                    GlassCard(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          Icon(
                            Icons.notifications_none_rounded,
                            size: 65,
                            color: AppColors.heading,
                          ),

                          const SizedBox(height: 18),

                          Text(
                            'You\'re All Caught Up',
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
                            'You have no new notifications.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 15),
                        ],
                      ),
                    )

                  else
                    Column(
                      children: [
                        // ------------------------------------------------
                        // SOS NOTIFICATIONS
                        // ------------------------------------------------

                        for (final notification
                            in _sosNotifications) ...[
                          _buildSOSCard(notification),
                          const SizedBox(height: 18),
                        ],

                        // ------------------------------------------------
                        // GUARDIAN REQUESTS
                        // ------------------------------------------------

                        for (final request in _requests) ...[
                          _buildRequestCard(request),
                          const SizedBox(height: 18),
                        ],
                      ],
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