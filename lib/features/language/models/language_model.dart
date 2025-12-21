/// Represents a language option with its metadata
class LanguageModel {
  final String code;
  final String name;
  final String nativeName;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  /// Predefined list of supported languages
  static const List<LanguageModel> supportedLanguages = [
    LanguageModel(code: 'en', name: 'English', nativeName: 'English'),
    LanguageModel(code: 'hi', name: 'Hindi', nativeName: 'हिंदी'),
    LanguageModel(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
  ];
}

