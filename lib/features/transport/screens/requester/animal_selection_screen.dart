/// Animal Selection Screen
///
/// Step 1: Select animals for transport request.
/// Supports both selecting from user's listings and manual entry.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';
import 'package:flutter_app/features/profile/services/my_listings_service.dart';
import 'package:flutter_app/features/transport/controllers/create_request_controller.dart';
import 'package:flutter_app/features/transport/models/cargo_animal_model.dart';
import 'package:flutter_app/features/transport/widgets/animal_selection_card.dart';
import 'package:flutter_app/features/transport/widgets/manual_animal_entry.dart';

/// Selection mode for animal selection
enum AnimalSelectionMode {
  myListings,
  manualEntry,
}

class AnimalSelectionScreen extends StatefulWidget {
  const AnimalSelectionScreen({super.key});

  @override
  State<AnimalSelectionScreen> createState() => _AnimalSelectionScreenState();
}

class _AnimalSelectionScreenState extends State<AnimalSelectionScreen> {
  final MyListingsService _listingsService = MyListingsService();

  AnimalSelectionMode _selectionMode = AnimalSelectionMode.myListings;
  List<ListingModel> _myListings = [];
  bool _isLoadingListings = false;
  String? _listingsError;

  // Track selected listings with their counts: {listingId: count}
  final Map<int, int> _selectedListings = {};

  // Track manual entries separately
  List<CargoAnimalModel> _manualEntries = [];

  @override
  void initState() {
    super.initState();
    _loadMyListings();
    _initializeFromController();
  }

  void _initializeFromController() {
    final controller = context.read<CreateRequestController>();
    final existingAnimals = controller.data.cargoAnimals;

    // Separate existing animals into listings vs manual entries
    for (final animal in existingAnimals) {
      if (animal.animalId != null) {
        // This is a listing-based animal
        _selectedListings[animal.animalId!] = animal.count;
      } else {
        // This is a manual entry
        _manualEntries.add(animal);
      }
    }
  }

  Future<void> _loadMyListings() async {
    setState(() {
      _isLoadingListings = true;
      _listingsError = null;
    });

    try {
      // Fetch approved listings only (animals available for transport)
      final listings = await _listingsService.fetchMyListings(status: 'approved');
      if (mounted) {
        setState(() {
          _myListings = listings;
          _isLoadingListings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _listingsError = 'Failed to load your listings';
          _isLoadingListings = false;
          // Default to manual entry if listings fail to load
          if (_myListings.isEmpty) {
            _selectionMode = AnimalSelectionMode.manualEntry;
          }
        });
      }
    }
  }

  void _updateController() {
    final controller = context.read<CreateRequestController>();

    // Build final cargo animals list from both sources
    final allAnimals = <CargoAnimalModel>[];

    // Add selected listings
    for (final entry in _selectedListings.entries) {
      final listing = _myListings.firstWhere(
        (l) => l.id == entry.key,
        orElse: () => throw StateError('Listing not found'),
      );
      allAnimals.add(CargoAnimalModel.fromListing(listing, count: entry.value));
    }

    // Add manual entries
    allAnimals.addAll(_manualEntries);

    controller.setCargoAnimals(allAnimals);
  }

