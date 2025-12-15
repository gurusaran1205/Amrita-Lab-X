import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import '../models/forgot_password_models.dart';

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
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Send OTP to user's email
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

  /// Delete Department by ID
  Future<ApiResponse<bool>> deleteDepartment(String departmentId) async {
    try {
      final url = Uri.parse(
          '$_baseUrl${AppConstants.departmentsEndpoint}/$departmentId');

      print("🗑️ Delete Department API: $url");

      final response = await _client
          .delete(url, headers: _headers)
          .timeout(AppConstants.connectionTimeout);

      print("📥 Delete Response: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: true,
          message: "Department deleted successfully",
          statusCode: 200,
        );
      } else {
        final body = jsonDecode(response.body);
        final message = body["message"] ?? "Failed to delete department";

        return ApiResponse.error(
          message: message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print("❌ Delete Department Error: $e");
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
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

  /// Get pending logout sessions
  Future<ApiResponse<List<dynamic>>> getPendingSessions(String token) async {
    try {
      final url = Uri.parse('$_baseUrl/api/sessions/pending');
      final response = await _client.get(
        url,
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConstants.connectionTimeout);

      print("📥 Pending Sessions Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return ApiResponse.success(
          data: data,
          message: "Pending sessions fetched successfully",
          statusCode: 200,
        );
      } else {
        return ApiResponse.error(
          message: "Failed to fetch pending sessions",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print("❌ Pending Sessions API Error: $e");
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }

  /// Approve logout for a session
  Future<ApiResponse<bool>> approveLogout(String sessionId, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/api/sessions/$sessionId/approve');
      final response = await _client.put(
        url,
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConstants.connectionTimeout);

      print("📥 Approve Logout Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: true,
          message: "Session logout approved successfully",
          statusCode: 200,
        );
      } else {
        final body = jsonDecode(response.body);
        return ApiResponse.error(
          message: body['message'] ?? "Failed to approve logout",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print("❌ Approve Logout API Error: $e");
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }

  /// Reject logout for a session
  Future<ApiResponse<bool>> rejectLogout(String sessionId, String token) async {
    try {
      final url = Uri.parse('$_baseUrl/api/sessions/$sessionId/reject');
      final response = await _client.put(
        url,
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConstants.connectionTimeout);

      print("📥 Reject Logout Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: true,
          message: "Session logout rejected successfully",
          statusCode: 200,
        );
      } else {
        final body = jsonDecode(response.body);
        return ApiResponse.error(
          message: body['message'] ?? "Failed to reject logout",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print("❌ Reject Logout API Error: $e");
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }

  /// Download Report
  /// Returns raw bytes of the file
  Future<ApiResponse<List<int>>> downloadReport(String endpoint, String token) async {
    try {
      // Endpoint provided might be full URL or partial path. 
      // Assuming partial path based on user request "api/reports/..."
      final url = Uri.parse('$_baseUrl$endpoint');
      
      print("📥 Downloading Report from: $url");

      final response = await _client.get(
        url,
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 60)); // Longer timeout for reports

      print("📥 Download Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: response.bodyBytes,
          message: "Report downloaded successfully",
          statusCode: 200,
        );
      } else {
        return ApiResponse.error(
          message: "Failed to download report",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print("❌ Download Report Error: $e");
      return ApiResponse.error(
        message: AppConstants.genericError,
        statusCode: 500,
      );
    }
  }
}
