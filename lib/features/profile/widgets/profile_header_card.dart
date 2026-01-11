import 'package:flutter/material.dart';
import 'package:flutter_app/features/profile/models/profile_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Profile header card with user info, stats, and edit button
class ProfileHeaderCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback? onEditProfile;

  const ProfileHeaderCard({
    super.key,
    required this.profile,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
          // Profile info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              _buildAvatar(),
              const SizedBox(width: 16),
              
              // User details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name with verification badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2B2B2B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            color: AppTheme.authPrimaryColor,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Identity and Location
                    Text(
                      '${profile.identity ?? 'User'} • ${profile.location ?? 'Location'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Rating
                    _buildRating(),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Stats row
          _buildStatsRow(),
          
          const SizedBox(height: 20),
          
          // Edit Profile button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onEditProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.authPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
        ),
        image: profile.profileImage != null
            ? DecorationImage(
                image: NetworkImage(profile.profileImage!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: profile.profileImage == null
          ? ClipOval(
              child: Image.network(
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        const Icon(
          Icons.star,
          color: Color(0xFFFFC107),
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          profile.rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2B2B2B),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${profile.reviewCount} reviews)',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            value: profile.stats.animalsSold.toString(),
            label: 'Animals Sold',
          ),
          _buildStatDivider(),
          _buildStatItem(
            value: profile.stats.transactions.toString(),
            label: 'Transactions',
          ),
          _buildStatDivider(),
          _buildStatItem(
            value: profile.memberDuration,
            label: 'Member Since',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B2B2B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }
}

