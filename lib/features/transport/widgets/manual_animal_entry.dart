/// Manual Animal Entry Widget
///
/// Form for manually entering animal species and count for transport requests.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/features/transport/models/cargo_animal_model.dart';

class ManualAnimalEntry extends StatefulWidget {
  final List<CargoAnimalModel> entries;
  final ValueChanged<List<CargoAnimalModel>> onEntriesChanged;
  final int maxEntries;

  const ManualAnimalEntry({
    super.key,
    required this.entries,
    required this.onEntriesChanged,
    this.maxEntries = 5,
  });

  @override
  State<ManualAnimalEntry> createState() => _ManualAnimalEntryState();
}

class _ManualAnimalEntryState extends State<ManualAnimalEntry> {
  final List<TextEditingController> _speciesControllers = [];
  final List<TextEditingController> _countControllers = [];
  final List<TextEditingController> _weightControllers = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    // Clear existing controllers
    for (final c in _speciesControllers) {
      c.dispose();
    }
    for (final c in _countControllers) {
      c.dispose();
    }
    for (final c in _weightControllers) {
      c.dispose();
    }
    _speciesControllers.clear();
    _countControllers.clear();
    _weightControllers.clear();

    // Create controllers for existing entries
    for (final entry in widget.entries) {
      _speciesControllers.add(TextEditingController(text: entry.species ?? ''));
      _countControllers.add(TextEditingController(text: entry.count.toString()));
      _weightControllers.add(
          TextEditingController(text: entry.estimatedWeightKg?.toString() ?? ''));
    }

    // Add one empty entry if none exist
    if (widget.entries.isEmpty) {
      _addEntry();
    }
  }

  @override
  void dispose() {
    for (final c in _speciesControllers) {
      c.dispose();
    }
    for (final c in _countControllers) {
      c.dispose();
    }
    for (final c in _weightControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    if (_speciesControllers.length >= widget.maxEntries) return;

    setState(() {
      _speciesControllers.add(TextEditingController());
      _countControllers.add(TextEditingController(text: '1'));
      _weightControllers.add(TextEditingController());
    });
    _notifyChanged();
  }

  void _removeEntry(int index) {
    if (_speciesControllers.length <= 1) return;

    setState(() {
      _speciesControllers[index].dispose();
      _countControllers[index].dispose();
      _weightControllers[index].dispose();
      _speciesControllers.removeAt(index);
      _countControllers.removeAt(index);
      _weightControllers.removeAt(index);
    });
    _notifyChanged();
  }

  void _notifyChanged() {
    final entries = <CargoAnimalModel>[];

    for (var i = 0; i < _speciesControllers.length; i++) {
      final species = _speciesControllers[i].text.trim();
      final countText = _countControllers[i].text.trim();
      final weightText = _weightControllers[i].text.trim();

      if (species.isNotEmpty) {
        entries.add(CargoAnimalModel(
          species: species,
          count: int.tryParse(countText) ?? 1,
          estimatedWeightKg:
              weightText.isNotEmpty ? double.tryParse(weightText) : null,
        ));
      }
    }

    widget.onEntriesChanged(entries);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Manual Entry',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (_speciesControllers.length < widget.maxEntries)
              TextButton.icon(
                onPressed: _addEntry,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Animal'),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Entry forms
        ...List.generate(_speciesControllers.length, (index) {
          return _buildEntryForm(context, index);
        }),

        const SizedBox(height: 8),

        // Help text
        Text(
          'Enter the type and quantity of animals you need to transport.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEntryForm(BuildContext context, int index) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                // Species field
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _speciesControllers[index],
                    decoration: const InputDecoration(
                      labelText: 'Animal Type',
                      hintText: 'e.g., Cow, Buffalo, Goat',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => _notifyChanged(),
                  ),
                ),

                const SizedBox(width: 12),

                // Count field
                Expanded(
                  child: TextFormField(
                    controller: _countControllers[index],
                    decoration: const InputDecoration(
                      labelText: 'Count',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (_) => _notifyChanged(),
                  ),
                ),

                // Remove button
                if (_speciesControllers.length > 1)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () => _removeEntry(index),
                    tooltip: 'Remove',
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Weight field (optional)
            TextFormField(
              controller: _weightControllers[index],
              decoration: const InputDecoration(
                labelText: 'Estimated Weight (kg) - Optional',
                hintText: 'e.g., 450',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: (_) => _notifyChanged(),
            ),
          ],
        ),
      ),
    );
  }
}
