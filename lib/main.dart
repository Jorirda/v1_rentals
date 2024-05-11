import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:v1_rentals/auth/auth.dart';
import 'package:v1_rentals/screens/account/account_page.dart';
import 'package:v1_rentals/screens/clients/client_bookings.dart';
import 'package:v1_rentals/screens/clients/favorites_page.dart';
import 'package:v1_rentals/screens/main/home_page.dart';
import 'package:v1_rentals/screens/main/search_page.dart';
import 'package:v1_rentals/screens/vendors/fleet_screen.dart';
import 'package:v1_rentals/screens/vendors/vendor_bookings.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 157, 255)),
        useMaterial3: true,
      ),
      home: const AuthenticationWrapper(),
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
        children: const [
          HomeScreen(),
          FavoriteScreen(),
          ClientBookings(),
          AccountScreen(),
        ],
        physics: NeverScrollableScrollPhysics(), // Prevent swiping to navigate
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books), label: 'Bookings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Account'),
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
        children: const [
          HomeScreen(),
          FleetScreen(),
          VendorBookings(),
          AccountScreen(),
        ],
        physics: NeverScrollableScrollPhysics(), // Prevent swiping to navigate
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.car_rental), label: 'Fleet'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books), label: 'Bookings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Account'),
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
