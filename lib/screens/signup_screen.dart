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
import '../models/department.dart';
import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _departmentFocusNode = FocusNode();

  List<Department> _departments = [];
  String? _selectedDepartmentId;
  bool _isLoadingDepartments = false;

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _setupFormValidation();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    setState(() {
      _isLoadingDepartments = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final departments = await authProvider.getDepartments();
      if (mounted) {
        setState(() {
          _departments = departments;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDepartments = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _departmentFocusNode.dispose();
    super.dispose();
  }

  void _setupFormValidation() {
    void checkFormValidity() {
      setState(() {
        _isFormValid = _nameController.text.trim().isNotEmpty &&
            _emailController.text.trim().isNotEmpty &&
            _passwordController.text.isNotEmpty &&
            _selectedDepartmentId != null &&
            Validators.validateEmail(_emailController.text) == null &&
            Validators.validatePassword(_passwordController.text) == null &&
            Validators.validateName(_nameController.text) == null;
      });
    }

    _nameController.addListener(checkFormValidity);
    _emailController.addListener(checkFormValidity);
    _passwordController.addListener(checkFormValidity);
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.sendOtp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      department: _selectedDepartmentId!,
    );

    if (success) {
      _showSuccessToast('OTP sent to your email!');
      _navigateToOtpScreen();
    } else {
      _showErrorToast(authProvider.errorMessage ?? 'Failed to send OTP');
    }
  }

  void _navigateToOtpScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OtpVerificationScreen(),
      ),
    );
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
            message: 'Sending OTP...',
            child: SafeArea(
              // Key fix: Wrap in SafeArea
              child: Column(
                children: [
                  // Header - Make it flexible
                  const Flexible(
                    flex: 0,
                    child: AppHeader(
                      subtitle: AppConstants.signupSubtitle,
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

                              // Welcome message - Use custom widget instead of WelcomeHeader
                              _buildWelcomeHeader(),

                              SizedBox(
                                height: MediaQuery.of(context).size.height > 700
                                    ? AppConstants.largePadding * 2
                                    : AppConstants.largePadding,
                              ),

                              // Signup form
                              _buildSignupForm(authProvider),

                              const SizedBox(height: AppConstants.largePadding),

                              // Error message
                              if (authProvider.errorMessage != null)
                                _buildErrorMessage(authProvider.errorMessage!),

                              const SizedBox(
                                  height: AppConstants.defaultPadding),

                              // Send OTP button
                              PrimaryButton(
                                text: 'Send OTP',
                                onPressed: _isFormValid ? _handleSendOtp : null,
                                isLoading: authProvider.isLoading,
                                isEnabled: _isFormValid,
                              ),

                              const SizedBox(height: AppConstants.largePadding),

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

// Add this method to your signup screen class:
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
          child: const Icon(
            Icons.person_add_outlined,
            size: 40,
            color: AppColors.primaryMaroon,
          ),
        ),
        const SizedBox(height: AppConstants.largePadding),
        Text(
          AppConstants.welcomeMessage,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          AppConstants.signupSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignupForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name field
          NameTextField(
            controller: _nameController,
            validator: Validators.validateName,
            focusNode: _nameFocusNode,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

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
            validator: Validators.validatePassword,
            focusNode: _passwordFocusNode,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _departmentFocusNode.requestFocus(),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Department Dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Department',
              prefixIcon: Icon(Icons.school_outlined),
              border: OutlineInputBorder(),
            ),
            value: _selectedDepartmentId,
            items: _departments.map((dept) {
              return DropdownMenuItem(
                value: dept.id,
                child: Text(
                  dept.name,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDepartmentId = value;
                // Trigger validation check manually since it's not a text field controller
                _isFormValid = _nameController.text.trim().isNotEmpty &&
                    _emailController.text.trim().isNotEmpty &&
                    _passwordController.text.isNotEmpty &&
                    _selectedDepartmentId != null &&
                    Validators.validateEmail(_emailController.text) == null &&
                    Validators.validatePassword(_passwordController.text) ==
                        null &&
                    Validators.validateName(_nameController.text) == null;
              });
            },
            validator: (value) =>
                value == null ? 'Please select a department' : null,
            focusNode: _departmentFocusNode,
            hint: _isLoadingDepartments
                ? const Text('Loading departments...')
                : const Text('Select Department'),
            disabledHint: _isLoadingDepartments
                ? const Text('Loading departments...')
                : null,
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
  // Replace the _buildFooterText method in your signup_screen.dart with this:

  Widget _buildFooterText() {
    return Column(
      children: [
        Text(
          'By creating an account, you agree to our Terms of Service and Privacy Policy',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textLight,
                height: 1.4,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        GestureDetector(
          onTap: () {
            // Navigate to login screen
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              children: const [
                TextSpan(text: 'Already have an account? '),
                TextSpan(
                  text: 'Sign in',
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
