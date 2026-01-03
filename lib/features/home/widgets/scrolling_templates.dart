import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Horizontal scrolling templates section with indicator
class ScrollingTemplates extends StatefulWidget {
  final List<TemplateCardData> templates;
  final Duration autoScrollDuration;
  final Duration autoScrollInterval;

  const ScrollingTemplates({
    super.key,
    required this.templates,
    this.autoScrollDuration = const Duration(milliseconds: 500),
    this.autoScrollInterval = const Duration(seconds: 3),
  });

  @override
  State<ScrollingTemplates> createState() => _ScrollingTemplatesState();
}

class _ScrollingTemplatesState extends State<ScrollingTemplates> {
  final ScrollController _scrollController = ScrollController();
  int _currentCardIndex = 0;
  Timer? _autoScrollTimer;
  bool _userIsScrolling = false;
  Timer? _userScrollDebounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _userScrollDebounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Start auto-scrolling timer
  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(widget.autoScrollInterval, (timer) {
      if (!_userIsScrolling && mounted && _scrollController.hasClients) {
        _scrollToNextCard();
      }
    });
  }

  /// Scroll to the next card
  void _scrollToNextCard() {
    final double cardWidth = 280 + 16; // Card width + separator
    int nextIndex = _currentCardIndex + 1;

    // Loop back to first card if at the end
    if (nextIndex >= widget.templates.length) {
      nextIndex = 0;
    }

    final double targetOffset = nextIndex * cardWidth;

    _scrollController.animateTo(
      targetOffset,
      duration: widget.autoScrollDuration,
      curve: Curves.easeInOut,
    );
  }

  /// Handle manual scroll by user
  void _onScroll() {
    final double cardWidth = 280 + 16; // Card width + separator
    final double offset = _scrollController.offset;
    final int newIndex =
        (offset / cardWidth).round().clamp(0, widget.templates.length - 1);

    if (newIndex != _currentCardIndex) {
      setState(() {
        _currentCardIndex = newIndex;
      });
    }

    // Detect user interaction and pause auto-scroll
    _userIsScrolling = true;
    _userScrollDebounceTimer?.cancel();
    _userScrollDebounceTimer = Timer(const Duration(seconds: 2), () {
      _userIsScrolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.authBackgroundColor,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Detect when user starts scrolling
                if (notification is ScrollStartNotification) {
                  _userIsScrolling = true;
                  _userScrollDebounceTimer?.cancel();
                }
                // Reset auto-scroll after user stops scrolling
                else if (notification is ScrollEndNotification) {
                  _userScrollDebounceTimer?.cancel();
                  _userScrollDebounceTimer = Timer(const Duration(seconds: 2), () {
                    _userIsScrolling = false;
                  });
                }
                return false;
              },
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: widget.templates.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final template = widget.templates[index];
                  return _TemplateCard(
                    title: template.title,
                    subtitle: template.subtitle,
                    icon: template.icon,
                    backgroundColor: template.backgroundColor,
                    buttonText: template.buttonText,
                    onPressed: template.onPressed,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Sliding Indicator
          _ScrollIndicator(
            totalItems: widget.templates.length,
            currentIndex: _currentCardIndex,
          ),
        ],
      ),
    );
  }
}

/// Data model for template cards
class TemplateCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final String buttonText;
  final VoidCallback onPressed;

  const TemplateCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.buttonText,
    required this.onPressed,
  });
}

/// Template card widget
class _TemplateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final String buttonText;
  final VoidCallback onPressed;

  const _TemplateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 36),
            ],
          ),
          // View Button
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scroll indicator (dots)
class _ScrollIndicator extends StatelessWidget {
  final int totalItems;
  final int currentIndex;

  const _ScrollIndicator({
    required this.totalItems,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalItems,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: currentIndex == index ? 24 : 8,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? AppTheme.authPrimaryColor
                : Colors.grey[400],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

