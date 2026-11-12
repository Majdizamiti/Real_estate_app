import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../utils/app_colors.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/property_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'House', 'icon': Icons.home_rounded},
    {'name': 'Apartment', 'icon': Icons.apartment_rounded},
    {'name': 'Office', 'icon': Icons.business_rounded},
    {'name': 'Land', 'icon': Icons.landscape_rounded},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);

    final userName = authProvider.user?.username ?? 'James Butler';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row (Hello! James Butler + User Avatar)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello!',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        userName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(Icons.person, color: AppColors.primary, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Bar + Filter Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => propertyProvider.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.tune_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category Icon List
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = propertyProvider.selectedCategory == cat['name'];
                    return GestureDetector(
                      onTap: () => propertyProvider.setSelectedCategory(cat['name']),
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : AppColors.inputBackground,
                                shape: BoxShape.circle,
                                boxShadow: isSelected
                                    ? const [
                                        BoxShadow(
                                          color: AppColors.cardShadow,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                cat['icon'] as IconData,
                                color: isSelected ? AppColors.primary : AppColors.textMuted,
                                size: 22,
                              ),
                            ),
                            if (isSelected)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // "All Property" Header + See All link
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Property',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All >',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Horizontal Property Cards Carousel
              SizedBox(
                height: 270,
                child: propertyProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : propertyProvider.properties.isEmpty
                        ? Center(
                            child: Text(
                              'No properties found',
                              style: GoogleFonts.poppins(color: AppColors.textMuted),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: propertyProvider.properties.length,
                            itemBuilder: (context, index) {
                              return PropertyCard(
                                property: propertyProvider.properties[index],
                                isHorizontal: true,
                              );
                            },
                          ),
              ),
              const SizedBox(height: 28),

              // "Featured Property" Header
              Text(
                'Featured Property',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              // Vertical Featured Property List
              propertyProvider.isLoading
                  ? const SizedBox()
                  : Column(
                      children: propertyProvider.featuredProperties.map((p) {
                        return PropertyCard(property: p, isHorizontal: false);
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),

      // Custom Bottom Navigation Bar matching designs
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navIcon(Icons.home_outlined, Icons.home, 0),
            _navIcon(Icons.bookmark_outline, Icons.bookmark, 1),
            // Floating Center action button
            GestureDetector(
              onTap: () => setState(() => _currentNavIndex = 2),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 24),
              ),
            ),
            _navIcon(Icons.chat_bubble_outline, Icons.chat_bubble, 3),
            _navIcon(Icons.settings_outlined, Icons.settings, 4),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData unselectedIcon, IconData selectedIcon, int index) {
    final isSelected = _currentNavIndex == index;
    return IconButton(
      icon: Icon(
        isSelected ? selectedIcon : unselectedIcon,
        color: isSelected ? AppColors.primary : AppColors.textMuted,
        size: 24,
      ),
      onPressed: () => setState(() => _currentNavIndex = index),
    );
  }
}
