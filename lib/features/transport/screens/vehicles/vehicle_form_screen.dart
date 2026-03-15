/// Vehicle Form Screen
///
/// Add or edit vehicle details with document uploads.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/transport/controllers/vehicle_controller.dart';
import 'package:flutter_app/features/transport/models/vehicle_model.dart';

class VehicleFormScreen extends StatefulWidget {
  final int? vehicleId;

  const VehicleFormScreen({
    super.key,
    this.vehicleId,
  });

  bool get isEditing => vehicleId != null;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  late VehicleController _controller;
  final _formKey = GlobalKey<FormState>();

  final _registrationController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _maxWeightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  VehicleType? _selectedVehicleType;
  int? _selectedYear;
  String? _rcDocumentPath;
  String? _insuranceDocumentPath;
  List<String> _vehicleImagePaths = [];

  @override
  void initState() {
    super.initState();
    _controller = VehicleController();
    if (widget.isEditing) {
      _loadVehicle();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _registrationController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _maxWeightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicle() async {
    await _controller.loadVehicles();
    final vehicle = _controller.vehicles.where(
      (v) => v.vehicleId == widget.vehicleId,
    ).firstOrNull;
    if (vehicle != null) {
      _populateForm(vehicle);
    }
  }

  void _populateForm(VehicleModel vehicle) {
    setState(() {
      _selectedVehicleType = vehicle.vehicleTypeEnum;
      _registrationController.text = vehicle.registrationNumber;
      _makeController.text = vehicle.make;
      _modelController.text = vehicle.model;
      _selectedYear = vehicle.year;
      _maxWeightController.text = vehicle.maxWeightKg.toStringAsFixed(0);
      if (vehicle.maxLengthCm != null) {
        _lengthController.text = vehicle.maxLengthCm!.toStringAsFixed(0);
      }
      if (vehicle.maxWidthCm != null) {
        _widthController.text = vehicle.maxWidthCm!.toStringAsFixed(0);
      }
      if (vehicle.maxHeightCm != null) {
        _heightController.text = vehicle.maxHeightCm!.toStringAsFixed(0);
      }
      _rcDocumentPath = vehicle.rcDocument;
      _insuranceDocumentPath = vehicle.insuranceDocument;
      _vehicleImagePaths = List.from(vehicle.vehicleImages);
    });
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;
    if (_selectedVehicleType == null) {
      _showError('Please select vehicle type');
      return false;
    }
    if (!widget.isEditing) {
      if (_rcDocumentPath == null) {
        _showError('Please upload RC document');
        return false;
      }
      if (_insuranceDocumentPath == null) {
        _showError('Please upload insurance document');
        return false;
      }
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    // Upload documents if needed
    if (_rcDocumentPath != null && !_rcDocumentPath!.startsWith('http')) {
      final uploaded = await _controller.uploadRcDocument(_rcDocumentPath!);
      if (!uploaded || !mounted) {
        _showError(_controller.errorMessage ?? 'Failed to upload RC');
        return;
      }
    }

    if (_insuranceDocumentPath != null && !_insuranceDocumentPath!.startsWith('http')) {
      final uploaded = await _controller.uploadInsuranceDocument(_insuranceDocumentPath!);
      if (!uploaded || !mounted) {
        _showError(_controller.errorMessage ?? 'Failed to upload insurance');
        return;
      }
    }

    // Upload vehicle images
    final newImagePaths = _vehicleImagePaths.where((p) => !p.startsWith('http')).toList();
    if (newImagePaths.isNotEmpty) {
      final uploaded = await _controller.uploadVehicleImages(newImagePaths);
      if (!uploaded || !mounted) {
        _showError(_controller.errorMessage ?? 'Failed to upload images');
        return;
      }
    }

    final success = widget.isEditing
        ? await _controller.updateVehicle(
            vehicleId: widget.vehicleId!,
            vehicleType: _selectedVehicleType!.value,
            registrationNumber: _registrationController.text.trim(),
            make: _makeController.text.trim(),
            model: _modelController.text.trim(),
            year: _selectedYear,
            maxWeightKg: double.parse(_maxWeightController.text),
            maxLengthCm: _lengthController.text.isNotEmpty
                ? double.parse(_lengthController.text)
                : null,
            maxWidthCm: _widthController.text.isNotEmpty
                ? double.parse(_widthController.text)
                : null,
            maxHeightCm: _heightController.text.isNotEmpty
                ? double.parse(_heightController.text)
                : null,
          )
        : await _controller.addVehicle(
            vehicleType: _selectedVehicleType!.value,
            registrationNumber: _registrationController.text.trim(),
            make: _makeController.text.trim(),
            model: _modelController.text.trim(),
            year: _selectedYear,
            maxWeightKg: double.parse(_maxWeightController.text),
            maxLengthCm: _lengthController.text.isNotEmpty
                ? double.parse(_lengthController.text)
                : null,
            maxWidthCm: _widthController.text.isNotEmpty
                ? double.parse(_widthController.text)
                : null,
            maxHeightCm: _heightController.text.isNotEmpty
                ? double.parse(_heightController.text)
                : null,
          );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Vehicle updated successfully'
                : 'Vehicle added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<VehicleController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
            ),
            body: controller.isLoading && widget.isEditing
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Vehicle Details Section
                          _buildSectionHeader(context, 'Vehicle Details'),
                          const SizedBox(height: 16),

                          // Vehicle type
                          DropdownButtonFormField<VehicleType>(
                            value: _selectedVehicleType,
                            decoration: const InputDecoration(
                              labelText: 'Vehicle Type',
                              prefixIcon: Icon(Icons.local_shipping),
                            ),
                            items: VehicleType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedVehicleType = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select vehicle type';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Registration number
                          TextFormField(
                            controller: _registrationController,
                            decoration: const InputDecoration(
                              labelText: 'Registration Number',
                              hintText: 'e.g., MH12AB1234',
                              prefixIcon: Icon(Icons.confirmation_number),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Registration number is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Make and Model
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _makeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Make',
                                    hintText: 'e.g., Tata',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _modelController,
                                  decoration: const InputDecoration(
                                    labelText: 'Model',
                                    hintText: 'e.g., 407',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Year
                          DropdownButtonFormField<int>(
                            value: _selectedYear,
                            decoration: const InputDecoration(
                              labelText: 'Year (Optional)',
                              prefixIcon: Icon(Icons.calendar_month),
                            ),
                            items: List.generate(
                              25,
                              (i) => DateTime.now().year - i,
                            ).map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = value;
                              });
                            },
                          ),
                          const SizedBox(height: 32),

                          // Capacity Section
                          _buildSectionHeader(context, 'Capacity'),
                          const SizedBox(height: 16),

                          // Max weight
                          TextFormField(
                            controller: _maxWeightController,
                            decoration: const InputDecoration(
                              labelText: 'Max Weight Capacity (kg)',
                              prefixIcon: Icon(Icons.scale),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Max weight is required';
                              }
                              final weight = double.tryParse(value);
                              if (weight == null || weight <= 0) {
                                return 'Enter a valid weight';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Dimensions (Optional)
                          Text(
                            'Cargo Dimensions (Optional)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _lengthController,
                                  decoration: const InputDecoration(
                                    labelText: 'Length (cm)',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _widthController,
                                  decoration: const InputDecoration(
                                    labelText: 'Width (cm)',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _heightController,
                                  decoration: const InputDecoration(
                                    labelText: 'Height (cm)',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Documents Section
                          _buildSectionHeader(context, 'Documents'),
                          const SizedBox(height: 16),

                          // RC Document
                          _buildDocumentPicker(
                            context,
                            label: 'RC Document',
                            imagePath: _rcDocumentPath,
                            onPick: () => _pickDocument(isRC: true),
                            onRemove: () {
                              setState(() {
                                _rcDocumentPath = null;
                              });
                            },
                            isRequired: !widget.isEditing,
                          ),
                          const SizedBox(height: 16),

                          // Insurance Document
                          _buildDocumentPicker(
                            context,
                            label: 'Insurance Document',
                            imagePath: _insuranceDocumentPath,
                            onPick: () => _pickDocument(isRC: false),
                            onRemove: () {
                              setState(() {
                                _insuranceDocumentPath = null;
                              });
                            },
                            isRequired: !widget.isEditing,
                          ),
                          const SizedBox(height: 32),

                          // Vehicle Images Section
                          _buildSectionHeader(context, 'Vehicle Photos'),
                          const SizedBox(height: 8),
                          Text(
                            'Add up to 5 photos of your vehicle',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _buildVehicleImagesPicker(context),
                          const SizedBox(height: 32),

                          // Error message
                          if (controller.errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller.errorMessage!,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Submit button
                          ElevatedButton(
                            onPressed: controller.isLoading || controller.isUploading
                                ? null
                                : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isLoading || controller.isUploading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    widget.isEditing
                                        ? 'Save Changes'
                                        : 'Add Vehicle',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildDocumentPicker(
    BuildContext context, {
    required String label,
    required String? imagePath,
    required VoidCallback onPick,
    required VoidCallback onRemove,
    required bool isRequired,
  }) {
    final theme = Theme.of(context);

    if (imagePath != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.description, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    imagePath.split('/').last,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.upload_file,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    isRequired ? 'Required' : 'Optional',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleImagesPicker(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._vehicleImagePaths.asMap().entries.map((entry) {
          return _VehicleImageTile(
            imagePath: entry.value,
            onRemove: () {
              setState(() {
                _vehicleImagePaths.removeAt(entry.key);
              });
            },
          );
        }),
        if (_vehicleImagePaths.length < 5)
          InkWell(
            onTap: _pickVehicleImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickDocument({required bool isRC}) async {
    // TODO: Implement document picker
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRC ? 'Upload RC Document' : 'Upload Insurance'),
        content: const Text('Document picker will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              isRC ? 'rc_document.jpg' : 'insurance.jpg',
            ),
            child: const Text('Select'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        if (isRC) {
          _rcDocumentPath = result;
        } else {
          _insuranceDocumentPath = result;
        }
      });
    }
  }

  Future<void> _pickVehicleImage() async {
    // TODO: Implement image picker
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Vehicle Photo'),
        content: const Text('Image picker will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              'vehicle_photo_${_vehicleImagePaths.length + 1}.jpg',
            ),
            child: const Text('Select'),
          ),
        ],
      ),
    );

    if (result != null && _vehicleImagePaths.length < 5) {
      setState(() {
        _vehicleImagePaths.add(result);
      });
    }
  }
}

class _VehicleImageTile extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;

  const _VehicleImageTile({
    required this.imagePath,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Icon(
                Icons.image,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
