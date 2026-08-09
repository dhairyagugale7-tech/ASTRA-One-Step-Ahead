import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class TrackingService {
  static const String trackingBaseUrl =
      'http://127.0.0.1:5500/tracking/index.html';

  static String generateTrackingUrl({
    required String userId,
    required String journeyId,
  }) {
    return '$trackingBaseUrl'
        '?uid=$userId&journeyId=$journeyId';
  }

  static String generateCurrentUserTrackingUrl({
    required String journeyId,
  }) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    return generateTrackingUrl(
      userId: user.uid,
      journeyId: journeyId,
    );
  }

  static Future<void> shareTrackingUrl({
    required String journeyId,
  }) async {
    final trackingUrl = generateCurrentUserTrackingUrl(
      journeyId: journeyId,
    );

    await SharePlus.instance.share(
      ShareParams(
        text: 'Track my live location with ASTRA:\n$trackingUrl',
      ),
    );
  }
}