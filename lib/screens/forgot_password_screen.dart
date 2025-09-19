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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _setupFormValidation();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _setupFormValidation() {
    void checkFormValidity() {
      setState(() {
        _isFormValid = _emailController.text.trim().isNotEmpty &&
            Validators.validateEmail(_emailController.text) == null;
      });
    }

    _emailController.addListener(checkFormValidity);
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.sendForgotPasswordOtp(
      email: _emailController.text.trim(),
    );

    if (success) {
      _showSuccessToast(AppConstants.forgotPasswordOtpSent);
      _navigateToResetPassword();
    } else {
      _showErrorToast(authProvider.errorMessage ?? 'Failed to send reset code');
    }
  }

  void _navigateToResetPassword() {
    Navigator.pushReplacementNamed(
      context,
      '/reset-password',
      arguments: _emailController.text.trim(),
    );
  }

  void _navigateBackToLogin() {
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
            message: 'Sending reset code...',
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  const Flexible(
                    flex: 0,
                    child: AppHeader(
                      subtitle: AppConstants.forgotPasswordSubtitle,
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

                              // Forgot password header
                              _buildForgotPasswordHeader(),

                              SizedBox(
                                height: MediaQuery.of(context).size.height > 700
                                    ? AppConstants.largePadding * 2
                                    : AppConstants.largePadding,
                              ),

                              // Email form
                              _buildEmailForm(authProvider),

                              const SizedBox(height: AppConstants.largePadding),

                              // Error message
                              if (authProvider.errorMessage != null)
                                _buildErrorMessage(authProvider.errorMessage!),

                              const SizedBox(
                                  height: AppConstants.defaultPadding),

                              // Send reset code button
                              PrimaryButton(
                                text: 'Send Reset Code',
                                onPressed:
                                    _isFormValid ? _handleForgotPassword : null,
                                isLoading: authProvider.isLoading,
                                isEnabled: _isFormValid,
                              ),

                              const SizedBox(height: AppConstants.largePadding),

                              // Back to login link
                              _buildBackToLoginLink(),

                              const Spacer(),

                              // Instructions
                              _buildInstructions(),

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

  Widget _buildForgotPasswordHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryMaroon.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_reset_outlined,
            size: 40,
            color: AppColors.primaryMaroon,
          ),
        ),
        const SizedBox(height: AppConstants.largePadding),
        Text(
          AppConstants.forgotPasswordTitle,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          AppConstants.forgotPasswordSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          EmailTextField(
            controller: _emailController,
            validator: Validators.validateEmail,
            focusNode: _emailFocusNode,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleForgotPassword(),
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

  Widget _buildBackToLoginLink() {
    return TextButton(
      onPressed: _navigateBackToLogin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.arrow_back_ios,
            size: 16,
            color: AppColors.primaryMaroon,
          ),
          const SizedBox(width: 4),
          Text(
            'Back to Sign In',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryMaroon,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryMaroon.withOpacity(0.05),
        border: Border.all(color: AppColors.primaryMaroon.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primaryMaroon,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Instructions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryMaroon,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. Enter your registered email address\n'
            '2. Check your email for a 6-digit reset code\n'
            '3. Use the code to reset your password',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}
