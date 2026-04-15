import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<dynamic>? _authStateSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isOwner => _currentUser?.role == UserRole.owner;

  AuthProvider() {
    _initAuthState();
  }

  void _initAuthState() {
    _authStateSubscription = _authService.authStateChanges.listen((user) async {
      if (user != null) {
        _currentUser = await _authService.getCurrentUser();
      } else {
        _currentUser = null;
      }
      // Check if disposed before notifying listeners in an async callback
      try {
        notifyListeners();
      } catch (e) {
        // Disposed
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    UserRole role = UserRole.user,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserModel? user = await _authService.signup(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
      );

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw Exception('Signup failed');
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserModel? user = await _authService.login(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw Exception('Login failed');
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
