import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'create_post/create_post_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: _getScreen(appProvider.currentIndex),
          bottomNavigationBar: CurvedNavigationBar(
            index: appProvider.currentIndex,
            height: 60,
            items: const [
              Icon(Icons.home_filled, size: 30, color: Colors.white),
              Icon(Icons.search, size: 30, color: Colors.white),
              Icon(Icons.add, size: 30, color: Colors.white),
              Icon(Icons.notifications, size: 30, color: Colors.white),
              Icon(Icons.person, size: 30, color: Colors.white),
            ],
            color: AppTheme.primaryColor,
            buttonBackgroundColor: AppTheme.primaryColor,
            backgroundColor: AppTheme.backgroundColor,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 300),
            onTap: (index) {
              appProvider.setCurrentIndex(index);
            },
          ),
        );
      },
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const SearchScreen();
      case 2:
        return const CreatePostScreen();
      case 3:
        return const NotificationsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}