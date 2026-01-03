import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/sell/controllers/post_animal_controller.dart';
import 'package:flutter_app/features/sell/mixins/post_animal_state_mixin.dart';
import 'package:flutter_app/features/sell/services/sell_service.dart';
import 'package:flutter_app/features/sell/widgets/details_tab.dart';
import 'package:flutter_app/features/sell/widgets/health_tab.dart';
import 'package:flutter_app/features/sell/widgets/location_tab.dart';
import 'package:flutter_app/features/sell/widgets/media_tab.dart';
import 'package:flutter_app/features/sell/widgets/preview_tab.dart';
import 'package:flutter_app/features/sell/widgets/step_indicator.dart';

/// Post Animal Page
///
/// Multi-step form with step indicator for posting animal listings
class PostAnimalPage extends StatefulWidget {
  const PostAnimalPage({super.key});

  @override
  State<PostAnimalPage> createState() => _PostAnimalPageState();
}

class _PostAnimalPageState extends State<PostAnimalPage>
    with PostAnimalStateMixin, ToastMixin {
  late final PostAnimalController _controller;
  late final SellService _sellService;

  @override
  void initState() {
    super.initState();
    _controller = PostAnimalController();
    _sellService = SellService();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handle publish action
  Future<void> _handlePublish() async {
    if (!_controller.listingData.isComplete()) {
      showErrorToast('Please complete all required fields');
      return;
    }

    final result = await _sellService.publishListing(
      _controller.listingData.toJson(),
    );

    if (!mounted) return;

    if (result.success) {
      showSuccessToast(result.message ?? 'Listing published successfully!');
      Navigator.pop(context);
    } else {
      showErrorToast(result.message ?? 'Failed to publish listing');
    }
  }

  /// Handle close/cancel
  void _handleClose() {
    // TODO: Show confirmation dialog if form has data
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Step Indicator
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
                DetailsTab(
                  onNext: nextStep,
                  onPrevious: null,
                ),
                HealthTab(
                  onNext: nextStep,
                  onPrevious: previousStep,
                ),
                LocationTab(
                  onNext: nextStep,
                  onPrevious: previousStep,
                ),
                MediaTab(
                  onNext: nextStep,
                  onPrevious: previousStep,
                ),
                PreviewTab(
                  onPrevious: previousStep,
                  onPublish: _handlePublish,
                ),
              ],
            ),
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
