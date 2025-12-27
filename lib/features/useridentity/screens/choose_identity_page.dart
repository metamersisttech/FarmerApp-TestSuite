import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/home/screens/home_page.dart';
import 'package:flutter_app/features/useridentity/controllers/user_identity_controller.dart';
import 'package:flutter_app/features/useridentity/mixins/user_identity_state_mixin.dart';
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

class _ChooseIdentityPageState extends State<ChooseIdentityPage>
    with UserIdentityStateMixin, ToastMixin {
  late final UserIdentityController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UserIdentityController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handle identity selection
  Future<void> _handleIdentitySelection(UserIdentityModel identity) async {
    selectIdentity(identity.code);
    _controller.selectIdentity(identity.code);
    
    // Save identity to backend
    setLoading(true);
    final result = await _controller.saveIdentity();
    setLoading(false);

    if (!mounted) return;

    if (result.success) {
      _navigateToHome();
    } else {
      showErrorToast(result.message ?? 'Failed to save identity');
      setError(result.message);
    }
  }

  void _handleHoverEnter(String code) {
    onHoverEnter(code);
    _controller.setHoveredIdentity(code);
  }

  void _handleHoverExit() {
    onHoverExit();
    _controller.setHoveredIdentity(null);
  }

  void _navigateToHome() {
    Future.delayed(SelectionCardTheme.animationDuration, () {
      if (mounted) {
        // Navigate to Home page after identity selection with user data
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
              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : UserIdentityList(
                        identities: UserIdentityModel.supportedIdentities,
                        selectedCode: selectedIdentityCode,
                        hoveredCode: hoveredIdentityCode,
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
