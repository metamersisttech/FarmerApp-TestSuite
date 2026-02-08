import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/features/vet/controllers/vet_profile_controller.dart';
import 'package:flutter_app/features/vet/mixins/vet_profile_state_mixin.dart';

/// Vet profile dashboard screen
///
/// Shows the vet's own profile with availability toggle,
/// bio, specializations, experience, and navigation to
/// availability and pricing management.
class VetProfileScreen extends StatefulWidget {
  const VetProfileScreen({super.key});

  @override
  State<VetProfileScreen> createState() => _VetProfileScreenState();
}

class _VetProfileScreenState extends State<VetProfileScreen>
    with VetProfileStateMixin, ToastMixin {
  late final VetProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VetProfileController();
    _loadProfile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setProfileLoading(true);
    setProfileError(null);

    final result = await _controller.loadProfile();

    if (!mounted) return;

    if (!result.success) {
      setProfileError(result.message ?? 'Failed to load profile');
      showErrorToast(result.message ?? 'Failed to load profile');
    }

    setProfileLoading(false);
  }

  Future<void> _handleToggleAvailability(bool value) async {
    final result = await _controller.toggleAvailability(value);

    if (!mounted) return;

    if (result.success) {
      showSuccessToast(
        value ? 'You are now available' : 'You are now unavailable',
      );
    } else {
      showErrorToast(result.message ?? 'Failed to update availability');
    }
    setState(() {}); // Refresh UI
  }

  void _handleManageAvailability() async {
    await Navigator.pushNamed(context, AppRoutes.vetAvailability);
    // Refresh profile on return
    _loadProfile();
  }

  void _handleManagePricing() async {
    await Navigator.pushNamed(context, AppRoutes.vetPricing);
    // Refresh profile on return
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Vet Profile'),
        backgroundColor: AppTheme.authPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null && _controller.profile == null
              ? _buildErrorState()
              : _controller.profile != null
                  ? _buildProfileContent()
                  : const SizedBox.shrink(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    final profile = _controller.profile!;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            _buildHeaderCard(profile),
            const SizedBox(height: 16),

            // Bio Section
            _buildBioSection(profile),
            const SizedBox(height: 16),

            // Specializations
            if (profile.specializations.isNotEmpty) ...[
              _buildSpecializationsSection(profile),
              const SizedBox(height: 16),
            ],

            // Experience & Info
            _buildInfoSection(profile),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.authPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    profile.initials,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.authPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name & details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isDocumentsVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    if (profile.qualifications != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.qualifications!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (profile.registrationNo != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Reg: ${profile.registrationNo}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Availability toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: profile.available
                  ? Colors.green.withOpacity(0.08)
                  : Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: profile.available ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      profile.available
                          ? 'Available for consultations'
                          : 'Currently unavailable',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: profile.available
                            ? Colors.green[700]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: profile.available,
                  onChanged: _handleToggleAvailability,
                  activeColor: AppTheme.authPrimaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            profile.bio ?? 'No bio added yet.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationsSection(profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services_outlined,
                  size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              const Text(
                'Specializations',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.specializations.map<Widget>((String spec) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.authPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  spec,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.authPrimaryColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.work_outline,
            'Experience',
            profile.yearsOfExperience != null
                ? '${profile.yearsOfExperience} years'
                : 'Not set',
          ),
          const Divider(height: 20),
          _buildInfoRow(
            Icons.local_hospital_outlined,
            'Clinic',
            profile.clinicName ?? 'Not set',
          ),
          if (profile.consultationFee != null) ...[
            const Divider(height: 20),
            _buildInfoRow(
              Icons.payments_outlined,
              'Consultation Fee',
              '\u20B9${profile.consultationFee}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.authPrimaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _handleManageAvailability,
            icon: const Icon(Icons.schedule),
            label: const Text(
              'Manage Availability',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.authPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _handleManagePricing,
            icon: Icon(Icons.payments_outlined,
                color: AppTheme.authPrimaryColor),
            label: Text(
              'Manage Pricing',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.authPrimaryColor,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.authPrimaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
