import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Details Tab - Animal type, breed, gender, etc.
class DetailsTab extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onPrevious;

  const DetailsTab({
    super.key,
    required this.onNext,
    this.onPrevious,
  });

  @override
  State<DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {
  String? _selectedAnimalType;
  String? _selectedBreed;
  String? _selectedGender;
  String? _selectedAge;
  String? _selectedPriceType;
  
  final TextEditingController _animalSearchController = TextEditingController();
  final TextEditingController _breedSearchController = TextEditingController();

  final List<String> _allAnimals = [
    'Cow',
    'Buffalo',
    'Goat',
    'Sheep',
    'Camel',
    'Horse',
    'Donkey',
    'Mule',
    'Pig',
    'Rabbit',
    'Duck',
    'Chicken',
    'Turkey',
    'Goose',
  ];

  final List<String> _allBreeds = [
    'Gir',
    'Murrah',
    'Sahiwal',
    'Jafarabadi',
    'Tharparkar',
    'Holstein Friesian',
    'Jersey',
    'Red Sindhi',
    'Kankrej',
    'Rathi',
    'Hariana',
    'Ongole',
    'Other',
  ];

  @override
  void dispose() {
    _animalSearchController.dispose();
    _breedSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable content area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animal Type
                _buildSectionTitle('Animal Type'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.authPrimaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownMenu<String>(
              controller: _animalSearchController,
              width: MediaQuery.of(context).size.width - 40,
              hintText: 'Select or search animal type',
              leadingIcon: const Icon(Icons.pets, size: 20),
              menuHeight: 300,
              enableFilter: true,
              enableSearch: true,
              requestFocusOnTap: true,
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.authPrimaryColor.withOpacity(0.5), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              dropdownMenuEntries: _allAnimals.map((animal) {
                return DropdownMenuEntry<String>(
                  value: animal,
                  label: animal,
                );
              }).toList(),
              onSelected: (value) {
                setState(() {
                  _selectedAnimalType = value;
                  if (value != null) {
                    _animalSearchController.text = value;
                  }
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Breed
          _buildSectionTitle('Breed'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.authPrimaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownMenu<String>(
              controller: _breedSearchController,
              width: MediaQuery.of(context).size.width - 40,
              hintText: 'Select or search breed',
              menuHeight: 300,
              enableFilter: true,
              enableSearch: true,
              requestFocusOnTap: true,
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.authPrimaryColor.withOpacity(0.5), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              dropdownMenuEntries: _allBreeds.map((breed) {
                return DropdownMenuEntry<String>(
                  value: breed,
                  label: breed,
                );
              }).toList(),
              onSelected: (value) {
                setState(() {
                  _selectedBreed = value;
                  if (value != null) {
                    _breedSearchController.text = value;
                  }
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Gender
          _buildSectionTitle('Gender'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGenderChip(
                  label: 'Male',
                  icon: Icons.male,
                  isSelected: _selectedGender == 'Male',
                  onTap: () => setState(() => _selectedGender = 'Male'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderChip(
                  label: 'Female',
                  icon: Icons.female,
                  isSelected: _selectedGender == 'Female',
                  onTap: () => setState(() => _selectedGender = 'Female'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Age and Weight Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Age'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedAge,
                      decoration: InputDecoration(
                        hintText: '1 Year',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.authPrimaryColor.withOpacity(0.5), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: ['1 Year', '2 Years', '3 Years', '4 Years', '5+ Years']
                          .map((age) => DropdownMenuItem(value: age, child: Text(age)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedAge = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Weight (kg)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'e.g. 350',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.authPrimaryColor.withOpacity(0.5), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Price Type
          _buildSectionTitle('Price Type'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPriceTypeChip(
                  label: 'Fixed Price',
                  icon: '💰',
                  isSelected: _selectedPriceType == 'Fixed',
                  onTap: () => setState(() => _selectedPriceType = 'Fixed'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriceTypeChip(
                  label: 'Auction',
                  icon: '🔨',
                  isSelected: _selectedPriceType == 'Auction',
                  onTap: () => setState(() => _selectedPriceType = 'Auction'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Enter Price
          _buildSectionTitle('Enter Price (₹)'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.authPrimaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 50000',
                prefixIcon: const Icon(Icons.currency_rupee, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.authPrimaryColor.withOpacity(0.5), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20), // Bottom padding for scroll
        ],
      ),
    ),
  ),

        // Fixed navigation buttons at bottom
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.onPrevious != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onPrevious,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
              if (widget.onPrevious != null) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.authPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildGenderChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.authPrimaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.authPrimaryColor : AppTheme.authPrimaryColor.withOpacity(0.5),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppTheme.authPrimaryColor.withOpacity(0.2) : AppTheme.authPrimaryColor.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppTheme.authPrimaryColor : Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.authPrimaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTypeChip({
    required String label,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.authPrimaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.authPrimaryColor : AppTheme.authPrimaryColor.withOpacity(0.5),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppTheme.authPrimaryColor.withOpacity(0.2) : AppTheme.authPrimaryColor.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.authPrimaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

