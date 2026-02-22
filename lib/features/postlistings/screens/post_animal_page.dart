import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/postlistings/controllers/post_animal_controller.dart';
import 'package:flutter_app/features/postlistings/details/screens/details_page.dart';
import 'package:flutter_app/features/postlistings/health/screens/health_page.dart';
import 'package:flutter_app/features/postlistings/media/screens/media_page.dart';
import 'package:flutter_app/features/postlistings/mixins/post_animal_state_mixin.dart';
import 'package:flutter_app/features/postlistings/preview/screens/preview_page.dart';
import 'package:flutter_app/features/postlistings/widgets/step_indicator.dart';

/// Post Animal Page
///
/// Multi-step form with step indicator for posting animal listings
/// Flow: Details (POST) -> Health (PATCH) -> Media (PATCH) -> Preview
class PostAnimalPage extends StatefulWidget {
  const PostAnimalPage({super.key});

  @override
  State<PostAnimalPage> createState() => _PostAnimalPageState();
}

class _PostAnimalPageState extends State<PostAnimalPage>
    with PostAnimalStateMixin, ToastMixin {
  late final PostAnimalController _controller;

  // Listing ID from POST response, used for PATCH calls
  int? _listingId;

  @override
  void initState() {
    super.initState();
    _controller = PostAnimalController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handle listing created from Details page
  void _onListingCreated(int listingId) {
    setState(() {
      _listingId = listingId;
    });
    _controller.setListingId(listingId);
    nextStep();
  }

  /// Handle publish action
  void _handlePublish() {
    // Listing is already saved, navigate back and return true to indicate success
    Navigator.pop(context, true);
  }

  /// Handle close/cancel
  void _handleClose() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Step Indicator (4 steps now)
          StepIndicator(
            currentStep: currentStep,
            totalSteps: PostAnimalController.totalSteps,
            stepLabels: PostAnimalController.stepLabels,
          ),

          // Page Content
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: updateStep,
              children: [
                // Step 0: Details (POST creates listing)
                DetailsPage(onNext: _onListingCreated, onPrevious: null),

                // Step 1: Health (PATCH updates listing)
                _listingId != null
                    ? HealthPage(
                        listingId: _listingId!,
                        onNext: nextStep,
                        onPrevious: previousStep,
                      )
                    : _buildPlaceholder('Health'),

                // Step 2: Media (PATCH updates listing)
                _listingId != null
                    ? MediaPage(
                        listingId: _listingId!,
                        onNext: nextStep,
                        onPrevious: previousStep,
                      )
                    : _buildPlaceholder('Media'),

                // Step 3: Preview (fetch and display)
                _listingId != null
                    ? PreviewPage(
                        listingId: _listingId!,
                        onPrevious: previousStep,
                        onPublish: _handlePublish,
                      )
                    : _buildPlaceholder('Preview'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build placeholder widget for pages before listing is created
  Widget _buildPlaceholder(String stepName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Complete Details step first',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: _handleClose,
      ),
      title: const Text(
        'Post Animal',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: _handleClose,
        ),
      ],
    );
  }
}
