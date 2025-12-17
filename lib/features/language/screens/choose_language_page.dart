import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/screens/login_page.dart';
import 'package:flutter_app/features/language/models/language_model.dart';
import 'package:flutter_app/features/language/widgets/language_list.dart';
import 'package:flutter_app/shared/widgets/cards/selection_card.dart';
import 'package:flutter_app/shared/widgets/common/page_header.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Page for selecting the app's language preference
class ChooseLanguagePage extends StatefulWidget {
  const ChooseLanguagePage({super.key});

  @override
  State<ChooseLanguagePage> createState() => _ChooseLanguagePageState();
}

class _ChooseLanguagePageState extends State<ChooseLanguagePage> {
  String? _selectedLanguageCode;
  String? _hoveredLanguageCode;

  void _handleLanguageSelection(LanguageModel language) {
    setState(() => _selectedLanguageCode = language.code);
    _navigateToLogin();
  }

  void _handleHoverEnter(String code) {
    setState(() => _hoveredLanguageCode = code);
  }

  void _handleHoverExit() {
    setState(() => _hoveredLanguageCode = null);
  }

  void _navigateToLogin() {
    Future.delayed(SelectionCardTheme.animationDuration, () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.authBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const PageHeader(
                title: 'Choose Language',
                subtitle: 'Select your preferred language',
              ),
              const SizedBox(height: 50),
              Expanded(
                child: LanguageList(
                  languages: LanguageModel.supportedLanguages,
                  selectedCode: _selectedLanguageCode,
                  hoveredCode: _hoveredLanguageCode,
                  onSelect: _handleLanguageSelection,
                  onHoverEnter: _handleHoverEnter,
                  onHoverExit: _handleHoverExit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
