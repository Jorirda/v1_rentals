import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/auth/auth_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

// auth_provider.dart
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.loading;
  CustomUser? _currentUser;
  bool _showLoginPage = true;

  AuthStatus get status => _status;
  CustomUser? get currentUser => _currentUser;
  bool get showLoginPage => _showLoginPage;

  AuthProvider() {
    _authService.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
    } else {
      _status = AuthStatus.loading;
      _currentUser = await _authService.getCurrentUser();
      if (_currentUser != null) {
        print('User type: ${_currentUser!.userType}');
      }
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _authService.signInWithEmailAndPassword(email, password);
  }

  Future<void> signUp(CustomUser user) async {
    await _authService.signUp(user);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void toggleScreens() {
    _showLoginPage = !_showLoginPage;
    notifyListeners();
  }
}
