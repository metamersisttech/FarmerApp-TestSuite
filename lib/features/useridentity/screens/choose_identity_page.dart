import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/home/screens/home_page.dart';
import 'package:flutter_app/features/useridentity/models/user_identity_model.dart';
import 'package:flutter_app/features/useridentity/widgets/user_identity_list.dart';
import 'package:flutter_app/shared/widgets/cards/selection_card.dart';
import 'package:flutter_app/shared/widgets/common/page_header.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Page for selecting the user's identity/role
class ChooseIdentityPage extends StatefulWidget {
  final UserModel? user;
  
  const ChooseIdentityPage({super.key, this.user});

  @override
  State<ChooseIdentityPage> createState() => _ChooseIdentityPageState();
}

class _ChooseIdentityPageState extends State<ChooseIdentityPage> {
  String? _selectedIdentityCode;
  String? _hoveredIdentityCode;

  void _handleIdentitySelection(UserIdentityModel identity) {
    setState(() => _selectedIdentityCode = identity.code);
    _navigateToHome();
  }

  void _handleHoverEnter(String code) {
    setState(() => _hoveredIdentityCode = code);
  }

  void _handleHoverExit() {
    setState(() => _hoveredIdentityCode = null);
  }

  void _navigateToHome() {
    Future.delayed(SelectionCardTheme.animationDuration, () {
      if (mounted) {
        // Navigate to Home page after identity selection with user data
        // TODO: Save selected identity to user profile/preferences
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage(user: widget.user)),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.authBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const PageHeader(
                title: 'Who are you?',
                subtitle: 'Select your role to get started',
              ),
              const SizedBox(height: 50),
              Expanded(
                child: UserIdentityList(
                  identities: UserIdentityModel.supportedIdentities,
                  selectedCode: _selectedIdentityCode,
                  hoveredCode: _hoveredIdentityCode,
                  onSelect: _handleIdentitySelection,
                  onHoverEnter: _handleHoverEnter,
                  onHoverExit: _handleHoverExit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

