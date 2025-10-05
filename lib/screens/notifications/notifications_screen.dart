import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  String _selectedTimeFilter = 'Today';

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read when tapped
    if (!notification.isRead) {
      _notificationService.markAsRead(notification.id);
    }
    
    // Navigate to post detail if notification has postId
    if (notification.postId != null) {
      // TODO: Navigate to post detail screen
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => PostDetailScreen(postId: notification.postId!),
      //   ),
      // );
    }
  }

  void _createTestNotification() async {
    print('NotificationScreen: Creating test notification');
    try {
      await _notificationService.createTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Test notification created',
              style: GoogleFonts.nunito(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error creating test notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error creating test notification: $e',
              style: GoogleFonts.nunito(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _testFirestoreConnection() async {
    print('NotificationScreen: Testing Firestore connection');
    try {
      await _notificationService.testFirestoreConnection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Firestore connection test completed - check console for details',
              style: GoogleFonts.nunito(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error testing Firestore connection: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Firestore connection test failed: $e',
              style: GoogleFonts.nunito(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showClearNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Clear Notifications',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to clear all notifications?',
            style: GoogleFonts.nunito(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.nunito(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _notificationService.clearAllNotifications();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'All notifications cleared',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: AppTheme.primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error clearing notifications',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Clear',
                style: GoogleFonts.nunito(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.raleway(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 172, 116, 236),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppTheme.textSecondaryColor,
                    ),
                    onSelected: (String value) {
                      if (value == 'clear') {
                        _showClearNotificationsDialog(context);
                      } else if (value == 'test') {
                        _createTestNotification();
                      } else if (value == 'firestore-test') {
                        _testFirestoreConnection();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'test',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bug_report,
                              color: AppTheme.textSecondaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Create Test Notification',
                              style: GoogleFonts.nunito(
                                color: AppTheme.textColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'firestore-test',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cloud,
                              color: AppTheme.textSecondaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Test Firestore Connection',
                              style: GoogleFonts.nunito(
                                color: AppTheme.textColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'clear',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.clear_all,
                              color: AppTheme.textSecondaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Clear Notifications',
                              style: GoogleFonts.nunito(
                                color: AppTheme.textColor,
                                fontSize: 14,
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

            // Time Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _TimeFilterChip(
                    label: 'Today',
                    isSelected: _selectedTimeFilter == 'Today',
                    onTap: () {
                      setState(() {
                        _selectedTimeFilter = 'Today';
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  _TimeFilterChip(
                    label: 'This Week',
                    isSelected: _selectedTimeFilter == 'This Week',
                    onTap: () {
                      setState(() {
                        _selectedTimeFilter = 'This Week';
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Notifications List
            Expanded(
              child: StreamBuilder<List<AppNotification>>(
                stream: _notificationService.getNotificationsStream(),
                builder: (context, snapshot) {
                  print('NotificationScreen: StreamBuilder state: ${snapshot.connectionState}');
                  print('NotificationScreen: Has error: ${snapshot.hasError}');
                  print('NotificationScreen: Error: ${snapshot.error}');
                  print('NotificationScreen: Data length: ${snapshot.data?.length}');
                  
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    print('NotificationScreen: Showing loading indicator');
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    print('NotificationScreen: Showing error: ${snapshot.error}');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading notifications',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final allNotifications = snapshot.data ?? [];
                  
                  if (allNotifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications yet',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter notifications based on selected time filter
                  List<AppNotification> filteredNotifications;
                  if (_selectedTimeFilter == 'Today') {
                    filteredNotifications = allNotifications.where((n) => n.isToday).toList();
                  } else {
                    filteredNotifications = allNotifications.where((n) => n.isThisWeek).toList();
                  }

                  // Group notifications by day
                  final todayNotifications = filteredNotifications.where((n) => n.isToday).toList();
                  final weekNotifications = filteredNotifications.where((n) => !n.isToday && n.isThisWeek).toList();

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Today's notifications
                      if (todayNotifications.isNotEmpty) ...[
                        ...todayNotifications.map((notification) => _NotificationItem(
                          notification: notification,
                          onTap: () => _handleNotificationTap(notification),
                          onMarkAsRead: () => _notificationService.markAsRead(notification.id),
                        )),
                        const SizedBox(height: 20),
                      ],
                      
                      // This week's notifications
                      if (weekNotifications.isNotEmpty && _selectedTimeFilter == 'This Week') ...[
                        const Text(
                          'This Week',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...weekNotifications.map((notification) => _NotificationItem(
                          notification: notification,
                          onTap: () => _handleNotificationTap(notification),
                          onMarkAsRead: () => _notificationService.markAsRead(notification.id),
                        )),
                      ],
                      
                      const SizedBox(height: 100), // Space for bottom navigation
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Remove the old enum since we're using the one from the notification model

class _TimeFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;

  const _NotificationItem({
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : AppTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: notification.isRead ? null : Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Image
            Stack(
              children: [
                _buildProfileImage(notification.senderPhotoUrl, authProvider),
                // Notification Type Indicator
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      _getNotificationIcon(),
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Notification Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textColor,
                      ),
                      children: [
                        TextSpan(
                          text: notification.senderName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' ${notification.message}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.getTimeAgo(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            // Post thumbnail (if available)
            if (notification.postImageUrl != null && notification.postImageUrl!.isNotEmpty) ...[
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildPostImage(notification.postImageUrl!),
              ),
            ],
            // Action Button
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!notification.isRead)
                        ListTile(
                          leading: const Icon(Icons.mark_email_read),
                          title: const Text('Mark as read'),
                          onTap: () {
                            Navigator.pop(context);
                            onMarkAsRead?.call();
                          },
                        ),
                      ListTile(
                        leading: const Icon(Icons.delete),
                        title: const Text('Delete notification'),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Implement delete notification
                        },
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(
                Icons.more_horiz,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl, AuthProvider authProvider) {
    if (imageUrl.isEmpty) {
      return const CircleAvatar(
        radius: 20,
        backgroundColor: AppTheme.primaryColor,
        child: Icon(
          Icons.person,
          size: 20,
          color: Colors.white,
        ),
      );
    }
    
    if (imageUrl == 'firestore:profile_image') {
      return FutureBuilder<String?>(
        future: authProvider.getProfileImageData(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final dataUrl = snapshot.data!;
            final base64Data = dataUrl.split(',').last;
            final bytes = base64Decode(base64Data);
            return CircleAvatar(
              radius: 20,
              backgroundImage: MemoryImage(bytes),
            );
          }
          return const CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryColor,
            child: Icon(
              Icons.person,
              size: 20,
              color: Colors.white,
            ),
          );
        },
      );
    }
    
    if (imageUrl.startsWith('data:image/')) {
      final base64Data = imageUrl.split(',').last;
      final bytes = base64Decode(base64Data);
      return CircleAvatar(
        radius: 20,
        backgroundImage: MemoryImage(bytes),
      );
    }
    
    return CircleAvatar(
      radius: 20,
      backgroundImage: CachedNetworkImageProvider(imageUrl),
    );
  }

  Widget _buildPostImage(String imageUrl) {
    if (imageUrl.startsWith('data:image/')) {
      final base64Data = imageUrl.split(',').last;
      final bytes = base64Decode(base64Data);
      return SizedBox(
        width: 40,
        height: 40,
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
        ),
      );
    }
    
    if (imageUrl.startsWith('http')) {
      return SizedBox(
        width: 40,
        height: 40,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.image, color: Colors.grey),
          ),
        ),
      );
    }
    
    return SizedBox(
      width: 40,
      height: 40,
      child: Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, color: Colors.grey),
      ),
    );
  }

  Color _getNotificationColor() {
    switch (notification.type) {
      case NotificationType.like:
        return Colors.red;
      case NotificationType.save:
        return Colors.purple;
      case NotificationType.comment:
        return Colors.blue;
      case NotificationType.mention:
        return Colors.orange;
      case NotificationType.follow:
        return Colors.green;
    }
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.save:
        return Icons.bookmark;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.follow:
        return Icons.person_add;
    }
  }
}