import 'package:flutter/material.dart';
import 'package:flutter_app/features/bidding/controllers/bid_controller.dart';
import 'package:flutter_app/features/bidding/mixins/my_bids_state_mixin.dart';
import 'package:flutter_app/features/bidding/widgets/bid_card.dart';
import 'package:flutter_app/features/bidding/widgets/bid_confirm_dialogs.dart';
import 'package:flutter_app/features/bidding/widgets/bid_empty_state.dart';
import 'package:flutter_app/features/bidding/widgets/bid_status_filter.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// My Bids page - shows the buyer's bid history
class MyBidsPage extends StatefulWidget {
  const MyBidsPage({super.key});

  @override
  State<MyBidsPage> createState() => _MyBidsPageState();
}

class _MyBidsPageState extends State<MyBidsPage> with MyBidsStateMixin {
  late final BidController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BidController();
    _loadBids();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBids() async {
    await _controller.fetchMyBids(status: selectedFilter);
    if (mounted) setState(() {});
  }

  void _onFilterChanged(String? filter) {
    setFilter(filter);
    _loadBids();
  }

  Future<void> _handleCancel(int listingId, int bidId) async {
    final confirmed = await BidConfirmDialogs.showCancelDialog(context);
    if (!confirmed || !mounted) return;

    final success = await _controller.cancelBid(
      listingId: listingId,
      bidId: bidId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bid cancelled.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadBids();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel bid.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToListing(int listingId) {
    Navigator.pushNamed(context, AppRoutes.animalDetail, arguments: listingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            title: const Text(
              'My Bids',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.authPrimaryColor,
            foregroundColor: Colors.white,
            pinned: true,
            floating: true,
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: BidStatusFilter(
                selectedFilter: selectedFilter,
                onFilterChanged: _onFilterChanged,
              ),
            ),
          ),

          // Content
          if (_controller.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.authPrimaryColor,
                ),
              ),
            )
          else if (_controller.errorMessage != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      _controller.errorMessage!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadBids,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.authPrimaryColor,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (!_controller.hasBids)
            const SliverFillRemaining(
              child: BidEmptyState(
                title: 'No bids found',
                subtitle: 'Your bids on listings will appear here.',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final bid = _controller.bids[index];
                  return BidCard(
                    bid: bid,
                    showListingInfo: true,
                    onCancelTap: bid.isPending
                        ? () => _handleCancel(bid.listingId, bid.id)
                        : null,
                    onTap: bid.listingInfo != null
                        ? () => _navigateToListing(bid.listingInfo!.listingId)
                        : null,
                  );
                },
                childCount: _controller.bids.length,
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
