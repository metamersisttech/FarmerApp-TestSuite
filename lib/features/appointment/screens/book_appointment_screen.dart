import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/mixins/book_appointment_state_mixin.dart';
import 'package:flutter_app/features/appointment/widgets/appointment_vet_info_card.dart';
import 'package:flutter_app/features/appointment/widgets/consultation_mode_selector.dart';
import 'package:flutter_app/features/vet/models/vet_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Book Appointment Screen
///
/// Allows the farmer to request an appointment with a vet.
/// Shows vet info, consultation mode selector, animal dropdown,
/// notes field, fee summary, and submit button.
class BookAppointmentScreen extends StatefulWidget {
  final VetModel vet;

  const BookAppointmentScreen({
    super.key,
    required this.vet,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen>
    with BookAppointmentStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeBooking(widget.vet);
    });
  }

  @override
  void dispose() {
    disposeBooking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: handleBackTap,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vet info card (read-only)
            AppointmentVetInfoCard(
              name: widget.vet.name,
              clinicName: widget.vet.clinicName,
              specialization: widget.vet.specialization,
              profileImage: widget.vet.profileImage,
            ),
            const SizedBox(height: 20),

            // Consultation mode selector
            ConsultationModeSelector(
              selectedMode: selectedMode,
              consultationFee: widget.vet.formattedConsultationFee,
              videoCallFee: widget.vet.formattedVideoCallFee,
              onModeSelected: selectMode,
            ),
            const SizedBox(height: 20),

            // Animal selection dropdown
            _buildAnimalDropdown(),
            const SizedBox(height: 20),

            // Notes field
            _buildNotesField(),
            const SizedBox(height: 20),

            // Fee summary
            _buildFeeSummary(),
            const SizedBox(height: 16),

            // Info banner
            _buildInfoBanner(),
            const SizedBox(height: 24),

            // Submit button
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Animal (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: isLoadingListings
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Loading your animals...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: selectedListing?.listingId,
                    isExpanded: true,
                    hint: Text(
                      userListings.isEmpty
                          ? 'No animals listed'
                          : 'Choose an animal',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...userListings.map(
                        (listing) => DropdownMenuItem<int?>(
                          value: listing.listingId,
                          child: Text(listing.title),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        selectListing(null);
                      } else {
                        final listing = userListings.firstWhere(
                          (l) => l.listingId == value,
                        );
                        selectListing(listing);
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Describe the issue or reason for visit...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.white,
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
                  const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Consultation Fee',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            selectedFee,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your appointment request will be sent to the vet for confirmation. '
              'The vet will schedule a time and notify you once confirmed.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : submitAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Request Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
