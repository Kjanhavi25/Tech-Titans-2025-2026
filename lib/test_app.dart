import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'firebase_options.dart';
import 'utils/database_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Initializing Firebase for testing...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('Connected to: ${DefaultFirebaseOptions.currentPlatform.projectId}');

  await DatabaseSeeder.seedTestData();

  print('Test finished.');
}
