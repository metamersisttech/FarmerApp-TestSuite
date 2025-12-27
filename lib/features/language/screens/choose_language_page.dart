import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/language/controllers/language_controller.dart';
import 'package:flutter_app/features/language/mixins/language_state_mixin.dart';
import 'package:flutter_app/features/language/models/language_model.dart';
import 'package:flutter_app/features/language/services/language_navigation_service.dart';
import 'package:flutter_app/features/language/widgets/language_list.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/cards/selection_card.dart';
import 'package:flutter_app/shared/widgets/common/page_header.dart';

/// Page for selecting the app's language preference
class ChooseLanguagePage extends StatefulWidget {
  final UserModel? user;
  
  const ChooseLanguagePage({super.key, this.user});

  @override
  State<ChooseLanguagePage> createState() => _ChooseLanguagePageState();
}

class _ChooseLanguagePageState extends State<ChooseLanguagePage>
    with LanguageStateMixin {
  late final LanguageController _languageController;

  @override
  void initState() {
    super.initState();
    _languageController = LanguageController();
  }

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  /// Handle language selection
  void _handleLanguageSelection(LanguageModel language) {
    // Update local state
    selectLanguage(language.code);
    
    // Update controller
    _languageController.selectLanguage(language.code);
    
    // Save preference (when backend is ready)
    _languageController.saveLanguagePreference();
    
    // Navigate after animation
    _navigateToNextPage();
  }

  /// Handle hover enter
  void _handleHoverEnter(String code) {
    onHoverEnter(code);
    _languageController.setHoveredLanguage(code);
  }

  /// Handle hover exit
  void _handleHoverExit() {
    onHoverExit();
    _languageController.setHoveredLanguage(null);
  }

  /// Navigate to next page after delay
  void _navigateToNextPage() {
    Future.delayed(SelectionCardTheme.animationDuration, () {
      if (mounted) {
        LanguageNavigationService.toUserIdentity(context, user: widget.user);
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
                  selectedCode: selectedLanguageCode,
                  hoveredCode: hoveredLanguageCode,
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
