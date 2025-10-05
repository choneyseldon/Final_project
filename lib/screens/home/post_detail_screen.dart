import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../models/post.dart';
import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/post_service.dart';
import '../profile/user_profile_view_screen.dart';
import '../../services/user_service.dart';
import '../../services/notification_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool isSaved = false;
  late Post currentPost;

  @override
  void initState() {
    super.initState();
    currentPost = widget.post;
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final saved = await PostService.instance.isPostSaved(
        widget.post.id,
        authProvider.user!.uid,
      );
      if (mounted) {
        setState(() {
          isSaved = saved;
        });
      }
    }
  }

  Future<void> _toggleSave() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      await PostService.instance.toggleSavePost(
        widget.post.id,
        authProvider.user!.uid,
      );
      setState(() {
        isSaved = !isSaved;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSaved ? 'Post saved!' : 'Post removed from saved'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleLike() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      await postProvider.toggleLike(currentPost.id);
      // Update the current post to reflect the like change
      final updatedPosts = postProvider.posts;
      final updatedPost = updatedPosts.firstWhere(
        (p) => p.id == currentPost.id,
        orElse: () => currentPost,
      );
      setState(() {
        currentPost = updatedPost;
      });
    }
  }

  Widget _buildUserProfileImage(String userId) {
    return FutureBuilder<String?>(
      future: UserService.instance.getUserProfileImageData(userId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.startsWith('data:image/')) {
          final base64Data = snapshot.data!.split(',').last;
          final bytes = base64Decode(base64Data);
          return ClipOval(
            child: Image.memory(
              bytes,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultProfileImage();
              },
            ),
          );
        }
        return _buildDefaultProfileImage();
      },
    );
  }

  Widget _buildDefaultProfileImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.2),
            const Color(0xFFB794F6).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF8B5CF6),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.person,
        color: Color(0xFF8B5CF6),
        size: 28,
      ),
    );
  }

  Widget _buildFollowButton(String userId) {
    // Don't show follow button for current user's own posts
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.uid == userId) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<bool>(
      future: _isFollowing(userId),
      builder: (context, snapshot) {
        final isFollowing = snapshot.data ?? false;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        
        return GestureDetector(
          onTap: isLoading ? null : () => _toggleFollow(userId),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isFollowing ? Colors.grey[200] : const Color(0xFF8B5CF6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF8B5CF6),
                width: 1,
              ),
            ),
            child: Text(
              isLoading ? '...' : (isFollowing ? 'Following' : 'Follow'),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isFollowing ? const Color(0xFF8B5CF6) : Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _isFollowing(String userId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return false;
    
    try {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .get();
      
      if (currentUserDoc.exists) {
        final following = List<String>.from(currentUserDoc.data()?['following'] ?? []);
        return following.contains(userId);
      }
    } catch (e) {
      print('Error checking follow status: $e');
    }
    return false;
  }

  Future<void> _toggleFollow(String userId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    try {
      final currentUserId = authProvider.user!.uid;
      final isCurrentlyFollowing = await _isFollowing(userId);
      
      final batch = FirebaseFirestore.instance.batch();
      
      // Update current user's following list
      final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);
      if (isCurrentlyFollowing) {
        batch.update(currentUserRef, {
          'following': FieldValue.arrayRemove([userId])
        });
      } else {
        batch.update(currentUserRef, {
          'following': FieldValue.arrayUnion([userId])
        });
      }
      
      // Update target user's followers list
      final targetUserRef = FirebaseFirestore.instance.collection('users').doc(userId);
      if (isCurrentlyFollowing) {
        batch.update(targetUserRef, {
          'followers': FieldValue.arrayRemove([currentUserId])
        });
      } else {
        batch.update(targetUserRef, {
          'followers': FieldValue.arrayUnion([currentUserId])
        });
      }
      
      await batch.commit();
      
      // Create notification if user just started following (not unfollowing)
      if (!isCurrentlyFollowing) {
        try {
          await NotificationService().createFollowNotification(
            followedUserId: userId,
          );
        } catch (e) {
          print('Error creating follow notification: $e');
          // Don't throw error here, just log it
        }
      }
      
      // Trigger rebuild
      setState(() {});
      
    } catch (e) {
      print('Error toggling follow: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating follow status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer2<PostProvider, AuthProvider>(
        builder: (context, postProvider, authProvider, child) {
          // Find the current post (it might have been updated with likes, etc.)
          final latestPost = postProvider.posts.firstWhere(
            (p) => p.id == widget.post.id,
            orElse: () => currentPost,
          );
          currentPost = latestPost;
          final isLiked = currentPost.likedBy.contains(authProvider.user?.uid ?? '');

          return SafeArea(
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
                              child: CachedNetworkImage(
                                imageUrl: currentPost.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Post info
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Interactive icons row with Save button
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _toggleLike,
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      size: 24,
                                      color: const Color(0xFF8B5CF6),
                                    ),
                                  ),
                                  Text(
                                    '${currentPost.likes}',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
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
                                      gradient: LinearGradient(
                                        colors: isSaved
                                            ? [Colors.green, Colors.green.shade400]
                                            : [
                                                const Color(0xFF8B5CF6),
                                                const Color(0xFFB794F6),
                                              ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _toggleSave,
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
                                        isSaved ? 'Saved' : 'Save',
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
                              GestureDetector(
                                onTap: () {
                                  // Navigate to user profile
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserProfileViewScreen(
                                        userId: currentPost.userId,
                                        userName: currentPost.userName,
                                        userEmail: currentPost.userEmail,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Profile image
                                    _buildUserProfileImage(currentPost.userId),
                                    const SizedBox(width: 12),
                                    // Username and caption
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentPost.userName.isNotEmpty 
                                                ? currentPost.userName 
                                                : 'Anonymous User',
                                            style: GoogleFonts.nunito(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF8B5CF6),
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        if (currentPost.title.isNotEmpty) ...[
                                          Text(
                                            currentPost.title,
                                            style: GoogleFonts.nunito(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                          if (currentPost.caption.isNotEmpty)
                                            Text(
                                              currentPost.caption,
                                              style: GoogleFonts.nunito(
                                                fontSize: 14,
                                                color: Colors.black54,
                                                height: 1.4,
                                              ),
                                            ),
                                          if (currentPost.tags.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: currentPost.tags.map((tag) => 
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    '#$tag',
                                                    style: GoogleFonts.nunito(
                                                      fontSize: 12,
                                                      color: const Color(0xFF8B5CF6),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ).toList(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildFollowButton(currentPost.userId),
                                  ],
                                ),
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
                        
                        // Related posts grid
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: _buildRelatedPostsGrid(postProvider, currentPost),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRelatedPostsGrid(PostProvider postProvider, Post currentPost) {
    // Get related posts (same tags or by same user, excluding current post)
    final relatedPosts = postProvider.posts
        .where((post) => 
            post.id != currentPost.id && 
            (post.tags.any((tag) => currentPost.tags.contains(tag)) ||
             post.userId == currentPost.userId))
        .take(4)
        .toList();

    if (relatedPosts.isEmpty) {
      // Show some random posts if no related posts found
      final randomPosts = postProvider.posts
          .where((post) => post.id != currentPost.id)
          .take(4)
          .toList();
      
      if (randomPosts.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return _buildPostsGrid(randomPosts);
    }

    return _buildPostsGrid(relatedPosts);
  }

  Widget _buildPostsGrid(List<Post> posts) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: posts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: post),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 0.8, // Consistent aspect ratio for grid
              child: CachedNetworkImage(
                imageUrl: post.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}