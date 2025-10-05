import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import 'post_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static UserService? _instance;
  
  static UserService get instance {
    _instance ??= UserService._();
    return _instance!;
  }
  
  UserService._();

  // Get user profile data by userId
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Get user's bio
  Future<String> getUserBio(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      return profile?['bio'] ?? '';
    } catch (e) {
      print('Error getting user bio: $e');
      return '';
    }
  }

  // Get user's profile picture data
  Future<String?> getUserProfileImageData(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      return profile?['profileImageData'] as String?;
    } catch (e) {
      print('Error getting user profile image data: $e');
      return null;
    }
  }

  // Get user's profile picture URL
  Future<String?> getUserProfileImageUrl(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      return profile?['photoURL'] as String?;
    } catch (e) {
      print('Error getting user profile image URL: $e');
      return null;
    }
  }

  // Get user posts count
  Future<int> getUserPostsCount(String userId) async {
    try {
      final posts = await PostService.instance.getPostsByUser(userId);
      return posts.length;
    } catch (e) {
      print('Error getting user posts count: $e');
      return 0;
    }
  }

  // Get user posts
  Future<List<Post>> getUserPosts(String userId) async {
    try {
      return await PostService.instance.getPostsByUser(userId);
    } catch (e) {
      print('Error getting user posts: $e');
      return [];
    }
  }

  // Get user saved posts
  Future<List<Post>> getUserSavedPosts(String userId) async {
    try {
      return await PostService.instance.getSavedPosts(userId);
    } catch (e) {
      print('Error getting user saved posts: $e');
      return [];
    }
  }

  // Get user stats (followers, following - placeholder for future implementation)
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      // TODO: Implement actual followers/following system
      final postsCount = await getUserPostsCount(userId);
      return {
        'posts': postsCount,
        'followers': 0, // Placeholder
        'following': 0, // Placeholder
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {
        'posts': 0,
        'followers': 0,
        'following': 0,
      };
    }
  }
}