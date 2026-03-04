import 'package:flutter/material.dart';
import 'package:flutter_app/features/vet/models/vet_profile_model.dart';
import 'package:flutter_app/features/vet_dashboard/widgets/profile_stat_item.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Card displaying vet profile information with avatar, name, and stats
class VetProfileInfoCard extends StatelessWidget {
  final VetProfileModel profile;
  final String? fallbackName;

  const VetProfileInfoCard({
    super.key,
    required this.profile,
    this.fallbackName,
  });

  @override
  Widget build(BuildContext context) {
    // Use fallbackName if profile displayName is generic "Vet" OR if we have a better fallback
    final profileName = profile.displayName;
    debugPrint('[VetProfileInfoCard] profileName: $profileName');
    debugPrint('[VetProfileInfoCard] fallbackName: $fallbackName');
    debugPrint('[VetProfileInfoCard] userFirstName: ${profile.userFirstName}');
    
    final name = (fallbackName != null && 
                  fallbackName!.isNotEmpty && 
                  (profileName == 'Vet' || profile.userFirstName == null || profile.userFirstName!.isEmpty))
        ? fallbackName!
        : profileName;
    
    debugPrint('[VetProfileInfoCard] Final name: $name');
    final initials = profile.initials;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar + name
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.authPrimaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.authPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Dr. $name',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (profile.isDocumentsVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    if (profile.specialization != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.specialization!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (profile.clinicName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        profile.clinicName!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Stats row
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ProfileStatItem(
                value: '${profile.yearsOfExperience ?? 0}',
                label: 'Years Exp.',
              ),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              ProfileStatItem(
                value: profile.specializations.length.toString(),
                label: 'Specializations',
              ),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              ProfileStatItem(
                value: profile.consultationFee != null
                    ? '\u20B9${double.tryParse(profile.consultationFee!)?.toInt() ?? profile.consultationFee}'
                    : 'N/A',
                label: 'Consult Fee',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
