import 'package:flutter/material.dart';

class LanguageSwitcherWidget extends StatelessWidget {
  final bool compact;

  const LanguageSwitcherWidget({super.key, this.compact = false});

  static void showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Marathi'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPicker(context),
      child: compact
          ? const Icon(Icons.language, size: 24)
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language, size: 20),
                SizedBox(width: 4),
                Text('EN'),
              ],
            ),
    );
  }
}
