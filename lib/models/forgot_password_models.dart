/// Forgot Password request model
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
      };

  @override
  String toString() => 'ForgotPasswordRequest(email: $email)';
}

/// Forgot Password response model
class ForgotPasswordResponse {
  final bool success;
  final String message;

  const ForgotPasswordResponse({
    required this.success,
    required this.message,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] as String? ?? 'OTP has been sent to your email.',
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
      };

  @override
  String toString() => 'ForgotPasswordResponse(message: $message)';
}

/// Reset Password request model
class ResetPasswordRequest {
  final String email;
  final String otp;
  final String newPassword;

  const ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      };

  @override
  String toString() =>
      'ResetPasswordRequest(email: $email, otp: $otp, newPassword: [HIDDEN])';
}

/// Reset Password response model
class ResetPasswordResponse {
  final String message;

  const ResetPasswordResponse({
    required this.message,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      message: json['message'] as String? ?? 'Password reset successfully.',
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
      };

  @override
  String toString() => 'ResetPasswordResponse(message: $message)';
}
