/// Create Request Screen
///
/// Multi-step wizard container for creating transport requests.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/transport/controllers/create_request_controller.dart';
import 'package:flutter_app/features/transport/screens/requester/animal_selection_screen.dart';
import 'package:flutter_app/features/transport/screens/requester/location_selection_screen.dart';
import 'package:flutter_app/features/transport/screens/requester/datetime_selection_screen.dart';
import 'package:flutter_app/features/transport/screens/requester/fare_estimate_screen.dart';
import 'package:flutter_app/features/transport/widgets/wizard_step_indicator.dart';
import 'package:flutter_app/routes/app_routes.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  late CreateRequestController _controller;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _controller = CreateRequestController();
    _pageController = PageController();

    // Listen for step changes to sync page controller
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    // Sync page controller with current step
    if (_pageController.hasClients) {
      final targetPage = _controller.currentStep;
      if (_pageController.page?.round() != targetPage) {
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_controller.currentStep > 0) {
      _controller.previousStep();
      return false;
    }
    return true;
  }

  void _onNextPressed() {
    if (_controller.isLastStep) {
      _submitRequest();
    } else {
      _controller.nextStep();
    }
  }

  Future<void> _submitRequest() async {
    final success = await _controller.submitRequest();
    if (success && mounted) {
      // Show success and navigate to my requests
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transport request created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to my requests screen
      AppRoutes.navigateAndReplace(context, AppRoutes.transportMyRequests);
    } else if (mounted && _controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Consumer<CreateRequestController>(
          builder: (context, controller, _) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Request Transport'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (controller.data.isStep1Complete ||
                        controller.data.isStep2Complete ||
                        controller.data.isStep3Complete) {
                      _showExitConfirmation();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
              body: Column(
                children: [
                  // Step indicator
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: WizardStepIndicator(
                      currentStep: controller.currentStep,
                      totalSteps: CreateRequestController.totalSteps,
                      stepLabels: CreateRequestController.stepLabels,
                    ),
                  ),

                  // Page content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        AnimalSelectionScreen(),
                        LocationSelectionScreen(),
                        DateTimeSelectionScreen(),
                        FareEstimateScreen(),
                      ],
                    ),
                  ),

                  // Bottom navigation
                  _buildBottomNavigation(context, controller),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    CreateRequestController controller,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button (if not first step)
            if (!controller.isFirstStep)
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      controller.isSubmitting ? null : controller.previousStep,
                  child: const Text('Back'),
                ),
              ),

            if (!controller.isFirstStep) const SizedBox(width: 16),

            // Next/Submit button
            Expanded(
              flex: controller.isFirstStep ? 1 : 1,
              child: FilledButton(
                onPressed: controller.canProceed &&
                        !controller.isSubmitting &&
                        !controller.isEstimating
                    ? _onNextPressed
                    : null,
                child: controller.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(controller.isLastStep ? 'Confirm Request' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExitConfirmation() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Request?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      Navigator.of(context).pop();
    }
  }
}
