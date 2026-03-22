import 'package:flutter/material.dart';
import 'package:flutter_app/features/search/screens/search_page.dart';

/// Search bar widget for home page
class HomeSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool enabled;

  const HomeSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search livestocks, products...',
    this.onChanged,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('search_bar'),
      onTap: () {
        // Navigate to full search page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[400], size: 22),
            const SizedBox(width: 12),
            Text(
              hintText,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

