import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  UserModel? _user;
  UserRole _selectedRegisterRole = UserRole.client;
  UserRole _selectedLoginRole = UserRole.client;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  UserRole get selectedRegisterRole => _selectedRegisterRole;
  UserRole get selectedLoginRole => _selectedLoginRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  void setSelectedRegisterRole(UserRole role) {
    _selectedRegisterRole = role;
    notifyListeners();
  }

  void setSelectedLoginRole(UserRole role) {
    _selectedLoginRole = role;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signInWithEmail(
        email: email,
        password: password,
        selectedRole: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle({required UserRole role}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserModel? res = await _authService.signInWithGoogle(role: role);
      if (res != null) {
        _user = res;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> savePreferences({
    required double minBudget,
    required double maxBudget,
    required String preferredLocation,
  }) async {
    if (_user == null) return;
    _user = _user!.copyWith(
      minBudget: minBudget,
      maxBudget: maxBudget,
      preferredLocation: preferredLocation,
    );
    await _dbService.updateUserPreferences(
      uid: _user!.uid,
      minBudget: minBudget,
      maxBudget: maxBudget,
      preferredLocation: preferredLocation,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
