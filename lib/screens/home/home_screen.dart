import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'photo_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  final List<String> categories = [
    'All',
    'Photography',
    'Art',
    'Fashion',
    'Travel',
    'Food',
    'Architecture',
    'Nature',
  ];

  List<PhotoItem> _getPhotos() {
    return [
      PhotoItem(
        imagePath: 'assets/images/1.jpg',
        caption: 'Beautiful nature photography',
        category: 'Photography',
        aspectRatio: 0.75,
      ),
      PhotoItem(
        imagePath: 'assets/images/2.jpg',
        caption: 'Artistic composition',
        category: 'Art',
        aspectRatio: 1.2,
      ),
      PhotoItem(
        imagePath: 'assets/images/3.jpg',
        caption: 'Fashion inspiration',
        category: 'Fashion',
        aspectRatio: 0.8,
      ),
      PhotoItem(
        imagePath: 'assets/images/4.jpg',
        caption: 'Travel destination',
        category: 'Travel',
        aspectRatio: 1.0,
      ),
      PhotoItem(
        imagePath: 'assets/images/5.jpg',
        caption: 'Delicious food',
        category: 'Food',
        aspectRatio: 0.9,
      ),
      PhotoItem(
        imagePath: 'assets/images/6.jpg',
        caption: 'Modern architecture',
        category: 'Architecture',
        aspectRatio: 1.1,
      ),
      PhotoItem(
        imagePath: 'assets/images/7.jpg',
        caption: 'Natural beauty',
        category: 'Nature',
        aspectRatio: 0.7,
      ),
      PhotoItem(
        imagePath: 'assets/images/8.jpg',
        caption: 'Creative shot',
        category: 'Photography',
        aspectRatio: 1.3,
      ),
    ];
  }

  List<PhotoItem> _getFilteredPhotos() {
    final photos = _getPhotos();
    if (selectedCategory == 'All') {
      return photos;
    }
    return photos.where((photo) => photo.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFF),
              Color(0xFFEEF2FF),
            ],
          ),
        ),
        child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFB794F6), // Lighter purple
                      Color.fromARGB(255, 203, 158, 245), // Lighter pink
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Looma',
                    style: GoogleFonts.raleway(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),

            // Category filters with glassmorphism
            Container(
              height: 55,
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: !isSelected 
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 74, 0, 247).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 0,
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      category,
                                      style: GoogleFonts.nunito(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 216, 199, 255).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: const Color.fromARGB(255, 89, 20, 248).withOpacity(0.7),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    spreadRadius: 0,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: GoogleFonts.nunito(
                                    color: const Color(0xFF8B5CF6),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),

            // Photo grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  itemCount: _getFilteredPhotos().length,
                  itemBuilder: (context, index) {
                    final photo = _getFilteredPhotos()[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoDetailScreen(photo: photo),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: photo.aspectRatio,
                            child: Image.asset(
                              photo.imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

