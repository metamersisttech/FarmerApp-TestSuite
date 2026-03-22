import 'package:flutter/material.dart';
import 'package:flutter_app/features/bidding/models/bid_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Reusable bid display card
///
/// Used by both My Bids (buyer) and Listing Bids (seller) screens.
class BidCard extends StatelessWidget {
  final BidModel bid;
  final bool showListingInfo;
  final bool showBuyerInfo;
  final VoidCallback? onCancelTap;
  final VoidCallback? onApproveTap;
  final VoidCallback? onRejectTap;
  final VoidCallback? onTap;

  const BidCard({
    super.key,
    required this.bid,
    this.showListingInfo = false,
    this.showBuyerInfo = false,
    this.onCancelTap,
    this.onApproveTap,
    this.onRejectTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('bid_card'),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: bid amount + status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bid.formattedBidPrice,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  _StatusBadge(status: bid.status, color: bid.statusColor),
                ],
              ),

              const SizedBox(height: 4),

              // Listed price reference
              Text(
                'Listed at ${bid.formattedActualPrice}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),

              // Listing info (for buyer's my-bids screen)
              if (showListingInfo && bid.listingInfo != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pets, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bid.listingInfo!.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (bid.listingInfo!.sellerName != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          bid.listingInfo!.sellerName!,
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

              // Buyer info (for seller's listing-bids screen)
              if (showBuyerInfo && bid.bidder != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        bid.bidder!.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (bid.bidder!.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 16, color: Colors.blue),
                      ],
                    ],
                  ),
                ),
              ],

              // Message
              if (bid.message != null && bid.message!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.message_outlined, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        bid.message!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Date
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(bid.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),

              // Action buttons
              if (onCancelTap != null || onApproveTap != null || onRejectTap != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onRejectTap != null)
                      _ActionButton(
                        key: const Key('reject_bid_btn'),
                        label: 'Reject',
                        color: Colors.red,
                        icon: Icons.close,
                        onTap: onRejectTap!,
                      ),
                    if (onRejectTap != null && onApproveTap != null)
                      const SizedBox(width: 10),
                    if (onApproveTap != null)
                      _ActionButton(
                        key: const Key('approve_bid_btn'),
                        label: 'Approve',
                        color: AppTheme.authPrimaryColor,
                        icon: Icons.check,
                        onTap: onApproveTap!,
                        filled: true,
                      ),
                    if (onCancelTap != null)
                      _ActionButton(
                        key: const Key('cancel_bid_btn'),
                        label: 'Cancel Bid',
                        color: Colors.red,
                        icon: Icons.cancel_outlined,
                        onTap: onCancelTap!,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (_) {
      return dateStr;
    }
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status[0] + status.substring(1).toLowerCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Action button for bid card
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _ActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
