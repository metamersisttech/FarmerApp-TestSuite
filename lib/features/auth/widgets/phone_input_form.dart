import 'package:flutter/material.dart';
import 'package:flutter_app/core/utils/validators.dart';
import 'package:flutter_app/shared/widgets/auth/phone_number_field.dart';

/// Reusable phone number input form with error display
class PhoneInputForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isLoading;
  final String? errorMessage;
  final bool enabled;

  const PhoneInputForm({
    super.key,
    required this.formKey,
    required this.controller,
    this.isLoading = false,
    this.errorMessage,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          if (errorMessage != null) ...[
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
          ],
          PhoneNumberField(
            controller: controller,
            enabled: enabled && !isLoading,
            validator: Validators.validatePhone,
          ),
        ],
      ),
    );
  }
}

