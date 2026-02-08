import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Card showing per-document verification status (accepted/rejected)
class VetDocumentStatusCard extends StatelessWidget {
  final String documentLabel;
  final String? documentUrl;
  final bool isRejected;
  final String? rejectionReason;
  final VoidCallback? onReuploadTap;

  const VetDocumentStatusCard({
    super.key,
    required this.documentLabel,
    this.documentUrl,
    this.isRejected = false,
    this.rejectionReason,
    this.onReuploadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRejected ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: label + status badge
          Row(
            children: [
              Expanded(
                child: Text(
                  documentLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              _buildStatusBadge(),
            ],
          ),

          // Thumbnail
          if (documentUrl != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                CommonHelper.getImageUrl(documentUrl!),
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey[400],
                    size: 32,
                  ),
                ),
              ),
            ),
          ],

          // Rejection reason
          if (isRejected && rejectionReason != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red[400],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rejectionReason!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Re-upload button
          if (isRejected && onReuploadTap != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReuploadTap,
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Re-upload'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.authPrimaryColor,
                  side: BorderSide(color: AppTheme.authPrimaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isRejected
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRejected ? Icons.close : Icons.check,
            size: 14,
            color: isRejected ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            isRejected ? 'Rejected' : 'Accepted',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isRejected ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
