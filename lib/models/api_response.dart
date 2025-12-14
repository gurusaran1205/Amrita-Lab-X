/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.errors,
  });

  /// Create successful response
  factory ApiResponse.success({
    required String message,
    T? data,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  /// Create error response
  factory ApiResponse.error({
    required String message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, statusCode: $statusCode}';
  }
}

/// Send OTP Request model
class SendOtpRequest {
  final String name;
  final String email;
  final String password;
  final String department;

  const SendOtpRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.department,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'department': department,
    };
  }

  @override
  String toString() {
    return 'SendOtpRequest{name: $name, email: $email, department: $department}'; // Don't log password
  }
}

/// Verify OTP Request model
class VerifyOtpRequest {
  final String email;
  final String otp;

  const VerifyOtpRequest({
    required this.email,
    required this.otp,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }

  @override
  String toString() {
    return 'VerifyOtpRequest{email: $email, otp: $otp}';
  }
}

/// OTP Response model (for send OTP response)
class OtpResponse {
  final String message;
  final bool success;
  final DateTime? expiresAt;

  const OtpResponse({
    required this.message,
    this.success = true,
    this.expiresAt,
  });

  /// Create from JSON response
  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      message: json['message'] as String? ?? '',
      success: json['success'] as bool? ?? true,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'OtpResponse{message: $message, success: $success}';
  }
}

/// Auth State enum for better state management
enum AuthState {
  initial,
  loading,
  otpSent,
  otpVerifying,
  authenticated,
  error,
}

/// Auth Error types for better error handling
class AuthError {
  final String message;
  final AuthErrorType type;
  final int? statusCode;

  const AuthError({
    required this.message,
    required this.type,
    this.statusCode,
  });

  @override
  String toString() {
    return 'AuthError{message: $message, type: $type, statusCode: $statusCode}';
  }
}

enum AuthErrorType {
  network,
  server,
  validation,
  userExists,
  invalidOtp,
  otpExpired,
  unknown,
}

// Add these classes to your existing models/api_response.dart or create a separate file

/// Login Request Model
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };

  @override
  String toString() => 'LoginRequest(email: $email, password: [HIDDEN])';
}