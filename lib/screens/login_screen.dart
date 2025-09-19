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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _setupFormValidation();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _setupFormValidation() {
    void checkFormValidity() {
      setState(() {
        _isFormValid = _emailController.text.trim().isNotEmpty &&
            _passwordController.text.isNotEmpty &&
            Validators.validateEmail(_emailController.text) == null;
      });
    }

    _emailController.addListener(checkFormValidity);
    _passwordController.addListener(checkFormValidity);
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success) {
      _showSuccessToast('Login successful!');
      _navigateToHome();
    } else {
      _showErrorToast(authProvider.errorMessage ?? 'Login failed');
    }
  }

  void _navigateToHome() {
    // Navigate to success screen after successful login
    Navigator.pushReplacementNamed(context, '/success');
  }

  void _navigateToSignup() {
    Navigator.pushReplacementNamed(context, '/signup');
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
      resizeToAvoidBottomInset:
          true, // Key fix: Allow screen to resize for keyboard
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            message: 'Signing in...',
            child: SafeArea(
              // Key fix: Wrap in SafeArea
              child: Column(
                children: [
                  // Header - Make it flexible
                  const Flexible(
                    flex: 0,
                    child: AppHeader(
                      subtitle: AppConstants.loginSubtitle,
                    ),
                  ),

                  // Form content - Make it scrollable and flexible
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
                              100, // Approximate header height
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(
                                  height: AppConstants.defaultPadding),

                              // Welcome message - Reduced spacing on mobile
                              _buildWelcomeHeader(),

                              SizedBox(
                                height: MediaQuery.of(context).size.height > 700
                                    ? AppConstants.largePadding * 2
                                    : AppConstants.largePadding,
                              ),

                              // Login form
                              _buildLoginForm(authProvider),

                              const SizedBox(height: AppConstants.largePadding),

                              // Error message
                              if (authProvider.errorMessage != null)
                                _buildErrorMessage(authProvider.errorMessage!),

                              const SizedBox(
                                  height: AppConstants.defaultPadding),

                              // Login button
                              PrimaryButton(
                                text: 'Sign In',
                                onPressed: _isFormValid ? _handleLogin : null,
                                isLoading: authProvider.isLoading,
                                isEnabled: _isFormValid,
                              ),

                              const SizedBox(height: AppConstants.largePadding),

                              // Forgot password link
                              _buildForgotPasswordLink(),

                              const Spacer(), // Push footer to bottom

                              // Footer text
                              _buildFooterText(),

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

  Widget _buildWelcomeHeader() {
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
            Icons.login_outlined,
            size: 40,
            color: AppColors.primaryMaroon,
          ),
        ),
        const SizedBox(height: AppConstants.largePadding),
        Text(
          AppConstants.welcomeBackMessage,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          AppConstants.loginSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          EmailTextField(
            controller: _emailController,
            validator: Validators.validateEmail,
            focusNode: _emailFocusNode,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Password field
          PasswordTextField(
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
            focusNode: _passwordFocusNode,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
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

  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: () {
        _showSuccessToast('Forgot password feature coming soon!');
      },
      child: Text(
        'Forgot Password?',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryMaroon,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
      ),
    );
  }

  Widget _buildFooterText() {
    return Column(
      children: [
        Text(
          'By signing in, you agree to our Terms of Service and Privacy Policy',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textLight,
                height: 1.4,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        GestureDetector(
          onTap: _navigateToSignup,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              children: const [
                TextSpan(text: "Don't have an account? "),
                TextSpan(
                  text: 'Sign up',
                  style: TextStyle(
                    color: AppColors.primaryMaroon,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
