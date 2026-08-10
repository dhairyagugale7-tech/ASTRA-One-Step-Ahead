import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future sendGuardianJourneyMessage({
    required String phone,
    required String guardianName,
    required String destination,
    required String trackingLink,
  }) async {
    // Remove spaces, brackets, dashes, etc.
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    // If the number is a normal Indian 10-digit number,
    // automatically add India's country code.
    if (cleanPhone.length == 10) {
      cleanPhone = '91$cleanPhone';
    }

    // Remove '+' because wa.me expects digits.
    cleanPhone = cleanPhone.replaceAll('+', '');

    final String message =
        '''Hey $guardianName! 💗

    I'm starting a Guardian Journey with ASTRA.

    📍 Destination: $destination

    You can track my live location here:

    $trackingLink

    Please keep an eye on my journey. Stay safe!''';

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
    );

    try {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('WhatsApp launch error: $e');
      throw Exception('Could not open WhatsApp.');
    }
  }

  static Future<void> sendJourneyCompletedMessage({
    required String phone,
    required String guardianName,
    required String destination,
    required double latitude,
    required double longitude,
  }) async {
    // Clean guardian phone number
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    // If number is 10 digits, assume India (+91)
    if (cleanPhone.length == 10) {
      cleanPhone = '91$cleanPhone';
    }
      
    // Remove + if present
    cleanPhone = cleanPhone.replaceAll('+', '');

    // Google Maps link using final/current location
    final String locationLink =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    // WhatsApp message
    final String message = '''
  Hey $guardianName! 💗

  My Guardian Journey with ASTRA has been completed successfully. ✅

  📍 Destination:
  $destination

  🏁 Journey Status:
  I have safely completed my journey and reached my destination.

  📌 My current location:
  $locationLink

  You can check my current location using the link above.

  Stay safe! 🌙💗
  — ASTRA
  ''';

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
    );

    try {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('WhatsApp completion message error: $e');
      throw Exception('Could not open WhatsApp.');
    }
  }
}