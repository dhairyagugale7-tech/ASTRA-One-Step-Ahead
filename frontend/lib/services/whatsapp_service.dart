import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future<void> sendGuardianJourneyMessage({
    required String phone,
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
        '''Hey! I'm starting a Guardian Journey with ASTRA. 💗

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
}