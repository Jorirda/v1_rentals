import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseApp extends Mock implements FirebaseApp {
  @override
  String get name => 'MockApp';

  @override
  FirebaseOptions get options => const FirebaseOptions(
        apiKey: 'test_api_key',
        appId: 'test_app_id',
        messagingSenderId: 'test_messaging_sender_id',
        projectId: 'test_project_id',
      );
}
