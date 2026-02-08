import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/models/available_slot_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// 3-column grid of selectable time slots for the approve screen.
///
/// Green/white for available, grey+lock for booked, primary color for selected.
class TimeSlotGrid extends StatelessWidget {
  final List<AvailableSlot> slots;
  final AvailableSlot? selectedSlot;
  final ValueChanged<AvailableSlot>? onSlotTap;

  const TimeSlotGrid({
    super.key,
    required this.slots,
    this.selectedSlot,
    this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No time slots available for this date.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.4,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = selectedSlot != null &&
            selectedSlot!.startTime == slot.startTime &&
            selectedSlot!.endTime == slot.endTime;

        return _SlotTile(
          slot: slot,
          isSelected: isSelected,
          onTap: slot.available ? () => onSlotTap?.call(slot) : null,
        );
      },
    );
  }
}

class _SlotTile extends StatelessWidget {
  final AvailableSlot slot;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SlotTile({
    required this.slot,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;

    if (isSelected) {
      bgColor = AppTheme.primaryColor;
      borderColor = AppTheme.primaryColor;
      textColor = Colors.white;
    } else if (slot.available) {
      bgColor = Colors.white;
      borderColor = Colors.green.shade300;
      textColor = Colors.green.shade700;
    } else {
      bgColor = Colors.grey.shade100;
      borderColor = Colors.grey.shade300;
      textColor = Colors.grey.shade400;
      trailingIcon = Icons.lock_outline;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingIcon != null) ...[
                Icon(trailingIcon, size: 12, color: textColor),
                const SizedBox(width: 3),
              ],
              Text(
                slot.displayStartTime,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Legend row explaining slot colors
class TimeSlotLegend extends StatelessWidget {
  const TimeSlotLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(Colors.green.shade300, 'Available'),
        const SizedBox(width: 16),
        _legendDot(Colors.grey.shade300, 'Booked'),
        const SizedBox(width: 16),
        _legendDot(AppTheme.primaryColor, 'Selected'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
