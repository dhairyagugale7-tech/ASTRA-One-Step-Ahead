import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/screens/auth/auth_wrapper.dart';

import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'screens/splash/splash_screen.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/create_account_screen.dart';
import 'screens/auth/location_permission_screen.dart';
import 'screens/auth/notification_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

import 'screens/guardian/guardian_setup_screen.dart';
import 'screens/guardian/add_guardian_screen.dart';
import 'screens/guardian/guardian_management_screen.dart';
import 'screens/guardian/guardian_management_screen.dart';
import 'screens/guardian/edit_guardian_screen.dart';

import 'screens/home/home_screen.dart';

import 'screens/journey/journey_setup_screen.dart';
import 'screens/journey/guardian_selection_screen.dart';
import 'screens/journey/journey_active_screen.dart';
import 'screens/journey/journey_completed_screen.dart';

import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';

import 'screens/sos/sos_setting_screen.dart';
import 'screens/sos/sos_active_screen.dart';

import 'screens/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home: LocationPermissionScreen(),
    );
  }
}