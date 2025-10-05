import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/photo_provider.dart';
import 'providers/post_provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding/animated_welcome_screen.dart';
import 'screens/onboarding/categories_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'Looma',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: Consumer2<AuthProvider, AppProvider>(
          builder: (context, authProvider, appProvider, child) {
            if (authProvider.isAuthenticated) {
              // Check if user needs to select categories (first-time user)
              if (appProvider.isFirstTimeUser && appProvider.selectedCategories.isEmpty) {
                return const CategoriesScreen();
              }
              return const MainScreen();
            } else if (appProvider.isOnboardingCompleted) {
              return const LoginScreen();
            } else {
              return const AnimatedWelcomeScreen();
            }
          },
        ),
      ),
    );
  }
}