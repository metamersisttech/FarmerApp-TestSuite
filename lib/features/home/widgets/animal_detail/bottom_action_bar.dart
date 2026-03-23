import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Bottom Action Bar for Animal Detail Page
///
/// Fixed bottom bar with Call, Chat, Video, and Buy Now buttons.
/// Shows "View Bids" instead of "Buy Now" when the current user owns the listing.
class BottomActionBar extends StatelessWidget {
  final VoidCallback? onCallTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onVideoTap;
  final VoidCallback? onBuyNowTap;
  final bool isOwner;
  final VoidCallback? onViewBidsTap;
  final int bidCount;

  const BottomActionBar({
    super.key,
    this.onCallTap,
    this.onChatTap,
    this.onVideoTap,
    this.onBuyNowTap,
    this.isOwner = false,
    this.onViewBidsTap,
    this.bidCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!isOwner) ...[
              // Call Button
              _ActionIconButton(
                icon: Icons.call_outlined,
                onTap: onCallTap,
              ),
              const SizedBox(width: 12),
              // Chat Button
              _ActionIconButton(
                icon: Icons.chat_bubble_outline,
                onTap: onChatTap,
              ),
              const SizedBox(width: 12),
              // Video Button
              _ActionIconButton(
                icon: Icons.videocam_outlined,
                onTap: onVideoTap,
              ),
              const SizedBox(width: 16),
            ],
            // Main action button
            Expanded(
              child: isOwner
                  ? ElevatedButton.icon(
                      onPressed: onViewBidsTap,
                      icon: const Icon(Icons.gavel, size: 20),
                      label: Text(
                        bidCount > 0 ? 'View Bids ($bidCount)' : 'View Bids',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.authPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: onBuyNowTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.authPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

/// Individual action icon button
class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.grey.shade700,
          size: 24,
        ),
      ),
    );
  }
}
