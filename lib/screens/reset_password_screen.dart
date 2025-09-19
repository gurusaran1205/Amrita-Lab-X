import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../providers/auth_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widget.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/otp_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _otpFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _setupFormValidation();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _setupFormValidation() {
    void checkFormValidity() {
      setState(() {
        _isFormValid = _otpController.text.length == AppConstants.otpLength &&
            _passwordController.text.length >= AppConstants.minPasswordLength &&
            _confirmPasswordController.text == _passwordController.text;
      });
    }

    _otpController.addListener(checkFormValidity);
    _passwordController.addListener(checkFormValidity);
    _confirmPasswordController.addListener(checkFormValidity);
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorToast('Passwords do not match');
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.resetPassword(
      email: widget.email,
      otp: _otpController.text.trim(),
      newPassword: _passwordController.text,
    );

    if (success) {
      _showSuccessToast(AppConstants.passwordResetSuccess);
      _navigateToLogin();
    } else {
      _showErrorToast(authProvider.errorMessage ?? 'Failed to reset password');
    }
  }

  Future<void> _handleResendOtp() async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.sendForgotPasswordOtp(
      email: widget.email,
    );

    if (success) {
      _showSuccessToast('Reset code sent again');
    } else {
      _showErrorToast(authProvider.errorMessage ?? 'Failed to resend code');
    }
  }

  void _navigateToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  void _navigateBackToForgotPassword() {
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            message: 'Resetting password...',
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  const Flexible(
                    flex: 0,
                    child: AppHeader(
                      subtitle: AppConstants.resetPasswordSubtitle,
                    ),
                  ),

                  // Form content
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.all(AppConstants.defaultPadding),
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top -
                              kToolbarHeight -
                              100,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(
                                  height: AppConstants.defaultPadding),

                              // Reset password header
                              _buildResetPasswordHeader(),

                              const SizedBox(height: AppConstants.largePadding),

                              // Email info
                              _buildEmailInfo(),

                              const SizedBox(height: AppConstants.largePadding),

                              // Reset password form
                              _buildResetPasswordForm(authProvider),

                              const SizedBox(height: AppConstants.largePadding),

                              // Error message
                              if (authProvider.errorMessage != null)
                                _buildErrorMessage(authProvider.errorMessage!),

                              const SizedBox(
                                  height: AppConstants.defaultPadding),

                              // Reset password button
                              PrimaryButton(
                                text: 'Reset Password',
                                onPressed:
                                    _isFormValid ? _handleResetPassword : null,
                                isLoading: authProvider.isLoading,
                                isEnabled: _isFormValid,
                              ),

                              const SizedBox(height: AppConstants.largePadding),

                              // Resend OTP and back links
                              _buildActionLinks(),

                              const Spacer(),

                              // Security note
                              _buildSecurityNote(),

                              const SizedBox(
                                  height: AppConstants.defaultPadding),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResetPasswordHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryMaroon.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.security_outlined,
            size: 40,
            color: AppColors.primaryMaroon,
          ),
        ),
        const SizedBox(height: AppConstants.largePadding),
        Text(
          AppConstants.resetPasswordTitle,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          AppConstants.resetPasswordSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryMaroon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: AppColors.primaryMaroon.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.email_outlined,
            color: AppColors.primaryMaroon,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset code sent to:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                Text(
                  widget.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryMaroon,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetPasswordForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // OTP field
          OtpTextField(
            controller: _otpController,
            focusNode: _otpFocusNode,
            onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'OTP is required';
              }
              if (value.length != AppConstants.otpLength) {
                return 'Please enter a ${AppConstants.otpLength}-digit OTP';
              }
              return null;
            },
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // New password field
          PasswordTextField(
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'New password is required';
              }
              if (value.length < AppConstants.minPasswordLength) {
                return 'Password must be at least ${AppConstants.minPasswordLength} characters';
              }
              return null;
            },
            focusNode: _passwordFocusNode,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
            label: 'New Password',
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Confirm password field
          PasswordTextField(
            controller: _confirmPasswordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            focusNode: _confirmPasswordFocusNode,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleResetPassword(),
            label: 'Confirm New Password',
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

  Widget _buildActionLinks() {
    return Column(
      children: [
        // Resend OTP link
        TextButton(
          onPressed: _handleResendOtp,
          child: Text(
            'Didn\'t receive the code? Resend',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryMaroon,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),

        const SizedBox(height: AppConstants.smallPadding),

        // Back to forgot password
        TextButton(
          onPressed: _navigateBackToForgotPassword,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Back to Email Entry',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.05),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Note',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your new password will be encrypted and stored securely. Make sure to use a strong, unique password.',
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
