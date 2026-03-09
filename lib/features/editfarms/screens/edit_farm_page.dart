import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/editfarms/controllers/edit_farm_controller.dart';
import 'package:flutter_app/features/editfarms/mixins/edit_farm_state_mixin.dart';
import 'package:flutter_app/features/location/models/location_model.dart';
import 'package:flutter_app/features/location/screens/location_page.dart';
import 'package:flutter_app/features/postlistings/mixins/farm_state_mixin.dart';
import 'package:flutter_app/features/postlistings/widgets/farm_form_widgets.dart';

/// Edit Farm Page - Form to edit an existing farm
class EditFarmPage extends StatefulWidget {
  final int farmId;
  final Map<String, dynamic>? farmData;

  const EditFarmPage({
    super.key,
    required this.farmId,
    this.farmData,
  });

  @override
  State<EditFarmPage> createState() => _EditFarmPageState();
}

class _EditFarmPageState extends State<EditFarmPage>
    with ToastMixin, FarmStateMixin, EditFarmStateMixin {
  late EditFarmController _controller;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _controller = EditFarmController(farmId: widget.farmId);
    _initializeFarmData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Initialize farm data - either from passed data or fetch from API
  Future<void> _initializeFarmData() async {
    if (widget.farmData != null) {
      preFillFromFarm(widget.farmData!);
      setState(() => _isFetching = false);
    } else {
      await _fetchFarmData();
    }
  }

  /// Fetch farm data from API
  Future<void> _fetchFarmData() async {
    final data = await _controller.loadFarm();

    if (!mounted) return;

    if (data != null) {
      preFillFromFarm(data);
      setState(() => _isFetching = false);
    } else {
      setState(() => _isFetching = false);
      showErrorToast(_controller.errorMessage ?? 'Failed to load farm details');
      Navigator.of(context).pop();
    }
  }

  /// Handle location selection
  Future<void> _handleLocationSelection() async {
    final result = await Navigator.push<LocationData>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPage(),
      ),
    );

    if (result != null) {
      updateLocation(result);
    }
  }

  /// Submit form and update farm
  Future<void> _submitForm() async {
    if (!validateForm()) {
      return;
    }

    final formData = buildFarmData();
    final result = await _controller.updateFarm(formData);

    if (!mounted) return;

    if (result.success) {
      showSuccessToast('Farm updated successfully!');
      Navigator.of(context).pop(result.data);
    } else {
      showErrorToast(result.errorMessage ?? 'Failed to update farm');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Farm',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isFetching
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: formKey,
              child: Column(
                children: [
                  // Scrollable form content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Farm Name
                          const FarmSectionTitle(
                            title: 'Farm Name',
                            isRequired: true,
                          ),
                          const SizedBox(height: 8),
                          FarmTextField(
                            controller: nameController,
                            hintText: 'e.g. Green Valley Farm',
                            prefixIcon: Icons.agriculture,
                            validator: validateFarmName,
                          ),

                          const SizedBox(height: 20),

                          // Area
                          const FarmSectionTitle(
                            title: 'Area (sq. meters)',
                            isRequired: true,
                          ),
                          const SizedBox(height: 8),
                          FarmTextField(
                            controller: areaController,
                            hintText: 'e.g. 50000',
                            prefixIcon: Icons.square_foot,
                            keyboardType: TextInputType.number,
                            validator: validateArea,
                          ),

                          const SizedBox(height: 20),

                          // Address
                          const FarmSectionTitle(
                            title: 'Address',
                            isRequired: true,
                          ),
                          const SizedBox(height: 8),
                          FarmTextField(
                            controller: addressController,
                            hintText: 'e.g. Village Khed, Taluka Ambegaon, District Pune',
                            prefixIcon: Icons.location_on,
                            maxLines: 3,
                            validator: validateAddress,
                          ),

                          const SizedBox(height: 20),

                          // Location Search Field
                          const FarmSectionTitle(
                            title: 'Location',
                            isRequired: false,
                          ),
                          const SizedBox(height: 8),
                          FarmLocationField(
                            controller: locationController,
                            onTap: _handleLocationSelection,
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Submit button at bottom
                  FarmSubmitButton(
                    isLoading: _controller.isLoading,
                    onPressed: _submitForm,
                    text: 'Update Farm',
                  ),
                ],
              ),
            ),
    );
  }
}
