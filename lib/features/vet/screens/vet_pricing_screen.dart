import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/vet/controllers/vet_profile_controller.dart';
import 'package:flutter_app/features/vet/models/vet_pricing_model.dart';
import 'package:flutter_app/features/vet/mixins/vet_pricing_state_mixin.dart';

/// Screen for managing vet consultation pricing
class VetPricingScreen extends StatefulWidget {
  const VetPricingScreen({super.key});

  @override
  State<VetPricingScreen> createState() => _VetPricingScreenState();
}

class _VetPricingScreenState extends State<VetPricingScreen>
    with VetPricingStateMixin, ToastMixin {
  late final VetProfileController _controller;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _consultationFeeController;
  late final TextEditingController _videoFeeController;
  late final TextEditingController _homeVisitFeeController;
  late final TextEditingController _emergencyMultiplierController;

  @override
  void initState() {
    super.initState();
    _controller = VetProfileController();
    _consultationFeeController = TextEditingController();
    _videoFeeController = TextEditingController();
    _homeVisitFeeController = TextEditingController();
    _emergencyMultiplierController = TextEditingController();
    _loadPricing();
  }

  @override
  void dispose() {
    _controller.dispose();
    _consultationFeeController.dispose();
    _videoFeeController.dispose();
    _homeVisitFeeController.dispose();
    _emergencyMultiplierController.dispose();
    super.dispose();
  }

  Future<void> _loadPricing() async {
    setPricingLoading(true);
    setPricingError(null);

    final result = await _controller.loadPricing();

    if (!mounted) return;

    if (result.success && result.pricing != null) {
      final p = result.pricing!;
      _consultationFeeController.text = p.consultationFee ?? '';
      _videoFeeController.text = p.videoConsultationFee ?? '';
      _homeVisitFeeController.text = p.homeVisitFee ?? '';
      _emergencyMultiplierController.text = p.emergencyFeeMultiplier ?? '';
    } else if (result.message != null) {
      setPricingError(result.message);
      showErrorToast(result.message!);
    }

    setPricingLoading(false);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setPricingSaving(true);

    final pricing = VetPricingModel(
      consultationFee: _consultationFeeController.text.trim(),
      videoConsultationFee: _videoFeeController.text.trim(),
      homeVisitFee: _homeVisitFeeController.text.trim(),
      emergencyFeeMultiplier: _emergencyMultiplierController.text.trim(),
    );

    final result = await _controller.savePricing(pricing);

    if (!mounted) return;
    setPricingSaving(false);

    if (result.success) {
      showSuccessToast('Pricing saved successfully');
    } else {
      showErrorToast(result.message ?? 'Failed to save pricing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Pricing'),
        backgroundColor: AppTheme.authPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null && _controller.pricing == null
              ? _buildErrorState()
              : _buildPricingForm(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadPricing,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.authPrimaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.authPrimaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.authPrimaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Set your consultation fees. Farmers will see these prices when booking appointments.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Fee cards
            _buildFeeCard(
              icon: Icons.local_hospital_outlined,
              iconColor: AppTheme.authPrimaryColor,
              label: 'In-Clinic Consultation',
              hint: 'e.g., 500',
              controller: _consultationFeeController,
            ),
            const SizedBox(height: 16),

            _buildFeeCard(
              icon: Icons.videocam_outlined,
              iconColor: Colors.blue,
              label: 'Video Consultation',
              hint: 'e.g., 400',
              controller: _videoFeeController,
            ),
            const SizedBox(height: 16),

            _buildFeeCard(
              icon: Icons.home_outlined,
              iconColor: Colors.orange,
              label: 'Home Visit',
              hint: 'e.g., 1000',
              controller: _homeVisitFeeController,
            ),
            const SizedBox(height: 16),

            _buildFeeCard(
              icon: Icons.emergency_outlined,
              iconColor: Colors.red,
              label: 'Emergency Fee Multiplier',
              hint: 'e.g., 1.5',
              controller: _emergencyMultiplierController,
              prefix: null,
              suffix: 'x',
              helperText: 'Emergency fee = Consultation fee x multiplier',
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.authPrimaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Pricing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String hint,
    required TextEditingController controller,
    String? prefix = '\u20B9',
    String? suffix,
    String? helperText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final number = double.tryParse(value.trim());
              if (number == null) return 'Enter a valid number';
              if (number <= 0) return 'Must be greater than zero';
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixText: prefix != null ? '$prefix ' : null,
              prefixStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              suffixText: suffix,
              suffixStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              helperText: helperText,
              helperStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppTheme.authPrimaryColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
