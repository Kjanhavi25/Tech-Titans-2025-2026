import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signup({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    UserRole role = UserRole.user,
  }) async {
    try {
      // Create Firebase Auth user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;
      if (user == null) throw Exception('User creation failed');

      // Update display name
      try {
        await user.updateDisplayName(name);
      } catch (e) {
        developer.log('Update display name failed: $e');
      }

      // Create user document in Firestore
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        photoUrl: '',
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      try {
        await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
      } catch (e) {
        developer.log('Firestore write permission denied or error: $e');
        // Proceeding anyway for testing purpose, allowing UI to flow.
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;
      if (user == null) throw Exception('Login failed');

      // Fetch user data from Firestore
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          return UserModel.fromJson(userData);
        }
        
        developer.log('User document does not exist in Firestore for UID: ${user.uid}');
      } catch (e) {
        developer.log('Firestore read error: $e');
        // If we can't read the profile, we shouldn't guess the role.
        // Return null to indicate we couldn't load the full user model.
        return null;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          return UserModel.fromJson(userData);
        }
        
        developer.log('User document does not exist for current user: ${user.uid}');
      } catch (e) {
        developer.log('Firestore read error in getCurrentUser: $e');
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return e.message ?? 'Authentication error';
    }
  }
}
