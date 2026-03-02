import 'package:flutter/material.dart';
import 'package:flutter_app/features/vet/mixins/vet_detail_state_mixin.dart';
import 'package:flutter_app/features/vet/widgets/vet_detail/vet_about_section.dart';
import 'package:flutter_app/features/vet/widgets/vet_detail/vet_availability_section.dart';
import 'package:flutter_app/features/vet/widgets/vet_detail/vet_bottom_action_bar.dart';
import 'package:flutter_app/features/vet/widgets/vet_detail/vet_clinic_info_section.dart';
import 'package:flutter_app/features/vet/widgets/vet_detail/vet_fee_section.dart';
import 'package:flutter_app/features/vet/widgets/vet_detail/vet_header_section.dart';
import 'package:flutter_app/features/vet/widgets/vet_detail/vet_reviews_section.dart';
import 'package:flutter_app/features/vet/widgets/vet_detail/vet_specializations_section.dart';
import 'package:flutter_app/features/vet/widgets/vet_detail/vet_stats_row.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Vet Detail Page
///
/// Displays comprehensive information about a veterinarian.
/// Includes profile, stats, about, clinic info, availability,
/// specializations, fees, and reviews.
class VetDetailPage extends StatefulWidget {
  final int vetId;

  const VetDetailPage({
    super.key,
    required this.vetId,
  });

  @override
  State<VetDetailPage> createState() => _VetDetailPageState();
}

class _VetDetailPageState extends State<VetDetailPage>
    with VetDetailStateMixin {
  @override
  int get vetId => widget.vetId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeVetDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: isLoading
          ? _buildLoadingState()
          : errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
      bottomNavigationBar: hasData
          ? VetBottomActionBar(
              onCallTap: handleCallTap,
              onVideoTap: handleVideoTap,
              onChatTap: handleChatTap,
              onBookTap: handleBookTap,
              isAvailable: vet!.isAvailable,
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load vet details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'An error occurred',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: handleBackTap,
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: loadVetDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final vetData = vet;
    if (vetData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with profile
          VetHeaderSection(
            vet: vetData,
            onBackTap: handleBackTap,
          ),

          // Stats row (hide when no real data)
          if (vetData.rating > 0 || vetData.reviewCount > 0)
            VetStatsRow(
              rating: vetData.rating,
              reviewCount: vetData.reviewCount,
              experienceYears: vetData.experienceYears,
              distanceKm: vetData.distanceKm,
            ),

          // About section
          VetAboutSection(
            bio: vetData.bio,
            languages: vetData.languages,
          ),

          // Clinic info section
          VetClinicInfoSection(
            clinicName: vetData.clinicName,
            clinicAddress: vetData.clinicAddress,
            workingHours: vetData.workingHours,
          ),

          // Weekly availability section
          VetAvailabilitySection(
            slots: availabilitySlots,
          ),

          // Specializations section
          VetSpecializationsSection(
            animalTypes: vetData.animalTypes,
            services: vetData.services,
          ),

          // Fee section
          VetFeeSection(
            consultationFee: vetData.consultationFee,
            videoCallFee: vetData.videoCallFee,
            homeVisitFee: vetData.homeVisitFee,
          ),

          // Reviews section (hide when no reviews)
          if (reviews.isNotEmpty)
            VetReviewsSection(
              rating: vetData.rating,
              reviewCount: vetData.reviewCount,
              reviews: reviews,
            ),

          // Bottom padding for bottom action bar
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
