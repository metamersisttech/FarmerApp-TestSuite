import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Language')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('English'),
            leading: const Icon(Icons.language),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            title: const Text('Marathi'),
            leading: const Icon(Icons.language),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
