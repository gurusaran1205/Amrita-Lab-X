import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/api_service.dart';
import 'auth_provider.dart'; // Ensure AuthProvider is imported

class SessionProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  final ApiService _apiService = ApiService();

  List<Session> _pendingSessions = [];
  bool _isLoading = false;
  String? _errorMessage;

  SessionProvider({required this.authProvider});

  List<Session> get pendingSessions => _pendingSessions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> fetchPendingSessions() async {
    _setLoading(true);
    _errorMessage = null;

    final token = authProvider.token;
    if (token == null) {
      _errorMessage = 'Authentication token not found';
      _setLoading(false);
      return false;
    }

    final response = await _apiService.getPendingSessions(token);

    if (response.statusCode == 200 && response.data != null) {
      try {
        final List<dynamic> data = response.data as List<dynamic>;
        _pendingSessions = data.map((json) => Session.fromJson(json)).toList();
        notifyListeners();
        _setLoading(false);
        return true;
      } catch (e) {
        print("❌ Error parsing session data: $e");
        print("❌ Data received: ${response.data}");
        _errorMessage = 'Failed to parse session data: $e';
        _setLoading(false);
        return false;
      }
    } else {
      _errorMessage = response.message;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> approveLogout(String sessionId) async {
    _errorMessage = null;
    // We don't necessarily need full screen loader, but let's notify
    // or we can handle local optimistic update.
    
    final token = authProvider.token;
    if (token == null) {
      _errorMessage = 'Authentication token not found';
      notifyListeners();
      return false;
    }

    final response = await _apiService.approveLogout(sessionId, token);

    if (response.statusCode == 200) {
      // Remove the session from the list locally
      _pendingSessions.removeWhere((session) => session.id == sessionId);
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
