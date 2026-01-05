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
    
    // Add listeners to each controller to handle auto-focus
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].addListener(() => _handleTextChange(i));
    }
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

  /// Handle text change and auto-focus to next field
  void _handleTextChange(int index) {
    final text = _controllers[index].text;
    
    // If user types more than one character (paste or fast typing)
    if (text.length > 1) {
      // Take only the first character
      _controllers[index].text = text[0];
      _controllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: 1),
      );
      
      // If there's more text, put it in the next fields
      if (index < widget.length - 1 && text.length > 1) {
        final remaining = text.substring(1);
        _fillRemainingFields(index + 1, remaining);
      }
    }
  }

  /// Fill remaining fields with pasted text
  void _fillRemainingFields(int startIndex, String text) {
    for (int i = 0; i < text.length && (startIndex + i) < widget.length; i++) {
      _controllers[startIndex + i].text = text[i];
    }
    
    // Move focus to the last filled field or next empty field
    final lastFilledIndex = (startIndex + text.length - 1).clamp(0, widget.length - 1);
    if (lastFilledIndex < widget.length - 1 && _controllers[lastFilledIndex + 1].text.isEmpty) {
      _focusNodes[lastFilledIndex + 1].requestFocus();
    } else {
      _focusNodes[lastFilledIndex].requestFocus();
    }
    
    // Notify parent
    widget.onChanged(otp);
    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

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
          // Handle text input
          if (value.isNotEmpty) {
            // Move to next field if current field has text
            if (index < widget.length - 1) {
              // Use a small delay to ensure the text is set before moving focus
              Future.microtask(() {
                if (mounted) {
                  _focusNodes[index + 1].requestFocus();
                }
              });
            } else {
              // Last field - unfocus keyboard
              FocusScope.of(context).unfocus();
            }
          }
          
          // Notify parent of OTP change
          widget.onChanged(otp);
          
          // Trigger completion if all fields are filled
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

