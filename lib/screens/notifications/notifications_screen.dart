import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
              onPressed: () {
                Navigator.of(context).pop();
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
                      }
                    },
                    itemBuilder: (BuildContext context) => [
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
                    isSelected: true,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _TimeFilterChip(
                    label: 'This Week',
                    isSelected: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Notifications List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _NotificationItem(
                    profileImage: 'assets/images/1.jpg',
                    username: 'Ronaldo',
                    action: 'Liked your post/pin',
                    timeAgo: '2h ago',
                    type: NotificationType.like,
                  ),
                  _NotificationItem(
                    profileImage: 'assets/images/2.jpg',
                    username: 'Contact',
                    action: 'Liked your post/pin',
                    timeAgo: '2h ago',
                    type: NotificationType.like,
                  ),
                  _NotificationItem(
                    profileImage: 'assets/images/3.jpg',
                    username: 'Rendy',
                    action: 'mentions you in some post',
                    timeAgo: '3h ago',
                    type: NotificationType.mention,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'This Week',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _NotificationItem(
                    profileImage: 'assets/images/4.jpg',
                    username: 'Ronaldo',
                    action: 'Liked your post/pin',
                    timeAgo: '2d ago',
                    type: NotificationType.like,
                  ),
                  _NotificationItem(
                    profileImage: 'assets/images/5.jpg',
                    username: 'Contact',
                    action: 'Liked your post/pin',
                    timeAgo: '2d ago',
                    type: NotificationType.like,
                  ),
                  _NotificationItem(
                    profileImage: 'assets/images/6.jpg',
                    username: 'Jeremy',
                    action: 'mentions you in some post',
                    timeAgo: '3d ago',
                    type: NotificationType.mention,
                  ),
                  const SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum NotificationType { like, comment, mention, follow }

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
  final String profileImage;
  final String username;
  final String action;
  final String timeAgo;
  final NotificationType type;

  const _NotificationItem({
    required this.profileImage,
    required this.username,
    required this.action,
    required this.timeAgo,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(profileImage),
              ),
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
                        text: username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' $action',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          // Action Button
          IconButton(
            onPressed: () {
              // TODO: Handle notification action
            },
            icon: const Icon(
              Icons.more_horiz,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor() {
    switch (type) {
      case NotificationType.like:
        return Colors.red;
      case NotificationType.comment:
        return Colors.blue;
      case NotificationType.mention:
        return Colors.orange;
      case NotificationType.follow:
        return Colors.green;
    }
  }

  IconData _getNotificationIcon() {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.follow:
        return Icons.person_add;
    }
  }
}