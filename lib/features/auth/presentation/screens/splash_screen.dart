import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/first_launch.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        progress += 0.02;
      });
      if (progress >= 1) {
        timer.cancel();
        _navigateAfterSplash();
      }
    });
  }

  Future<void> _navigateAfterSplash() async {
    final nextRoute = await FirstLaunchService.getInitialRoute();
    if (!mounted) return;
    context.replace(nextRoute);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9), Color(0xFFF9FBE7)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 84, color: Color(0xFF2E7D32)),
            const SizedBox(height: 18),
            const Text(
              'FarmKeeper',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 8),
            const Text('INITIALIZING FIELD SENSORS', style: TextStyle(color: Colors.black54, letterSpacing: 1.2)),
            const SizedBox(height: 36),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 52),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                borderRadius: BorderRadius.circular(12),
                backgroundColor: Colors.green.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
