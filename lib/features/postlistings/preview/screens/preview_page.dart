import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/postlistings/preview/controllers/preview_controller.dart';
import 'package:flutter_app/features/postlistings/preview/mixins/preview_state_mixin.dart';
import 'package:flutter_app/features/postlistings/preview/widgets/animal_info_card.dart';
import 'package:flutter_app/features/postlistings/preview/widgets/boost_card.dart';
import 'package:flutter_app/features/postlistings/preview/widgets/image_carousel.dart';
import 'package:flutter_app/features/postlistings/preview/widgets/price_section.dart';
import 'package:flutter_app/features/postlistings/preview/widgets/tags_section.dart';
import 'package:flutter_app/features/postlistings/preview/widgets/verification_card.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Preview Page - Display listing preview before publishing
class PreviewPage extends StatefulWidget {
  final int listingId;
  final VoidCallback onPrevious;
  final VoidCallback onPublish;
  /// Optional label for the publish button (e.g. 'Done' for edit flow)
  final String? publishButtonLabel;

  const PreviewPage({
    super.key,
    required this.listingId,
    required this.onPrevious,
    required this.onPublish,
    this.publishButtonLabel,
  });

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage>
    with PreviewStateMixin, ToastMixin {
  late final PreviewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PreviewController();
    initializeControllers();
    _fetchListingPreview();
  }

  @override
  void dispose() {
    disposeControllers();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchListingPreview() async {
    final result = await _controller.fetchListingPreview(widget.listingId);

    if (!mounted) return;

    if (result.success && result.listingData != null) {
      setListingData(result.listingData);
    } else {
      setError(result.errorMessage);
    }
  }

  Future<void> _handlePublish() async {
    setPublishing(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      showSuccessToast('Listing published successfully!');
      widget.onPublish();
    } catch (e) {
      if (!mounted) return;
      setPublishing(false);
      showErrorToast(e.toString());
    }
  }

  List<String> get _imageUrls {
    if (listingData == null) return [];
    final images = listingData!['animal_images'];
    if (images == null) return [];
    if (images is List) {
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
          child: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
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
    if (listingData == null) return const Center(child: Text('No data'));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImageCarousel(
            imageUrls: _imageUrls,
            imagePageController: imagePageController,
            currentImageIndex: currentImageIndex,
            onPageChanged: setImageIndex,
          ),
          AnimalInfoCard(
            listingData: listingData!,
            parseNumber: parseNumber,
          ),
          PriceSection(
            listingData: listingData!,
            formatPrice: formatPrice,
          ),
          TagsSection(listingData: listingData!),
          _buildLocationSection(),
          const SizedBox(height: 16),
          VerificationCard(listingData: listingData!),
          const SizedBox(height: 16),
          const BoostCard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    final farm = listingData!['farm'];
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

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16, // Add system nav bar padding
      ),
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isPublishing ? null : widget.onPrevious,
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
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isPublishing ? null : _handlePublish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.authPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isPublishing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.publishButtonLabel ?? 'Post Listing',
                          style: const TextStyle(
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
}
