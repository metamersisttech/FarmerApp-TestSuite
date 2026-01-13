import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Preview Tab - Display listing preview before publishing
class PreviewTab extends StatefulWidget {
  final int listingId;
  final VoidCallback onPrevious;
  final VoidCallback onPublish;

  const PreviewTab({
    super.key,
    required this.listingId,
    required this.onPrevious,
    required this.onPublish,
  });

  @override
  State<PreviewTab> createState() => _PreviewTabState();
}

class _PreviewTabState extends State<PreviewTab> with ToastMixin {
  final BackendHelper _backendHelper = BackendHelper();
  final PageController _imagePageController = PageController();

  Map<String, dynamic>? _listingData;
  bool _isLoading = true;
  bool _isPublishing = false;
  String? _error;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchListingPreview();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  Future<void> _fetchListingPreview() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _backendHelper.getListingById(widget.listingId);
      if (!mounted) return;
      setState(() {
        _listingData = response;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _handlePublish() async {
    setState(() => _isPublishing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      showSuccessToast('Listing published successfully!');
      widget.onPublish();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPublishing = false);
      showErrorToast(e.toString());
    }
  }

  List<String> get _imageUrls {
    if (_listingData == null) return [];
    final images = _listingData!['animal_images'];
    if (images == null) return [];
    if (images is List) {
      // Convert image keys to full GCS URLs
      return images
          .map((e) => CommonHelper.getImageUrl(e.toString()))
          .where((url) => url.isNotEmpty)
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorState()
                  : _buildPreviewContent(),
        ),
        _buildBottomSection(),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text('Failed to load preview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchListingPreview,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (_listingData == null) return const Center(child: Text('No data'));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Carousel
          _buildImageCarousel(),

          // Animal Info Card
          _buildAnimalInfoCard(),

          // Price Section
          _buildPriceSection(),

          // Tags Section
          _buildTagsSection(),

          // Location Section
          _buildLocationSection(),

          const SizedBox(height: 16),

          // Verification Status Card
          _buildVerificationCard(),

          const SizedBox(height: 16),

          // Boost Card (optional - for UI completeness)
          _buildBoostCard(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = _imageUrls;

    return Stack(
      children: [
        // Image PageView
        Container(
          height: 280,
          color: Colors.grey[200],
          child: images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('No images',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : PageView.builder(
                  controller: _imagePageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() => _currentImageIndex = index);
                  },
                  itemBuilder: (context, index) {
                    return Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image,
                              size: 64, color: Colors.grey[500]),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
        ),

        // Photo count badge
        if (images.isNotEmpty)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${images.length} Photos',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // Page indicators
        if (images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAnimalInfoCard() {
    final title = _listingData!['title']?.toString() ?? 'Animal Listing';
    final gender = _listingData!['gender']?.toString() ?? '';

    // Parse numeric values (API may return strings)
    final ageMonths = _parseNumber(_listingData!['age_months']);
    final weightKg = _parseNumber(_listingData!['weight_kg']);

    // Convert months to years for display
    final years = (ageMonths / 12).floor();
    final ageDisplay = years > 0 ? '$years Years' : '${ageMonths.toInt()} Months';

    // Build info parts
    final infoParts = <String>[];
    if (gender.isNotEmpty) {
      infoParts.add(gender[0].toUpperCase() + gender.substring(1));
    }
    if (ageMonths > 0) infoParts.add(ageDisplay);
    if (weightKg > 0) infoParts.add('${weightKg.toStringAsFixed(weightKg.truncateToDouble() == weightKg ? 0 : 1)} kg');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (infoParts.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    infoParts.join(' • '),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final price = _listingData!['price'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '₹${_formatPrice(price)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.authPrimaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Fixed Price',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    final vaccinationStatus = _listingData!['vaccination_status']?.toString();
    final pashuAadhar = _listingData!['pashu_aadhar']?.toString();
    final healthStatus = _listingData!['health_status']?.toString();

    final tags = <Widget>[];

    // Health status tag
    if (healthStatus != null && healthStatus.isNotEmpty && healthStatus != 'null') {
      tags.add(_buildTag(
        healthStatus[0].toUpperCase() + healthStatus.substring(1),
        Colors.blue,
      ));
    }

    // Vaccination tag
    if (vaccinationStatus != null &&
        vaccinationStatus.toLowerCase() == 'vaccinated') {
      tags.add(_buildTag('Vaccinated', Colors.green, icon: Icons.check_circle));
    }

    // Pashu Aadhar tag
    if (pashuAadhar != null && pashuAadhar.isNotEmpty && pashuAadhar != 'null') {
      tags.add(_buildTag('Pashu Aadhaar', Colors.orange, icon: Icons.credit_card));
    }

    if (tags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags,
      ),
    );
  }

  Widget _buildTag(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    // Get location from farm if available
    final farm = _listingData!['farm'];
    String? location;
    if (farm is Map) {
      location = farm['address']?.toString();
    }

    if (location == null || location.isEmpty || location == 'null') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              location,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    final vaccinationStatus = _listingData!['vaccination_status']?.toString();
    final pashuAadhar = _listingData!['pashu_aadhar']?.toString();
    final vetCertificate = _listingData!['vet_certificate']?.toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verification Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildVerificationRow(
            'Phone Verified',
            true, // Assume phone is verified since user is logged in
          ),
          const SizedBox(height: 12),
          _buildVerificationRow(
            'Pashu Aadhaar Linked',
            pashuAadhar != null && pashuAadhar.isNotEmpty && pashuAadhar != 'null',
          ),
          const SizedBox(height: 12),
          _buildVerificationRow(
            'Vet Certificate',
            vetCertificate != null && vetCertificate.isNotEmpty && vetCertificate != 'null',
          ),
          const SizedBox(height: 12),
          _buildVerificationRow(
            'Vaccinated',
            vaccinationStatus?.toLowerCase() == 'vaccinated',
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRow(String label, bool isVerified) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Icon(
          isVerified ? Icons.check_circle : Icons.cancel_outlined,
          size: 20,
          color: isVerified ? Colors.green : Colors.grey[400],
        ),
      ],
    );
  }

  Widget _buildBoostCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade50,
            Colors.orange.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
              color: Colors.amber.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Boost Your Listing',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Get 5x more views • ₹99 only',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Terms text
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'By posting, you agree to our Terms of Service and confirm that all information is accurate.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ),

          // Buttons row
          Row(
            children: [
              // Previous button
              Expanded(
                child: OutlinedButton(
                  onPressed: _isPublishing ? null : widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Previous',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Post Listing button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isPublishing ? null : _handlePublish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.authPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isPublishing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Post Listing',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Parse a value to number (handles both String and num from API)
  double _parseNumber(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final numPrice = price is num ? price : num.tryParse(price.toString()) ?? 0;
    if (numPrice >= 100000) {
      return '${(numPrice / 100000).toStringAsFixed(numPrice % 100000 == 0 ? 0 : 1)}L';
    } else if (numPrice >= 1000) {
      final formatted = numPrice.toStringAsFixed(0);
      final result = StringBuffer();
      int count = 0;
      for (int i = formatted.length - 1; i >= 0; i--) {
        if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
          result.write(',');
        }
        result.write(formatted[i]);
        count++;
      }
      return result.toString().split('').reversed.join();
    }
    return numPrice.toStringAsFixed(0);
  }
}
