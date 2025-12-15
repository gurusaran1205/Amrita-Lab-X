import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/department.dart';
import '../models/api_response.dart';
import '../models/forgot_password_models.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Authentication Provider using Provider state management
/// Handles user authentication, OTP verification, forgot password, and user session
class AuthProvider with ChangeNotifier {
  // Private fields
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  // OTP related fields
  String? _pendingEmail;
  String? _pendingName;
  String? _pendingPassword;
  String? _pendingDepartment;
  DateTime? _otpSentAt;

  // Forgot password related fields
  String? _forgotPasswordEmail;
  DateTime? _forgotPasswordOtpSentAt;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading =>
      _state == AuthState.loading || _state == AuthState.otpVerifying;
  bool get isAuthenticated =>
      _state == AuthState.authenticated && _user != null;
  bool get isOtpSent => _state == AuthState.otpSent;
  String? get pendingEmail => _pendingEmail;
  DateTime? get otpSentAt => _otpSentAt;
  String? get forgotPasswordEmail => _forgotPasswordEmail;
  String? get token => _user?.token;

  /// Initialize the auth provider
  AuthProvider() {
    _apiService.initialize();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  /// Send OTP to user's email for signup
  ///
  /// This is the first step in the signup process
  Future<bool> sendOtp({
    required String name,
    required String email,
    required String password,
    required String department,
  }) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      final request = SendOtpRequest(
        name: name,
        email: email,
        password: password,
        department: department,
      );

      final response = await _apiService.sendOtp(request);

      if (response.success) {
        // Store pending signup data
        _pendingName = name;
        _pendingEmail = email;
        _pendingPassword = password;
        _pendingDepartment = department;
        _otpSentAt = DateTime.now();

        _setState(AuthState.otpSent);

        debugPrint('✅ OTP sent successfully to: $email');
        return true;
      } else {
        _setError(response.message);
        _setState(AuthState.error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Send OTP failed: $e');
      _setError(AppConstants.genericError);
      _setState(AuthState.error);
      return false;
    }
  }

  /// Verify OTP and complete the signup process
  ///
  /// This is the second step that creates the user account
  Future<bool> verifyOtpAndSignup({
    required String otp,
  }) async {
    try {
      if (_pendingEmail == null) {
        _setError('No pending signup found. Please start over.');
        _setState(AuthState.error);
        return false;
      }

      _setState(AuthState.otpVerifying);
      _clearError();

      final request = VerifyOtpRequest(
        email: _pendingEmail!,
        otp: otp,
      );

      final response = await _apiService.verifyOtpAndSignup(request);

      if (response.success && response.data != null) {
        _user = response.data;
        _setState(AuthState.authenticated);

        // Clear pending data
        _clearPendingData();

        // Save user to local storage
        await _saveUserToStorage(_user!);

        debugPrint('✅ User signed up successfully: ${_user!.email}');
        return true;
      } else {
        _setError(response.message);
        _setState(AuthState.error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ OTP verification failed: $e');
      _setError(AppConstants.genericError);
      _setState(AuthState.error);
      return false;
    }
  }

  /// Login user with email and password
  ///
  /// This handles the login process and stores the user data
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      final request = LoginRequest(
        email: email,
        password: password,
      );

      final response = await _apiService.login(request);

      if (response.success && response.data != null) {
        _user = response.data;
        _setState(AuthState.authenticated);

        // Save user to local storage
        await _saveUserToStorage(_user!);

        debugPrint('✅ User logged in successfully: ${_user!.email}');
        return true;
      } else {
        _setError(response.message);
        _setState(AuthState.error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Login failed: $e');
      _setError(AppConstants.loginFailed);
      _setState(AuthState.error);
      return false;
    }
  }

  /// Send Forgot Password OTP
  ///
  /// This sends an OTP to the user's email for password reset
  Future<bool> sendForgotPasswordOtp({
    required String email,
  }) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      final request = ForgotPasswordRequest(
        email: email,
      );

      final response = await _apiService.sendForgotPasswordOtp(request);

      if (response.success) {
        // Store forgot password email
        _forgotPasswordEmail = email;
        _forgotPasswordOtpSentAt = DateTime.now();

        _setState(AuthState.initial);

        debugPrint('✅ Forgot password OTP sent successfully to: $email');
        return true;
      } else {
        _setError(response.message);
        _setState(AuthState.error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Send forgot password OTP failed: $e');
      _setError(AppConstants.genericError);
      _setState(AuthState.error);
      return false;
    }
  }

  /// Reset Password with OTP
  ///
  /// This resets the user's password using the OTP
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      final request = ResetPasswordRequest(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      final response = await _apiService.resetPassword(request);

      if (response.success) {
        // Clear forgot password data
        _clearForgotPasswordData();
        _setState(AuthState.initial);

        debugPrint('✅ Password reset successfully for: $email');
        return true;
      } else {
        _setError(response.message);
        _setState(AuthState.error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Reset password failed: $e');
      _setError(AppConstants.genericError);
      _setState(AuthState.error);
      return false;
    }
  }

  /// Resend OTP to the pending email
  Future<bool> resendOtp() async {
    if (_pendingName == null ||
        _pendingEmail == null ||
        _pendingPassword == null ||
        _pendingDepartment == null) {
      _setError('No pending signup found. Please start over.');
      return false;
    }

    return await sendOtp(
      name: _pendingName!,
      email: _pendingEmail!,
      password: _pendingPassword!,
      department: _pendingDepartment!,
    );
  }

  /// Check if OTP can be resent (based on timer)
  bool canResendOtp() {
    if (_otpSentAt == null) return false;

    final timeSinceOtpSent = DateTime.now().difference(_otpSentAt!);
    return timeSinceOtpSent >= AppConstants.otpResendTimer;
  }

  /// Get remaining time before OTP can be resent
  Duration? getRemainingResendTime() {
    if (_otpSentAt == null) return null;

    final timeSinceOtpSent = DateTime.now().difference(_otpSentAt!);
    final remainingTime = AppConstants.otpResendTimer - timeSinceOtpSent;

    return remainingTime.isNegative ? null : remainingTime;
  }

  /// Check if forgot password OTP can be resent
  bool canResendForgotPasswordOtp() {
    if (_forgotPasswordOtpSentAt == null) return false;

    final timeSinceOtpSent =
        DateTime.now().difference(_forgotPasswordOtpSentAt!);
    return timeSinceOtpSent >= AppConstants.otpResendTimer;
  }

  /// Logout user and clear all data
  Future<void> logout() async {
    _user = null;
    _clearPendingData();
    _clearForgotPasswordData();
    _setState(AuthState.initial);
    await _clearUserFromStorage();
    debugPrint('✅ User logged out successfully');
  }

  /// Delete a department by ID
  Future<Map<String, dynamic>?> deleteDepartment(String departmentId) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      final response = await _apiService.deleteDepartment(departmentId);

      if (response.success) {
        _setState(AuthState.initial);
        return {
          "success": true,
          "message": response.message,
        };
      } else {
        _setError(response.message);
        _setState(AuthState.error);
        return {
          "success": false,
          "message": response.message,
        };
      }
    } catch (e) {
      debugPrint("❌ Delete department failed: $e");
      _setError("Failed to delete department");
      _setState(AuthState.error);

      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  /// Fetch list of departments for signup
  Future<List<Department>> getDepartments() async {
    try {
      final response = await _apiService.getDepartments();
      if (response.success && response.data != null) {
        return (response.data as List)
            .map((item) => Department.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Failed to fetch departments: $e');
      return [];
    }
  }

  /// Clear any error messages
  void clearError() {
    _clearError();
    if (_state == AuthState.error) {
      _setState(AuthState.initial);
    }
  }

  /// Reset to initial state (for navigation back)
  void resetToInitial() {
    if (_state != AuthState.authenticated) {
      _setState(AuthState.initial);
      _clearError();
    }
  }

  /// Clear pending signup data
  void clearPendingData() {
    _clearPendingData();
    if (_state == AuthState.otpSent) {
      _setState(AuthState.initial);
    }
  }

  /// Clear forgot password data
  void clearForgotPasswordData() {
    _clearForgotPasswordData();
  }

  // Private helper methods

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _clearPendingData() {
    _pendingName = null;
    _pendingEmail = null;
    _pendingPassword = null;
    _pendingDepartment = null;
    _otpSentAt = null;
  }

  void _clearForgotPasswordData() {
    _forgotPasswordEmail = null;
    _forgotPasswordOtpSentAt = null;
  }


  /// Try to auto-login from local storage
  /// Returns true if valid token exists and is not expired, false otherwise
  Future<bool> tryAutoLogin() async {
    await _loadUserFromStorage();
    
    // Check if user and token exist
    if (_user == null || _user!.token == null) {
      _setState(AuthState.initial);
      return false;
    }

    final token = _user!.token!;
    
    // Check if token is expired
    bool isExpired = true;
    try {
      isExpired = JwtDecoder.isExpired(token);
    } catch (e) {
      debugPrint('❌ Error decoding token: $e');
      isExpired = true; // Assume expired on error
    }

    if (isExpired) {
      debugPrint('⚠️ Token expired, logging out...');
      await logout(); // Clear storage and state
      return false;
    }

    // Token is valid
    _setState(AuthState.authenticated);
    return true;
  }

  /// Save user data to local storage
  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));
      if (user.token != null) {
        await prefs.setString('auth_token', user.token!);
      }
    } catch (e) {
      debugPrint('❌ Failed to save user to storage: $e');
    }
  }

  /// Load user data from local storage
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      final authToken = prefs.getString('auth_token');

      if (userDataString != null && authToken != null) {
        final userData = jsonDecode(userDataString);
        _user = User.fromJson(userData);
        // State update moved to tryAutoLogin
        debugPrint('✅ User loaded from storage: ${_user!.email}');
      }
    } catch (e) {
      debugPrint('❌ Failed to load user from storage: $e');
    }
  }

  /// Clear user data from local storage
  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.remove('auth_token');
    } catch (e) {
      debugPrint('❌ Failed to clear user from storage: $e');
    }
  }
}
