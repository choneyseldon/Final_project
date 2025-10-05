import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../auth/login_screen.dart';

class AnimatedWelcomeScreen extends StatefulWidget {
  const AnimatedWelcomeScreen({super.key});

  @override
  State<AnimatedWelcomeScreen> createState() => _AnimatedWelcomeScreenState();
}

class _AnimatedWelcomeScreenState extends State<AnimatedWelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start fade animation
    _fadeController.forward();
    
    // Start scale animation after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    
    // Start slide animation after another delay
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    
    // Auto-navigate to onboarding after showing welcome screen
    await Future.delayed(const Duration(milliseconds: 3000));
    _navigateToOnboarding();
  }

  void _navigateToOnboarding() async {
    // Fade out animation
    await _fadeController.reverse();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Main content centered
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // App Name "Looma" with scale animation
                            AnimatedBuilder(
                              animation: _scaleController,
                              builder: (context, child) {
                                return ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Text(
                                    'Looma',
                                    style: GoogleFonts.raleway(
                                      fontSize: screenWidth > 600 ? 64 : 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(0, 4),
                                          blurRadius: 8.0,
                                          color: Colors.black.withOpacity(0.3),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                            
                            // Spacing
                            SizedBox(height: screenHeight * 0.03),
                            
                            // Horizontal line with fade animation
                            AnimatedBuilder(
                              animation: _fadeController,
                              builder: (context, child) {
                                return FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    width: screenWidth * 0.4,
                                    height: 1,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            // Spacing
                            SizedBox(height: screenHeight * 0.03),
                            
                            // Subtitle with slide animation
                            AnimatedBuilder(
                              animation: _slideController,
                              builder: (context, child) {
                                return SlideTransition(
                                  position: _slideAnimation,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 40),
                                    child: Text(
                                      'Weave Your World of Inspiration',
                                      style: GoogleFonts.nunito(
                                        fontSize: screenWidth > 600 ? 20 : 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white.withOpacity(0.9),
                                        letterSpacing: 0.5,
                                        height: 1.3,
                                        shadows: [
                                          Shadow(
                                            offset: const Offset(0, 2),
                                            blurRadius: 4.0,
                                            color: Colors.black.withOpacity(0.2),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // Loading indicator with animation
                      AnimatedBuilder(
                        animation: _fadeController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 50),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white.withOpacity(0.7),
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Loading...',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.7),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Import the onboarding screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController pageController = PageController();
  int currentPage = 0;

  final List<OnboardingData> onboardingPages = [
    OnboardingData(
      title: 'Endless Visual Ideas',
      description: 'Explore stunning photos, art,\nand designs tailored to your interests.',
      image: 'assets/images/object1.png',
    ),
    OnboardingData(
      title: 'Save & Organize',
      description: 'Pin your favorite visuals, build boards, and\nkeep inspiration at your fingertips.',
      image: 'assets/images/object 2.png',
    ),
    OnboardingData(
      title: 'Build Your Collection',
      description: 'Save favorites, create boards, and\norganize inspiration into one.',
      image: 'assets/images/object3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Skip Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _navigateToLogin();
                      },
                      child: Text(
                        'Skip',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Page View
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemCount: onboardingPages.length,
                  itemBuilder: (context, index) {
                    return OnboardingPageWidget(
                      data: onboardingPages[index],
                    );
                  },
                ),
              ),
              // Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingPages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Next/Done Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    // Back Button
                    if (currentPage > 0)
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Back',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(width: 16),
                    
                    // Next/Start Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (currentPage == onboardingPages.length - 1) {
                            // Last page - go to login
                            _navigateToLogin();
                          } else {
                            // Next page
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentPage == onboardingPages.length - 1 ? 'Start' : 'Next',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (currentPage < onboardingPages.length - 1) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLogin() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.completeOnboarding();
    
    // Navigate to login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPageWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circle background with object image
          Container(
            width: screenWidth * 0.6,
            height: screenWidth * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(data.image),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            data.title,
            style: GoogleFonts.raleway(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            data.description,
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
  });
}