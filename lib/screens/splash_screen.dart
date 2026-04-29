import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recipe_bloc.dart';
import '../services/location_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  final LocationService _locationService = LocationService();
  String? _currentArea;
  String? _suggestedCategory;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );
    
    _animationController.forward();
    
    // Initialize app data
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Get location and time context
    await _getLocationContext();
    _suggestedCategory = _getTimeBasedCategory();
    
    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 2500));
    
    // Navigate to home with context data
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            initialArea: _currentArea,
            suggestedCategory: _suggestedCategory,
          ),
        ),
      );
    }
  }

  Future<void> _getLocationContext() async {
    final hasPermission = await _locationService.requestPermission();
    if (hasPermission && mounted) {
      final position = await _locationService.getCurrentPosition();
      if (position != null && mounted) {
        final country = await _locationService.getCountryFromPosition(position);
        if (country != null && mounted) {
          setState(() {
            _currentArea = _mapCountryToArea(country);
          });
        }
      }
    }
  }

  String _getTimeBasedCategory() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return 'Breakfast';
    if (hour >= 12 && hour < 17) return 'Lunch';
    return 'Dinner';
  }

  String _mapCountryToArea(String country) {
    final countryToArea = {
      'United States': 'American',
      'United Kingdom': 'British',
      'Canada': 'Canadian',
      'Italy': 'Italian',
      'Mexico': 'Mexican',
      'India': 'Indian',
      'China': 'Chinese',
      'Japan': 'Japanese',
      'Korea': 'Korean',
      'France': 'French',
      'Germany': 'German',
      'Spain': 'Spanish',
      'Greece': 'Greek',
      'Thailand': 'Thai',
      'Vietnam': 'Vietnamese',
      'Turkey': 'Turkish',
      'Russia': 'Russian',
      'Australia': 'Australian',
      'Brazil': 'Brazilian',
    };
    return countryToArea[country] ?? 'International';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade700,
              Colors.deepPurple.shade500,
              Colors.purple.shade400,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background circles
              ..._buildAnimatedBackground(),
              
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo Container (using Icon, no asset needed)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.9),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            size: 70,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // App Name with Slide Animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white70,
                                Colors.white,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'Recipe Discovery',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Context-Aware Recipe Finder',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Loading Indicator with Message
                    Column(
                      children: [
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Text(
                              _getLoadingMessage(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Version text at bottom
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedBackground() {
    return [
      // Animated circle 1
      Positioned(
        top: -50,
        right: -50,
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 2000),
          builder: (context, value, child) {
            return Container(
              width: 200 * value,
              height: 200 * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      
      // Animated circle 2
      Positioned(
        bottom: -50,
        left: -50,
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 2500),
          builder: (context, value, child) {
            return Container(
              width: 180 * value,
              height: 180 * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purple.withOpacity(0.2),
                    Colors.purple.withOpacity(0.0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      
      // Animated circle 3
      Positioned(
        top: MediaQuery.of(context).size.height / 3,
        left: -30,
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 3000),
          builder: (context, value, child) {
            return Container(
              width: 120 * value,
              height: 120 * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  String _getLoadingMessage() {
    final messages = [
      '🍳 Finding delicious recipes...',
      '📍 Checking your location...',
      '⏰ Personalizing suggestions...',
      '🌟 Discovering local cuisine...',
      '🍽️ Almost ready...',
    ];
    
    // Cycle through messages based on animation progress
    int index = (_animationController.value * messages.length).floor();
    index = index.clamp(0, messages.length - 1);
    return messages[index];
  }
}