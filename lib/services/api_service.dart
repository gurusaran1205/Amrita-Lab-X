import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import '../models/forgot_password_models.dart';
import '../models/booking.dart';
/// API Service class for handling HTTP requests to AmritaULABS backend
class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  // HTTP Client with timeout configuration
  late final http.Client _client;

  /// Initialize API service
  void initialize() {
    _client = http.Client();
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }

  /// Base URL for all API calls
  /// TODO: Replace with your actual API base URL
  static const String _baseUrl = AppConstants.baseUrl;

  /// Common headers for all requests
  Map<String, String> get _headers =>
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Send OTP to user's email
  ///
  /// Endpoint: POST /api/auth/send-otp
  /// Request: { "name": "John Doe", "email": "john@example.com", "password": "password123" }
  /// Response: { "message": "OTP has been sent to your email." }
  Future<ApiResponse<OtpResponse>> sendOtp(SendOtpRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl${AppConstants.sendOtpEndpoint}');

      print('📤 Sending OTP request to: $url');
      print('📤 Request body: ${request.toString()}');

      final response = await _client
          .post(
        url,
        headers: _headers,
        body: jsonEncode(request.toJson()),
      )
          .timeout(AppConstants.connectionTimeout);

      print('📥 Send OTP Response: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return _handleSendOtpResponse(response);
    } on SocketException {
      return ApiResponse.error(
        message: AppConstants.networkError,
        statusCode: 0,
      );
    } on http.ClientException {
      return ApiResponse.error(
        message: AppConstants.networkError,
        statusCode: 0,
      );
    } catch (e) {
      print('❌ Send OTP Error: $e');
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }

  /// Verify OTP and complete signup
  ///
  /// Endpoint: POST /api/auth/signup
  /// Request: { "email": "john@example.com", "otp": "123456" }
  /// Response: { "_id": "...", "name": "John Doe", "email": "john@example.com", "role": "user", "token": "..." }
  Future<ApiResponse<User>> verifyOtpAndSignup(VerifyOtpRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl${AppConstants.signupEndpoint}');

      print('📤 Verifying OTP request to: $url');
      print('📤 Request body: ${request.toString()}');

      final response = await _client
          .post(
        url,
        headers: _headers,
        body: jsonEncode(request.toJson()),
      )
          .timeout(AppConstants.connectionTimeout);

      print('📥 Verify OTP Response: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return _handleSignupResponse(response);
    } on SocketException {
      return ApiResponse.error(
        message: AppConstants.networkError,
        statusCode: 0,
      );
    } on http.ClientException {
      return ApiResponse.error(
        message: AppConstants.networkError,
        statusCode: 0,
      );
    } catch (e) {
      print('❌ Verify OTP Error: $e');
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }

  /// Handle Send OTP API response
  ApiResponse<OtpResponse> _handleSendOtpResponse(http.Response response) {
    final Map<String, dynamic> responseData;

    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return ApiResponse.error(
        message: 'Invalid response format',
        statusCode: response.statusCode,
      );
    }

    switch (response.statusCode) {
      case 200:
      // Success
        final otpResponse = OtpResponse.fromJson(responseData);
        return ApiResponse.success(
          message: otpResponse.message,
          data: otpResponse,
          statusCode: response.statusCode,
        );

      case 400:
      // Bad Request - Missing fields or User exists
        final message = responseData['message'] as String? ?? 'Bad request';
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );

      case 500:
      // Server error
        final message = responseData['message'] as String? ??
            'Server error while sending OTP.';
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );

      default:
        final message =
            responseData['message'] as String? ?? 'Unknown error occurred';
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );
    }
  }

  /// Handle Signup API response
  ApiResponse<User> _handleSignupResponse(http.Response response) {
    final Map<String, dynamic> responseData;

    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return ApiResponse.error(
        message: 'Invalid response format',
        statusCode: response.statusCode,
      );
    }

    switch (response.statusCode) {
      case 201:
      // Success - User created
        try {
          final user = User.fromJson(responseData);
          return ApiResponse.success(
            message: AppConstants.signupSuccess,
            data: user,
            statusCode: response.statusCode,
          );
        } catch (e) {
          return ApiResponse.error(
            message: 'Invalid user data received',
            statusCode: response.statusCode,
          );
        }

      case 400:
      // Bad Request - Invalid OTP or expired
        final message = responseData['message'] as String? ?? 'Invalid OTP';
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );

      case 500:
      // Server error
        final message = responseData['message'] as String? ?? 'Server Error';
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );

      default:
        final message =
            responseData['message'] as String? ?? 'Unknown error occurred';
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );
    }
  }

  ApiResponse<ForgotPasswordResponse> _handleForgotPasswordResponse(
      http.Response response) {
    final Map<String, dynamic> responseData;

    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return ApiResponse.error(
        message: 'Invalid response format',
        statusCode: response.statusCode,
      );
    }

    switch (response.statusCode) {
      case 200:
      // Success - OTP sent
        final forgotPasswordResponse =
        ForgotPasswordResponse.fromJson(responseData);
        return ApiResponse.success(
          message: forgotPasswordResponse.message,
          data: forgotPasswordResponse,
          statusCode: response.statusCode,
        );

      case 404:
      // User not found
        final message =
            responseData['message'] as String? ?? AppConstants.userNotFound;
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );

      case 500:
      // Server error
        final message = responseData['message'] as String? ??
            'Server error while sending OTP.';
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );

      default:
        final message =
            responseData['message'] as String? ?? 'Unknown error occurred';
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );
    }
  }

  ApiResponse<ResetPasswordResponse> _handleResetPasswordResponse(
      http.Response response) {
    final Map<String, dynamic> responseData;

    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return ApiResponse.error(
        message: 'Invalid response format',
        statusCode: response.statusCode,
      );
    }

    switch (response.statusCode) {
      case 200:
      // Success - Password reset
        final resetPasswordResponse =
        ResetPasswordResponse.fromJson(responseData);
        return ApiResponse.success(
          message: resetPasswordResponse.message,
          data: resetPasswordResponse,
          statusCode: response.statusCode,
        );

      case 400:
      // Bad Request - Invalid OTP
        final message = responseData['message'] as String? ?? 'Invalid OTP';
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );

      case 404:
      // User not found
        final message =
            responseData['message'] as String? ?? AppConstants.userNotFound;
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );

      case 500:
      // Server error
        final message = responseData['message'] as String? ?? 'Server Error';
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );

      default:
        final message =
            responseData['message'] as String? ?? 'Unknown error occurred';
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );
    }
  }

  /// Health check endpoint (optional - for testing connectivity)
  Future<bool> healthCheck() async {
    try {
      final url = Uri.parse('$_baseUrl/health');
      final response = await _client
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }

  // Add this method to your existing ApiService class

  /// User Login
  ///
  /// Endpoint: POST /api/auth/login
  /// Request: { "email": "john.doe@example.com", "password": "a-strong-password-123" }
  /// Response: { "_id": "...", "name": "John Doe", "email": "john@example.com", "role": "user", "token": "..." }
  Future<ApiResponse<User>> login(LoginRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl${AppConstants.loginEndpoint}');

      print('📤 Login request to: $url');
      print('📤 Request body: ${request.toString()}');

      final response = await _client
          .post(
        url,
        headers: _headers,
        body: jsonEncode(request.toJson()),
      )
          .timeout(AppConstants.connectionTimeout);

      print('📥 Login Response: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return _handleLoginResponse(response);
    } on SocketException {
      return ApiResponse.error(
        message: AppConstants.networkError,
        statusCode: 0,
      );
    } on http.ClientException {
      return ApiResponse.error(
        message: AppConstants.networkError,
        statusCode: 0,
      );
    } catch (e) {
      print('❌ Login Error: $e');
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }

  /// Handle Login API response
  ApiResponse<User> _handleLoginResponse(http.Response response) {
    final Map<String, dynamic> responseData;

    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return ApiResponse.error(
        message: 'Invalid response format',
        statusCode: response.statusCode,
      );
    }

    switch (response.statusCode) {
      case 200:
      // Success - User logged in
        try {
          final user = User.fromJson(responseData);
          return ApiResponse.success(
            message: AppConstants.loginSuccess,
            data: user,
            statusCode: response.statusCode,
          );
        } catch (e) {
          return ApiResponse.error(
            message: 'Invalid user data received',
            statusCode: response.statusCode,
          );
        }

      case 401:
      // Unauthorized - Invalid credentials
        final message = responseData['message'] as String? ??
            AppConstants.invalidCredentials;
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );

      case 500:
      // Server error
        final message = responseData['message'] as String? ?? 'Server Error';
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );

      default:
        final message =
            responseData['message'] as String? ?? 'Unknown error occurred';
        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );
    }
  }

  /// Fetch all Departments
  Future<ApiResponse<List<dynamic>>> getDepartments() async {
    try {
      final url = Uri.parse('$_baseUrl${AppConstants.departmentsEndpoint}');
      final response = await _client
          .get(url, headers: _headers)
          .timeout(AppConstants.connectionTimeout);

      print("📥 Departments Response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return ApiResponse.success(
          data: data,
          message: "Departments fetched successfully",
          statusCode: 200,
        );
      } else {
        return ApiResponse.error(
          message: "Failed to fetch departments",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print("❌ Departments API Error: $e");
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }

  /// Fetch Labs by Department ID
  Future<ApiResponse<List<dynamic>>> getLabsByDepartment(String deptId) async {
    try {
      final url = Uri.parse(
          '$_baseUrl${AppConstants.labsByDepartmentEndpoint}/$deptId');
      final response = await _client
          .get(url, headers: _headers)
          .timeout(AppConstants.connectionTimeout);

      print("📥 Labs Response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return ApiResponse.success(
          data: data,
          message: "Labs fetched successfully",
          statusCode: 200,
        );
      } else {
        return ApiResponse.error(
          message: "Failed to fetch labs",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print("❌ Labs API Error: $e");
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }

  /// Fetch Equipments by Lab ID
  Future<ApiResponse<List<dynamic>>> getEquipmentsByLab(String labId) async {
    try {
      final url =
      Uri.parse('$_baseUrl${AppConstants.equipmentsByLabEndpoint}/$labId');
      final response = await _client
          .get(url, headers: _headers)
          .timeout(AppConstants.connectionTimeout);

      print("📥 Equipments Response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return ApiResponse.success(
          data: data,
          message: "Equipments fetched successfully",
          statusCode: 200,
        );
      } else {
        return ApiResponse.error(
          message: "Failed to fetch equipments",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print("❌ Equipments API Error: $e");
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<ForgotPasswordResponse>> sendForgotPasswordOtp(
      ForgotPasswordRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl${AppConstants.forgotPasswordEndpoint}');

      print('📤 Forgot Password request to: $url');
      print('📤 Request body: ${request.toString()}');

      final response = await _client
          .post(
        url,
        headers: _headers,
        body: jsonEncode(request.toJson()),
      )
          .timeout(AppConstants.connectionTimeout);

      print('📥 Forgot Password Response: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return _handleForgotPasswordResponse(response);
    } on SocketException {
      return ApiResponse.error(
        message: AppConstants.networkError,
        statusCode: 0,
      );
    } on http.ClientException {
      return ApiResponse.error(
        message: AppConstants.networkError,
        statusCode: 0,
      );
    } catch (e) {
      print('❌ Forgot Password Error: $e');
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }

  /// Reset Password with OTP
  ///
  /// Endpoint: POST /api/auth/reset-password
  /// Request: { "email": "user@example.com", "otp": "123456", "newPassword": "new-password" }
  /// Response: { "message": "Password reset successfully." }
  Future<ApiResponse<ResetPasswordResponse>> resetPassword(
      ResetPasswordRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl${AppConstants.resetPasswordEndpoint}');

      print('📤 Reset Password request to: $url');
      print('📤 Request body: ${request.toString()}');

      final response = await _client
          .post(
        url,
        headers: _headers,
        body: jsonEncode(request.toJson()),
      )
          .timeout(AppConstants.connectionTimeout);

      print('📥 Reset Password Response: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return _handleResetPasswordResponse(response);
    } on SocketException {
      return ApiResponse.error(
        message: AppConstants.networkError,
        statusCode: 0,
      );
    } on http.ClientException {
      return ApiResponse.error(
        message: AppConstants.networkError,
        statusCode: 0,
      );
    } catch (e) {
      print('❌ Reset Password Error: $e');
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }

  Map<String, String> _headersWithAuth(String token) =>
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// Fetch My Bookings
  ///
  /// Endpoint: GET /api/bookings/my-bookings
  /// Authorization: Required (Bearer Token)
  /// Response: Array of booking objects with populated user and equipment
  Future<ApiResponse<List<Booking>>> getMyBookings(String token) async {
    try {
      final url = Uri.parse('$_baseUrl${AppConstants.myBookingsEndpoint}');

      print('📤 Fetching my bookings from: $url');

      final response = await _client
          .get(
        url,
        headers: _headersWithAuth(token),
      )
          .timeout(AppConstants.connectionTimeout);

      print('📥 My Bookings Response: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return _handleMyBookingsResponse(response);
    } on SocketException {
      return ApiResponse.error(
        message: AppConstants.networkError,
        statusCode: 0,
      );
    } on http.ClientException {
      return ApiResponse.error(
        message: AppConstants.networkError,
        statusCode: 0,
      );
    } catch (e) {
      print('❌ My Bookings Error: $e');
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }

  /// Handle My Bookings API response
  ApiResponse<List<Booking>> _handleMyBookingsResponse(http.Response response) {
    try {
      switch (response.statusCode) {
        case 200:
        // Success
          final List<dynamic> responseData = jsonDecode(response.body);
          final bookings = responseData
              .map((json) => Booking.fromJson(json as Map<String, dynamic>))
              .toList();

          return ApiResponse.success(
            message: 'Bookings fetched successfully',
            data: bookings,
            statusCode: response.statusCode,
          );

        case 401:
        // Unauthorized
          return ApiResponse.error(
            message: AppConstants.unauthorized,
            statusCode: response.statusCode,
          );

        case 500:
        // Server error
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          final message = errorData['message'] as String? ?? 'Server Error';
          return ApiResponse.error(
            message: message,
            statusCode: response.statusCode,
          );

        default:
          return ApiResponse.error(
            message: AppConstants.unknownError,
            statusCode: response.statusCode,
          );
      }
    } catch (e) {
      print('❌ Parse My Bookings Error: $e');
      return ApiResponse.error(
        message: 'Invalid response format',
        statusCode: response.statusCode,
      );
    }
  }

  /// Cancel/Update Booking Status
  ///
  /// Endpoint: PUT /api/bookings/:id/status
  /// Authorization: Required (Bearer Token)
  /// Request: { "status": "cancelled" }
  /// Response: Updated booking object
  Future<ApiResponse<Booking>> updateBookingStatus({
    required String token,
    required String bookingId,
    required String status, // 'confirmed' or 'cancelled'
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl${AppConstants
            .updateBookingStatusEndpoint}/$bookingId/status',
      );

      print('📤 Updating booking status: $url');
      print('📤 Request body: {"status": "$status"}');

      final response = await _client
          .put(
        url,
        headers: _headersWithAuth(token),
        body: jsonEncode({'status': status}),
      )
          .timeout(AppConstants.connectionTimeout);

      print('📥 Update Booking Status Response: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return _handleUpdateBookingStatusResponse(response);
    } on SocketException {
      return ApiResponse.error(
        message: AppConstants.networkError,
        statusCode: 0,
      );
    } on http.ClientException {
      return ApiResponse.error(
        message: AppConstants.networkError,
        statusCode: 0,
      );
    } catch (e) {
      print('❌ Update Booking Status Error: $e');
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }

  /// Handle Update Booking Status API response
  ApiResponse<Booking> _handleUpdateBookingStatusResponse(
      http.Response response) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
        // Success
          final booking = Booking.fromJson(responseData);
          return ApiResponse.success(
            message: 'Booking status updated successfully',
            data: booking,
            statusCode: response.statusCode,
          );

        case 400:
        // Bad Request
          final message = responseData['message'] as String? ??
              'Invalid status update';
          return ApiResponse.error(
            message: message,
            statusCode: response.statusCode,
          );

        case 401:
        // Unauthorized
          return ApiResponse.error(
            message: AppConstants.unauthorized,
            statusCode: response.statusCode,
          );

        case 403:
        // Forbidden
          final message = responseData['message'] as String? ?? 'Access denied';
          return ApiResponse.error(
            message: message,
            statusCode: response.statusCode,
          );

        case 404:
        // Not Found
          final message = responseData['message'] as String? ??
              'Booking not found';
          return ApiResponse.error(
            message: message,
            statusCode: response.statusCode,
          );

        default:
          return ApiResponse.error(
            message: AppConstants.unknownError,
            statusCode: response.statusCode,
          );
      }
    } catch (e) {
      print('❌ Parse Update Booking Status Error: $e');
      return ApiResponse.error(
        message: 'Invalid response format',
        statusCode: response.statusCode,
      );
    }
  }

  /// Fetch Bookings by Equipment
  ///
  /// Endpoint: GET /api/bookings/equipment/:equipmentId
  /// Authorization: Required (Bearer Token)
  /// Response: Array of booking objects (simplified)
  Future<ApiResponse<List<Map<String, dynamic>>>> getBookingsByEquipment({
    required String token,
    required String equipmentId,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl${AppConstants.bookingsByEquipmentEndpoint}/$equipmentId',
      );

      print('📤 Fetching bookings by equipment: $url');

      final response = await _client
          .get(
        url,
        headers: _headersWithAuth(token),
      )
          .timeout(AppConstants.connectionTimeout);

      print('📥 Bookings by Equipment Response: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return ApiResponse.success(
          message: 'Bookings fetched successfully',
          data: responseData.cast<Map<String, dynamic>>(),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          message: 'Failed to fetch bookings',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Bookings by Equipment Error: $e');
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }
}
