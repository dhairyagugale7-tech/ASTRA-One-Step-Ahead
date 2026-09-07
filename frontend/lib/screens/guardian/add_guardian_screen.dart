import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';

import '../../services/guardian_request_service.dart';

import 'guardian_management_screen.dart';
import '../home/home_screen.dart';

class AddGuardianScreen extends StatefulWidget {
  const AddGuardianScreen({super.key});

  @override
  State<AddGuardianScreen> createState() => _AddGuardianScreenState();
}

class _AddGuardianScreenState extends State<AddGuardianScreen> {
  final TextEditingController _contactController =
      TextEditingController();

  final GuardianRequestService _requestService =
      GuardianRequestService();

  bool isLoading = false;

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  bool validateInput() {
    final value = _contactController.text.trim();

    if (value.isEmpty) {
      showMessage(
        "Please enter the guardian's phone number or email.",
      );
      return false;
    }

    return true;
  }

  Future<void> sendGuardianRequest() async {
    if (!validateInput()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final String input = _contactController.text.trim();

      debugPrint('Guardian request input: $input');

      // ----------------------------------------------------------
      // STEP 1: Find the ASTRA user
      // ----------------------------------------------------------

      final String? receiverId =
          await _requestService.findUserByPhoneOrEmail(input);

      debugPrint('Found receiver ID: $receiverId');

      if (!mounted) return;

      // ----------------------------------------------------------
      // STEP 2: User not found
      // ----------------------------------------------------------

      if (receiverId == null) {
        showMessage(
          "No ASTRA user found with this phone number or email.",
        );
        return;
      }

      // ----------------------------------------------------------
      // STEP 3: Send guardian request
      // ----------------------------------------------------------

      debugPrint('Sending guardian request to: $receiverId');

      debugPrint('ASTRA: User found. Receiver ID = $receiverId');

      debugPrint('ASTRA: Sending guardian request...');

      await _requestService.sendRequest(receiverId);

      debugPrint('ASTRA: Guardian request created successfully.');

      debugPrint('Guardian request sent successfully.');

      if (!mounted) return;

      showMessage(
        "Guardian request sent successfully!",
      );

      // ----------------------------------------------------------
      // STEP 4: Return to Guardian Management
      // ----------------------------------------------------------

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const GuardianManagementScreen(),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Guardian request ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      final String error = e.toString().toLowerCase();

      // ----------------------------------------------------------
      // Known errors
      // ----------------------------------------------------------

      if (error.contains('already sent')) {
        showMessage(
          "Guardian request already sent.",
        );
      } else if (error.contains('yourself')) {
        showMessage(
          "You cannot send a guardian request to yourself.",
        );
      } else if (error.contains('permission-denied')) {
        showMessage(
          "ASTRA does not have permission to create guardian requests.",
        );
      } else if (error.contains('failed-precondition')) {
        showMessage(
          "Firestore needs an index for this request. "
          "Check the Firebase console.",
        );
      } else if (error.contains('unauthenticated')) {
        showMessage(
          "Please log in again before sending a guardian request.",
        );
      } else if (error.contains('network')) {
        showMessage(
          "Network error. Please check your internet connection.",
        );
      } else {
        // IMPORTANT:
        // During development, show the actual Firebase error.
        showMessage(
          "Guardian request failed:\n$e",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const NightSky(),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 70),

                      // --------------------------------------------------
                      // TITLE
                      // --------------------------------------------------

                      Text(
                        'Add Guardian',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Send a request to someone you trust\n'
                        'to become your guardian.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --------------------------------------------------
                      // IMAGE
                      // --------------------------------------------------

                      Image.asset(
                        'assets/images/add_guardian_and_edit_guardian.png',
                        height: 230,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 20),

                      // --------------------------------------------------
                      // FORM
                      // --------------------------------------------------

                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find your guardian',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.heading,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Enter their phone number or email '
                              'registered with ASTRA.',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 20),

                            CustomTextField(
                              controller: _contactController,
                              hintText: 'Phone number or email',
                              keyboardType:
                                  TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 28),

                            Center(
                              child: PrimaryButton(
                                text: isLoading
                                    ? 'Sending...'
                                    : 'Send Request',
                                onPressed: isLoading
                                    ? null
                                    : sendGuardianRequest,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --------------------------------------------------------------
          // BACK BUTTON
          // --------------------------------------------------------------

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

          // --------------------------------------------------------------
          // HOME BUTTON
          // --------------------------------------------------------------

          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
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