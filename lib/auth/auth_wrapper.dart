import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/auth/auth_page.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/widgets/splash_screen.dart';
import 'package:v1_rentals/providers/auth_provider.dart';
import 'package:v1_rentals/main.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case AuthStatus.loading:
        return SplashScreen();
      case AuthStatus.authenticated:
        final userType = authProvider.currentUser!.userType;
        print('Authenticated user type: $userType');
        return userType == UserType.vendor
            ? const VendorMainScreen()
            : const MainScreen();
      case AuthStatus.unauthenticated:
      default:
        return const AuthPage();
    }
  }
}
