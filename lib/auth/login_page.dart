import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/l10n/locale_provider.dart';
import 'package:v1_rentals/generated/l10n.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen(this.showSignUp, {super.key});

  final VoidCallback showSignUp;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  var _isAuthenticating = false;
  bool _obscureText = true;

  final AssetImage _backgroundImage =
      AssetImage('assets/images/car-rental-bg3.jpg');

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isAuthenticating = true;
        });

        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String userId = userCredential.user!.uid;

        // Retrieve FCM token and update it in Firestore
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _authService.updateFcmToken(userId, token);
        }

        // Navigate to the appropriate screen after successful login
        // You can navigate to the main screen or any other screen here
      } catch (e) {
        // Handle login errors
        print("Error logging in: $e");
      } finally {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    precacheImage(_backgroundImage, context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).login,
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(
              Icons.language,
              color: Colors.blue,
            ),
            onSelected: (Locale locale) {
              localeProvider.setLocale(locale);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: const Locale('en'),
                  child: Text(S.of(context).english),
                ),
                PopupMenuItem(
                  value: const Locale('zh'),
                  child: Text(S.of(context).chinese),
                ),
              ];
            },
          ),
        ],
      ),
      body: Stack(children: [
        // Background image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _backgroundImage,
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: Image.asset('assets/images/v1-rentals-logo.png'),
              ),
              SizedBox(
                height: 200,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email TextField
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                border: Border.all(
                                    color: Colors.black.withOpacity(1)),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: S.of(context).email,
                                    border: InputBorder.none,
                                    icon: Icon(
                                      Icons.email,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return S
                                          .of(context)
                                          .please_enter_your_email;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Password TextField
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                border: Border.all(
                                    color: Colors.black.withOpacity(1)),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscureText,
                                      decoration: InputDecoration(
                                        hintText: S.of(context).password,
                                        border: InputBorder.none,
                                        icon: Icon(
                                          Icons.password_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return S
                                              .of(context)
                                              .please_enter_your_password;
                                        }
                                        return null;
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ]),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(S.of(context).login),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).not_a_member,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 4,
                ),
                // Switch to Sign Up page
                GestureDetector(
                  onTap: widget.showSignUp,
                  child: Text(
                    S.of(context).register_now,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
