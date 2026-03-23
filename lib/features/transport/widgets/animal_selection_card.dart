/// Animal Selection Card Widget
///
/// Displays a selectable listing card for animal selection in transport requests.
library;

import 'package:flutter/material.dart';

class AnimalSelectionCard extends StatelessWidget {
  final int listingId;
  final String title;
  final String? imageUrl;
  final String species;
  final String? breed;
  final double? weightKg;
  final bool isSelected;
  final int count;
  final ValueChanged<bool>? onSelectionChanged;
  final ValueChanged<int>? onCountChanged;
  final int maxCount;
  final EdgeInsetsGeometry? margin;

  const AnimalSelectionCard({
    super.key,
    required this.listingId,
    required this.title,
    this.imageUrl,
    required this.species,
    this.breed,
    this.weightKg,
    this.isSelected = false,
    this.count = 1,
    this.onSelectionChanged,
    this.onCountChanged,
    this.maxCount = 10,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: margin ?? EdgeInsets.zero,
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => onSelectionChanged?.call(!isSelected),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: isSelected,
                onChanged: (value) => onSelectionChanged?.call(value ?? false),
              ),

              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                      )
                    : _buildPlaceholder(theme),
              ),

              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      breed != null ? '$breed $species' : species,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (weightKg != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${weightKg!.toStringAsFixed(0)} kg',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Count selector (only if selected)
              if (isSelected && onCountChanged != null) ...[
                const SizedBox(width: 8),
                _CountSelector(
                  count: count,
                  maxCount: maxCount,
                  onChanged: onCountChanged!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.pets,
        size: 32,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _CountSelector extends StatelessWidget {
  final int count;
  final int maxCount;
  final ValueChanged<int> onChanged;

  const _CountSelector({
    required this.count,
    required this.maxCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: count > 1 ? () => onChanged(count - 1) : null,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),

          // Count
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Increase button
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: count < maxCount ? () => onChanged(count + 1) : null,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
