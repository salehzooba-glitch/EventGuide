import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/errors.dart';

class UserProvider extends ChangeNotifier {
  final AuthService authService;

  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  UserProvider({required this.authService});

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;

  // Check auth state on app start
  Future<void> checkAuthState() async {
    _isLoading = true;
    notifyListeners();

    if (authService.currentUser != null) {
      final result = await authService.getCurrentUserData();
      if (result is Success<UserModel>) {
        _user = result.data;
        _isLoggedIn = true;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Sign In
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await authService.signIn(email: email, password: password);

    if (result is Success<UserModel>) {
      _user = result.data;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result is Failure<UserModel>) {
      _error = result.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Sign Up
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await authService.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );

    if (result is Success<UserModel>) {
      _user = result.data;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result is Failure<UserModel>) {
      _error = result.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Sign Out
  Future<void> signOut() async {
    await authService.signOut();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // Update Profile
  Future<bool> updateProfile({
    String? fullName,
    String? profileImage,
    List<String>? interests,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await authService.updateProfile(
      fullName: fullName,
      profileImage: profileImage,
      interests: interests,
    );

    if (result is Success<UserModel>) {
      _user = result.data;
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result is Failure<UserModel>) {
      _error = result.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
