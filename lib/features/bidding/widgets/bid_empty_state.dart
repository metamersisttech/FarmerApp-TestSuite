import 'package:flutter/material.dart';

/// Empty state widget for bid screens
class BidEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const BidEmptyState({
    super.key,
    this.title = 'No bids yet',
    this.subtitle = 'Bids will appear here when placed.',
    this.icon = Icons.gavel_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
