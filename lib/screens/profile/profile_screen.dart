import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../models/post.dart';
import '../../services/post_service.dart';
import '../home/post_detail_screen.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import 'settings_screen.dart';
import 'user_profile_view_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;
  String _userBio = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserBio();
    
    // Load posts when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      postProvider.loadPosts();
    });
  }

  void _loadUserBio() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final bio = await authProvider.getUserBio();
      if (mounted) {
        setState(() {
          _userBio = bio;
        });
      }
    } catch (e) {
      print('Error loading bio: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
        
        try {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final imageUrl = await authProvider.uploadProfilePicture(image);
          
          if (mounted) {
            Navigator.pop(context); // Close loading dialog
            
            if (imageUrl != null) {
              // Force UI refresh - the Consumer will pick up the updated photoURL
              setState(() {
                // The Consumer<AuthProvider> will automatically refresh with the new photoURL
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile picture updated successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to upload profile picture'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            Navigator.pop(context); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload profile picture: ${e.toString()}'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick image. Please try again.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _signOut() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await context.read<AuthProvider>().signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      endDrawer: _buildMenuDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Profile',
                      style: GoogleFonts.raleway(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 159, 110, 238),
                      ),
                    ),
                    const Spacer(),
                    Builder(
                      builder: (context) => IconButton(
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                        icon: const Icon(
                          Icons.menu,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Info Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 235, 226, 253), Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 237, 229, 255)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color.fromARGB(255, 211, 200, 253).withOpacity(0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                    // Profile Picture
                    Stack(
                      children: [
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            final user = authProvider.user;
                            final photoUrl = user?.photoURL;
                            
                            return CircleAvatar(
                              radius: 50,
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                              child: photoUrl != null
                                  ? ClipOval(
                                      child: _buildProfileImage(photoUrl, authProvider),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppTheme.primaryColor,
                                    ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // User Info
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final user = authProvider.user;
                        return Column(
                          children: [
                            Text(
                              user?.displayName ?? 'User',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'user@example.com',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Bio Section
                            _userBio.isEmpty 
                                ? Text(
                                    'Add a bio to tell others about yourself',
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: AppTheme.textSecondaryColor.withOpacity(0.7),
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      _userBio,
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        color: AppTheme.textColor,
                                        height: 1.3,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Stats Row
                    Consumer2<PostProvider, AuthProvider>(
                      builder: (context, postProvider, authProvider, child) {
                        final userId = authProvider.user?.uid ?? '';
                        final userPosts = postProvider.posts.where((post) => post.userId == userId).toList();
                        
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              title: 'Posts',
                              count: '${userPosts.length}',
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            _StatItem(
                              title: 'Followers',
                              count: '1.2K', // TODO: Implement followers system
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            _StatItem(
                              title: 'Following',
                              count: '348', // TODO: Implement following system
                            ),
                          ],
                        );
                      },
                    ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tabs Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: AppTheme.primaryColor,
                      unselectedLabelColor: AppTheme.textSecondaryColor,
                      indicatorColor: AppTheme.primaryColor,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      tabs: const [
                        Tab(text: 'Pins'),
                        Tab(text: 'Saves'),
                      ],
                    ),
                    const SizedBox(height: 20),
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

              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                ),
                child: const Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuTile(
                icon: Icons.settings,
                title: 'Settings',
                subtitle: 'Manage your account settings',
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                  // Refresh bio when returning from settings
                  _loadUserBio();
                },
              ),
              _buildMenuTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help with your account',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Help & Support coming soon!'),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                onTap: () {
                  Navigator.pop(context);
                  _signOut();
                },
                isDestructive: true,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive 
              ? AppTheme.errorColor.withOpacity(0.1)
              : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppTheme.errorColor : AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppTheme.errorColor : AppTheme.textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondaryColor,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildPinsTab() {
    return Consumer2<PostProvider, AuthProvider>(
      builder: (context, postProvider, authProvider, child) {
        final userId = authProvider.user?.uid ?? '';
        if (userId.isEmpty) {
          return const Center(
            child: Text('Please log in to view your posts'),
          );
        }
        
        // Filter posts by current user
        final userPosts = postProvider.posts.where((post) => post.userId == userId).toList();
        
        if (postProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (userPosts.isEmpty) {
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
                  'Create your first post to get started!',
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
          padding: const EdgeInsets.all(8),
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: userPosts.length,
            itemBuilder: (context, index) {
              final post = userPosts[index];
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
            },
          ),
        );
      },
    );
  }

  Widget _buildSavesTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userId = authProvider.user?.uid ?? '';
        if (userId.isEmpty) {
          return const Center(
            child: Text('Please log in to view your saved posts'),
          );
        }
        
        return StreamBuilder<List<Post>>(
          stream: PostService.instance.getSavedPostsStream(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading saved posts: ${snapshot.error}'),
              );
            }
            
            final savedPosts = snapshot.data ?? [];
            
            if (savedPosts.isEmpty) {
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
                      'Posts you save will appear here',
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
              padding: const EdgeInsets.all(8),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: savedPosts.length,
                itemBuilder: (context, index) {
                  final post = savedPosts[index];
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
                                
                                // User info and like button
                                Row(
                                  children: [
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
                                        child: Text(
                                          'by ${post.userName}',
                                          style: GoogleFonts.nunito(
                                            fontSize: 11,
                                            color: const Color(0xFF8B5CF6),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
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
                },
              ),
            );

          },
        );
      },
    );
  }

  Widget _buildProfileImage(String imageUrl, AuthProvider authProvider) {
    // Check if it's a Firestore reference
    if (imageUrl == 'firestore:profile_image') {
      return FutureBuilder<String?>(
        future: authProvider.getProfileImageData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(strokeWidth: 2);
          }
          
          if (snapshot.hasData && snapshot.data != null) {
            final dataUrl = snapshot.data!;
            final base64Data = dataUrl.split(',').last;
            final bytes = base64Decode(base64Data);
            return Image.memory(
              bytes,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  size: 50,
                  color: AppTheme.primaryColor,
                );
              },
            );
          }
          
          return const Icon(
            Icons.person,
            size: 50,
            color: AppTheme.primaryColor,
          );
        },
      );
    }
    
    // Check if it's a data URL (base64 encoded image)
    if (imageUrl.startsWith('data:image/')) {
      // Data URL - decode and display
      final base64Data = imageUrl.split(',').last;
      final bytes = base64Decode(base64Data);
      return Image.memory(
        bytes,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.person,
            size: 50,
            color: AppTheme.primaryColor,
          );
        },
      );
    } else if (imageUrl.startsWith('http')) {
      // Network image
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
        errorWidget: (context, url, error) => const Icon(
          Icons.person,
          size: 50,
          color: AppTheme.primaryColor,
        ),
      );
    } else {
      // Fallback for any other format
      return const Icon(
        Icons.person,
        size: 50,
        color: AppTheme.primaryColor,
      );
    }
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
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.image,
              color: AppTheme.textSecondaryColor,
            ),
          );
        },
      );
    } else if (imageUrl.startsWith('http')) {
      // Network image
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.image,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      );
    } else {
      // Fallback for any other format
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(
          Icons.image,
          color: AppTheme.textSecondaryColor,
        ),
      );
    }
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String count;

  const _StatItem({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}