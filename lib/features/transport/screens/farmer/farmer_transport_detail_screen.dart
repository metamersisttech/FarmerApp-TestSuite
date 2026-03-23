/// Farmer Transport Detail Screen
///
/// Displays full details of a transport request from the farmer's perspective:
/// - Current status with timeline
/// - Route, cargo, schedule information
/// - Fare negotiation (approve transport provider's proposed fare)
/// - Cancel option (when pending)
/// - Navigate to transport chat
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/services/farmer_transport_service.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

class FarmerTransportDetailScreen extends StatefulWidget {
  final int requestId;
  const FarmerTransportDetailScreen({super.key, required this.requestId});

  @override
  State<FarmerTransportDetailScreen> createState() =>
      _FarmerTransportDetailScreenState();
}

class _FarmerTransportDetailScreenState
    extends State<FarmerTransportDetailScreen> with ToastMixin {
  final _service = FarmerTransportService();

  TransportRequestModel? _request;
  bool _isLoading = true;
  String? _error;
  bool _isCancelling = false;
  bool _isApprovingFare = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final r = await _service.getRequestById(widget.requestId);
      if (mounted) setState(() => _request = r);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelRequest() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('transport.cancel_booking'.tr()),
        content: Text('transport.cancel_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('common.no'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'common.yes_cancel'.tr(),
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isCancelling = true);
    try {
      await _service.cancelRequest(widget.requestId);
      if (!mounted) return;
      showSuccessToast('transport.booking_cancelled'.tr());
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      showErrorToast('transport.cancel_failed'.tr());
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  Future<void> _approveFare() async {
    setState(() => _isApprovingFare = true);
    try {
      final updated = await _service.approveFare(widget.requestId);
      if (!mounted) return;
      setState(() => _request = updated);
      showSuccessToast('transport.fare_approved'.tr());
    } catch (e) {
      if (!mounted) return;
      showErrorToast('transport.fare_approve_failed'.tr());
    } finally {
      if (mounted) setState(() => _isApprovingFare = false);
    }
  }

  void _openChat() {
    if (_request == null) return;
    Navigator.pushNamed(
      context,
      AppRoutes.transportChat,
      arguments: {
        'requestId': widget.requestId,
        'otherUserName':
            _request!.transportProvider?.businessName ?? 'Transport Provider',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'transport.booking_details'.tr(),
          style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_request != null &&
              (_request!.statusEnum == TransportRequestStatus.accepted ||
                  _request!.statusEnum == TransportRequestStatus.inProgress ||
                  _request!.statusEnum == TransportRequestStatus.inTransit))
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              onPressed: _openChat,
              tooltip: 'transport.chat'.tr(),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primaryColor))
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text('transport.load_error'.tr(),
              style: TextStyle(color: Colors.red.shade700)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white),
            child: Text('common.retry'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final r = _request!;
    final status = r.statusEnum;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner
          _StatusBanner(status: status),
          const SizedBox(height: 16),

          // Fare approval card (highest priority action)
          if (status == TransportRequestStatus.accepted &&
              r.proposedFare != null &&
              !r.fareApprovedByRequestor)
            _FareApprovalCard(
              proposedFare: r.proposedFare!,
              isLoading: _isApprovingFare,
              onApprove: _approveFare,
            ),

          // Route card
          _InfoCard(
            title: 'transport.route_details'.tr(),
            icon: Icons.route_rounded,
            child: Column(
              children: [
                _RouteItem(
                    icon: Icons.location_on_rounded,
                    color: Colors.green,
                    label: 'transport.pickup'.tr(),
                    value: r.sourceAddress),
                const SizedBox(height: 8),
                _RouteItem(
                    icon: Icons.flag_rounded,
                    color: Colors.red,
                    label: 'transport.destination'.tr(),
                    value: r.destinationAddress),
                if (r.distanceKm > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.straighten_rounded,
                          size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '${r.distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Schedule + Cargo row
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  title: 'transport.pickup_date'.tr(),
                  icon: Icons.calendar_today_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy')
                            .format(r.pickupDate),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (r.formattedPickupTime?.isNotEmpty == true)
                        Text(
                          r.formattedPickupTime!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  title: 'transport.fare'.tr(),
                  icon: Icons.currency_rupee_rounded,
                  child: Text(
                    r.formattedFare,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Cargo
          if (r.cargoAnimals.isNotEmpty)
            _InfoCard(
              title: 'transport.animal_cargo'.tr(),
              icon: Icons.pets_rounded,
              child: Column(
                children: r.cargoAnimals
                    .map((a) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              const Icon(Icons.fiber_manual_record,
                                  size: 8,
                                  color: AppTheme.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                a.summary,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textPrimary),
                              ),
                              if (a.formattedWeight?.isNotEmpty == true) ...[
                                const Spacer(),
                                Text(
                                  a.formattedWeight!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary),
                                ),
                              ],
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),

          // Transport Provider card (if assigned)
          if (r.transportProvider != null) ...[
            const SizedBox(height: 12),
            _ProviderCard(
              provider: r.transportProvider!,
              onChat: status != TransportRequestStatus.pending
                  ? _openChat
                  : null,
            ),
          ],

          // Notes
          if (r.notes != null && r.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoCard(
              title: 'transport.special_notes'.tr(),
              icon: Icons.notes_rounded,
              child: Text(
                r.notes!,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Cancel button (only for pending requests)
          if (status == TransportRequestStatus.pending)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _isCancelling ? null : _cancelRequest,
                icon: _isCancelling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cancel_outlined,
                        color: AppTheme.errorColor),
                label: Text(
                  'transport.cancel_booking'.tr(),
                  style: const TextStyle(color: AppTheme.errorColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.errorColor),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusMedium)),
                ),
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final TransportRequestStatus status;
  const _StatusBanner({required this.status});

  String _message(TransportRequestStatus s) {
    switch (s) {
      case TransportRequestStatus.pending:
        return 'transport.status_pending_msg'.tr();
      case TransportRequestStatus.accepted:
        return 'transport.status_accepted_msg'.tr();
      case TransportRequestStatus.inProgress:
        return 'transport.status_in_progress_msg'.tr();
      case TransportRequestStatus.inTransit:
        return 'transport.status_in_transit_msg'.tr();
      case TransportRequestStatus.completed:
        return 'transport.status_completed_msg'.tr();
      case TransportRequestStatus.cancelled:
        return 'transport.status_cancelled_msg'.tr();
      case TransportRequestStatus.expired:
        return 'transport.status_expired_msg'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: status.color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _message(status),
              style: TextStyle(fontSize: 13, color: status.color),
            ),
          ),
        ],
      ),
    );
  }
}

class _FareApprovalCard extends StatelessWidget {
  final double proposedFare;
  final bool isLoading;
  final VoidCallback onApprove;

  const _FareApprovalCard({
    required this.proposedFare,
    required this.isLoading,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.currency_rupee_rounded,
                  size: 16, color: Colors.orange),
              const SizedBox(width: 6),
              Text(
                'transport.fare_proposed'.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${proposedFare.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'transport.fare_approval_sub'.tr(),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: isLoading ? null : onApprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium)),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('transport.approve_fare'.tr(),
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _RouteItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _RouteItem(
      {required this.icon,
      required this.color,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary)),
              Text(
                value,
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

class _ProviderCard extends StatelessWidget {
  final dynamic provider;
  final VoidCallback? onChat;

  const _ProviderCard({required this.provider, this.onChat});

  @override
  Widget build(BuildContext context) {
    final name = provider.providerName ?? 'Transport Provider';
    final rating = provider.rating ?? 0.0;
    final trips = provider.totalTrips ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
            child: Text(
              provider.displayInitials ?? name[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 13, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· $trips ${'transport.trips'.tr()}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onChat != null)
            IconButton(
              onPressed: onChat,
              icon: const Icon(Icons.chat_bubble_outline_rounded,
                  color: AppTheme.primaryColor),
              tooltip: 'transport.chat'.tr(),
            ),
        ],
      ),
    );
  }
}
