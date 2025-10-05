import 'dart:ui';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/post.dart';
import '../../services/post_service.dart';
import 'post_detail_screen.dart';
import '../profile/user_profile_view_screen.dart';
import '../../services/user_service.dart';

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
    'Art & Design',
    'Fashion',
    'Travel',
    'Food & Recipes',
    'Nature',
    'Home',
    'Beauty & Skincare',
  ];

  @override
  void initState() {
    super.initState();
  }

  List<Post> _getFilteredPosts(List<Post> posts) {
    if (selectedCategory == 'All') {
      return posts;
    }
    return posts.where((post) => 
      post.tags.any((tag) => tag.toLowerCase().contains(selectedCategory.toLowerCase()))
    ).toList();
  }

  Widget _buildUserProfileIcon(String userId) {
    return FutureBuilder<String?>(
      future: UserService.instance.getUserProfileImageData(userId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.startsWith('data:image/')) {
          final base64Data = snapshot.data!.split(',').last;
          final bytes = base64Decode(base64Data);
          return ClipOval(
            child: Image.memory(
              bytes,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultProfileIcon();
              },
            ),
          );
        }
        return _buildDefaultProfileIcon();
      },
    );
  }

  Widget _buildDefaultProfileIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        border: Border.all(
          color: const Color(0xFF8B5CF6),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.person,
        color: Color(0xFF8B5CF6),
        size: 18,
      ),
    );
  }



  Widget _buildPostImage(String imageUrl) {
    // Check if it's a data URL (base64 encoded image)
    if (imageUrl.startsWith('data:image/')) {
      // Data URL - decode and display
      final base64Data = imageUrl.split(',').last;
      final bytes = base64Decode(base64Data);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error, color: Colors.grey),
          );
        },
      );
    } else if (imageUrl.startsWith('http')) {
      // Network image
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.error, color: Colors.grey),
        ),
      );
    } else {
      // Local file path
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error, color: Colors.grey),
          );
        },
      );
    }
  }

  Widget _buildPostCard(Post post, AuthProvider authProvider, PostProvider postProvider) {
    final isLiked = post.likedBy.contains(authProvider.user?.uid ?? '');
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1.0, // You can randomize this or calculate based on image
                child: _buildPostImage(post.imageUrl),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    post.title,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  if (post.caption.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      post.caption,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  const SizedBox(height: 8),
                  
                  // Tags
                  if (post.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: post.tags.take(2).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            color: const Color(0xFF8B5CF6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // User info and like button
                  Row(
                    children: [
                      // Profile icon and username
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to user profile
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfileViewScreen(
                                  userId: post.userId,
                                  userName: post.userName,
                                  userEmail: post.userEmail,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              _buildUserProfileIcon(post.userId),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  post.userName.isNotEmpty ? post.userName : 'Anonymous User',
                                  style: GoogleFonts.nunito(
                                    fontSize: 11,
                                    color: const Color(0xFF8B5CF6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          postProvider.toggleLike(post.id);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: isLiked ? Colors.red : Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post.likes}',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
              child: Row(
                children: [
                  const Spacer(),
                  ShaderMask(
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
                  const Spacer(),
                  Consumer<PostProvider>(
                    builder: (context, postProvider, child) {
                      return IconButton(
                        onPressed: postProvider.isLoading 
                            ? null 
                            : () => postProvider.refreshPosts(),
                        icon: postProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.refresh,
                                color: Color(0xFF8B5CF6),
                                size: 28,
                              ),
                        tooltip: 'Refresh posts',
                      );
                    },
                  ),
                ],
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

            // Posts grid with real-time Firebase updates
            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return StreamBuilder<List<Post>>(
                    stream: PostService.instance.getAllPostsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load posts',
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Error: ${snapshot.error}',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {}); // Trigger rebuild to retry stream
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final allPosts = snapshot.data ?? [];
                      final filteredPosts = _getFilteredPosts(allPosts);

                      if (filteredPosts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 64,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                allPosts.isEmpty ? 'No posts yet' : 'No posts in this category',
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                allPosts.isEmpty 
                                    ? 'Create your first post to get started!'
                                    : 'Try selecting a different category',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState(() {}); // Refresh the stream
                          },
                          child: MasonryGridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            itemCount: filteredPosts.length,
                            itemBuilder: (context, index) {
                              final post = filteredPosts[index];
                              return Consumer<PostProvider>(
                                builder: (context, postProvider, child) => 
                                    _buildPostCard(post, authProvider, postProvider),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }




}

