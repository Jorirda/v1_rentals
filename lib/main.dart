import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:v1_rentals/auth/auth.dart';
import 'package:v1_rentals/auth/push_notifications.dart';
import 'package:v1_rentals/l10n/locale_provider.dart';
import 'package:v1_rentals/screens/account/account_page.dart';
import 'package:v1_rentals/screens/clients/client_bookings.dart';
import 'package:v1_rentals/screens/clients/favorites_page.dart';
import 'package:v1_rentals/screens/main/home_page.dart';
import 'package:v1_rentals/screens/vendors/fleet_screen.dart';
import 'package:v1_rentals/screens/vendors/vendor_bookings.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:v1_rentals/generated/l10n.dart'; // Correctly import the generated localization file
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load environment variables from the .env file
  await dotenv.load(fileName: ".env");

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await pushNotificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        // Add other providers here if needed
      ],
      child: MyApp(),
    ),
  );
}

// Define a top-level function to handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'V1 Rentals',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 0, 157, 255),
            ),
            useMaterial3: true,
          ),
          locale: localeProvider.locale,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: AuthenticationWrapper(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        physics: NeverScrollableScrollPhysics(),
        children: const [
          HomeScreen(),
          FavoriteScreen(),
          ClientBookings(),
          AccountScreen(),
        ], // Prevent swiping to navigate
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home), label: S.of(context).home),
          BottomNavigationBarItem(
              icon: const Icon(Icons.favorite), label: S.of(context).favorites),
          BottomNavigationBarItem(
              icon: const Icon(Icons.library_books),
              label: S.of(context).bookings),
          BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle),
              label: S.of(context).account),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class VendorMainScreen extends StatefulWidget {
  const VendorMainScreen({super.key});

  @override
  _VendorMainScreenState createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends State<VendorMainScreen> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        physics: NeverScrollableScrollPhysics(),
        children: const [
          HomeScreen(),
          FleetScreen(),
          VendorBookings(),
          AccountScreen(),
        ], // Prevent swiping to navigate
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home), label: S.of(context).home),
          BottomNavigationBarItem(
              icon: const Icon(Icons.car_rental), label: S.of(context).fleet),
          BottomNavigationBarItem(
              icon: const Icon(Icons.library_books),
              label: S.of(context).bookings),
          BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle),
              label: S.of(context).account),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
