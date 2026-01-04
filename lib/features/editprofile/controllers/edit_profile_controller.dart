import 'dart:io';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/data/services/token_storage_service.dart';

/// Controller for edit profile operations
class EditProfileController extends BaseController {
  final AuthService _authService;
  final TokenStorageService _tokenStorage;

  // Form field values
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  String _phoneNumber = '';
  String _email = '';
  String? _profileImageUrl;
  File? _localProfileImage;

  EditProfileController({
    AuthService? authService,
    TokenStorageService? tokenStorage,
  })  : _authService = authService ?? AuthService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  // Getters
  String get username => _username;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get phoneNumber => _phoneNumber;
  String get email => _email;
  String? get profileImageUrl => _profileImageUrl;
  File? get localProfileImage => _localProfileImage;

  /// Initialize with existing profile data
  void initializeProfile({
    required String username,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    String? profileImageUrl,
  }) {
    _username = username;
    _firstName = firstName;
    _lastName = lastName;
    _phoneNumber = phoneNumber;
    _email = email;
    _profileImageUrl = profileImageUrl;
    notifyListeners();
  }

  /// Update username
  void updateUsername(String value) {
    _username = value;
    notifyListeners();
  }

  /// Update first name
  void updateFirstName(String value) {
    _firstName = value;
    notifyListeners();
  }

  /// Update last name
  void updateLastName(String value) {
    _lastName = value;
    notifyListeners();
  }

  /// Update phone number
  void updatePhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  /// Update email
  void updateEmail(String value) {
    _email = value;
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
    _profileImageUrl = null;
    notifyListeners();
  }

  /// Validate all fields
  bool validateFields() {
    if (_username.trim().isEmpty) {
      setError('Username is required');
      return false;
    }
    if (_firstName.trim().isEmpty) {
      setError('First name is required');
      return false;
    }
    if (_lastName.trim().isEmpty) {
      setError('Last name is required');
      return false;
    }
    if (_phoneNumber.trim().isEmpty) {
      setError('Phone number is required');
      return false;
    }
    if (_email.trim().isEmpty) {
      setError('Email is required');
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
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken != null) {
        _authService.setAuthToken(accessToken);
      }

      // Call API to update profile
      await _authService.updateMe(
        username: _username.trim(),
        firstName: _firstName.trim(),
        lastName: _lastName.trim(),
        phone: _phoneNumber.trim(),
        email: _email.trim(),
      );
      
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
    required String originalUsername,
    required String originalFirstName,
    required String originalLastName,
    required String originalPhoneNumber,
    required String originalEmail,
  }) {
    return _username != originalUsername ||
        _firstName != originalFirstName ||
        _lastName != originalLastName ||
        _phoneNumber != originalPhoneNumber ||
        _email != originalEmail ||
        _localProfileImage != null;
  }
}

