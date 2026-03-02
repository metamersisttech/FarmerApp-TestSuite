import 'package:flutter/material.dart';
import 'package:flutter_app/features/editlistings/details/screens/edit_details_page.dart';
import 'package:flutter_app/features/editlistings/health/screens/edit_health_page.dart';
import 'package:flutter_app/features/editlistings/media/screens/edit_media_page.dart';
import 'package:flutter_app/features/editlistings/preview/screens/edit_preview_page.dart';
import 'package:flutter_app/features/postlistings/mixins/post_animal_state_mixin.dart';
import 'package:flutter_app/features/postlistings/widgets/step_indicator.dart';

/// Edit Listing Page
///
/// Multi-step form with step indicator (same as Post Animal).
/// Flow: Details (PATCH) -> Health (PATCH) -> Media (PATCH) -> Preview -> Done
class EditListingPage extends StatefulWidget {
  final int listingId;

  const EditListingPage({
    super.key,
    required this.listingId,
  });

  @override
  State<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage>
    with PostAnimalStateMixin {
  static const int _totalSteps = 4;
  static const List<String> _stepLabels = [
    'Details',
    'Health',
    'Media',
    'Preview',
  ];

  // Track if any updates were made during the edit flow
  bool _hasUpdates = false;

  void _handleDone() {
    Navigator.of(context).pop(true);
  }

  /// Mark that updates have been made
  void _markAsUpdated() {
    _hasUpdates = true;
  }

  /// Handle back button press
  void _handleBack() {
    Navigator.of(context).pop(_hasUpdates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          StepIndicator(
            currentStep: currentStep,
            totalSteps: _totalSteps,
            stepLabels: _stepLabels,
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: updateStep,
              children: [
                EditDetailsPage(
                  listingId: widget.listingId,
                  embeddedInFlow: true,
                  onNext: () {
                    _markAsUpdated();
                    nextStep();
                  },
                  onPrevious: previousStep,
                ),
                EditHealthPage(
                  listingId: widget.listingId,
                  onNext: () {
                    _markAsUpdated();
                    nextStep();
                  },
                  onPrevious: previousStep,
                ),
                EditMediaPage(
                  listingId: widget.listingId,
                  onNext: () {
                    _markAsUpdated();
                    nextStep();
                  },
                  onPrevious: previousStep,
                ),
                EditPreviewPage(
                  listingId: widget.listingId,
                  onPrevious: previousStep,
                  onDone: _handleDone,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: _handleBack,
      ),
      title: const Text(
        'Edit Listing',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: _handleBack,
        ),
      ],
    );
  }
}
