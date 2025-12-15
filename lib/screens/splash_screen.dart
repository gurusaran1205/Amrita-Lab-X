import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/colors.dart';
import 'login_screen.dart';
import 'my_bookings_screen.dart'; // Or Home/Dashboard if you have one

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for BOTH the animation time (3s) AND the auth check
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 3)), // Minimum splash time
      authProvider.tryAutoLogin(), // Actual auth check
    ]);

    // results[1] is the return value of tryAutoLogin (bool)
    final bool isLoggedIn = results[1] as bool;

    if (!mounted) return;

    if (isLoggedIn) {
       Navigator.of(context).pushReplacementNamed('/main_navigation');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryMaroon,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle, // Circular shape
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval( // Clip image to circle
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Column(
                children: [
                   Text(
                    'AmritaULABS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                   SizedBox(height: 8),
                   Text(
                    'University Lab Booking System',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
