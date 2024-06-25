import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1_rentals/providers/theme_provider.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/l10n/locale_provider.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/widgets/square_tile.dart';

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
  String _errorMessage = '';

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isAuthenticating = true;
          _errorMessage = ''; // Clear previous error messages
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
        setState(() {
          _errorMessage = "Incorrect login credentials";
        });
      } finally {
        if (mounted) {
          setState(() {
            _isAuthenticating = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required TextInputType keyboardType,
    required String hintText,
    required IconData? icon,
    required bool obscureText,
    required String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        obscureText: obscureText,
        style: TextStyle(
          color: Colors.grey,
        ),
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                )
              : null,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            themeProvider.themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            themeProvider.setThemeMode(
              themeProvider.themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark,
            );
          },
        ),
        title: Text(
          S.of(context).login,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50),
              SizedBox(
                height: 150,
                child: Image.asset('assets/images/v1-rentals-logo.png'),
              ),
              SizedBox(height: 20),
              Text(
                S.of(context).welcome,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
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
                          _buildTextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            hintText: S.of(context).email,
                            icon: Icons.email,
                            obscureText: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).please_enter_your_email;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          _buildTextFormField(
                            controller: _passwordController,
                            keyboardType: TextInputType.text,
                            hintText: S.of(context).password,
                            icon: Icons.lock,
                            obscureText: _obscureText,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).please_enter_your_password;
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: Text(S.of(context).forgot_password),
                              )
                            ],
                          ),
                          if (_errorMessage.isNotEmpty) // Display error message
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                _errorMessage,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          SizedBox(height: 20),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    thickness: 0.5,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Text(
                                    S.of(context).sign_in_method,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    thickness: 0.5,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SquareTile(
                                onTap: () async {
                                  try {
                                    await _authService.signInWithGoogle();
                                    // Navigate to the home screen or show a success message
                                  } catch (e) {
                                    // Handle error (e.g., show a snackbar with error message)
                                    print('Error signing in with Google: $e');
                                  }
                                },
                                imagePath: 'assets/images/google_icon_2.png',
                              ),
                            ],
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
            ],
          ),
        ),
      ),
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
                const SizedBox(width: 4),
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
