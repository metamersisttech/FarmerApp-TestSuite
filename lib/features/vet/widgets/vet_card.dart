import 'package:flutter/material.dart';
import 'package:flutter_app/features/vet/models/vet_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Card widget displaying vet information
class VetCard extends StatelessWidget {
  final VetModel vet;
  final VoidCallback? onCallTap;
  final VoidCallback? onVideoTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onBookTap;

  const VetCard({
    super.key,
    required this.vet,
    this.onCallTap,
    this.onVideoTap,
    this.onChatTap,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image
              _buildProfileImage(),
              const SizedBox(width: 12),
              // Vet details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name with verified badge
                    _buildNameRow(),
                    const SizedBox(height: 2),
                    // Specialization
                    Text(
                      vet.specialization,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Stats row
                    _buildStatsRow(),
                  ],
                ),
              ),
              // Availability badge
              if (vet.isAvailable) _buildAvailabilityBadge(),
            ],
          ),
          const SizedBox(height: 12),
          // Divider
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 12),
          // Action row
          _buildActionRow(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: vet.profileImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                vet.profileImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
              ),
            )
          : _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        vet.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      children: [
        Flexible(
          child: Text(
            vet.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (vet.isVerified) ...[
          const SizedBox(width: 4),
          const Icon(
            Icons.verified,
            color: AppTheme.primaryColor,
            size: 18,
          ),
        ],
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        // Rating
        _buildStatItem(
          icon: Icons.star,
          iconColor: Colors.amber,
          text: '${vet.rating} (${vet.reviewCount})',
        ),
        const SizedBox(width: 12),
        // Distance
        _buildStatItem(
          icon: Icons.location_on_outlined,
          iconColor: Colors.grey[600]!,
          text: '${vet.distanceKm} km',
        ),
        const SizedBox(width: 12),
        // Experience
        _buildStatItem(
          icon: Icons.work_outline,
          iconColor: Colors.grey[600]!,
          text: '${vet.experienceYears} yrs',
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Available',
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        // Price
        Text(
          '\u20B9${vet.consultationFee.toInt()}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        const Spacer(),
        // Action icons
        _buildActionIcon(Icons.phone_outlined, onCallTap),
        const SizedBox(width: 8),
        _buildActionIcon(Icons.videocam_outlined, onVideoTap),
        const SizedBox(width: 8),
        _buildActionIcon(Icons.chat_outlined, onChatTap),
        const SizedBox(width: 12),
        // Book button
        _buildBookButton(),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    return GestureDetector(
      onTap: onBookTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor, width: 1.5),
        ),
        child: const Text(
          'Book',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
