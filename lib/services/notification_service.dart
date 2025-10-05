import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a notification
  Future<void> createNotification({
    required String receiverId,
    required NotificationType type,
    required String message,
    String? postId,
    String? postImageUrl,
  }) async {
    final currentUser = _auth.currentUser;
    print('NotificationService: Creating notification - currentUser: ${currentUser?.uid}, receiverId: $receiverId');
    
    if (currentUser == null || currentUser.uid == receiverId) {
      print('NotificationService: Skipping notification - user is null or self-notification');
      return;
    }

    try {
      // Get sender information
      final senderDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final senderData = senderDoc.data() ?? {};
      final senderName = senderData['displayName'] ?? currentUser.displayName ?? 'Anonymous';
      print('NotificationService: Sender name: $senderName');
      
      String senderPhotoUrl = '';
      if (currentUser.photoURL == 'firestore:profile_image') {
        senderPhotoUrl = senderData['profileImageData'] ?? '';
      } else {
        senderPhotoUrl = currentUser.photoURL ?? '';
      }

      final notification = AppNotification(
        id: '', // Will be set by Firestore
        senderId: currentUser.uid,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        receiverId: receiverId,
        type: type,
        message: message,
        postId: postId,
        postImageUrl: postImageUrl,
        createdAt: DateTime.now(),
        isRead: false,
      );

      final docRef = await _firestore.collection('notifications').add(notification.toFirestore());
      print('NotificationService: Notification created successfully with ID: ${docRef.id}');
    } catch (e) {
      print('Error creating notification: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  // Get notifications for current user
  Stream<List<AppNotification>> getNotificationsStream() {
    final currentUser = _auth.currentUser;
    print('NotificationService: Getting notifications stream for user: ${currentUser?.uid}');
    
    if (currentUser == null) {
      print('NotificationService: No current user, returning empty stream');
      return Stream.value([]);
    }

    // Temporarily remove orderBy to avoid potential index issues
    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
          print('NotificationService: Received ${snapshot.docs.length} notifications from Firestore');
          final notifications = snapshot.docs
              .map((doc) {
                try {
                  print('NotificationService: Processing document ${doc.id}');
                  return AppNotification.fromFirestore(doc);
                } catch (e) {
                  print('Error parsing notification ${doc.id}: $e');
                  return null;
                }
              })
              .where((notification) => notification != null)
              .cast<AppNotification>()
              .toList();
          
          // Sort manually by creation date
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          print('NotificationService: Successfully parsed ${notifications.length} notifications');
          return notifications;
        });
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('receiverId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('receiverId', isEqualTo: currentUser.uid)
          .get();

      for (final doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  // Get unread notification count
  Stream<int> getUnreadCountStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Helper methods for specific notification types
  Future<void> createLikeNotification({
    required String postOwnerId,
    required String postId,
    String? postImageUrl,
  }) async {
    print('NotificationService: Creating like notification for post owner: $postOwnerId');
    await createNotification(
      receiverId: postOwnerId,
      type: NotificationType.like,
      message: 'liked your post',
      postId: postId,
      postImageUrl: postImageUrl,
    );
  }

  Future<void> createSaveNotification({
    required String postOwnerId,
    required String postId,
    String? postImageUrl,
  }) async {
    print('NotificationService: Creating save notification for post owner: $postOwnerId');
    await createNotification(
      receiverId: postOwnerId,
      type: NotificationType.save,
      message: 'saved your post',
      postId: postId,
      postImageUrl: postImageUrl,
    );
  }

  // Create a follow notification
  Future<void> createFollowNotification({
    required String followedUserId,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid == followedUserId) {
      return; // Don't create notification for self-follow or when not logged in
    }

    try {
      // Get the follower's name
      final followerDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final followerData = followerDoc.data() ?? {};
      final followerName = followerData['displayName'] ?? 
                          followerData['userName'] ?? 
                          currentUser.displayName ?? 
                          'Someone';

      await createNotification(
        receiverId: followedUserId,
        type: NotificationType.follow,
        message: '$followerName started following you',
      );
    } catch (e) {
      print('Error creating follow notification: $e');
    }
  }

  // Test method to create a notification for debugging
  Future<void> createTestNotification() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('NotificationService: No current user for test notification');
      return;
    }
    
    print('NotificationService: Creating test notification for current user: ${currentUser.uid}');
    
    try {
      // Create a simple test notification directly
      final testNotification = {
        'senderId': currentUser.uid,
        'senderName': 'Test User',
        'senderPhotoUrl': '',
        'receiverId': currentUser.uid,
        'type': 'like',
        'message': 'This is a test notification - if you see this, the system is working!',
        'postId': 'test-post-id',
        'postImageUrl': null,
        'createdAt': Timestamp.now(),
        'isRead': false,
      };
      
      final docRef = await _firestore.collection('notifications').add(testNotification);
      print('NotificationService: Test notification created with ID: ${docRef.id}');
    } catch (e) {
      print('NotificationService: Error creating test notification: $e');
      rethrow;
    }
  }

  // Test method to check Firestore connectivity
  Future<void> testFirestoreConnection() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('NotificationService: No current user for Firestore test');
      return;
    }

    try {
      print('NotificationService: Testing Firestore read access...');
      final snapshot = await _firestore
          .collection('notifications')
          .where('receiverId', isEqualTo: currentUser.uid)
          .limit(1)
          .get();
      
      print('NotificationService: Firestore read test successful. Found ${snapshot.docs.length} documents');
    } catch (e) {
      print('NotificationService: Firestore read test failed: $e');
      print('This might indicate a Firestore rules or permissions issue');
    }
  }
}