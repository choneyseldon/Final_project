import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../auth/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
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
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
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
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Text(
                                'Looma',
                                style: GoogleFonts.raleway(
                                  fontSize: screenWidth > 600 ? 64 : 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            // Spacing
                            SizedBox(height: screenHeight * 0.03),
                            
                            // Horizontal line
                            SlideTransition(
                              position: _slideAnimation,
                              child: Container(
                                width: screenWidth * 0.4,
                                height: 1,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                            
                            // Spacing
                            SizedBox(height: screenHeight * 0.03),
                            
                            // Subtitle with slide animation
                            SlideTransition(
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
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Get Started Button with slide animation
                      SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _navigateToOnboarding();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF6A4C93),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'Get Started',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

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
      description: 'Explore stunning photos, art, and designs tailored to your interests.',
      image: 'assets/images/object1.png',
    ),
    OnboardingData(
      title: 'Save & Organize',
      description: 'Pin your favorite visuals, build boards, and keep inspiration at your fingertips.',
      image: 'assets/images/object 2.png',
    ),
    OnboardingData(
      title: 'Build Your Collection',
      description: 'Save favorites, create boards, and organize inspiration your way.',
      image: 'assets/images/object3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with purple circle
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top Skip Button
                Padding(
                  padding: const EdgeInsets.all(20),
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
                            color: Colors.black54,
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
                // Page Indicator and Navigation
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
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
                                  ? const Color(0xFF6A59D0)
                                  : Colors.grey.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Navigation Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back Button (only show if not first page)
                          if (currentPage > 0)
                            IconButton(
                              onPressed: () {
                                pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xFF6A59D0),
                              ),
                            )
                          else
                            const SizedBox(width: 48),
                          // Next/Start Button
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A59D0), Color(0xFF8B7FD8)],
                              ),
                            ),
                            child: currentPage == onboardingPages.length - 1
                                ? ElevatedButton(
                                    onPressed: () {
                                      _navigateToLogin();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Text(
                                      'Start',
                                      style: GoogleFonts.nunito(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    onPressed: () {
                                      pageController.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    icon: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF6A59D0),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    context.read<AppProvider>().completeOnboarding();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration/Image with circular background
          SizedBox(
            height: 400,
            width: 400,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none, // Allow overflow
              children: [
                // Background circle with gradient (matching the UI)
                Container(
                  height: 280,
                  width: 280,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF9B8CE8),
                        Color(0xFF7A6AD8),
                        Color(0xFF6A59D0),
                      ],
                    ),
                  ),
                ),
                // Object image - significantly bigger with no scaling down
                SizedBox(
                  height: 400,
                  width: 380,
                  child: Transform.scale(
                    scale: 6, // Make it 50% bigger than normal
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(data.image),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Title
          Text(
            data.title,
            style: GoogleFonts.raleway(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              data.description,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
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