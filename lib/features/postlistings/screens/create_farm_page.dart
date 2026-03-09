import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/location/models/location_model.dart';
import 'package:flutter_app/features/location/screens/location_page.dart';
import 'package:flutter_app/features/postlistings/mixins/farm_state_mixin.dart';
import 'package:flutter_app/features/postlistings/widgets/farm_form_widgets.dart';

/// Create Farm Page - Form to create a new farm
class CreateFarmPage extends StatefulWidget {
  const CreateFarmPage({super.key});

  @override
  State<CreateFarmPage> createState() => _CreateFarmPageState();
}

class _CreateFarmPageState extends State<CreateFarmPage>
    with ToastMixin, FarmStateMixin {
  final BackendHelper _backendHelper = BackendHelper();
  bool _isLoading = false;

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

  /// Submit form and create farm
  Future<void> _submitForm() async {
    if (!validateForm()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = buildFarmData();
      final result = await _backendHelper.postCreateFarm(data);

      if (!mounted) return;

      setState(() => _isLoading = false);

      showSuccessToast('Farm created successfully!');

      // Return the created farm data to the previous screen
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      showErrorToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Create Farm',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Form(
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
              isLoading: _isLoading,
              onPressed: _submitForm,
              text: 'Create Farm',
            ),
          ],
        ),
      ),
    );
  }
}
