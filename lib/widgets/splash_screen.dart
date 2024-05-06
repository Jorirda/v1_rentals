import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              child: Image.asset('assets/images/v1-rentals-logo.png'),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(), // Display circular progress indicator
          ],
        ),
      ),
    );
  }
}