  void _onListingSelectionChanged(ListingModel listing, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedListings[listing.id] = 1; // Default count of 1
      } else {
        _selectedListings.remove(listing.id);
      }
    });
    _updateController();
  }

  void _onListingCountChanged(ListingModel listing, int count) {
    if (count <= 0) {
      _selectedListings.remove(listing.id);
    } else {
      _selectedListings[listing.id] = count;
    }
    setState(() {});
    _updateController();
  }

  void _onManualEntriesChanged(List<CargoAnimalModel> entries) {
    _manualEntries = entries;
    _updateController();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'What animals need transport?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select from your listings or add animals manually.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 20),

          // Selection mode toggle
          _buildModeToggle(theme),

          const SizedBox(height: 20),

          // Content based on mode
          if (_selectionMode == AnimalSelectionMode.myListings)
            _buildListingsSection(theme)
          else
            _buildManualEntrySection(theme),

          const SizedBox(height: 24),

          // Summary section
          _buildSummary(theme),
        ],
      ),
    );
  }

  Widget _buildModeToggle(ThemeData theme) {
    return SegmentedButton<AnimalSelectionMode>(
      segments: const [
        ButtonSegment<AnimalSelectionMode>(
          value: AnimalSelectionMode.myListings,
          label: Text('My Listings'),
          icon: Icon(Icons.list_alt),
        ),
        ButtonSegment<AnimalSelectionMode>(
          value: AnimalSelectionMode.manualEntry,
          label: Text('Manual Entry'),
          icon: Icon(Icons.edit),
        ),
      ],
      selected: {_selectionMode},
      onSelectionChanged: (selection) {
        setState(() {
          _selectionMode = selection.first;
        });
      },
      showSelectedIcon: false,
    );
  }

  Widget _buildListingsSection(ThemeData theme) {
    if (_isLoadingListings) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_listingsError != null) {
      return _buildErrorState(theme);
    }

    if (_myListings.isEmpty) {
      return _buildEmptyListingsState(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select animals from your approved listings:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Listings list
        ..._myListings.map((listing) {
          final isSelected = _selectedListings.containsKey(listing.id);
          final count = _selectedListings[listing.id] ?? 1;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AnimalSelectionCard(
              listingId: listing.id,
              title: listing.name,
              imageUrl: listing.imageUrl,
              species: listing.species ?? 'Unknown',
              breed: listing.breed,
              weightKg: null, // ListingModel doesn't have weight
              isSelected: isSelected,
              count: count,
              onSelectionChanged: (selected) =>
                  _onListingSelectionChanged(listing, selected),
              onCountChanged: (newCount) =>
                  _onListingCountChanged(listing, newCount),
              maxCount: 10,
            ),
          );
        }),

        // Hint to add more via manual entry
        if (_selectedListings.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: ListTile(
              leading: Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Need to add more animals?',
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Switch to Manual Entry to add unlisted animals.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _listingsError!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _loadMyListings,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectionMode = AnimalSelectionMode.manualEntry;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Use Manual Entry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyListingsState(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No approved listings found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any approved animal listings yet. You can add animals manually for transport.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _selectionMode = AnimalSelectionMode.manualEntry;
                });
              },
              icon: const Icon(Icons.edit),
              label: const Text('Add Animals Manually'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntrySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ManualAnimalEntry(
          entries: _manualEntries,
          onEntriesChanged: _onManualEntriesChanged,
        ),

        const SizedBox(height: 24),

        // Quick add suggestions
        Text(
          'Common Animals',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _buildQuickAddChips(theme),
        ),
      ],
    );
  }

  List<Widget> _buildQuickAddChips(ThemeData theme) {
    final suggestions = [
      ('Cow', 'Cattle', 450.0),
      ('Buffalo', 'Buffalo', 500.0),
      ('Goat', 'Goat', 40.0),
      ('Sheep', 'Sheep', 45.0),
      ('Bull', 'Cattle', 600.0),
      ('Calf', 'Cattle', 150.0),
    ];

    return suggestions.map((s) {
      return ActionChip(
        avatar: const Icon(Icons.add, size: 18),
        label: Text(s.$1),
        onPressed: () {
          final newAnimal = CargoAnimalModel(
            species: s.$2,
            breed: s.$1,
            count: 1,
            estimatedWeightKg: s.$3,
          );

          // Check if similar entry exists in manual entries
          final existingIndex = _manualEntries.indexWhere(
            (a) => a.species == s.$2 && a.breed == s.$1,
          );

          setState(() {
            if (existingIndex >= 0) {
              // Increment count
              final existing = _manualEntries[existingIndex];
              _manualEntries[existingIndex] = existing.copyWith(
                count: existing.count + 1,
              );
            } else {
              // Add new entry
              _manualEntries.add(newAnimal);
            }
          });
          _updateController();
        },
      );
    }).toList();
  }

  Widget _buildSummary(ThemeData theme) {
    final hasListings = _selectedListings.isNotEmpty;
    final hasManual = _manualEntries.isNotEmpty;

    if (!hasListings && !hasManual) {
      return const SizedBox.shrink();
    }

    // Calculate totals
    int totalFromListings = 0;
    for (final count in _selectedListings.values) {
      totalFromListings += count;
    }

    int totalManual = 0;
    for (final entry in _manualEntries) {
      totalManual += entry.count;
    }

    final totalAnimals = totalFromListings + totalManual;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),

        Text(
          'Summary',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total header
                Row(
                  children: [
                    Icon(
                      Icons.pets,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Total Animals: $totalAnimals',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                if (hasListings || hasManual) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                ],

                // From listings
                if (hasListings) ...[
                  _buildSummarySection(
                    theme,
                    'From My Listings',
                    Icons.list_alt,
                    _buildListingsSummaryItems(theme),
                  ),
                  if (hasManual) const SizedBox(height: 12),
                ],

                // Manual entries
                if (hasManual)
                  _buildSummarySection(
                    theme,
                    'Manual Entries',
                    Icons.edit,
                    _buildManualSummaryItems(theme),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(
    ThemeData theme,
    String title,
    IconData icon,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  List<Widget> _buildListingsSummaryItems(ThemeData theme) {
    return _selectedListings.entries.map((entry) {
      final listing = _myListings.firstWhere(
        (l) => l.id == entry.key,
        orElse: () => throw StateError('Listing not found'),
      );
      final count = entry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$count × ${listing.name}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18,
                color: theme.colorScheme.error,
              ),
              onPressed: () {
                setState(() {
                  _selectedListings.remove(entry.key);
                });
                _updateController();
              },
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildManualSummaryItems(ThemeData theme) {
    return _manualEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final animal = entry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                animal.summary,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            if (animal.estimatedWeightKg != null)
              Text(
                '${animal.estimatedWeightKg!.toStringAsFixed(0)} kg',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18,
                color: theme.colorScheme.error,
              ),
              onPressed: () {
                setState(() {
                  _manualEntries.removeAt(index);
                });
                _updateController();
              },
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
      );
    }).toList();
  }
}
