import 'package:flutter/material.dart';
import '../models/user.dart'; // CHANGE THIS IMPORT
import '../services/equip_api.dart';
import 'auth_provider.dart';

class UserProvider with ChangeNotifier {
  final AuthProvider authProvider;
  late final ApiService _apiService;

  UserProvider({required this.authProvider}) {
    _apiService = ApiService(token: authProvider.token);
  }

  List<User> _users = []; // UPDATE THE TYPE
  List<User> get users => _users; // UPDATE THE TYPE

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllUsers() async {
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      _errorMessage = "Authentication error: Not logged in.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _apiService.fetchAllUsers();
    } catch (e) {
      _errorMessage = "Failed to load users: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleUserBlockStatus(String userId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUserStatus = await _apiService.toggleUserBlockStatus(userId);

      if (updatedUserStatus != null) {
        // Find the user in the list and update their status using copyWith
        final index = _users.indexWhere((user) => user.id == userId);
        if (index != -1) {
          _users[index] = _users[index].copyWith(isBlocked: updatedUserStatus['isBlocked']);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _errorMessage = "Failed to update user status: $e";
      notifyListeners();
      return false;
    }
  }
}