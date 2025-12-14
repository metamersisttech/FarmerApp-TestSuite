import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_app/shared/themes/app_theme.dart';

/// Phone number input field styled like the screenshot (flag + country code).
class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String countryCode;
  final String flagEmoji;
  final String hintText;
  final String? Function(String?)? validator;

  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.enabled,
    this.countryCode = '+91',
    this.flagEmoji = '🇮🇳',
    this.hintText = 'Enter 10 digit number',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: AppTheme.authFieldFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppTheme.authBorderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(flagEmoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                countryCode,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.authTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Container(height: 22, width: 1, color: AppTheme.authBorderColor),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}


