import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nightsky.dart';
import '../../widgets/primary_button.dart';

import '../../models/guardian_model.dart';
import '../../services/guardian_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'guardian_management_screen.dart';

class EditGuardianScreen extends StatefulWidget {
  final GuardianModel guardian;

  const EditGuardianScreen({
    super.key,
    required this.guardian,
  });


  @override
  State<EditGuardianScreen> createState() => _EditGuardianScreenState();
}

class _EditGuardianScreenState extends State<EditGuardianScreen> {

  final TextEditingController nameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController relationshipController = TextEditingController();

  bool isPrimary = true;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  bool validateInputs() {

    if (nameController.text.trim().isEmpty) {
      showMessage("Please enter guardian's name.");
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      showMessage("Please enter guardian's phone number.");
      return false;
    }

    if (relationshipController.text.trim().isEmpty) {
      showMessage("Please enter relationship.");
      return false;
    }

    if (phoneController.text.trim().length != 10) {
      showMessage("Phone number must be 10 digits.");
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();

    nameController.text = widget.guardian.name;
    phoneController.text = widget.guardian.phone;
    relationshipController.text = widget.guardian.relationship;

    isPrimary = widget.guardian.isPrimary;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    relationshipController.dispose();
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

                      const Text(
                        'Edit Guardian',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Change is Permanent',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          color: AppColors.textPrimary,
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
                              controller: nameController,
                            ),

                            const SizedBox(height: 20),

                            CustomTextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: 20),

                            CustomTextField(
                              controller: relationshipController,
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
                                  groupValue: isPrimary,
                                  activeColor: AppColors.heading,
                                  onChanged: (value) {
                                    setState(() {
                                      isPrimary = value!;
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

                                const SizedBox(width: 20),

                                Radio<bool>(
                                  value: false,
                                  groupValue: isPrimary,
                                  activeColor: AppColors.heading,
                                  onChanged: (value) {
                                    setState(() {
                                      isPrimary = value!;
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
                              child: PrimaryButton(
                                text: 'Save Changes',
                                width: 210,
                                fontSize: 18,
                                onPressed: () async {

                                  if (!validateInputs()) return;

                                  try {

                                    GuardianModel updatedGuardian = GuardianModel(
                                      id: widget.guardian.id,
                                      name: nameController.text.trim(),
                                      phone: phoneController.text.trim(),
                                      relationship: relationshipController.text.trim(),
                                      isPrimary: isPrimary,
                                      createdAt: widget.guardian.createdAt,
                                    );

                                    await GuardianService().updateGuardian(updatedGuardian);

                                    if (!mounted) return;

                                    showMessage("Guardian updated successfully!");

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

                                  }

                                },
                              ),
                            ),

                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: PrimaryButton(
                          text: 'Delete Guardian',
                          width: 230,
                          fontSize: 18,
                          onPressed: () {

                            showDialog(
                              context: context,
                              builder: (context) {

                                return AlertDialog(

                                  title: const Text(
                                    "Delete Guardian",
                                  ),

                                  content: const Text(
                                    "Are you sure you want to delete this guardian?",
                                  ),

                                  actions: [

                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancel"),
                                    ),

                                    TextButton(
                                      onPressed: () async {

                                        try {

                                          await GuardianService()
                                              .deleteGuardian(widget.guardian.id);

                                          if (!mounted) return;

                                          Navigator.pop(context); // Close Dialog

                                          showMessage("Guardian deleted successfully!");

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const GuardianManagementScreen(),
                                            ),
                                          ); // Back to previous screen

                                        } on FirebaseException catch (e) {

                                          Navigator.pop(context);

                                          showMessage(
                                            e.message ?? "Something went wrong.",
                                          );

                                        } catch (_) {

                                          Navigator.pop(context);

                                          showMessage("Something went wrong.");

                                        }

                                      },
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),

                                  ],
                                );

                              },
                            );

                          },
                        ),
                      ),

                      const SizedBox(height: 15),
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
        ],
      ),
    );
  }
}