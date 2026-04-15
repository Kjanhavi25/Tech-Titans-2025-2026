import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class DatabaseSeeder {
  static final AuthService _authService = AuthService();

  static Future<void> seedTestData() async {
    print('Starting database seeding...');

    try {
      // 1. Create a Test User
      try {
        final user = await _authService.signup(
          email: 'testuser@example.com',
          password: 'Password123!',
          name: 'Regular User',
          phoneNumber: '1234567890',
          role: UserRole.user,
        );
        print('Created test user: ${user?.email}');
      } catch (e) {
        print('Error creating user (it might already exist): $e');
      }

      // 2. Create a Test Owner
      try {
        final owner = await _authService.signup(
          email: 'testowner@example.com',
          password: 'Password123!',
          name: 'Shop Owner',
          phoneNumber: '0987654321',
          role: UserRole.owner,
        );
        print('Created test owner: ${owner?.email}');
      } catch (e) {
        print('Error creating owner (it might already exist): $e');
      }

      print('Seeding complete! Check your Firebase Console.');
    } catch (e) {
      print('Seeding failed: $e');
    }
  }
}
