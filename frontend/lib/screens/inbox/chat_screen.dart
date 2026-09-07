import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/colors.dart';
import '../../models/message_model.dart';
import '../../services/message_service.dart';
import '../../services/location_service.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService =
      MessageService();

  final LocationService _locationService =
      LocationService();

  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  // ============================================================
  // SEND NORMAL MESSAGE
  // ============================================================

  Future<void> _sendMessage() async {
    final text =
        _messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    try {
      await _messageService.sendMessage(
        receiverId: widget.otherUserId,
        message: text,
      );

      _messageController.clear();

      if (!mounted) return;

      Future.delayed(
        const Duration(milliseconds: 200),
        _scrollToBottom,
      );
    } catch (e) {
      _showMessage(
        'Unable to send message.',
      );
    }
  }

  // ============================================================
  // SEND CURRENT LOCATION
  // ============================================================

  Future<void> _sendCurrentLocation() async {
    try {
      final position =
          await _locationService.getCurrentLocation();

      final latitude = position.latitude;
      final longitude = position.longitude;

      final locationUrl =
          'https://www.google.com/maps/search/?api=1'
          '&query=$latitude,$longitude';

      final message =
          '📍 Current Location\n'
          '$locationUrl';

      await _messageService.sendMessage(
        receiverId: widget.otherUserId,
        message: message,
        messageType: 'location',
      );

      _showMessage(
        'Current location shared.',
      );

      Future.delayed(
        const Duration(milliseconds: 200),
        _scrollToBottom,
      );
    } catch (e) {
      _showMessage(
        'Unable to get current location.',
      );
    }
  }

  // ============================================================
  // SEND LIVE LOCATION
  // ============================================================

  Future<void> _sendLiveLocation() async {
    try {
      final userId =
          _messageService.currentUserId;

      final snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(userId)
          .collection('journeys')
          .where(
            'isActive',
            isEqualTo: true,
          )
          .where(
            'shareLiveLocation',
            isEqualTo: true,
          )
          .get();

      if (snapshot.docs.isEmpty) {
        _showMessage(
          'No active live location journey found.',
        );
        return;
      }

      // Find the most recent active journey.
      final documents =
          [...snapshot.docs];

      documents.sort((a, b) {
        final Timestamp aTime =
            a.data()['startedAt'] ??
            Timestamp.fromDate(
              DateTime.fromMillisecondsSinceEpoch(0),
            );

        final Timestamp bTime =
            b.data()['startedAt'] ??
            Timestamp.fromDate(
              DateTime.fromMillisecondsSinceEpoch(0),
            );

        return bTime.compareTo(aTime);
      });

      final journeyId =
          documents.first.id;

      final trackingUrl =
          'https://astra-one-step-ahead.web.app/'
          '?uid=$userId&journeyId=$journeyId';

      final message =
          '🛡️ Live Location\n'
          'Track my live location with ASTRA:\n'
          '$trackingUrl';

      await _messageService.sendMessage(
        receiverId: widget.otherUserId,
        message: message,
        messageType: 'live_location',
      );

      _showMessage(
        'Live location shared.',
      );

      Future.delayed(
        const Duration(milliseconds: 200),
        _scrollToBottom,
      );
    } catch (e) {
      debugPrint(
        'ASTRA: Live location error: $e',
      );

      _showMessage(
        'Unable to share live location.',
      );
    }
  }

  // ============================================================
  // OPEN LINK
  // ============================================================

  Future<void> _openLink(
    String url,
  ) async {
    final Uri uri =
        Uri.parse(url);

    try {
      final launched =
          await launchUrl(
        uri,
        mode:
            LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showMessage(
          'Unable to open link.',
        );
      }
    } catch (e) {
      debugPrint(
        'ASTRA: Unable to open URL: $e',
      );

      _showMessage(
        'Unable to open link.',
      );
    }
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration:
          const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget _buildMessageBubble(
    MessageModel message,
  ) {
    final bool isMine =
        message.senderId ==
            _messageService.currentUserId;

    // ============================================================
    // CURRENT LOCATION MESSAGE
    // ============================================================

    if (message.messageType == 'location') {
      final RegExp urlRegex =
          RegExp(r'https?://[^\s]+');

      final match =
          urlRegex.firstMatch(message.message);

      final String? locationUrl =
          match?.group(0);

      return Align(
        alignment: isMine
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          width: 250,
          margin:
              const EdgeInsets.only(bottom: 10),
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isMine
                ? AppColors.headerBackground
                : Colors.white.withOpacity(0.12),
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: isMine
                        ? Colors.white
                        : AppColors.heading,
                    size: 25,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Current Location',
                      style: TextStyle(
                        fontFamily:
                            'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        color: isMine
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      locationUrl == null
                          ? null
                          : () {
                              _openLink(
                                locationUrl,
                              );
                            },
                  icon: const Icon(
                    Icons.map_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Open Location',
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.black.withOpacity(
                      0.35,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ============================================================
    // LIVE LOCATION MESSAGE
    // ============================================================

    if (message.messageType == 'live_location') {
      final RegExp urlRegex =
          RegExp(r'https?://[^\s]+');

      final match =
          urlRegex.firstMatch(message.message);

      final String? trackingUrl =
          match?.group(0);

      return Align(
        alignment: isMine
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          width: 270,
          margin:
              const EdgeInsets.only(bottom: 10),
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isMine
                ? AppColors.headerBackground
                : Colors.white.withOpacity(0.12),
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.my_location_rounded,
                    color: isMine
                        ? Colors.white
                        : AppColors.heading,
                    size: 25,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Live Location',
                      style: TextStyle(
                        fontFamily:
                            'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        color: isMine
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                'Track this person\'s live journey with ASTRA.',
                style: TextStyle(
                  fontFamily:
                      'PlusJakartaSans',
                  fontSize: 13,
                  color: isMine
                      ? Colors.white.withOpacity(
                          0.85,
                        )
                      : AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      trackingUrl == null
                          ? null
                          : () {
                              _openLink(
                                trackingUrl,
                              );
                            },
                  icon: const Icon(
                    Icons.location_searching_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Track Live Location',
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.black.withOpacity(
                      0.35,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ============================================================
    // NORMAL TEXT MESSAGE
    // ============================================================

    final RegExp urlRegex =
        RegExp(r'https?://[^\s]+');

    final List<InlineSpan> spans = [];

    int lastIndex = 0;

    for (final match
        in urlRegex.allMatches(
      message.message,
    )) {
      final String beforeUrl =
          message.message.substring(
        lastIndex,
        match.start,
      );

      if (beforeUrl.isNotEmpty) {
        spans.add(
          TextSpan(
            text: beforeUrl,
          ),
        );
      }

      final String url =
          match.group(0)!;

      spans.add(
        WidgetSpan(
          child: GestureDetector(
            onTap: () {
              _openLink(url);
            },
            child: Text(
              url,
              style: TextStyle(
                fontFamily:
                    'PlusJakartaSans',
                fontSize: 14,
                color: isMine
                    ? Colors.white
                    : AppColors.heading,
                decoration:
                    TextDecoration.underline,
                decorationColor: isMine
                    ? Colors.white
                    : AppColors.heading,
              ),
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    final String remainingText =
        message.message.substring(
      lastIndex,
    );

    if (remainingText.isNotEmpty) {
      spans.add(
        TextSpan(
          text: remainingText,
        ),
      );
    }

    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 10,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 11,
        ),
        constraints:
            BoxConstraints(
          maxWidth:
              MediaQuery.of(context)
                      .size
                      .width *
                  0.75,
        ),
        decoration:
            BoxDecoration(
          color: isMine
              ? AppColors.headerBackground
              : Colors.white.withOpacity(0.12),
          borderRadius:
              BorderRadius.only(
            topLeft:
                const Radius.circular(18),
            topRight:
                const Radius.circular(18),
            bottomLeft:
                Radius.circular(
              isMine ? 18 : 4,
            ),
            bottomRight:
                Radius.circular(
              isMine ? 4 : 18,
            ),
          ),
        ),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily:
                  'PlusJakartaSans',
              fontSize: 14,
              color: isMine
                  ? Colors.white
                  : AppColors.textPrimary,
            ),
            children: spans,
          ),
        ),
      ),
    );
  }
  // ============================================================
  // LOCATION ACTION BUTTON
  // ============================================================

  Widget _buildLocationButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
        ),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: Colors.white
                .withOpacity(0.25),
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          padding:
              const EdgeInsets.symmetric(
            vertical: 11,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF17132E),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF352B59),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                widget.otherUserName,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily:
                      'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // ======================================================
          // MESSAGES
          // ======================================================

          Expanded(
            child: StreamBuilder<
                List<MessageModel>>(
              stream:
                  _messageService
                      .getMessages(
                widget.otherUserId,
              ),

              builder:
                  (context, snapshot) {
                if (snapshot
                        .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to load messages.',
                      style: TextStyle(
                        color: AppColors
                            .textPrimary,
                      ),
                    ),
                  );
                }

                final messages =
                    snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Start your conversation.',
                      style: TextStyle(
                        fontFamily:
                            'PlusJakartaSans',
                        fontSize: 15,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),
                  );
                }

                WidgetsBinding
                    .instance
                    .addPostFrameCallback(
                  (_) =>
                      _scrollToBottom(),
                );

                return ListView.builder(
                  controller:
                      _scrollController,
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    18,
                    20,
                    18,
                    10,
                  ),
                  itemCount:
                      messages.length,
                  itemBuilder:
                      (context, index) {
                    return _buildMessageBubble(
                      messages[index],
                    );
                  },
                );
              },
            ),
          ),

          // ======================================================
          // LOCATION BUTTONS
          // ======================================================

          SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                12,
                4,
                12,
                4,
              ),
              child: Row(
                children: [
                  _buildLocationButton(
                    icon:
                        Icons.location_on_rounded,
                    label:
                        'Current Location',
                    onPressed:
                        _sendCurrentLocation,
                  ),

                  const SizedBox(width: 8),

                  _buildLocationButton(
                    icon:
                        Icons.my_location_rounded,
                    label:
                        'Live Location',
                    onPressed:
                        _sendLiveLocation,
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // MESSAGE INPUT
          // ======================================================

          SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          _messageController,
                      textInputAction:
                          TextInputAction.send,
                      onSubmitted: (_) {
                        _sendMessage();
                      },
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontFamily:
                            'PlusJakartaSans',
                      ),
                      decoration:
                          InputDecoration(
                        hintText:
                            'Type a message...',
                        hintStyle:
                            TextStyle(
                          color: Colors.white
                              .withOpacity(
                            0.55,
                          ),
                        ),
                        filled: true,
                        fillColor:
                            Colors.white
                                .withOpacity(
                          0.10,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            24,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    width: 50,
                    height: 50,
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .headerBackground,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed:
                          _sendMessage,
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}