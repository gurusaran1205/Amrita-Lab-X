import 'dart:async';
import 'package:amrita_ulabs/models/api_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../providers/auth_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widget.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _currentOtp = '';
  bool _isOtpComplete = false;
  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    final authProvider = context.read<AuthProvider>();
    final remainingTime = authProvider.getRemainingResendTime();

    if (remainingTime != null) {
      _resendCountdown = remainingTime.inSeconds;
      _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            timer.cancel();
          }
        });
      });
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (!_isOtpComplete) {
      _showErrorToast('Please enter the complete OTP');
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.verifyOtpAndSignup(otp: _currentOtp);

    if (success) {
      _showSuccessToast('Account created successfully!');
      _navigateToSuccess();
    } else {
      _showErrorToast(authProvider.errorMessage ?? 'Invalid OTP');
      _clearOtp();
    }
  }

  Future<void> _handleResendOtp() async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.resendOtp();

    if (success) {
      _showSuccessToast('OTP resent to your email!');
      _startResendTimer();
      _clearOtp();
    } else {
      _showErrorToast(authProvider.errorMessage ?? 'Failed to resend OTP');
    }
  }

  void _clearOtp() {
    _otpController.clear();
    setState(() {
      _currentOtp = '';
      _isOtpComplete = false;
    });
  }

  void _navigateToSuccess() {
    Navigator.pushReplacementNamed(context, '/success');
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.success,
      textColor: AppColors.white,
      fontSize: 16.0,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.error,
      textColor: AppColors.white,
      fontSize: 16.0,
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true, // 👈 Prevent overflow when keyboard opens
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return LoadingOverlay(
            isLoading: authProvider.state == AuthState.otpVerifying,
            message: 'Verifying OTP...',
            child: SafeArea( // 👈 Protect from notches/status bar
              child: SingleChildScrollView( // 👈 Makes the whole screen scrollable
                child: Column(
                  children: [
                    // Header with back button
                    AppHeader(
                      subtitle: AppConstants.otpVerificationSubtitle,
                      showBackButton: true,
                      onBackPressed: () {
                        authProvider.clearError();
                        Navigator.pop(context);
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppConstants.largePadding),

                          // Header with icon
                          WelcomeHeader(
                            title: AppConstants.otpVerificationTitle,
                            subtitle:
                            'We sent a 6-digit code to\n${authProvider.pendingEmail ?? 'your email'}',
                            icon: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primaryMaroon.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.email_outlined,
                                size: 40,
                                color: AppColors.primaryMaroon,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppConstants.largePadding * 2),

                          // OTP Input
                          _buildOtpInput(),

                          const SizedBox(height: AppConstants.largePadding),

                          // Error message
                          if (authProvider.errorMessage != null)
                            _buildErrorMessage(authProvider.errorMessage!),

                          const SizedBox(height: AppConstants.defaultPadding),

                          // Verify button
                          PrimaryButton(
                            text: 'Verify & Create Account',
                            onPressed: _isOtpComplete ? _handleVerifyOtp : null,
                            isLoading:
                            authProvider.state == AuthState.otpVerifying,
                            isEnabled: _isOtpComplete,
                          ),

                          const SizedBox(height: AppConstants.largePadding),

                          // Resend OTP section
                          _buildResendSection(authProvider),

                          const SizedBox(height: AppConstants.largePadding),

                          // Help text
                          _buildHelpText(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOtpInput() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(
            'Enter OTP Code',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          PinCodeTextField(
            appContext: context,
            length: AppConstants.otpLength,
            controller: _otpController,
            animationType: AnimationType.fade,
            animationDuration: AppConstants.shortAnimation,
            enableActiveFill: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              fieldHeight: 60,
              fieldWidth: 50,
              borderWidth: 2,
              activeColor: AppColors.primaryMaroon,
              selectedColor: AppColors.primaryMaroon,
              inactiveColor: AppColors.inputBorder,
              errorBorderColor: AppColors.error,
              activeFillColor: AppColors.inputFill,
              selectedFillColor: AppColors.primaryMaroon.withOpacity(0.1),
              inactiveFillColor: AppColors.inputFill,
            ),
            onCompleted: (value) {
              setState(() {
                _currentOtp = value;
                _isOtpComplete = true;
              });
            },
            onChanged: (value) {
              setState(() {
                _currentOtp = value;
                _isOtpComplete = value.length == AppConstants.otpLength;
              });
            },
            validator: (value) => Validators.validateOTP(value),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResendSection(AuthProvider authProvider) {
    final canResend = _resendCountdown <= 0;

    return Column(
      children: [
        Text(
          'Didn\'t receive the code?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        if (canResend)
          CompactButton(
            text: 'Resend OTP',
            onPressed: _handleResendOtp,
            isLoading: authProvider.isLoading,
          )
        else
          Text(
            'Resend in ${_formatTime(_resendCountdown)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildHelpText() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Having trouble?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Check your spam/junk folder\n'
                      '• Make sure you entered the correct email\n'
                      '• OTP expires in 10 minutes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
