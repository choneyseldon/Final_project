import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { 
  like, 
  save, 
  comment, 
  mention, 
  follow 
}

class AppNotification {
  final String id;
  final String senderId;
  final String senderName;
  final String senderPhotoUrl;
  final String receiverId;
  final NotificationType type;
  final String message;
  final String? postId;
  final String? postImageUrl;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderPhotoUrl,
    required this.receiverId,
    required this.type,
    required this.message,
    this.postId,
    this.postImageUrl,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'] ?? '',
      receiverId: data['receiverId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${data['type']}',
        orElse: () => NotificationType.like,
      ),
      message: data['message'] ?? '',
      postId: data['postId'],
      postImageUrl: data['postImageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'receiverId': receiverId,
      'type': type.toString().split('.').last,
      'message': message,
      'postId': postId,
      'postImageUrl': postImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
           createdAt.month == now.month &&
           createdAt.day == now.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return createdAt.isAfter(weekAgo);
  }
}