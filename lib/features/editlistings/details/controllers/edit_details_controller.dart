import 'package:flutter_app/features/editlistings/details/services/edit_details_service.dart';
import 'package:flutter_app/features/postlistings/details/controllers/details_controller.dart';
import 'package:flutter_app/features/postlistings/details/services/details_service.dart';

/// Controller for edit listing details: extends DetailsController for shared
/// dropdown data and adds loadListing + updateListing via PATCH.
class EditDetailsController extends DetailsController {
  final int listingId;
  final EditDetailsService _editService;

  EditDetailsController({
    required this.listingId,
    DetailsService? detailsService,
    EditDetailsService? editDetailsService,
  })  : _editService = editDetailsService ?? EditDetailsService(),
        super(detailsService: detailsService ?? DetailsService());

  /// Load listing by ID for pre-fill
  Future<Map<String, dynamic>?> loadListing() async {
    return _editService.getListingById(listingId);
  }

  /// PATCH update listing with form data
  Future<EditDetailsResult> updateListing(Map<String, dynamic> formData) async {
    setLoading(true);
    clearError();

    final result = await _editService.patchUpdateListing(listingId, formData);

    if (!result.success) {
      setError(result.errorMessage ?? 'Failed to update listing');
    }

    setLoading(false);
    return result;
  }
}
