import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../main_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Set<String> selectedCategories = {};
  
  final List<CategoryItem> categories = [
    CategoryItem(icon: '📷', title: 'Photography'),
    CategoryItem(icon: '🎨', title: 'Art & Design'),
    CategoryItem(icon: '🌍', title: 'Travel & Adventure'),
    CategoryItem(icon: '🎵', title: 'Music'),
    CategoryItem(icon: '👗', title: 'Fashion'),
    CategoryItem(icon: '✂️', title: 'DIY & Crafts'),
    CategoryItem(icon: '🍳', title: 'Food & Recipes'),
    CategoryItem(icon: '💪', title: 'Fitness'),
    CategoryItem(icon: '💻', title: 'Tech & Gadgets'),
    CategoryItem(icon: '🏠', title: 'Home'),
    CategoryItem(icon: '📚', title: 'Books'),
    CategoryItem(icon: '📸', title: 'Photography'),
    CategoryItem(icon: '💰', title: 'Finance & Investing'),
    CategoryItem(icon: '🚀', title: 'Space'),
    CategoryItem(icon: '🎮', title: 'Gaming'),
    CategoryItem(icon: '💄', title: 'Beauty & Skincare'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  // Top Header
                  Text(
                    'Categories',
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Main Card Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // App Logo
                        Text(
                          'Looma',
                          style: GoogleFonts.raleway(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Title and Subtitle
                        Text(
                          'Choose Your Interests',
                          style: GoogleFonts.raleway(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Picks at least 3 categories.',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Categories Grid
                        _buildCategoriesGrid(),
                        
                        const SizedBox(height: 30),
                        
                        // See My Feed Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: selectedCategories.length >= 3 ? _handleContinue : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF6A59D0),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: Colors.white.withOpacity(0.5),
                              disabledForegroundColor: const Color(0xFF6A59D0).withOpacity(0.5),
                            ),
                            child: Text(
                              'See My Feed',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selectedCategories.contains(category.title);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedCategories.remove(category.title);
              } else {
                selectedCategories.add(category.title);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.white.withOpacity(0.25)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected 
                    ? Colors.white.withOpacity(0.8)
                    : Colors.white.withOpacity(0.4),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      category.title,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleContinue() {
    // Save selected categories to user preferences or backend
    final appProvider = context.read<AppProvider>();
    appProvider.setSelectedCategories(selectedCategories.toList());
    appProvider.setFirstTimeUser(false);
    appProvider.setCurrentIndex(0); // Ensure we start at home screen (index 0)
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }
}

class CategoryItem {
  final String icon;
  final String title;

  CategoryItem({
    required this.icon,
    required this.title,
  });
}