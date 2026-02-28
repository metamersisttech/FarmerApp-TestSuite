import 'package:flutter/material.dart';

/// Uber-style bid pricing bottom sheet
///
/// Allows buyer to adjust a bid price using a slider and quick-adjust buttons,
/// then submit the bid. Currently shows a success snackbar (no backend).
class BidPriceBottomSheet extends StatefulWidget {
  final double listedPrice;
  final String animalTitle;

  const BidPriceBottomSheet({
    super.key,
    required this.listedPrice,
    required this.animalTitle,
  });

  @override
  State<BidPriceBottomSheet> createState() => _BidPriceBottomSheetState();
}

class _BidPriceBottomSheetState extends State<BidPriceBottomSheet> {
  late double _bidPrice;
  late double _minPrice;
  late double _maxPrice;

  @override
  void initState() {
    super.initState();
    _bidPrice = widget.listedPrice;
    _minPrice = (widget.listedPrice * 0.7 / 100).round() * 100.0;
    _maxPrice = (widget.listedPrice * 1.3 / 100).round() * 100.0;
  }

  void _adjustPrice(double amount) {
    setState(() {
      _bidPrice = (_bidPrice + amount).clamp(_minPrice, _maxPrice);
      _bidPrice = (_bidPrice / 100).round() * 100.0;
    });
  }

  String _formatPrice(double price) {
    if (price >= 100000) {
      final lakhs = price / 100000;
      return lakhs == lakhs.roundToDouble()
          ? '${lakhs.toInt()}L'
          : '${lakhs.toStringAsFixed(1)}L';
    }
    if (price >= 1000) {
      final thousands = price / 1000;
      return thousands == thousands.roundToDouble()
          ? '${thousands.toInt()}K'
          : '${thousands.toStringAsFixed(1)}K';
    }
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Place Your Bid',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Subtitle
            Text(
              'Set a price that works for you',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Bid price display
            Text(
              '\u20B9${_bidPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 4),

            // Listed price reference
            Text(
              'Listed at \u20B9${widget.listedPrice.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 20),

            // Quick-adjust buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _QuickAdjustChip(
                  label: '-5K',
                  isNegative: true,
                  onTap: () => _adjustPrice(-5000),
                ),
                const SizedBox(width: 8),
                _QuickAdjustChip(
                  label: '-1K',
                  isNegative: true,
                  onTap: () => _adjustPrice(-1000),
                ),
                const SizedBox(width: 8),
                _QuickAdjustChip(
                  label: '+1K',
                  isNegative: false,
                  onTap: () => _adjustPrice(1000),
                ),
                const SizedBox(width: 8),
                _QuickAdjustChip(
                  label: '+5K',
                  isNegative: false,
                  onTap: () => _adjustPrice(5000),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF2E7D32),
                inactiveTrackColor: Colors.grey[200],
                thumbColor: const Color(0xFF2E7D32),
                overlayColor: const Color(0xFF2E7D32).withOpacity(0.12),
                trackHeight: 4,
              ),
              child: Slider(
                value: _bidPrice.clamp(_minPrice, _maxPrice),
                min: _minPrice,
                max: _maxPrice,
                onChanged: (value) {
                  setState(() {
                    _bidPrice = (value / 100).round() * 100.0;
                  });
                },
              ),
            ),

            // Min/max labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\u20B9${_formatPrice(_minPrice)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    '\u20B9${_formatPrice(_maxPrice)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hint text
            Text(
              'Higher bids have a better chance of being accepted by the seller',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),

            // Book a Bid Now button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Bid of \u20B9${_bidPrice.toStringAsFixed(0)} placed for ${widget.animalTitle}!',
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.only(
                          bottom: 100, left: 16, right: 16),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Book a Bid Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill-shaped quick-adjust chip
class _QuickAdjustChip extends StatelessWidget {
  final String label;
  final bool isNegative;
  final VoidCallback onTap;

  const _QuickAdjustChip({
    required this.label,
    required this.isNegative,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isNegative ? Colors.grey[100] : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isNegative ? Colors.grey[700] : const Color(0xFF2E7D32),
          ),
        ),
      ),
    );
  }
}
