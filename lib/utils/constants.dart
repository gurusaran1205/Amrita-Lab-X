/// AmritaULABS App Constants
class AppConstants {
  // App Information
  static const String appName = 'AmritaULABS';
  static const String appVersion = '1.0.0';

  // API Configuration
  // TODO: Replace with your actual API base URL
  static const String baseUrl =
      'http://107.21.163.19'; // Replace with actual URL
  static const String sendOtpEndpoint = '/api/auth/send-otp';
  static const String signupEndpoint = '/api/auth/signup';
  static const String departmentsEndpoint = "/departments";
  static const String labsByDepartmentEndpoint = "/labs"; // /labs/{deptId}
  static const String equipmentsByLabEndpoint = "/equipments";
  static const String forgotPasswordEndpoint = "/api/auth/forgot-password";
  static const String resetPasswordEndpoint = "/api/auth/reset-password";
  // API Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // OTP Configuration
  static const int otpLength = 6;
  static const Duration otpResendTimer = Duration(minutes: 2);
  static const Duration otpValidityDuration = Duration(minutes: 10);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double smallPadding = 8.0;

  static const double defaultRadius = 8.0;
  static const double largeRadius = 12.0;
  static const double buttonRadius = 25.0;

  static const double buttonHeight = 50.0;
  static const double inputHeight = 56.0;

  // Text Sizes
  static const double titleFontSize = 24.0;
  static const double headingFontSize = 20.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;
  static const double smallFontSize = 12.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Validation Constants
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;

  // Error Messages
  static const String networkError =
      'Network error. Please check your connection.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String invalidPassword =
      'Password must be at least 8 characters long.';
  static const String invalidName = 'Please enter your full name.';
  static const String invalidOtp = 'Please enter a valid 6-digit OTP.';
  static const String userNotFound = 'User not found';

  // Success Messages
  static const String otpSent = 'OTP has been sent to your email.';
  static const String signupSuccess = 'Account created successfully!';
  static const String forgotPasswordTitle = "Forgot Password";
  static const String forgotPasswordSubtitle =
      "Enter your email to receive an OTP";
  static const String forgotPasswordOtpSent = "OTP has been sent to your email";

  static const String resetPasswordTitle = "Reset Password";
  static const String resetPasswordSubtitle = "Enter OTP and your new password";
  static const String passwordResetSuccess = "Password reset successful!";

  // Brand Messages
  static const String welcomeMessage = 'Welcome to AmritaULABS';
  static const String signupSubtitle = 'Create your account to get started';
  static const String otpVerificationTitle = 'Verify Your Email';
  static const String otpVerificationSubtitle =
      'Enter the 6-digit code sent to your email';

  // Add these constants to your existing AppConstants class

// API Endpoints (add to existing endpoints)
  static const String loginEndpoint = '/api/auth/login';

// Brand Messages (add to existing messages)
  static const String welcomeBackMessage = 'Welcome Back!';
  static const String loginSubtitle = 'Sign in to your account';
  static const String loginSuccess = 'Login successful!';
  static const String unauthorized = "Unauthorized access";
  static const String unknownError =
      "Something went wrong, please try again later";

// Error Messages (add to existing error messages)
  static const String invalidCredentials = 'Invalid email or password';
  static const String loginFailed = 'Login failed. Please try again.';
}
