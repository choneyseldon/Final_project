import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/post.dart';

class PostService {
  static const String _storageKey = 'looma_global_posts';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static PostService? _instance;
  
  // Stream controller for cross-browser communication
  static final StreamController<List<Post>> _postsStreamController = 
      StreamController<List<Post>>.broadcast();
  
  static PostService get instance {
    _instance ??= PostService._();
    return _instance!;
  }
  
  PostService._() {
    if (kIsWeb) {
      // Listen for storage changes from other tabs/browsers
      html.window.addEventListener('storage', _onStorageChange);
    }
    
    // Load initial posts
    _loadAndNotify();
  }

  // Stream to notify listeners of posts changes
  Stream<List<Post>> get postsStream => _postsStreamController.stream;

  // Handle storage changes from other tabs/windows
  void _onStorageChange(html.Event event) {
    if (event is html.StorageEvent && event.key == _storageKey) {
      _loadAndNotify();
    }
  }

  // Load posts and notify listeners
  void _loadAndNotify() {
    getAllPosts().then((posts) {
      _postsStreamController.add(posts);
    });
  }

  // Get all posts from browser's localStorage (shared across tabs)
  Future<List<Post>> getAllPosts() async {
    try {
      if (kIsWeb) {
        // Use browser's localStorage for web
        final postsJson = html.window.localStorage[_storageKey];
        if (postsJson != null && postsJson.isNotEmpty) {
          final List<dynamic> postsList = json.decode(postsJson);
          return postsList.map((postData) => Post.fromJson(postData)).toList();
        }
        return [];
      } else {
        // For mobile, return empty for now
        return [];
      }
    } catch (e) {
      print('Error loading posts: $e');
      return [];
    }
  }

  Future<void> savePost(Post post) async {
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

      // Create post with user info
      final postWithUser = Post(
        id: post.id,
        title: post.title,
        caption: post.caption,
        imageUrl: post.imageUrl,
        tags: post.tags,
        createdAt: post.createdAt,
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        likes: post.likes,
        likedBy: post.likedBy,
      );

      // Get existing posts
      final existingPosts = await getAllPosts();
      
      // Add new post to the beginning (newest first)
      existingPosts.insert(0, postWithUser);
      
      if (kIsWeb) {
        // Save to browser's localStorage for web (shared across tabs)
        final postsJson = json.encode(existingPosts.map((p) => p.toJson()).toList());
        html.window.localStorage[_storageKey] = postsJson;
        
        // Trigger storage event manually for same-tab updates
        _postsStreamController.add(existingPosts);
      }
    } catch (e) {
      print('Error saving post: $e');
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final existingPosts = await getAllPosts();
      existingPosts.removeWhere((post) => post.id == postId);
      
      if (kIsWeb) {
        final postsJson = json.encode(existingPosts.map((p) => p.toJson()).toList());
        html.window.localStorage[_storageKey] = postsJson;
        _postsStreamController.add(existingPosts);
      }
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  Future<void> updatePost(Post updatedPost) async {
    try {
      final existingPosts = await getAllPosts();
      final index = existingPosts.indexWhere((post) => post.id == updatedPost.id);
      
      if (index != -1) {
        existingPosts[index] = updatedPost;
        
        if (kIsWeb) {
          final postsJson = json.encode(existingPosts.map((p) => p.toJson()).toList());
          html.window.localStorage[_storageKey] = postsJson;
          _postsStreamController.add(existingPosts);
        }
      }
    } catch (e) {
      print('Error updating post: $e');
      rethrow;
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      final existingPosts = await getAllPosts();
      final index = existingPosts.indexWhere((post) => post.id == postId);
      
      if (index != -1) {
        final post = existingPosts[index];
        final updatedPost = post.copyWith();
        
        if (updatedPost.likedBy.contains(userId)) {
          updatedPost.likedBy.remove(userId);
          updatedPost.likes = updatedPost.likes - 1;
        } else {
          updatedPost.likedBy.add(userId);
          updatedPost.likes = updatedPost.likes + 1;
        }

        existingPosts[index] = updatedPost;
        
        if (kIsWeb) {
          final postsJson = json.encode(existingPosts.map((p) => p.toJson()).toList());
          html.window.localStorage[_storageKey] = postsJson;
          _postsStreamController.add(existingPosts);
        }
      }
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  Future<List<Post>> getPostsByUser(String userId) async {
    final allPosts = await getAllPosts();
    return allPosts.where((post) => post.userId == userId).toList();
  }

  Future<List<Post>> getPostsByCategory(String category) async {
    final allPosts = await getAllPosts();
    if (category == 'All') {
      return allPosts;
    }
    return allPosts.where((post) => 
      post.tags.any((tag) => tag.toLowerCase().contains(category.toLowerCase()))
    ).toList();
  }

  Stream<List<Post>> getPostsByUserStream(String userId) {
    return postsStream.map((posts) => 
      posts.where((post) => post.userId == userId).toList()
    );
  }

  // Upload image (placeholder)
  Future<String> uploadImage(File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'https://picsum.photos/400/600?random=$timestamp';
    } catch (e) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'https://picsum.photos/400/600?random=$timestamp';
    }
  }

  // Clear all posts (for testing)
  Future<void> clearAllPosts() async {
    try {
      if (kIsWeb) {
        html.window.localStorage.remove(_storageKey);
        _postsStreamController.add([]);
      }
    } catch (e) {
      print('Error clearing posts: $e');
    }
  }
}