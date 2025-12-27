import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/useridentity/models/user_identity_model.dart';
import 'package:flutter_app/features/useridentity/services/user_identity_service.dart';

/// Controller for user identity selection operations
class UserIdentityController extends BaseController {
  final UserIdentityService _identityService;
  
  String? _selectedIdentityCode;
  String? _hoveredIdentityCode;

  UserIdentityController({UserIdentityService? identityService})
      : _identityService = identityService ?? UserIdentityService();

  /// Currently selected identity code
  String? get selectedIdentityCode => _selectedIdentityCode;

  /// Currently hovered identity code
  String? get hoveredIdentityCode => _hoveredIdentityCode;

  /// Check if an identity is selected
  bool get hasSelection => _selectedIdentityCode != null;

  /// Get the selected identity model
  UserIdentityModel? get selectedIdentity {
    if (_selectedIdentityCode == null) return null;
    return UserIdentityModel.supportedIdentities.firstWhere(
      (identity) => identity.code == _selectedIdentityCode,
      orElse: () => UserIdentityModel.supportedIdentities.first,
    );
  }

  /// Select an identity
  void selectIdentity(String code) {
    _selectedIdentityCode = code;
    notifyListeners();
  }

  /// Set hovered identity
  void setHoveredIdentity(String? code) {
    _hoveredIdentityCode = code;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedIdentityCode = null;
    _hoveredIdentityCode = null;
    notifyListeners();
  }

  /// Check if a specific identity is selected
  bool isSelected(String code) => _selectedIdentityCode == code;

  /// Check if a specific identity is hovered
  bool isHovered(String code) => _hoveredIdentityCode == code;

  /// Save selected identity to backend
  Future<IdentityResult> saveIdentity() async {
    if (_selectedIdentityCode == null) {
      setError('Please select an identity');
      return IdentityResult.error('Please select an identity');
    }

    setLoading(true);
    clearError();

    try {
      final result = await _identityService.saveUserIdentity(_selectedIdentityCode!);
      
      if (!result.success && result.message != null) {
        setError(result.message);
      }

      setLoading(false);
      return result;
    } catch (e) {
      setError('Failed to save identity. Please try again.');
      setLoading(false);
      return IdentityResult.error('Failed to save identity. Please try again.');
    }
  }

  /// Reset controller state
  void reset() {
    _selectedIdentityCode = null;
    _hoveredIdentityCode = null;
    clearError();
    notifyListeners();
  }
}

