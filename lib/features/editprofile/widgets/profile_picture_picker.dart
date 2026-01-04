import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Profile picture picker widget with bottom sheet options
class ProfilePicturePicker extends StatelessWidget {
  final String? currentImageUrl;
  final File? localImage;
  final Function(File) onImageSelected;
  final VoidCallback? onRemoveImage;
  final bool enabled;

  const ProfilePicturePicker({
    super.key,
    this.currentImageUrl,
    this.localImage,
    required this.onImageSelected,
    this.onRemoveImage,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => _showImageSourceBottomSheet(context) : null,
      child: Stack(
        children: [
          // Profile picture container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.authFieldFillColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.authBorderColor,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildProfileImage(),
            ),
          ),
          // Camera icon overlay
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.authPrimaryColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.authBackgroundColor,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    // Show local image if available
    if (localImage != null) {
      return Image.file(
        localImage!,
        fit: BoxFit.cover,
      );
    }

    // Show network image if available
    if (currentImageUrl != null && currentImageUrl!.isNotEmpty) {
      return Image.network(
        currentImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // Show placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.person_outline,
        size: 50,
        color: AppTheme.authTextSecondary,
      ),
    );
  }

  void _showImageSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.authBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.authBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.authTextPrimary,
                ),
              ),
              const SizedBox(height: 20),
              // Options
              _ImageSourceOption(
                icon: Icons.camera_alt_outlined,
                title: 'Take a picture',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1),
              _ImageSourceOption(
                icon: Icons.photo_library_outlined,
                title: 'Select from gallery',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (currentImageUrl != null || localImage != null) ...[
                const Divider(height: 1),
                _ImageSourceOption(
                  icon: Icons.delete_outline,
                  title: 'Remove photo',
                  iconColor: AppTheme.errorColor,
                  textColor: AppTheme.errorColor,
                  onTap: () {
                    Navigator.pop(context);
                    if (onRemoveImage != null) {
                      onRemoveImage!();
                    }
                  },
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        onImageSelected(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }
}

/// Image source option widget for bottom sheet
class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.title,
    this.iconColor,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? AppTheme.authTextPrimary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor ?? AppTheme.authTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

