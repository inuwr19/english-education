import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image full screen
          Image.asset(
            'asset/images/welcome_bg.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'asset/images/welcome_title.png',
                ), // teks "Madrasah An-Nahl"
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('asset/images/welcome_kid_left.png', width: 80),
                    const SizedBox(width: 100),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/input-name');
                      },
                      child: Image.asset(
                        'asset/images/welcome_play_button.png',
                        width: 100,
                      ),
                    ),
                    const SizedBox(width: 100),
                    Image.asset(
                      'asset/images/welcome_kid_right.png',
                      width: 80,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
