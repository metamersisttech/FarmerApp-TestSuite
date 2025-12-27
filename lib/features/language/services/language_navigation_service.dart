import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/useridentity/screens/choose_identity_page.dart';

/// Service for handling language navigation
class LanguageNavigationService {
  /// Navigate to User Identity selection
  static void toUserIdentity(BuildContext context, {UserModel? user}) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => ChooseIdentityPage(user: user)),
      (route) => false,
    );
  }
}

