import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 7), () {
      Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1CB),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Supaya tidak full tinggi layar
          children: [
            Image.asset(
              'asset/images/splash_logo.jpg', // Logo utama
              width: 250,
            ),
            const SizedBox(height: 20), // Jarak antara logo dan teks
            Image.asset(
              'asset/images/teks_splash.png', // Proudly Present
              width: 200, // Sesuaikan ukuran jika perlu
            ),
          ],
        ),
      ),
    );
  }
}
