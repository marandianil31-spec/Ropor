import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController logoController;
  late AnimationController glowController;
  late AnimationController textController;

  late Animation<double> scale;
  late Animation<double> rotation;
  late Animation<double> opacity;
  late Animation<double> glow;
  late Animation<double> textOpacity;

  @override
  void initState() {
    super.initState();

    // Logo animation
    logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    scale = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: logoController,
        curve: Curves.elasticOut,
      ),
    );

    rotation = Tween<double>(
      begin: -0.15,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: logoController,
        curve: Curves.easeOutBack,
      ),
    );

    opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: logoController,
        curve: const Interval(
          0.0,
          0.45,
          curve: Curves.easeIn,
        ),
      ),
    );

    // Glow animation
    glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    glow = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: glowController,
        curve: Curves.easeInOut,
      ),
    );

    // Text animation
    textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: textController,
        curve: Curves.easeIn,
      ),
    );

    logoController.forward();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        glowController.repeat(reverse: true);
        textController.forward();
      }
    });

    // Go to Home
    _startApp();

Future<void> _startApp() async {
  try {
    // Firebase Anonymous Login
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }

    // Splash screen 3 seconds
    await Future.delayed(
      const Duration(seconds: 3),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  } catch (e) {
    debugPrint('Firebase Auth Error: $e');
  }
}

  @override
  void dispose() {
    logoController.dispose();
    glowController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            logoController,
            glowController,
            textController,
          ]),
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Animated Ropor logo
                Opacity(
                  opacity: opacity.value,
                  child: Transform.scale(
                    scale: scale.value,
                    child: Transform.rotate(
                      angle: rotation.value,
                      child: Container(
                        width: 210,
                        height: 210,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(
                                0.45 * glow.value,
                              ),
                              blurRadius: 45,
                              spreadRadius: 8,
                            ),
                          ],
                        ),

                        child: Image.asset(
                          'lib/assets/Ropor_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Ropor text
                Opacity(
                  opacity: textOpacity.value,
                  child: const Text(
                    'Ropor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Opacity(
                  opacity: textOpacity.value,
                  child: const Text(
                    'Talk • Meet • Connect',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // Loading dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(Colors.cyan),
                    const SizedBox(width: 8),
                    _dot(Colors.lime),
                    const SizedBox(width: 8),
                    _dot(Colors.white),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.7),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}
