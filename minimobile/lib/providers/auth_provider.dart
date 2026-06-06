import 'package:flutter/material.dart';
import 'package:minimobile/services/auth_service.dart';
import 'package:minimobile/services/storage_service.dart';
import 'package:minimobile/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();

  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await _authService.login(
      email: email,
      password: password,
    );

    if (response.isSuccess && response.data != null) {
      _token = response.data!['access_token'];
      _user = response.data!['user'];
      await _storage.saveToken(_token!);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (e) {
      print('Logout API error: $e');
    } finally {
      await _storage.clear();

      _token = null;
      _user = null;
      _isLoading = false;

      notifyListeners();
    }
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}