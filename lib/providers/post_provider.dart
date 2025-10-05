import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import '../models/post.dart';
import '../services/post_service.dart';
import 'dart:async';

class PostProvider with ChangeNotifier {
  final PostService _postService = PostService.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<Post>>? _postsSubscription;
  
  PostProvider() {
    // Listen to real-time post updates from Firestore
    _postsSubscription = _postService.postsStream.listen((posts) {
      _posts = posts;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Failed to load posts: $error';
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }
  
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _postService.getAllPosts();
    } catch (e) {
      _errorMessage = 'Failed to load posts: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPost({
    required String title,
    required String caption,
    required List<String> tags,
    required XFile imageFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current user info (use Firebase Auth if available, otherwise anonymous)
      String userId, userName, userEmail;
      final currentUser = _auth.currentUser;
      
      if (currentUser != null) {
        userId = currentUser.uid;
        userName = currentUser.displayName ?? 'Firebase User';
        userEmail = currentUser.email ?? '';
      } else {
        // Fallback for anonymous users
        userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        userName = 'Anonymous User';
        userEmail = 'anonymous@example.com';
      }

      String imageUrl;
      
      // For web, we need to handle the image differently
      if (kIsWeb) {
        // For web, we'll create a blob URL from the file
        final bytes = await imageFile.readAsBytes();
        // Create a data URL for the image
        final base64String = base64Encode(bytes);
        imageUrl = 'data:image/jpeg;base64,$base64String';
      } else {
        // For mobile, use the file path
        imageUrl = await _postService.uploadImage(File(imageFile.path));
      }
      
      // Create new post
      final post = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        caption: caption,
        imageUrl: imageUrl,
        tags: tags,
        createdAt: DateTime.now(),
        userId: userId,
        userEmail: userEmail,
        userName: userName,
      );

      // Save post 
      await _postService.savePost(post);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create post: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleLike(String postId) async {
    try {
      final currentUser = _auth.currentUser;
      final userId = currentUser?.uid ?? 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
      
      // Use the PostService's toggleLike method
      await _postService.toggleLike(postId, userId);
      
      // No need to manually update _posts as the stream will handle real-time updates
    } catch (e) {
      _errorMessage = 'Failed to toggle like: $e';
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _postService.deletePost(postId);
      _posts.removeWhere((post) => post.id == postId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete post: $e';
      notifyListeners();
    }
  }

  List<Post> getPostsByCategory(String category) {
    if (category == 'All') {
      return _posts;
    }
    return _posts.where((post) => 
      post.tags.any((tag) => tag.toLowerCase().contains(category.toLowerCase()))
    ).toList();
  }

  List<Post> getPostsByUser(String userId) {
    return _posts.where((post) => post.userId == userId).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Method to refresh posts (useful for seeing posts from other users)
  Future<void> refreshPosts() async {
    await loadPosts();
  }

  // Method to clear all posts (for testing purposes)
  Future<void> clearAllPosts() async {
    try {
      // With Firestore, we can't easily clear all posts from the provider
      // This would need to be done through Firebase Console or admin functions
      _errorMessage = 'Clear all posts is not available with Firestore. Use Firebase Console to manage data.';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear posts: $e';
      notifyListeners();
    }
  }

  // Method to add sample posts for testing (can be removed in production)
  Future<void> addSamplePosts() async {
    if (_posts.isNotEmpty) return; // Don't add if posts already exist

    final samplePosts = [
      Post(
        id: 'sample_1_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Beautiful Sunset',
        caption: 'Captured this amazing sunset at the beach last evening. Nature never fails to amaze me!',
        imageUrl: 'https://picsum.photos/400/600?random=1',
        tags: ['Photography', 'Nature'],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        userId: 'sample_user_1',
        userEmail: 'john@example.com',
        userName: 'John Photographer',
        likes: 12,
        likedBy: ['user1', 'user2', 'user3'],
      ),
      Post(
        id: 'sample_2_${DateTime.now().millisecondsSinceEpoch + 1}',
        title: 'Fashion Forward',
        caption: 'Latest fashion trends for this season. What do you think?',
        imageUrl: 'https://picsum.photos/400/500?random=2',
        tags: ['Fashion'],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        userId: 'sample_user_2',
        userEmail: 'fashion@example.com',
        userName: 'Style Maven',
        likes: 28,
        likedBy: ['user4', 'user5'],
      ),
      Post(
        id: 'sample_3_${DateTime.now().millisecondsSinceEpoch + 2}',
        title: 'Delicious Pasta',
        caption: 'Homemade pasta with fresh herbs and tomatoes. Recipe in comments!',
        imageUrl: 'https://picsum.photos/400/550?random=3',
        tags: ['Food & Recipes', 'Home'],
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        userId: 'sample_user_3',
        userEmail: 'chef@example.com',
        userName: 'Home Chef',
        likes: 45,
        likedBy: ['user6', 'user7', 'user8', 'user9'],
      ),
      Post(
        id: 'sample_4_${DateTime.now().millisecondsSinceEpoch + 3}',
        title: 'Mountain Adventure',
        caption: 'Hiking through the mountains this weekend. The views were incredible!',
        imageUrl: 'https://picsum.photos/400/650?random=4',
        tags: ['Travel', 'Nature'],
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        userId: 'sample_user_4',
        userEmail: 'explorer@example.com',
        userName: 'Mountain Explorer',
        likes: 33,
        likedBy: ['user10', 'user11'],
      ),
      Post(
        id: 'sample_5_${DateTime.now().millisecondsSinceEpoch + 4}',
        title: 'Art Studio Setup',
        caption: 'Finally organized my art studio! Ready for some creative projects.',
        imageUrl: 'https://picsum.photos/400/520?random=5',
        tags: ['Art & Design', 'Home'],
        createdAt: DateTime.now().subtract(const Duration(hours: 24)),
        userId: 'sample_user_5',
        userEmail: 'artist@example.com',
        userName: 'Creative Artist',
        likes: 67,
        likedBy: ['user12', 'user13', 'user14'],
      ),
    ];

    try {
      for (final post in samplePosts) {
        await _postService.savePost(post);
      }
      await loadPosts();
    } catch (e) {
      _errorMessage = 'Failed to add sample posts: $e';
      notifyListeners();
    }
  }
}