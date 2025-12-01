import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class LabStaffDashboardScreen extends StatelessWidget {
  const LabStaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (user != null) _buildWelcomeCard(context, user.name),
              const SizedBox(height: AppConstants.largePadding),
              _buildDashboardGrid(context),
              const SizedBox(height: AppConstants.largePadding),
              _buildLogoutButton(context, authProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String name) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Row(
          children: [
            const Icon(
              Icons.admin_panel_settings_outlined,
              size: 40,
              color: AppColors.primaryMaroon,
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $name',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Manage lab operations from here.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppConstants.defaultPadding,
      mainAxisSpacing: AppConstants.defaultPadding,
      children: [
        _buildDashboardItem(
          context,
          icon: Icons.approval,
          label: 'Approve Requests',
          onTap: () {
            Navigator.pushNamed(context, '/approve_requests');
          },
        ),
        _buildDashboardItem(
          context,
          icon: Icons.add_business_outlined,
          label: 'Add Department',
          onTap: () {
            Navigator.pushNamed(context, '/add_department');
          },
        ),

        // ⭐ FIX: Edit Department must go to a screen that lists departments
        _buildDashboardItem(
          context,
          icon: Icons.edit_outlined,
          label: 'Edit Department',
          onTap: () {
            Navigator.pushNamed(context, '/manage_departments'); // <-- FIX
          },
        ),

        _buildDashboardItem(
          context,
          icon: Icons.delete_outline,
          label: 'Delete Department',
          onTap: () {
            Navigator.pushNamed(context, '/delete_department');
          },
        ),
        _buildDashboardItem(
          context,
          icon: Icons.science_outlined,
          label: 'Add Lab',
          onTap: () {
            Navigator.pushNamed(context, '/add_lab');
          },
        ),
        _buildDashboardItem(
          context,
          icon: Icons.edit_location_alt_outlined,
          label: 'Edit Lab',
          onTap: () {
            Navigator.pushNamed(context, '/manage_labs');
          },
        ),
        _buildDashboardItem(
          context,
          icon: Icons.delete_forever_outlined,
          label: 'Delete Lab',
          onTap: () {
            Navigator.pushNamed(context, '/delete_lab');
          },
        ),
        _buildDashboardItem(
          context,
          icon: Icons.biotech_outlined,
          label: 'Add Equipment',
          onTap: () {
            Navigator.pushNamed(context, '/add_equipment');
          },
        ),
        _buildDashboardItem(
          context,
          icon: Icons.edit_note_outlined,
          label: 'Edit Equipment',
          onTap: () {
            Navigator.pushNamed(context, '/manage_equipments');
          },
        ),
        _buildDashboardItem(
          context,
          icon: Icons.delete_sweep_outlined,
          label: 'Delete Equipment',
          onTap: () {
            Navigator.pushNamed(context, '/delete_equipment');
          },
        ),
        _buildDashboardItem(
          context,
          icon: Icons.block,
          label: 'Block Users',
          onTap: () {
            Navigator.pushNamed(context, '/block_users');
          },
        ),
        _buildDashboardItem(
          context,
          icon: Icons.qr_code_scanner,
          label: 'Generate QR',
          onTap: () {
            Navigator.pushNamed(context, '/qr_management');
          },
        ),
      ],
    );
  }

  Widget _buildDashboardItem(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: AppColors.primaryMaroon,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return ElevatedButton.icon(
      onPressed: () async {
        await authProvider.logout();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
      icon: const Icon(Icons.logout),
      label: const Text('Logout'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.white,
      ),
    );
  }
}
