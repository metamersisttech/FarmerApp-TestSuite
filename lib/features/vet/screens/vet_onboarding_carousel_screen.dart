import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/features/vet/mixins/vet_onboarding_state_mixin.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/features/vet/widgets/onboarding/vet_onboarding_slide.dart';
import 'package:flutter_app/features/vet/widgets/onboarding/vet_onboarding_dots.dart';

/// Vet onboarding carousel introducing the registration process
class VetOnboardingCarouselScreen extends StatefulWidget {
  const VetOnboardingCarouselScreen({super.key});

  @override
  State<VetOnboardingCarouselScreen> createState() =>
      _VetOnboardingCarouselScreenState();
}

class _VetOnboardingCarouselScreenState
    extends State<VetOnboardingCarouselScreen> with VetOnboardingStateMixin {
  @override
  void initState() {
    super.initState();
    initializeOnboarding();
  }

  @override
  void dispose() {
    disposeOnboarding();
    super.dispose();
  }

  void _handleSkip() {
    Navigator.pop(context);
  }

  void _handleGetStarted() {
    Navigator.pushNamed(context, AppRoutes.vetDocumentUpload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    color: Colors.grey[600],
                  ),
                  // Skip button
                  TextButton(
                    onPressed: _handleSkip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView slides
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: onPageChanged,
                children: const [
                  VetOnboardingSlide(
                    icon: Icons.medical_services,
                    title: 'Become a Verified Vet',
                    description:
                        'Join our platform as a verified veterinary professional and connect with farmers who need your expertise.',
                  ),
                  VetOnboardingSlide(
                    icon: Icons.description_outlined,
                    title: 'Documents Required',
                    description:
                        'Have these documents ready for a smooth registration process:',
                    bulletPoints: [
                      'Vet Certificate (issued by veterinary council)',
                      'Degree Certificate (BVSc / MVSc)',
                      'Registration Number',
                      'Clinic & College Details',
                    ],
                  ),
                  VetOnboardingSlide(
                    icon: Icons.verified_outlined,
                    title: 'Verification Process',
                    description:
                        'Our admin team will review your documents carefully. The verification typically takes 1-2 business days.',
                  ),
                  VetOnboardingSlide(
                    icon: Icons.rocket_launch_outlined,
                    title: 'Ready to Start?',
                    description:
                        'Once verified, you can receive appointment requests, set your availability, manage consultations, and grow your practice.',
                  ),
                ],
              ),
            ),

            // Dots indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: VetOnboardingDots(
                currentPage: currentPage,
                totalPages: totalPages,
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLastPage ? _handleGetStarted : nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.authPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isLastPage ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
