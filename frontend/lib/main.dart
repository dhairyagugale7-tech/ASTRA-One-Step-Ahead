import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/screens/auth/location_permission_screen.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/guardian/add_guardian_screen.dart';
import 'package:frontend/screens/guardian/guardian_management_screen.dart';
import 'package:frontend/screens/guardian/guardian_requests_screen.dart';
import 'package:frontend/screens/guardian/my_guardians_screen.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/journey/journey_active_screen.dart';
import 'package:frontend/screens/sos/sos_active_screen.dart';
import 'package:frontend/screens/sos/sos_setting_screen.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';

import 'screens/journey/journey_setup_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/journey/journey_setup_screen.dart';
import 'screens/journey/journey_active_screen.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final notificationService = NotificationService();

  await notificationService.initialize();

  runApp(const AstraApp());
}

class AstraApp extends StatelessWidget {
  const AstraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ASTRA',
      theme: AppTheme.darkTheme,
      home: HomeScreen(),
    );
  }
}