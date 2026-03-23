import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/vet/controllers/vet_profile_controller.dart';
import 'package:flutter_app/features/vet/models/vet_availability_slot_model.dart';
import 'package:flutter_app/features/vet/mixins/vet_availability_state_mixin.dart';

/// Screen for managing vet weekly availability
class VetAvailabilityScreen extends StatefulWidget {
  const VetAvailabilityScreen({super.key});

  @override
  State<VetAvailabilityScreen> createState() => _VetAvailabilityScreenState();
}

class _VetAvailabilityScreenState extends State<VetAvailabilityScreen>
    with VetAvailabilityStateMixin, ToastMixin {
  late final VetProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VetProfileController();
    _loadAvailability();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAvailability() async {
    setAvailabilityLoading(true);
    setAvailabilityError(null);

    final result = await _controller.loadAvailability();

    if (!mounted) return;

    if (!result.success) {
      setAvailabilityError(result.message ?? 'Failed to load availability');
      showErrorToast(result.message ?? 'Failed to load availability');
    }

    setAvailabilityLoading(false);
  }

  void _showAddSlotSheet({int? preselectedDay}) {
    int? selectedDay = preselectedDay;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    bool isSavingSlot = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + bottomPadding + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Availability',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Day picker
                  DropdownButtonFormField<int>(
                    value: selectedDay,
                    decoration: InputDecoration(
                      labelText: 'Day of Week',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    items: List.generate(7, (i) {
                      return DropdownMenuItem(
                        value: i,
                        child: Text(VetAvailabilitySlotModel.dayNames[i]),
                      );
                    }),
                    onChanged: (val) {
                      setSheetState(() => selectedDay = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Time pickers
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePickerTile(
                          label: 'Start Time',
                          time: startTime,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: startTime ?? const TimeOfDay(hour: 9, minute: 0),
                            );
                            if (picked != null) {
                              setSheetState(() => startTime = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimePickerTile(
                          label: 'End Time',
                          time: endTime,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: endTime ?? const TimeOfDay(hour: 17, minute: 0),
                            );
                            if (picked != null) {
                              setSheetState(() => endTime = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: (selectedDay != null &&
                              startTime != null &&
                              endTime != null &&
                              !isSavingSlot)
                          ? () async {
                              setSheetState(() => isSavingSlot = true);

                              final slot = VetAvailabilitySlotModel(
                                dayOfWeek: selectedDay!,
                                dayName: VetAvailabilitySlotModel
                                    .dayNames[selectedDay!],
                                startTime: VetAvailabilitySlotModel
                                    .timeOfDayToApiString(startTime!),
                                endTime: VetAvailabilitySlotModel
                                    .timeOfDayToApiString(endTime!),
                              );

                              final result = await _controller.addSlot(slot);

                              if (!mounted) return;
                              setSheetState(() => isSavingSlot = false);

                              if (result.success) {
                                Navigator.pop(context);
                                showSuccessToast('Availability slot added');
                                setState(() {}); // Refresh UI
                              } else {
                                showErrorToast(
                                  result.message ?? 'Failed to add slot',
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.authPrimaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isSavingSlot
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
                              'Save',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditSlotSheet(VetAvailabilitySlotModel existingSlot) {
    TimeOfDay startTime = existingSlot.startTimeOfDay;
    TimeOfDay endTime = existingSlot.endTimeOfDay;
    bool isSavingSlot = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + bottomPadding + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit ${existingSlot.dayName} Slot',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Time pickers
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePickerTile(
                          label: 'Start Time',
                          time: startTime,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null) {
                              setSheetState(() => startTime = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimePickerTile(
                          label: 'End Time',
                          time: endTime,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (picked != null) {
                              setSheetState(() => endTime = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: !isSavingSlot
                          ? () async {
                              setSheetState(() => isSavingSlot = true);

                              final updatedSlot = VetAvailabilitySlotModel(
                                dayOfWeek: existingSlot.dayOfWeek,
                                dayName: existingSlot.dayName,
                                startTime: VetAvailabilitySlotModel
                                    .timeOfDayToApiString(startTime),
                                endTime: VetAvailabilitySlotModel
                                    .timeOfDayToApiString(endTime),
                              );

                              final result = await _controller.updateSlot(
                                existingSlot.availabilityId!,
                                updatedSlot,
                              );

                              if (!mounted) return;
                              setSheetState(() => isSavingSlot = false);

                              if (result.success) {
                                Navigator.pop(context);
                                showSuccessToast('Slot updated');
                                setState(() {}); // Refresh UI
                              } else {
                                showErrorToast(
                                  result.message ?? 'Failed to update slot',
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.authPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isSavingSlot
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
                              'Update',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleDeleteSlot(VetAvailabilitySlotModel slot) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Slot'),
        content: Text(
          'Remove ${slot.dayName} ${slot.formattedTimeRange}?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final result =
                  await _controller.deleteSlot(slot.availabilityId!);

              if (!mounted) return;

              if (result.success) {
                showSuccessToast('Slot deleted');
                setState(() {}); // Refresh UI
              } else {
                showErrorToast(result.message ?? 'Failed to delete slot');
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerTile({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 16, color: AppTheme.authPrimaryColor),
                const SizedBox(width: 6),
                Text(
                  time != null
                      ? VetAvailabilitySlotModel.formatTimeOfDay(time)
                      : 'Select',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: time != null
                        ? AppTheme.textPrimary
                        : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Availability'),
        backgroundColor: AppTheme.authPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null &&
                  _controller.availabilitySlots.isEmpty
              ? _buildErrorState()
              : _buildAvailabilityList(),
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
              onPressed: _loadAvailability,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityList() {
    return RefreshIndicator(
      onRefresh: _loadAvailability,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 7,
        itemBuilder: (context, index) => _buildDayCard(index),
      ),
    );
  }

  Widget _buildDayCard(int dayOfWeek) {
    final dayName = VetAvailabilitySlotModel.dayNames[dayOfWeek];
    final slots = _controller.getSlotsForDay(dayOfWeek);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (slots.isEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'No slots',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ),
            ],
          ),
          if (slots.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...slots.map((slot) => _buildSlotRow(slot)),
          ],
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _showAddSlotSheet(preselectedDay: dayOfWeek),
            child: Row(
              children: [
                Icon(Icons.add_circle_outline,
                    size: 18, color: AppTheme.authPrimaryColor),
                const SizedBox(width: 6),
                Text(
                  'Add Availability',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.authPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotRow(VetAvailabilitySlotModel slot) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              slot.formattedTimeRange,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showEditSlotSheet(slot),
            icon: Icon(Icons.edit_outlined,
                size: 18, color: AppTheme.authPrimaryColor),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            onPressed: () => _handleDeleteSlot(slot),
            icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
