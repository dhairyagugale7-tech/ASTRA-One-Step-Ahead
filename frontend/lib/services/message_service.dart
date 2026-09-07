import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';

class MessageService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // CURRENT USER
  // ============================================================

  String get currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    return user.uid;
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> sendMessage({
    required String receiverId,
    required String message,
    String messageType = 'text',
  }) async {
    final senderId = currentUserId;

    final text = message.trim();

    if (text.isEmpty) {
      return;
    }

    final newMessage = MessageModel(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      message: text,
      messageType: messageType,
      createdAt: Timestamp.now(),
    );

    await _firestore
        .collection('messages')
        .add(
          newMessage.toMap(),
        );
  }

  // ============================================================
  // GET MESSAGES
  // ============================================================

  Stream<List<MessageModel>> getMessages(
    String otherUserId,
  ) {
    final userId = currentUserId;

    final sentStream = _firestore
        .collection('messages')
        .where(
          'senderId',
          isEqualTo: userId,
        )
        .where(
          'receiverId',
          isEqualTo: otherUserId,
        )
        .snapshots();

    final receivedStream = _firestore
        .collection('messages')
        .where(
          'senderId',
          isEqualTo: otherUserId,
        )
        .where(
          'receiverId',
          isEqualTo: userId,
        )
        .snapshots();

    return Stream.multi(
      (controller) {
        List<MessageModel> sentMessages = [];
        List<MessageModel> receivedMessages = [];

        void emitMessages() {
          final messages = [
            ...sentMessages,
            ...receivedMessages,
          ];

          messages.sort(
            (a, b) => a.createdAt.compareTo(
              b.createdAt,
            ),
          );

          controller.add(messages);
        }

        final sentSubscription =
            sentStream.listen(
          (snapshot) {
            sentMessages = snapshot.docs
                .map(
                  (doc) => MessageModel.fromMap(
                    doc.data(),
                    doc.id,
                  ),
                )
                .toList();

            emitMessages();
          },
          onError: controller.addError,
        );

        final receivedSubscription =
            receivedStream.listen(
          (snapshot) {
            receivedMessages = snapshot.docs
                .map(
                  (doc) => MessageModel.fromMap(
                    doc.data(),
                    doc.id,
                  ),
                )
                .toList();

            emitMessages();
          },
          onError: controller.addError,
        );

        controller.onCancel = () async {
          await sentSubscription.cancel();
          await receivedSubscription.cancel();
        };
      },
    );
  }

  // ============================================================
  // GET LAST MESSAGE
  // ============================================================

  Future<MessageModel?> getLastMessage(
    String otherUserId,
  ) async {
    final userId = currentUserId;

    final sentSnapshot = await _firestore
        .collection('messages')
        .where(
          'senderId',
          isEqualTo: userId,
        )
        .where(
          'receiverId',
          isEqualTo: otherUserId,
        )
        .get();

    final receivedSnapshot = await _firestore
        .collection('messages')
        .where(
          'senderId',
          isEqualTo: otherUserId,
        )
        .where(
          'receiverId',
          isEqualTo: userId,
        )
        .get();

    final messages = [
      ...sentSnapshot.docs.map(
        (doc) => MessageModel.fromMap(
          doc.data(),
          doc.id,
        ),
      ),
      ...receivedSnapshot.docs.map(
        (doc) => MessageModel.fromMap(
          doc.data(),
          doc.id,
        ),
      ),
    ];

    if (messages.isEmpty) {
      return null;
    }

    messages.sort(
      (a, b) => a.createdAt.compareTo(
        b.createdAt,
      ),
    );

    return messages.last;
  }

  // ============================================================
  // DELETE MESSAGE
  // ============================================================

  Future<void> deleteMessage(
    String messageId,
  ) async {
    await _firestore
        .collection('messages')
        .doc(messageId)
        .delete();
  }
}