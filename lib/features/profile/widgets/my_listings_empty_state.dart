import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Empty state widget for My Listings page
class MyListingsEmptyState extends StatelessWidget {
  final String? filterStatus;
  final VoidCallback onCreateListing;

  const MyListingsEmptyState({
    super.key,
    this.filterStatus,
    required this.onCreateListing,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.post_add,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                (filterStatus != null && filterStatus != 'all')
                    ? 'No $filterStatus listings'
                    : 'No listings yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                (filterStatus != null && filterStatus != 'all')
                    ? 'Try changing the filter to see other listings'
                    : 'Start posting your animals for sale',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onCreateListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.authPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Create Listing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
