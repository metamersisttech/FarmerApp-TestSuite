import 'package:flutter/material.dart';
import 'package:flutter_app/features/bidding/controllers/bid_controller.dart';
import 'package:flutter_app/features/bidding/mixins/my_bids_state_mixin.dart';
import 'package:flutter_app/features/bidding/widgets/bid_card.dart';
import 'package:flutter_app/features/bidding/widgets/bid_confirm_dialogs.dart';
import 'package:flutter_app/features/bidding/widgets/bid_empty_state.dart';
import 'package:flutter_app/features/bidding/widgets/bid_status_filter.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Listing Bids page - shows bids on a listing for the seller
class ListingBidsPage extends StatefulWidget {
  final int listingId;

  const ListingBidsPage({super.key, required this.listingId});

  @override
  State<ListingBidsPage> createState() => _ListingBidsPageState();
}

class _ListingBidsPageState extends State<ListingBidsPage>
    with MyBidsStateMixin {
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
    await _controller.fetchListingBids(
      listingId: widget.listingId,
      status: selectedFilter,
    );
    if (mounted) setState(() {});
  }

  void _onFilterChanged(String? filter) {
    setFilter(filter);
    _loadBids();
  }

  Future<void> _handleApprove(int bidId) async {
    final confirmed = await BidConfirmDialogs.showApproveDialog(context);
    if (!confirmed || !mounted) return;

    final success = await _controller.approveBid(
      listingId: widget.listingId,
      bidId: bidId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bid approved! Listing marked as sold.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadBids();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to approve bid.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleReject(int bidId) async {
    final confirmed = await BidConfirmDialogs.showRejectDialog(context);
    if (!confirmed || !mounted) return;

    final success = await _controller.rejectBid(
      listingId: widget.listingId,
      bidId: bidId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bid rejected.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadBids();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reject bid.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
              'Bids on Listing',
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
                title: 'No bids yet',
                subtitle: 'Bids from buyers will appear here.',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final bid = _controller.bids[index];
                  return BidCard(
                    bid: bid,
                    showBuyerInfo: true,
                    onApproveTap: bid.isPending
                        ? () => _handleApprove(bid.id)
                        : null,
                    onRejectTap: bid.isPending
                        ? () => _handleReject(bid.id)
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
