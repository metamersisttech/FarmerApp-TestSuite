import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/home/screens/home_page.dart';
import 'package:flutter_app/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_app/features/postlistings/screens/post_animal_page.dart';
import 'package:flutter_app/features/profile/screens/my_listings_page.dart';
import 'package:flutter_app/features/profile/screens/profile_page.dart';
import 'package:flutter_app/features/favourite/screens/favourite_listings_page.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Main Shell Page - Persistent bottom navigation across all main screens
///
/// Uses IndexedStack to keep all pages in memory and maintain their state
/// when switching between tabs.
class MainShellPage extends StatefulWidget {
  final UserModel? user;

  const MainShellPage({super.key, this.user});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;
  
  // Key for MyListingsPage to force refresh when needed
  Key _myListingsKey = UniqueKey();

  // Pages for each tab
  List<Widget> get _pages => [
    HomePage(user: widget.user, onNavigateToTab: _onBottomNavTap),      // Index 0: Home
    const FavouriteListingsPage(),        // Index 1: Favourite
    MyListingsPage(key: _myListingsKey), // Index 2: My Ads (instead of Community)
    const ProfilePage(),              // Index 3: Profile
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      // If switching to My Listings tab (index 2) and it was previously created,
      // generate a new key to force refresh
      if (index == 2 && _currentIndex != 2) {
        _myListingsKey = UniqueKey();
      }
      _currentIndex = index;
    });
  }

  void _handleAddTap() async {
    // Navigate to post animal page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PostAnimalPage()),
    );
    
    // If listing was created (result == true), refresh My Listings page
    if (result == true && mounted) {
      setState(() {
        // Generate new key to force MyListingsPage to rebuild and fetch fresh data
        _myListingsKey = UniqueKey();
      });
      
      // Optionally switch to My Listings tab to show the new listing
      // Uncomment if you want to auto-switch to My Listings after posting
      // setState(() {
      //   _currentIndex = 2;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // Floating Add Button - Centered in Bottom Nav Bar (Three-color segmented border)
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: CustomPaint(
          painter: _TriColorBorderPainter(),
          child: Container(
            margin: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              onPressed: _handleAddTap,
              icon: Icon(
                Icons.add,
                color: AppTheme.authPrimaryColor,
                size: 28,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}

/// Custom painter for three-color segmented circular border
class _TriColorBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 5.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw three arcs (120 degrees each = 2.094 radians)
    const sweepAngle = 2.094; // 120 degrees in radians
    
    // Segment 1: Green/Teal (AppTheme.authPrimaryColor) - top
    paint.color = AppTheme.authPrimaryColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -1.571, // Start at top (-90 degrees)
      sweepAngle,
      false,
      paint,
    );

    // Segment 2: Orange - bottom right
    paint.color = Colors.orange;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      0.523, // Start after first segment
      sweepAngle,
      false,
      paint,
    );

    // Segment 3: Deep Purple - bottom left
    paint.color = Colors.deepPurple;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      2.618, // Start after second segment
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
