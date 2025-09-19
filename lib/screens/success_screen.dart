import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/equipment_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_button.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../screens/equipment_selection.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          return Column(
            children: [
              // Header without back button
              const AppHeader(
                subtitle: 'Account Created Successfully',
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success animation/icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 60,
                          color: AppColors.success,
                        ),
                      ),

                      const SizedBox(height: AppConstants.largePadding),

                      // Success message
                      Text(
                        'Welcome to AmritaULABS!',
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppConstants.defaultPadding),

                      // User details
                      if (user != null) ...[
                        Text(
                          'Hello, ${user.name}!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: AppColors.primaryMaroon,
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.email,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: AppConstants.largePadding),

                      // Success description
                      Text(
                        'Your account has been created successfully.\n'
                        'You can now access all AmritaULABS features.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppConstants.largePadding * 2),

                      // Continue button
                      PrimaryButton(
                        text: 'Continue to App',
                        onPressed: () async {
                          final equipmentProvider =
                              context.read<EquipmentProvider>();
                          await equipmentProvider
                              .loadDepartments(); // ✅ only now, token exists

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EquipmentSelectionPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: AppConstants.defaultPadding),

                      // Logout option
                      TextButton(
                        onPressed: () => _handleLogout(context, authProvider),
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: AppConstants.bodyFontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleLogout(
      BuildContext context, AuthProvider authProvider) async {
    await authProvider.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}
