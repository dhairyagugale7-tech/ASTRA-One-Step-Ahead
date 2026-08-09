import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  static Future<void> openWhatsApp({
    required String phoneNumber,
    required String journeyId,
  }) async {
    final trackingUrl = generateCurrentUserTrackingUrl(
      journeyId: journeyId,
    );

    final message = '''
  🌙 ASTRA Guardian Journey

  A Guardian Journey has started.

  📍 Track live location:
  $trackingUrl

  Please keep an eye on the journey.
  ''';

    final whatsappUrl = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('Could not open WhatsApp.');
    }
  }
}