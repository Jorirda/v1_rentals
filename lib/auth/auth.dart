import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1_rentals/auth/auth_page.dart';
import 'package:v1_rentals/main.dart';

// Replace with your main screen

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator or splash screen while checking authentication state
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            // User is logged in, return the main screen
            return MainScreen(); // Replace with your main screen
          } else {
            // User is not logged in, redirect to the login screen
            return const AuthPage();
          }
        }
      },
    );
  }
}
