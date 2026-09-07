import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../services/guardian_request_service.dart';
import '../../models/guardian_request_model.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';

class GuardianRequestsScreen extends StatefulWidget {
  const GuardianRequestsScreen({super.key});

  @override
  State<GuardianRequestsScreen> createState() =>
      _GuardianRequestsScreenState();
}

class _GuardianRequestsScreenState
    extends State<GuardianRequestsScreen> {
  final GuardianRequestService _requestService =
      GuardianRequestService();

  List<GuardianRequestModel> _requests = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final requests =
          await _requestService.getReceivedRequests();

      if (!mounted) return;

      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to load guardian requests.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

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

      _showMessage('Guardian request declined.');
    } catch (_) {
      _showMessage(
        'Unable to decline the request.',
      );
    }
  }

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
    } catch (_) {
      _showMessage(
        'Unable to accept the request.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const NightSky(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  Text(
                    'Guardian Requests',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: AppColors.heading,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'People who want you to be their guardian.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: _buildRequestList(),
                  ),
                ],
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
        ],
      ),
    );
  }

  Widget _buildRequestList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_requests.isEmpty) {
      return Center(
        child: Text(
          'No pending guardian requests.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 17,
            color: AppColors.textPrimary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: GlassCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AppColors.heading,
                      size: 32,
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        'New Guardian Request',
                        style: TextStyle(
                          fontFamily:
                              'PlusJakartaSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.heading,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Text(
                  'Someone wants you to become their guardian on ASTRA.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

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
          ),
        );
      },
    );
  }
}