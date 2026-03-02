import 'package:flutter/material.dart';

/// Verification Card Widget
class VerificationCard extends StatelessWidget {
  final Map<String, dynamic> listingData;

  const VerificationCard({
    super.key,
    required this.listingData,
  });

  @override
  Widget build(BuildContext context) {
    final vaccinationStatus = listingData['vaccination_status']?.toString();
    final pashuAadhar = listingData['pashu_aadhar']?.toString();
    final vetCertificate = listingData['vet_certificate']?.toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verification Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildVerificationRow('Phone Verified', true),
          const SizedBox(height: 12),
          _buildVerificationRow(
            'Pashu Aadhaar Linked',
            pashuAadhar != null && pashuAadhar.isNotEmpty && pashuAadhar != 'null',
          ),
          const SizedBox(height: 12),
          _buildVerificationRow(
            'Vet Certificate',
            vetCertificate != null && vetCertificate.isNotEmpty && vetCertificate != 'null',
          ),
          const SizedBox(height: 12),
          _buildVerificationRow(
            'Vaccinated',
            vaccinationStatus?.toLowerCase() == 'vaccinated',
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRow(String label, bool isVerified) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Icon(
          isVerified ? Icons.check_circle : Icons.cancel_outlined,
          size: 20,
          color: isVerified ? Colors.green : Colors.grey[400],
        ),
      ],
    );
  }
}
