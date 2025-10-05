import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PhotoDetailScreen extends StatefulWidget {
  final PhotoItem photo;

  const PhotoDetailScreen({super.key, required this.photo});

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main image
                    Container(
                      margin: const EdgeInsets.all(16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Image.asset(
                            widget.photo.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    
                    // Photo info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Interactive icons row with Save button
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isLiked = !isLiked;
                                  });
                                },
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 24,
                                  color: const Color(0xFF8B5CF6),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // TODO: Comment functionality
                                },
                                icon: const Icon(
                                  Icons.comment_outlined,
                                  size: 24,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // TODO: Share functionality
                                },
                                icon: const Icon(
                                  Icons.share_outlined,
                                  size: 24,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // TODO: More options functionality
                                },
                                icon: const Icon(
                                  Icons.more_horiz,
                                  size: 24,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                              const Spacer(),
                              // Gradient Save button
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8B5CF6),
                                      Color(0xFFB794F6),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Save functionality
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: Text(
                                    'Save',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Profile info section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile image placeholder
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                  border: Border.all(
                                    color: Colors.grey[400]!,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey[600],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Username and caption
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'photographer_name',
                                      style: GoogleFonts.nunito(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.photo.caption,
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        color: Colors.black54,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Divider line
                          Container(
                            height: 1,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 20),
                          
                          // More to explore section
                          Text(
                            'More to explore',
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    
                    // Related images grid
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        itemCount: _getRelatedPhotos().length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final relatedPhoto = _getRelatedPhotos()[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: relatedPhoto.aspectRatio,
                              child: Image.asset(
                                relatedPhoto.imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PhotoItem> _getRelatedPhotos() {
    // Return some related photos based on category
    return [
      PhotoItem(
        imagePath: 'assets/images/1.jpg',
        caption: 'Beautiful flowers',
        category: 'Photography',
        aspectRatio: 0.7,
      ),
      PhotoItem(
        imagePath: 'assets/images/2.jpg',
        caption: 'Nature photography',
        category: 'Photography',
        aspectRatio: 1.2,
      ),
      PhotoItem(
        imagePath: 'assets/images/3.jpg',
        caption: 'Artistic shot',
        category: 'Photography',
        aspectRatio: 0.8,
      ),
      PhotoItem(
        imagePath: 'assets/images/4.jpg',
        caption: 'Creative composition',
        category: 'Photography',
        aspectRatio: 1.0,
      ),
    ];
  }
}

class PhotoItem {
  final String imagePath;
  final String caption;
  final String category;
  final double aspectRatio;

  PhotoItem({
    required this.imagePath,
    required this.caption,
    required this.category,
    required this.aspectRatio,
  });
}