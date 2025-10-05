import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static PostService? _instance;
  
  // Collections
  static const String postsCollection = 'posts';
  static const String savedPostsCollection = 'saved_posts';
  
  // Stream controllers
  static final StreamController<List<Post>> _postsStreamController = 
      StreamController<List<Post>>.broadcast();
  
  static PostService get instance {
    _instance ??= PostService._();
    return _instance!;
  }
  
  PostService._() {
    // Enable offline persistence
    _firestore.settings = const Settings(persistenceEnabled: true);
    _loadAndNotify();
  }

  // Stream to notify listeners of posts changes
  Stream<List<Post>> get postsStream => _postsStreamController.stream;

  // Load posts and notify listeners
  void _loadAndNotify() {
    getAllPosts().then((posts) {
      if (!_postsStreamController.isClosed) {
        _postsStreamController.add(posts);
      }
    }).catchError((e) {
      print('Error loading posts: $e');
      if (!_postsStreamController.isClosed) {
        _postsStreamController.add([]);
      }
    });
  }

  // Get all posts from all users (global feed)
  Future<List<Post>> getAllPosts() async {
    try {
      final querySnapshot = await _firestore
          .collection(postsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Post.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting all posts: $e');
      return [];
    }
  }

  // Get posts by specific user (for profile)
  Future<List<Post>> getPostsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(postsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Post.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting user posts: $e');
      return [];
    }
  }

  // Get saved posts for a user
  Future<List<Post>> getSavedPosts(String userId) async {
    try {
      // Get saved post IDs
      final savedPostsDoc = await _firestore
          .collection(savedPostsCollection)
          .doc(userId)
          .get();
      
      if (!savedPostsDoc.exists) {
        return [];
      }
      
      final savedPostIds = List<String>.from(savedPostsDoc.data()?['postIds'] ?? []);
      
      if (savedPostIds.isEmpty) {
        return [];
      }
      
      // Get the actual posts
      final posts = <Post>[];
      for (final postId in savedPostIds) {
        final postDoc = await _firestore
            .collection(postsCollection)
            .doc(postId)
            .get();
        
        if (postDoc.exists) {
          posts.add(Post.fromJson({...postDoc.data()!, 'id': postDoc.id}));
        }
      }
      
      return posts;
    } catch (e) {
      print('Error getting saved posts: $e');
      return [];
    }
  }

  // Save a new post
  Future<void> savePost(Post post) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to save posts');
      }

      final postWithUser = Post(
        id: post.id,
        title: post.title,
        caption: post.caption,
        imageUrl: post.imageUrl,
        tags: post.tags,
        createdAt: post.createdAt,
        userId: currentUser.uid,
        userEmail: currentUser.email ?? '',
        userName: currentUser.displayName ?? 'Firebase User',
        likes: post.likes,
        likedBy: post.likedBy,
      );

      await _firestore
          .collection(postsCollection)
          .doc(post.id)
          .set(postWithUser.toJson());
      
      _loadAndNotify();
    } catch (e) {
      print('Error saving post: $e');
      rethrow;
    }
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to delete posts');
      }

      // Check if user owns the post
      final postDoc = await _firestore
          .collection(postsCollection)
          .doc(postId)
          .get();
      
      if (!postDoc.exists) {
        throw Exception('Post not found');
      }
      
      final postData = postDoc.data()!;
      if (postData['userId'] != currentUser.uid) {
        throw Exception('You can only delete your own posts');
      }

      await _firestore
          .collection(postsCollection)
          .doc(postId)
          .delete();
      
      _loadAndNotify();
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  // Update a post
  Future<void> updatePost(Post updatedPost) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to update posts');
      }

      // Check if user owns the post
      final postDoc = await _firestore
          .collection(postsCollection)
          .doc(updatedPost.id)
          .get();
      
      if (!postDoc.exists) {
        throw Exception('Post not found');
      }
      
      final postData = postDoc.data()!;
      if (postData['userId'] != currentUser.uid) {
        throw Exception('You can only update your own posts');
      }

      await _firestore
          .collection(postsCollection)
          .doc(updatedPost.id)
          .update(updatedPost.toJson());
      
      _loadAndNotify();
    } catch (e) {
      print('Error updating post: $e');
      rethrow;
    }
  }

  // Toggle like on a post
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection(postsCollection).doc(postId);
      
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        
        if (!postDoc.exists) {
          throw Exception('Post not found');
        }
        
        final postData = postDoc.data()!;
        final List<String> likedBy = List<String>.from(postData['likedBy'] ?? []);
        int likes = postData['likes'] ?? 0;
        
        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
          likes = likes - 1;
        } else {
          likedBy.add(userId);
          likes = likes + 1;
        }
        
        transaction.update(postRef, {
          'likes': likes,
          'likedBy': likedBy,
        });
      });
      
      _loadAndNotify();
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  // Save/unsave a post for a user
  Future<void> toggleSavePost(String postId, String userId) async {
    try {
      final savedPostsRef = _firestore.collection(savedPostsCollection).doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final savedPostsDoc = await transaction.get(savedPostsRef);
        
        List<String> savedPostIds = [];
        if (savedPostsDoc.exists) {
          savedPostIds = List<String>.from(savedPostsDoc.data()?['postIds'] ?? []);
        }
        
        if (savedPostIds.contains(postId)) {
          savedPostIds.remove(postId);
        } else {
          savedPostIds.add(postId);
        }
        
        transaction.set(savedPostsRef, {
          'postIds': savedPostIds,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Error toggling save post: $e');
      rethrow;
    }
  }

  // Check if a post is saved by a user
  Future<bool> isPostSaved(String postId, String userId) async {
    try {
      final savedPostsDoc = await _firestore
          .collection(savedPostsCollection)
          .doc(userId)
          .get();
      
      if (!savedPostsDoc.exists) {
        return false;
      }
      
      final savedPostIds = List<String>.from(savedPostsDoc.data()?['postIds'] ?? []);
      return savedPostIds.contains(postId);
    } catch (e) {
      print('Error checking if post is saved: $e');
      return false;
    }
  }

  // Get posts by category
  Future<List<Post>> getPostsByCategory(String category) async {
    final allPosts = await getAllPosts();
    if (category == 'All') {
      return allPosts;
    }
    return allPosts.where((post) => 
      post.tags.any((tag) => tag.toLowerCase().contains(category.toLowerCase()))
    ).toList();
  }

  // Stream for user's posts
  Stream<List<Post>> getPostsByUserStream(String userId) {
    return _firestore
        .collection(postsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Stream for all posts
  Stream<List<Post>> getAllPostsStream() {
    return _firestore
        .collection(postsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Stream for saved posts
  Stream<List<Post>> getSavedPostsStream(String userId) {
    return _firestore
        .collection(savedPostsCollection)
        .doc(userId)
        .snapshots()
        .asyncMap((doc) async {
          if (!doc.exists) {
            return <Post>[];
          }
          
          final savedPostIds = List<String>.from(doc.data()?['postIds'] ?? []);
          
          if (savedPostIds.isEmpty) {
            return <Post>[];
          }
          
          final posts = <Post>[];
          for (final postId in savedPostIds) {
            final postDoc = await _firestore
                .collection(postsCollection)
                .doc(postId)
                .get();
            
            if (postDoc.exists) {
              posts.add(Post.fromJson({...postDoc.data()!, 'id': postDoc.id}));
            }
          }
          
          return posts;
        });
  }

  // Upload image (placeholder - you can integrate with your cloud storage)
  Future<String> uploadImage(File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'https://picsum.photos/400/600?random=$timestamp';
    } catch (e) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'https://picsum.photos/400/600?random=$timestamp';
    }
  }

  // Clear all posts (for testing - be careful with this!)
  Future<void> clearAllPosts() async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore.collection(postsCollection).get();
      
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      _loadAndNotify();
    } catch (e) {
      print('Error clearing posts: $e');
    }
  }

  // Dispose
  void dispose() {
    _postsStreamController.close();
  }
}