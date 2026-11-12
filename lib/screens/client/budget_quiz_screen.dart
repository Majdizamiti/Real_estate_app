import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

class BudgetQuizScreen extends StatefulWidget {
  const BudgetQuizScreen({super.key});

  @override
  State<BudgetQuizScreen> createState() => _BudgetQuizScreenState();
}

class _BudgetQuizScreenState extends State<BudgetQuizScreen> {
  RangeValues _currentRangeValues = const RangeValues(5000, 10000);
  String _selectedLocation = 'Outside';

  void _onShowProperties() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.savePreferences(
      minBudget: _currentRangeValues.start,
      maxBudget: _currentRangeValues.end,
      preferredLocation: _selectedLocation,
    );

    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    propertyProvider.setFilterPriceRange(_currentRangeValues);
    await propertyProvider.fetchProperties();

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header navigation icons (Back & Close)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24, color: AppColors.primary),
                    onPressed: _onSkip,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title 1
              Text(
                'What is your budget',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Card Container for Price Range Slider
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price Range',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '\$${_currentRangeValues.start.round()} - \$${_currentRangeValues.end.round()}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Custom Cyan Range Slider
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.accentBlue,
                        inactiveTrackColor: AppColors.accentBlue.withOpacity(0.2),
                        thumbColor: AppColors.accentBlue,
                        overlayColor: AppColors.accentBlue.withOpacity(0.2),
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                      ),
                      child: RangeSlider(
                        values: _currentRangeValues,
                        min: 1000,
                        max: 20000,
                        divisions: 19,
                        onChanged: (RangeValues values) {
                          setState(() {
                            _currentRangeValues = values;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${_currentRangeValues.start.round()}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '\$${_currentRangeValues.end.round()}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Title 2
              Text(
                'Where do you want to buy?',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Location Options Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedLocation = 'Near'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedLocation == 'Near' ? AppColors.primary : AppColors.inputBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'Near',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _selectedLocation == 'Near' ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedLocation = 'Outside'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedLocation == 'Outside' ? const Color(0xFFED5555) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedLocation == 'Outside' ? const Color(0xFFED5555) : AppColors.inputBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'Outside',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _selectedLocation == 'Outside' ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Show Properties Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onShowProperties,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Show Properties',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: _onSkip,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
