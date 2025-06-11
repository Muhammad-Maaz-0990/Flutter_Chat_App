import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

import 'home_screen.dart';
import 'welcome_screen.dart';
import '../api/apis.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    try {
      await APIs.init();
      _fadeController.forward();
      await Future.delayed(const Duration(seconds: 2));
      await _handleAuthFlow();
    } catch (e) {
      print("Splash initialization error: $e");
      _navigateToNext(false);
    }
  }

  Future<void> _handleAuthFlow() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Biometric/PIN/password check if user is logged in
      bool isAuthenticated = await _authenticateUser();
      if (isAuthenticated) {
        _navigateToNext(true); // Go to HomeScreen
      } else {
        _showAuthFailedDialog();
      }
    } else {
      _navigateToNext(false); // Go to WelcomeScreen
    }
  }

  Future<bool> _authenticateUser() async {
    try {
      bool canCheck = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!canCheck) return false;

      return await auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: false, // allows PIN/password too
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print("Authentication error: $e");
      return false;
    }
  }

  void _navigateToNext(bool isAuthenticated) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isAuthenticated ? const HomeScreen() : const WelcomeScreen(),
      ),
    );
  }

  void _showAuthFailedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Authentication Failed'),
        content: const Text('You need to authenticate to access the app.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToNext(false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Image.asset(
                      'assets/images/default_avatar.jpeg',
                      width: 200,
                      height: 200,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Powered By MS",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
