# Edit Profile Feature

A comprehensive edit profile screen with profile picture picker, form fields, and validation.

## 📁 Package Structure

```
lib/features/editprofile/
├── screens/
│   └── edit_profile_page.dart          # Main edit profile screen
├── controllers/
│   └── edit_profile_controller.dart    # State management
└── widgets/
    └── profile_picture_picker.dart     # Profile photo picker with bottom sheet
```

## ✨ Features

### 1. **Profile Picture Picker**
- Square profile picture with rounded corners (18px radius)
- Camera icon overlay for edit indication
- Bottom sheet with options:
  - 📷 Take a picture
  - 🖼️ Select from gallery
  - 🗑️ Remove photo (if exists)
- Supports both local and network images
- Placeholder when no image is set

### 2. **Basic Information Section**
Layout: Profile picture on left, fields on right
- **Profile Picture**: 100x100 clickable area
- **Username**: Text field with @ icon
- **First Name**: Text field with person icon
- **Last Name**: Text field with person icon

### 3. **Contact Information Section**
- **Phone Number**: Custom phone field with country code (+91 🇮🇳)
- **Email**: Text field with email icon

### 4. **Styling**
All fields maintain consistency with the register page:
- Border Radius: 18px
- Background Color: `AppTheme.authFieldFillColor` (#ECE7DF)
- Border Color: `AppTheme.authBorderColor` (#E5E2DA)
- Focused Border: `AppTheme.authPrimaryColor` (#4CAF50)
- Text Color: `AppTheme.authTextPrimary` (#2B2B2B)
- Hint Color: `AppTheme.authTextSecondary` (#8D8D8D)

## 🚀 Usage

### Method 1: Direct Navigation
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const EditProfilePage(
      initialUsername: 'john_doe',
      initialFirstName: 'John',
      initialLastName: 'Doe',
      initialPhoneNumber: '9876543210',
      initialEmail: 'john.doe@example.com',
      initialProfileImageUrl: 'https://example.com/image.jpg',
    ),
  ),
);
```

### Method 2: Named Route
```dart
AppRoutes.navigateTo(
  context,
  AppRoutes.editProfile,
  arguments: {
    'username': 'john_doe',
    'firstName': 'John',
    'lastName': 'Doe',
    'phoneNumber': '9876543210',
    'email': 'john.doe@example.com',
    'profileImageUrl': 'https://example.com/image.jpg',
  },
);
```

### Method 3: From Profile Page
```dart
// Add to profile page menu
IconButton(
  icon: const Icon(Icons.edit),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialUsername: profileModel.username,
          initialFirstName: profileModel.firstName,
          // ... other fields
        ),
      ),
    ).then((saved) {
      if (saved == true) {
        // Refresh profile data
        _refreshProfile();
      }
    });
  },
)
```

## 📝 Validation

The form includes comprehensive validation:
- **Username**: Required, valid format
- **First Name**: Required, valid name format
- **Last Name**: Required, valid name format
- **Phone Number**: Required, 10 digits
- **Email**: Required, valid email format

## 🔄 State Management

The `EditProfileController` extends `BaseController` and provides:
- Field value management
- Loading state
- Error handling
- Form validation
- Image selection tracking

## 📦 Dependencies

- `image_picker: ^1.0.7` - For camera/gallery image selection
- Form validation from `lib/core/utils/validators.dart`
- Theme constants from `lib/shared/themes/app_theme.dart`

## 🎨 UI Components Used

- `StyledTextField` - Consistent text input fields
- `PhoneNumberField` - Phone number with country code
- `ProfilePicturePicker` - Custom profile photo widget
- Material bottom sheet for image source selection

## 🔐 API Integration (TODO)

The controller has placeholder code for API integration:

```dart
Future<bool> saveProfile() async {
  // TODO: Implement API call
  // await _profileService.updateProfile({...});
  // await _profileService.uploadProfileImage(_localProfileImage!);
}
```

## 📱 Screenshots

The edit profile page features:
1. Clean, minimalist design matching the auth screens
2. Responsive layout with proper spacing
3. Bottom sheet for image selection options
4. Loading states and error handling
5. Save button in app bar

## 🎯 Future Enhancements

- [ ] Image cropping after selection
- [ ] Progress indicator for image upload
- [ ] Undo/discard changes confirmation
- [ ] Real-time field validation
- [ ] Backend API integration
- [ ] Profile image compression
- [ ] Support for multiple profile pictures

