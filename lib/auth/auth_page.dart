import 'package:flutter/material.dart';
import 'package:v1_rentals/screens/login_page.dart';
import 'package:v1_rentals/screens/signup_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginScreen(toggleScreens);
    } else {
      return SignUpScreen(toggleScreens);
    }
  }
}
