/// Book Transport Screen (Farmer Side)
///
/// Allows a farmer to request transport for an animal after viewing/purchasing.
/// Pre-fills pickup location from listing seller location, destination from profile.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/transport/services/farmer_transport_service.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

class BookTransportScreen extends StatefulWidget {
  /// Optional: Pre-fill from animal listing
  final int? listingId;
  final String? animalName;
  final String? sellerLocation;
  final double? sellerLat;
  final double? sellerLng;
  final String? animalSpecies;

  const BookTransportScreen({
    super.key,
    this.listingId,
    this.animalName,
    this.sellerLocation,
    this.sellerLat,
    this.sellerLng,
    this.animalSpecies,
  });

  @override
  State<BookTransportScreen> createState() => _BookTransportScreenState();
}

class _BookTransportScreenState extends State<BookTransportScreen>
    with ToastMixin {
  final _formKey = GlobalKey<FormState>();
  final _service = FarmerTransportService();

  // Controllers
  final _pickupCtrl = TextEditingController();
  final _dropCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _budgetMinCtrl = TextEditingController();
  final _budgetMaxCtrl = TextEditingController();
  final _animalCountCtrl = TextEditingController(text: '1');
  final _weightCtrl = TextEditingController();

  // State
  DateTime _pickupDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay? _pickupTime;
  String _selectedSpecies = 'Cattle';
  bool _isSubmitting = false;

  static const _speciesOptions = [
    'Cattle',
    'Buffalo',
    'Cow',
    'Goat',
    'Sheep',
    'Pig',
    'Poultry',
    'Horse',
    'Camel',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill from listing data
    if (widget.sellerLocation != null) {
      _pickupCtrl.text = widget.sellerLocation!;
    }
    if (widget.animalSpecies != null) {
      final match = _speciesOptions.firstWhere(
        (s) => s.toLowerCase() == widget.animalSpecies!.toLowerCase(),
        orElse: () => 'Cattle',
      );
      _selectedSpecies = match;
    }
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropCtrl.dispose();
    _notesCtrl.dispose();
    _budgetMinCtrl.dispose();
    _budgetMaxCtrl.dispose();
    _animalCountCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _pickupDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickupTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _pickupTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final count = int.tryParse(_animalCountCtrl.text.trim()) ?? 1;
      final weight = double.tryParse(_weightCtrl.text.trim());
      final fareMin = double.tryParse(_budgetMinCtrl.text.trim());
      final fareMax = double.tryParse(_budgetMaxCtrl.text.trim());

      final timeStr = _pickupTime != null
          ? '${_pickupTime!.hour.toString().padLeft(2, '0')}:${_pickupTime!.minute.toString().padLeft(2, '0')}'
          : null;

      await _service.createRequest(
        pickupAddress: _pickupCtrl.text.trim(),
        pickupLat: widget.sellerLat ?? 0.0,
        pickupLng: widget.sellerLng ?? 0.0,
        destinationAddress: _dropCtrl.text.trim(),
        destinationLat: 0.0,
        destinationLng: 0.0,
        cargoAnimals: [
          {
            'count': count,
            'species': _selectedSpecies,
            'breed': widget.animalName ?? '',
            if (weight != null) 'estimated_weight_kg': weight,
          }
        ],
        pickupDate: _pickupDate,
        pickupTime: timeStr,
        estimatedFareMin: fareMin,
        estimatedFareMax: fareMax,
        notes: _notesCtrl.text.trim(),
        listingId: widget.listingId,
      );

      if (!mounted) return;
      showSuccessToast('transport.booking_requested'.tr());
      Navigator.of(context).pop(true); // true = success
    } catch (e) {
      if (!mounted) return;
      showErrorToast('transport.booking_failed'.tr());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
          'transport.book_transport'.tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animal info banner (if pre-filled from listing)
              if (widget.animalName != null) _buildAnimalBanner(),

              _buildSectionHeader('transport.route_details'.tr()),
              _buildRouteCard(),

              const SizedBox(height: 16),
              _buildSectionHeader('transport.animal_cargo'.tr()),
              _buildCargoCard(),

              const SizedBox(height: 16),
              _buildSectionHeader('transport.schedule'.tr()),
              _buildScheduleCard(),

              const SizedBox(height: 16),
              _buildSectionHeader('transport.budget_optional'.tr()),
              _buildBudgetCard(),

              const SizedBox(height: 16),
              _buildNotesCard(),

              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppTheme.primaryColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${'transport.booking_for'.tr()}: ${widget.animalName}',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildRouteCard() {
    return _card(
      child: Column(
        children: [
          // Pickup
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _routeDot(Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _pickupCtrl,
                  decoration: _inputDec(
                    'transport.pickup_location'.tr(),
                    hint: 'transport.pickup_hint'.tr(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'transport.pickup_required'.tr()
                      : null,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Container(
              width: 2,
              height: 20,
              color: Colors.grey.shade300,
            ),
          ),

          // Destination
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _routeDot(Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _dropCtrl,
                  decoration: _inputDec(
                    'transport.destination'.tr(),
                    hint: 'transport.destination_hint'.tr(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'transport.destination_required'.tr()
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCargoCard() {
    return _card(
      child: Column(
        children: [
          // Species
          DropdownButtonFormField<String>(
            value: _selectedSpecies,
            decoration: _inputDec('transport.animal_type'.tr()),
            items: _speciesOptions
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedSpecies = v);
            },
          ),
          const SizedBox(height: 12),

          // Count + Weight row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _animalCountCtrl,
                  decoration: _inputDec('transport.animal_count'.tr()),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1) {
                      return 'transport.count_required'.tr();
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _weightCtrl,
                  decoration: _inputDec(
                    'transport.est_weight'.tr(),
                    hint: 'transport.weight_hint'.tr(),
                    suffix: 'kg',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    final dateStr = DateFormat('EEE, dd MMM yyyy').format(_pickupDate);
    final timeStr = _pickupTime != null
        ? _pickupTime!.format(context)
        : 'transport.any_time'.tr();

    return _card(
      child: Row(
        children: [
          // Date
          Expanded(
            child: _tapTile(
              icon: Icons.calendar_today_rounded,
              label: 'transport.pickup_date'.tr(),
              value: dateStr,
              onTap: _pickDate,
            ),
          ),
          Container(width: 1, height: 48, color: Colors.grey.shade200),
          // Time
          Expanded(
            child: _tapTile(
              icon: Icons.access_time_rounded,
              label: 'transport.pickup_time'.tr(),
              value: timeStr,
              onTap: _pickTime,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'transport.budget_hint'.tr(),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _budgetMinCtrl,
                  decoration: _inputDec(
                    'transport.min_budget'.tr(),
                    prefix: '₹',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('–',
                    style:
                        TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
              ),
              Expanded(
                child: TextFormField(
                  controller: _budgetMaxCtrl,
                  decoration: _inputDec(
                    'transport.max_budget'.tr(),
                    prefix: '₹',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final min =
                        double.tryParse(_budgetMinCtrl.text.trim()) ?? 0;
                    final max = double.tryParse(v ?? '');
                    if (max != null && min > 0 && max < min) {
                      return 'transport.max_less_than_min'.tr();
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return _card(
      child: TextFormField(
        controller: _notesCtrl,
        decoration: _inputDec(
          'transport.special_notes'.tr(),
          hint: 'transport.notes_hint'.tr(),
        ),
        maxLines: 3,
        maxLength: 500,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                'transport.request_transport'.tr(),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }

  Widget _routeDot(Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
      ),
    );
  }

  Widget _tapTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label,
      {String? hint, String? prefix, String? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      suffixText: suffix,
      labelStyle:
          const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
      hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textHint),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      isDense: true,
    );
  }
}
