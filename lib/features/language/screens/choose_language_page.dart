import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/screens/login_page.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

class ChooseLanguagePage extends StatefulWidget {
  const ChooseLanguagePage({super.key});

  @override
  State<ChooseLanguagePage> createState() => _ChooseLanguagePageState();
}

class _ChooseLanguagePageState extends State<ChooseLanguagePage> {
  String? _selectedLanguage;
  String? _hoveredLanguage;

  final List<LanguageOption> _languages = [
    LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
    LanguageOption(code: 'hi', name: 'Hindi', nativeName: 'हिंदी'),
    LanguageOption(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
  ];

  void _onLanguageSelected(String code) {
    setState(() {
      _selectedLanguage = code;
    });

    // Navigate to Login page after selection
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
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

              // Title
              Text(
                'Choose Language',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.authPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Select your preferred language',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 50),

              // Language options
              Expanded(
                child: ListView.separated(
                  itemCount: _languages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final language = _languages[index];
                    return _buildLanguageCard(language);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(LanguageOption language) {
    final isSelected = _selectedLanguage == language.code;
    final isHovered = _hoveredLanguage == language.code;

    // Hover color #80EF80
    const Color hoverBorderColor = Color(0xFF80EF80);

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredLanguage = language.code;
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredLanguage = null;
        });
      },
      child: GestureDetector(
        onTap: () => _onLanguageSelected(language.code),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : isHovered
                  ? hoverBorderColor
                  : Colors.grey.shade300,
              width: isSelected || isHovered ? 2.5 : 1.5,
            ),
            boxShadow: isHovered || isSelected
                ? [
                    BoxShadow(
                      color:
                          (isSelected
                                  ? AppTheme.primaryColor
                                  : hoverBorderColor)
                              .withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Language icon/flag placeholder
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : isHovered
                      ? hoverBorderColor.withOpacity(0.2)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    language.code.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Language name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language.nativeName,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : isHovered
                        ? hoverBorderColor
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;

  LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}
