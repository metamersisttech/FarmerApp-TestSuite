import 'dart:io';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/user_model.dart';

/// Controller for edit profile operations
class EditProfileController extends BaseController {
  final BackendHelper _backendHelper;
  final CommonHelper _commonHelper;

  // Form field values
  String _fullName = '';
  String _displayName = '';
  String _dob = '';
  String _address = '';
  String _state = '';
  String _district = '';
  String _village = '';
  String _pincode = '';
  String _latitude = '';
  String _longitude = '';
  String _about = '';
  String? _profileImageGcs;
  File? _localProfileImage;

  EditProfileController({
    BackendHelper? backendHelper,
    CommonHelper? commonHelper,
  })  : _backendHelper = backendHelper ?? BackendHelper(),
        _commonHelper = commonHelper ?? CommonHelper();

  // Getters
  String get fullName => _fullName;
  String get displayName => _displayName;
  String get dob => _dob;
  String get address => _address;
  String get state => _state;
  String get district => _district;
  String get village => _village;
  String get pincode => _pincode;
  String get latitude => _latitude;
  String get longitude => _longitude;
  String get about => _about;
  String? get profileImageGcs => _profileImageGcs;
  File? get localProfileImage => _localProfileImage;

  /// Initialize with existing profile data
  void initializeProfile({
    String? fullName,
    String? displayName,
    String? dob,
    String? address,
    String? state,
    String? district,
    String? village,
    String? pincode,
    String? latitude,
    String? longitude,
    String? about,
    String? profileImageGcs,
  }) {
    _fullName = fullName ?? '';
    _displayName = displayName ?? '';
    _dob = dob ?? '';
    _address = address ?? '';
    _state = state ?? '';
    _district = district ?? '';
    _village = village ?? '';
    _pincode = pincode ?? '';
    _latitude = latitude ?? '';
    _longitude = longitude ?? '';
    _about = about ?? '';
    _profileImageGcs = profileImageGcs;
    notifyListeners();
  }

  /// Update full name
  void updateFullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  /// Update display name
  void updateDisplayName(String value) {
    _displayName = value;
    notifyListeners();
  }

  /// Update date of birth
  void updateDob(String value) {
    _dob = value;
    notifyListeners();
  }

  /// Update address
  void updateAddress(String value) {
    _address = value;
    notifyListeners();
  }

  /// Update state
  void updateState(String value) {
    _state = value;
    notifyListeners();
  }

  /// Update district
  void updateDistrict(String value) {
    _district = value;
    notifyListeners();
  }

  /// Update village
  void updateVillage(String value) {
    _village = value;
    notifyListeners();
  }

  /// Update pincode
  void updatePincode(String value) {
    _pincode = value;
    notifyListeners();
  }

  /// Update latitude
  void updateLatitude(String value) {
    _latitude = value;
    notifyListeners();
  }

  /// Update longitude
  void updateLongitude(String value) {
    _longitude = value;
    notifyListeners();
  }

  /// Update about
  void updateAbout(String value) {
    _about = value;
    notifyListeners();
  }

  /// Update profile image
  void updateProfileImage(File image) {
    _localProfileImage = image;
    notifyListeners();
  }

  /// Remove profile image
  void removeProfileImage() {
    _localProfileImage = null;
    _profileImageGcs = null;
    notifyListeners();
  }

  /// Validate required fields
  bool validateFields() {
    if (_fullName.trim().isEmpty) {
      setError('Full name is required');
      return false;
    }
    if (_displayName.trim().isEmpty) {
      setError('Display name is required');
      return false;
    }
    return true;
  }

  /// Save profile changes
  Future<bool> saveProfile() async {
    if (!validateFields()) {
      return false;
    }

    setLoading(true);
    clearError();

    try {
      // Initialize auth with stored token
      final accessToken = await _commonHelper.getAccessToken();
      if (accessToken != null) {
        APIClient().setAuthorization(accessToken);
      }

      // Prepare request body
      final Map<String, dynamic> data = {
        'full_name': _fullName.trim(),
        'display_name': _displayName.trim(),
      };

      // Add optional fields only if they have values
      if (_dob.isNotEmpty) data['dob'] = _dob;
      if (_address.isNotEmpty) data['address'] = _address;
      if (_state.isNotEmpty) data['state'] = _state;
      if (_district.isNotEmpty) data['district'] = _district;
      if (_village.isNotEmpty) data['village'] = _village;
      if (_pincode.isNotEmpty) data['pincode'] = _pincode;
      if (_latitude.isNotEmpty) data['latitude'] = _latitude;
      if (_longitude.isNotEmpty) data['longitude'] = _longitude;
      if (_about.isNotEmpty) data['about'] = _about;
      if (_profileImageGcs != null) data['profile_image_gcs'] = _profileImageGcs;

      // Call API to update profile using BackendHelper
      await _backendHelper.putUpdateProfile(data);
      
      // Fetch complete user data after update (includes id, email, etc.)
      final userResponse = await _backendHelper.getMe();
      final updatedUser = UserModel.fromJson(userResponse);
      
      // Save updated user to local storage
      final commonHelper = CommonHelper();
      await commonHelper.setLoggedInUser(updatedUser);
      
      // TODO: If there's a local image, upload it
      // if (_localProfileImage != null) {
      //   await _profileService.uploadProfileImage(_localProfileImage!);
      // }

      setLoading(false);
      return true;
    } catch (e) {
      setError('Failed to save profile. Please try again.');
      setLoading(false);
      return false;
    }
  }

  /// Check if any changes were made
  bool hasChanges({
    String? originalFullName,
    String? originalDisplayName,
    String? originalDob,
    String? originalAddress,
    String? originalState,
    String? originalDistrict,
    String? originalVillage,
    String? originalPincode,
    String? originalLatitude,
    String? originalLongitude,
    String? originalAbout,
  }) {
    return _fullName != (originalFullName ?? '') ||
        _displayName != (originalDisplayName ?? '') ||
        _dob != (originalDob ?? '') ||
        _address != (originalAddress ?? '') ||
        _state != (originalState ?? '') ||
        _district != (originalDistrict ?? '') ||
        _village != (originalVillage ?? '') ||
        _pincode != (originalPincode ?? '') ||
        _latitude != (originalLatitude ?? '') ||
        _longitude != (originalLongitude ?? '') ||
        _about != (originalAbout ?? '') ||
        _localProfileImage != null;
  }
}
