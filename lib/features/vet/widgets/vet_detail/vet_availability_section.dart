import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/features/vet/models/vet_availability_slot_model.dart';

/// Weekly availability schedule section for the vet detail page
class VetAvailabilitySection extends StatelessWidget {
  final List<VetAvailabilitySlotModel> slots;

  const VetAvailabilitySection({
    super.key,
    required this.slots,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) return const SizedBox.shrink();

    // Build a map of dayOfWeek -> slot for quick lookup
    final slotMap = <int, VetAvailabilitySlotModel>{};
    for (final slot in slots) {
      slotMap[slot.dayOfWeek] = slot;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: 8),
              Text(
                'Weekly Schedule',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(7, (index) {
            final slot = slotMap[index];
            final dayName = VetAvailabilitySlotModel.dayNames[index];
            return _buildDayRow(dayName, slot);
          }),
        ],
      ),
    );
  }

  Widget _buildDayRow(String dayName, VetAvailabilitySlotModel? slot) {
    final isAvailable = slot != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              dayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isAvailable ? AppTheme.textPrimary : Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isAvailable ? slot.formattedTimeRange : 'Unavailable',
              style: TextStyle(
                fontSize: 14,
                color: isAvailable ? Colors.grey[700] : Colors.grey[400],
                fontStyle: isAvailable ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
          if (isAvailable)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
