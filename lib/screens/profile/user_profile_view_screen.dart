import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../models/post.dart';
import '../../services/user_service.dart';
import '../home/post_detail_screen.dart';
import '../../theme/app_theme.dart';

class UserProfileViewScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const UserProfileViewScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<UserProfileViewScreen> createState() => _UserProfileViewScreenState();
}

class _UserProfileViewScreenState extends State<UserProfileViewScreen> with TickerProviderStateMixin {
  List<Post> _userPosts = [];
  List<Post> _savedPosts = [];
  bool _isLoading = true;
  String _userBio = '';
  String? _profileImageUrl;
  String? _profileImageData;
  Map<String, int> _userStats = {'posts': 0, 'followers': 0, 'following': 0};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user data in parallel
      final results = await Future.wait([
        UserService.instance.getUserPosts(widget.userId),
        UserService.instance.getUserSavedPosts(widget.userId),
        UserService.instance.getUserBio(widget.userId),
        UserService.instance.getUserProfileImageUrl(widget.userId),
        UserService.instance.getUserProfileImageData(widget.userId),
        UserService.instance.getUserStats(widget.userId),
      ]);
      
      if (mounted) {
        setState(() {
          _userPosts = results[0] as List<Post>;
          _savedPosts = results[1] as List<Post>;
          _userBio = results[2] as String;
          _profileImageUrl = results[3] as String?;
          _profileImageData = results[4] as String?;
          _userStats = results[5] as Map<String, int>;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildProfileImage() {
    // Check if user has profile image data (base64)
    if (_profileImageData != null && _profileImageData!.startsWith('data:image/')) {
      final base64Data = _profileImageData!.split(',').last;
      final bytes = base64Decode(base64Data);
      return ClipOval(
        child: Image.memory(
          bytes,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        ),
      );
    }
    // Check if user has profile image URL
    else if (_profileImageUrl != null && _profileImageUrl!.startsWith('http')) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: _profileImageUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildDefaultAvatar(),
          errorWidget: (context, url, error) => _buildDefaultAvatar(),
        ),
      );
    }
    // Default avatar
    else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.3),
            AppTheme.primaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.person,
        size: 50,
        color: AppTheme.primaryColor,
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
      // Fallback for any other format
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.error, color: Colors.grey),
      );
    }
  }

  Widget _buildPostCard(Post post) {
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
                aspectRatio: 1.0,
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
                  
                  // Like button
                  Row(
                    children: [
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 16,
                            color: Colors.red,
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header with back button
                  SafeArea(
                    child: Padding(
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
                  ),
                  
                  // Profile Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Picture with edit icon indicator
                        Stack(
                          children: [
                            _buildProfileImage(),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // User Name
                        Text(
                          widget.userName.isNotEmpty ? widget.userName : 'Anonymous User',
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Email
                        Text(
                          widget.userEmail,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Bio
                        if (_userBio.isNotEmpty) ...[
                          Text(
                            _userBio,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                        ] else ...[
                          Text(
                            'Photography enthusiast and creative soul 📸✨',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn(
                              '${_userStats['posts'] ?? _userPosts.length}',
                              'Posts',
                            ),
                            _buildStatColumn(
                              _formatNumber(_userStats['followers'] ?? 1200),
                              'Followers',
                            ),
                            _buildStatColumn(
                              '${_userStats['following'] ?? 348}',
                              'Following',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tabs Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Tab Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: AppTheme.primaryColor,
                            unselectedLabelColor: Colors.grey[600],
                            indicatorColor: AppTheme.primaryColor,
                            indicatorWeight: 3,
                            indicatorSize: TabBarIndicatorSize.label,
                            labelStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            unselectedLabelStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            tabs: const [
                              Tab(text: 'Pins'),
                              Tab(text: 'Saves'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Tab Content
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildPinsTab(),
                              _buildSavesTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _buildPinsTab() {
    if (_userPosts.isEmpty) {
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
              'No posts yet',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This user hasn\'t shared any posts',
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

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildSavesTab() {
    if (_savedPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No saved posts yet',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Saved posts will appear here',
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

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: _savedPosts.length,
      itemBuilder: (context, index) {
        final post = _savedPosts[index];
        return _buildPostCard(post);
      },
    );
  }
}

