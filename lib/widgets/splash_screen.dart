import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Image.asset('assets/images/v1-rentals-logo.png'),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(), // Display circular progress indicator
          ],
        ),
      ),
    );
  }
}
