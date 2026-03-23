/// My Transport Bookings Screen (Farmer Side)
///
/// Shows all transport requests created by this farmer,
/// grouped by active vs. past, with status chips and navigation to detail.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/screens/farmer/book_transport_screen.dart';
import 'package:flutter_app/features/transport/screens/farmer/farmer_transport_detail_screen.dart';
import 'package:flutter_app/features/transport/services/farmer_transport_service.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

class MyTransportBookingsScreen extends StatefulWidget {
  const MyTransportBookingsScreen({super.key});

  @override
  State<MyTransportBookingsScreen> createState() =>
      _MyTransportBookingsScreenState();
}

class _MyTransportBookingsScreenState extends State<MyTransportBookingsScreen>
    with ToastMixin {
  final _service = FarmerTransportService();

  List<TransportRequestModel> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.getMyRequests();
      if (mounted) setState(() => _requests = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<TransportRequestModel> get _active => _requests
      .where((r) =>
          r.statusEnum == TransportRequestStatus.pending ||
          r.statusEnum == TransportRequestStatus.accepted ||
          r.statusEnum == TransportRequestStatus.inProgress ||
          r.statusEnum == TransportRequestStatus.inTransit)
      .toList();

  List<TransportRequestModel> get _past => _requests
      .where((r) =>
          r.statusEnum == TransportRequestStatus.completed ||
          r.statusEnum == TransportRequestStatus.cancelled ||
          r.statusEnum == TransportRequestStatus.expired)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'transport.my_bookings'.tr(),
          style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadRequests,
            tooltip: 'common.refresh'.tr(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
                builder: (_) => const BookTransportScreen()),
          );
          if (result == true) _loadRequests();
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'transport.new_booking'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                'transport.load_error'.tr(),
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 14, color: Colors.red.shade700),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadRequests,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('common.retry'.tr()),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_requests.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      color: AppTheme.primaryColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          if (_active.isNotEmpty) ...[
            _sectionHeader('transport.active_bookings'.tr(), _active.length),
            ..._active.map((r) => _RequestCard(
                  request: r,
                  onTap: () => _openDetail(r),
                )),
            const SizedBox(height: 16),
          ],
          if (_past.isNotEmpty) ...[
            _sectionHeader('transport.past_bookings'.tr(), _past.length),
            ..._past.map((r) => _RequestCard(
                  request: r,
                  onTap: () => _openDetail(r),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping_outlined,
                size: 64,
                color:
                    AppTheme.mutedForeground.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              'transport.no_bookings'.tr(),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'transport.no_bookings_sub'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.mutedForeground.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BookTransportScreen()),
                );
                if (result == true) _loadRequests();
              },
              icon: const Icon(Icons.add_rounded),
              label: Text('transport.book_now'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(TransportRequestModel r) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              FarmerTransportDetailScreen(requestId: r.requestId)),
    ).then((_) => _loadRequests());
  }
}

/// Single transport request card
class _RequestCard extends StatelessWidget {
  final TransportRequestModel request;
  final VoidCallback onTap;

  const _RequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = request.statusEnum;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status + date row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusChip(status: status),
                Text(
                  DateFormat('dd MMM').format(request.pickupDate),
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Route
            _RouteRow(
              from: request.sourceAddress,
              to: request.destinationAddress,
            ),

            const SizedBox(height: 10),

            // Cargo + Fare row
            Row(
              children: [
                const Icon(Icons.pets_rounded,
                    size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  request.cargoSummary,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
                const Spacer(),
                Text(
                  request.formattedFare,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),

            // Fare approval nudge
            if (status == TransportRequestStatus.accepted &&
                request.proposedFare != null &&
                !request.fareApprovedByRequestor) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'transport.fare_approval_needed'.tr(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TransportRequestStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final String from;
  final String to;
  const _RouteRow({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            Container(
                width: 1, height: 14, color: Colors.grey.shade300),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                from,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                to,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
