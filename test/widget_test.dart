import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:v1_rentals/main.dart';
import 'package:v1_rentals/firebase_options.dart';
import 'package:v1_rentals/providers/account_provider.dart';
import 'package:v1_rentals/providers/auth_provider.dart';
import 'package:v1_rentals/providers/booking_provider.dart';
import 'package:v1_rentals/providers/email_provider.dart';
import 'package:v1_rentals/providers/favorites_provider.dart';
import 'package:v1_rentals/providers/location_provider.dart';
import 'package:v1_rentals/providers/notification_provider.dart';
import 'package:v1_rentals/providers/payment_provider.dart';
import 'package:v1_rentals/l10n/locale_provider.dart';

void main() {
  setUpAll(() async {
    // Initialize Firebase
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => AccountDataProvider()),
          ChangeNotifierProvider(create: (_) => PaymentProvider()),
          ChangeNotifierProvider(create: (_) => BookingProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
            create: (context) => NotificationProvider(),
            update: (context, authProvider, notificationProvider) {
              notificationProvider
                  ?.updateUserId(authProvider.currentUser?.userId);
              return notificationProvider!;
            },
          ),
          ChangeNotifierProvider(create: (_) => EmailProvider()),
          ChangeNotifierProxyProvider<AuthProvider, LocationProvider>(
            create: (context) =>
                LocationProvider(context.read<AuthProvider>().currentUser),
            update: (context, authProvider, locationProvider) {
              locationProvider?.updateUser(authProvider.currentUser);
              return locationProvider!;
            },
          ),
        ],
        child: MyApp(),
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
