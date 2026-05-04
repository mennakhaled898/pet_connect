import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// FIX 5: Import both screens so we can route based on auth state
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // FIX 5: Route to HomeScreen if already logged in, otherwise LoginScreen
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              user != null ? const HomeScreen() : const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFFD7EBE5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7CB6A5).withValues(alpha: 0.04),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.pets, size: 80, color: Color(0xFF7CB6A5)),
            ),
            const SizedBox(height: 24),
            const Text(
              "PetConnect",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Find your forever friend",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFE57373),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 60),
            const SizedBox(
              width: 50,
              child: LinearProgressIndicator(
                backgroundColor: Color(0xFFFDE8EA),
                color: Color(0xFF7CB6A5),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
