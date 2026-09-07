import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';

import '../../services/guardian_request_service.dart';
import '../../services/message_service.dart';

import '../../models/guardian_relationship_model.dart';
import '../../models/message_model.dart';

import 'chat_screen.dart';
import '../home/home_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final GuardianRequestService _guardianService =
      GuardianRequestService();

  final MessageService _messageService =
      MessageService();

  bool _isLoading = true;

  final Map<String, Map<String, dynamic>> _users = {};

  final Map<String, MessageModel?> _lastMessages = {};

  @override
  void initState() {
    super.initState();
    _loadInbox();
  }

  // ------------------------------------------------------------
  // LOAD INBOX
  // ------------------------------------------------------------

  Future<void> _loadInbox() async {
    try {
      final myGuardians =
          await _guardianService.getMyGuardians();

      final usersIGuard =
          await _guardianService.getUsersIGuard();

      final Map<String, GuardianRelationshipModel>
          relationships = {};

      // People who guard me
      for (final relationship in myGuardians) {
        relationships[relationship.guardianId] =
            relationship;
      }

      // People I guard
      for (final relationship in usersIGuard) {
        relationships[relationship.userId] =
            relationship;
      }

      for (final userId in relationships.keys) {
        final details =
            await _guardianService.getUserDetails(
          userId,
        );

        if (details != null) {
          _users[userId] = details;
        }

        final lastMessage =
            await _messageService.getLastMessage(
          userId,
        );

        _lastMessages[userId] = lastMessage;
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'ASTRA: Error loading inbox: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to load messages.',
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
  // CONVERSATION CARD
  // ------------------------------------------------------------

  Widget _buildConversationCard(
    String userId,
  ) {
    final details = _users[userId];

    final String name =
        details?['name']?.toString() ??
        'ASTRA User';

    final String phone =
        details?['phone']?.toString() ??
        '';

    final MessageModel? lastMessage =
        _lastMessages[userId];

    final String preview =
        lastMessage?.message ??
        'Start a conversation';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              otherUserId: userId,
              otherUserName: name,
            ),
          ),
        ).then((_) {
          _loadInbox();
        });
      },
      child: GlassCard(
        child: Row(
          children: [
            // ----------------------------------------------------
            // PROFILE ICON
            // ----------------------------------------------------

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

            // ----------------------------------------------------
            // USER INFO
            // ----------------------------------------------------

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily:
                          'PlusJakartaSans',
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          AppColors.heading,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    phone.isNotEmpty
                        ? phone
                        : 'Guardian',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily:
                          'PlusJakartaSans',
                      fontSize: 12,
                      color:
                          AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    preview,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily:
                          'PlusJakartaSans',
                      fontSize: 13,
                      color: AppColors.textPrimary
                          .withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
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
          const NightSky(),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadInbox,
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
                      'Messages',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily:
                            'PlayfairDisplay',
                        fontSize: 40,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            AppColors.heading,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Stay connected with your guardians',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily:
                            'PlusJakartaSans',
                        fontSize: 16,
                        color:
                            AppColors.textPrimary,
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
                              Icons
                                  .chat_bubble_outline_rounded,
                              size: 65,
                              color:
                                  AppColors.heading,
                            ),

                            const SizedBox(height: 18),

                            Text(
                              'No Conversations Yet',
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
                              'Your guardians and the '
                              'people you guard will '
                              'appear here.',
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
                    // CONVERSATIONS
                    // ------------------------------------------------

                    else
                      Column(
                        children: [
                          for (final userId
                              in _users.keys) ...[
                            _buildConversationCard(
                              userId,
                            ),
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