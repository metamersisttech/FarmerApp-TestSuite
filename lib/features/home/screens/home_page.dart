import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/home/widgets/home_search_bar.dart';
import 'package:flutter_app/features/home/widgets/profile_section.dart';
import 'package:flutter_app/features/home/widgets/quick_actions_section.dart';
import 'package:flutter_app/features/home/widgets/recent_listing_section.dart';
import 'package:flutter_app/features/home/widgets/scrolling_templates.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Home Page
///
/// Main screen after user logs in.
class HomePage extends StatefulWidget {
  final UserModel? user;

  const HomePage({super.key, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // Extract first name from user, fallback to 'Guest'
    final firstName = widget.user?.firstName ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Profile Section
              ProfileSection(
                firstName: firstName,
                notificationCount: 3,
                onNotificationTap: () {},
                onProfileTap: () {},
                onWalletTap: () {},
              ),

              // 2. Search Bar
              HomeSearchBar(
                onChanged: (value) {
                  // TODO: Implement search
                },
              ),

              // 3. Horizontal Scrolling Templates
              ScrollingTemplates(
                templates: [
                  TemplateCardData(
                    title: 'New Listings',
                    subtitle: 'Check out latest animals',
                    icon: Icons.fiber_new,
                    backgroundColor: AppTheme.authPrimaryColor,
                    buttonText: 'View Now',
                    onPressed: () {},
                  ),
                  TemplateCardData(
                    title: 'Vet Discount',
                    subtitle: 'Special offers for you',
                    icon: Icons.local_hospital,
                    backgroundColor: Colors.orange,
                    buttonText: 'View',
                    onPressed: () {},
                  ),
                  TemplateCardData(
                    title: 'Premium Feed',
                    subtitle: 'Quality feed at best price',
                    icon: Icons.grass,
                    backgroundColor: Colors.green,
                    buttonText: 'Shop Now',
                    onPressed: () {},
                  ),
                  TemplateCardData(
                    title: 'Transportation',
                    subtitle: 'Book transport services',
                    icon: Icons.local_shipping,
                    backgroundColor: Colors.deepPurple,
                    buttonText: 'Book Now',
                    onPressed: () {},
                  ),
                ],
              ),

              // 4. Quick Actions Section
              const QuickActionsSection(),

              // 5. Recent Listing Section
              RecentListingSection(
                onActionPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
