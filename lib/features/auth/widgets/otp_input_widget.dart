import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Reusable OTP input widget with 6 fields
class OtpInputWidget extends StatefulWidget {
  final Function(String) onCompleted;
  final Function(String) onChanged;
  final bool enabled;
  final int length;

  const OtpInputWidget({
    super.key,
    required this.onCompleted,
    required this.onChanged,
    this.enabled = true,
    this.length = 6,
  });

  @override
  State<OtpInputWidget> createState() => OtpInputWidgetState();
}

class OtpInputWidgetState extends State<OtpInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Clear all OTP fields
  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  /// Get OTP value
  String get otp => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 45,
          height: 55,
          child: _buildOtpField(index),
        );
      }),
    );
  }

  Widget _buildOtpField(int index) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
          if (_controllers[index].text.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
            _controllers[index - 1].clear();
          }
        }
      },
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        enabled: widget.enabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppTheme.authTextPrimary,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < widget.length - 1) {
              _focusNodes[index + 1].requestFocus();
            } else {
              FocusScope.of(context).unfocus();
            }
          }
          widget.onChanged(otp);
          if (otp.length == widget.length) {
            widget.onCompleted(otp);
          }
        },
        onTap: () {
          if (_controllers[index].text.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
        onEditingComplete: () {
          if (index < widget.length - 1 && _controllers[index].text.isNotEmpty) {
            _focusNodes[index + 1].requestFocus();
          }
        },
      ),
    );
  }
}

