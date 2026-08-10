import 'package:flutter/material.dart';
import 'package:frontend/screens/guardian/guardian_management_screen.dart';

import '../../config/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';
import '../../services/guardian_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/guardian_model.dart';
import '../home/home_screen.dart';

class AddGuardianScreen extends StatefulWidget {
  const AddGuardianScreen({super.key});

  @override
  State<AddGuardianScreen> createState() => _AddGuardianScreenState();
}

class _AddGuardianScreenState extends State<AddGuardianScreen> {

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _relationshipController =
      TextEditingController();

  bool _isPrimary = false;

  bool isLoading = false;

  final GuardianService _guardianService = GuardianService();

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  bool validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      showMessage("Please enter guardian's name.");
      return false;
    }

    if (_phoneController.text.trim().isEmpty) {
      showMessage("Please enter guardian's phone number.");
      return false;
    }

    if (_relationshipController.text.trim().isEmpty) {
      showMessage("Please enter relationship.");
      return false;
    }

    if (_phoneController.text.trim().length != 10) {
      showMessage("Phone number must be 10 digits.");
      return false;
    }

    return true;
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
                        'Add someone you trust to receive\n'
                        'your journey alerts and SOS updates.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Image.asset(
                        'assets/images/add_guardian_and_edit_guardian.png',
                        height: 230,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 20),

                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            CustomTextField(
                              controller: _nameController,
                              hintText: 'Full name',
                              keyboardType: TextInputType.text,
                            ),

                            const SizedBox(height: 20),

                            CustomTextField(
                              controller: _phoneController,
                              hintText: 'Phone Number',
                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: 20),

                            CustomTextField(
                              controller: _relationshipController,
                              hintText: 'Relationship',
                              keyboardType: TextInputType.text,
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              'Make Primary?',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 18,
                                color: AppColors.heading,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [

                                Radio<bool>(
                                  value: true,
                                  groupValue: _isPrimary,
                                  activeColor: AppColors.heading,
                                  onChanged: (value) {
                                    setState(() {
                                      _isPrimary = value!;
                                    });
                                  },
                                ),

                                const Text(
                                  'Yes',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 16,
                                    color: AppColors.heading,
                                  ),
                                ),

                                const SizedBox(width: 24),

                                Radio<bool>(
                                  value: false,
                                  groupValue: _isPrimary,
                                  activeColor: AppColors.heading,
                                  onChanged: (value) {
                                    setState(() {
                                      _isPrimary = value!;
                                    });
                                  },
                                ),

                                const Text(
                                  'No',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 16,
                                    color: AppColors.heading,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            Center(
                              child : PrimaryButton(
                                text: 'Add Guardian',
                                onPressed: () async {
                                  if (!validateInputs()) return;

                                  setState(() {
                                    isLoading = true;
                                  });

                                  try {
                                    GuardianModel guardian = GuardianModel(
                                      id: '',
                                      name: _nameController.text.trim(),
                                      phone: _phoneController.text.trim(),
                                      relationship: _relationshipController.text.trim(),
                                      isPrimary: _isPrimary,
                                      createdAt: Timestamp.now(),
                                    );

                                    await _guardianService.addGuardian(guardian);

                                    if (!mounted) return;

                                    showMessage("Guardian added successfully!");

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const GuardianManagementScreen(),
                                      ),
                                    );

                                  } on FirebaseException catch (e) {
                                    showMessage(e.message ?? "Something went wrong.");
                                  } catch (_) {
                                    showMessage("Something went wrong.");
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  }
                                },
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
          Positioned(
            bottom: 20,
            right : 20,
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