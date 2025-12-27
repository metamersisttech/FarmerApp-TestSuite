import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/language/models/language_model.dart';

/// Controller for language selection operations
class LanguageController extends BaseController {
  String? _selectedLanguageCode;
  String? _hoveredLanguageCode;

  /// Currently selected language code
  String? get selectedLanguageCode => _selectedLanguageCode;

  /// Currently hovered language code
  String? get hoveredLanguageCode => _hoveredLanguageCode;

  /// Get selected language model
  LanguageModel? get selectedLanguage {
    if (_selectedLanguageCode == null) return null;
    return LanguageModel.supportedLanguages.firstWhere(
      (lang) => lang.code == _selectedLanguageCode,
    );
  }

  /// Select a language
  void selectLanguage(String code) {
    _selectedLanguageCode = code;
    notifyListeners();
  }

  /// Set hovered language
  void setHoveredLanguage(String? code) {
    _hoveredLanguageCode = code;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedLanguageCode = null;
    notifyListeners();
  }

  /// Save language preference (TODO: Implement when backend is ready)
  Future<bool> saveLanguagePreference() async {
    if (_selectedLanguageCode == null) return false;
    
    // TODO: Save to backend/local storage
    // await _languageService.savePreference(_selectedLanguageCode!);
    
    return true;
  }
}

