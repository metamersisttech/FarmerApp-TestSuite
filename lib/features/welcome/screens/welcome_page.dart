import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/screens/sendOtp_page.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.authPrimaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // Expanded widget to push title to center
            Expanded(
              child: Center(
                child: Text(
                  'Welcome to Animal World',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.authTextPrimary,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Get Started button at the bottom
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  key: const Key('get_started_btn'),
                  onPressed: () {
                    // Navigate to phone login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SendOtpPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
