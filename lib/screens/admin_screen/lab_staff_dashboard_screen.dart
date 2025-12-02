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
        child: Column(
          children: [
            // Header Section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryMaroon,
                    AppColors.primaryMaroon.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryMaroon.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lab Management',
                              style: TextStyle(
                                color: AppColors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user != null ? 'Welcome, ${user.name}' : 'Welcome',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_outlined,
                            color: AppColors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Manage lab operations from here',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Dashboard Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDashboardGrid(context),
                    const SizedBox(height: 20),
                    _buildLogoutButton(context, authProvider),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    final items = [
      DashboardItemData(
        icon: Icons.approval,
        label: 'Approve\nRequests',
        route: '/approve_requests',
        gradient: [const Color(0xFF6B4CE6), const Color(0xFF9D7CE6)],
      ),
      DashboardItemData(
        icon: Icons.add_business_outlined,
        label: 'Add\nDepartment',
        route: '/add_department',
        gradient: [const Color(0xFFFF6B9D), const Color(0xFFFF8DB9)],
      ),
      DashboardItemData(
        icon: Icons.edit_outlined,
        label: 'Edit\nDepartment',
        route: '/manage_departments',
        gradient: [const Color(0xFF4ECDC4), const Color(0xFF7ED9D3)],
      ),
      DashboardItemData(
        icon: Icons.delete_outline,
        label: 'Delete\nDepartment',
        route: '/delete_department',
        gradient: [const Color(0xFFFF8A5B), const Color(0xFFFFAA7F)],
      ),
      DashboardItemData(
        icon: Icons.science_outlined,
        label: 'Add\nLab',
        route: '/add_lab',
        gradient: [const Color(0xFF5B86E5), const Color(0xFF7EA3F5)],
      ),
      DashboardItemData(
        icon: Icons.edit_location_alt_outlined,
        label: 'Edit\nLab',
        route: '/manage_labs',
        gradient: [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)],
      ),
      DashboardItemData(
        icon: Icons.delete_forever_outlined,
        label: 'Delete\nLab',
        route: '/delete_lab',
        gradient: [const Color(0xFFFFBE0B), const Color(0xFFFFD04A)],
      ),
      DashboardItemData(
        icon: Icons.biotech_outlined,
        label: 'Add\nEquipment',
        route: '/add_equipment',
        gradient: [const Color(0xFF36D1DC), const Color(0xFF5BE3E3)],
      ),
      DashboardItemData(
        icon: Icons.edit_note_outlined,
        label: 'Edit\nEquipment',
        route: '/manage_equipments',
        gradient: [const Color(0xFFEE9CA7), const Color(0xFFFBC9D4)],
      ),
      DashboardItemData(
        icon: Icons.delete_sweep_outlined,
        label: 'Delete\nEquipment',
        route: '/delete_equipment',
        gradient: [const Color(0xFF8E54E9), const Color(0xFFAC7BE9)],
      ),
      DashboardItemData(
        icon: Icons.block,
        label: 'Block\nUsers',
        route: '/block_users',
        gradient: [const Color(0xFFFF512F), const Color(0xFFFF7557)],
      ),
      DashboardItemData(
        icon: Icons.qr_code_scanner,
        label: 'Generate\nQR Code',
        route: '/qr_management',
        gradient: [const Color(0xFF11998E), const Color(0xFF38C9A4)],
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildDashboardItem(
          context,
          item: item,
        );
      },
    );
  }

  Widget _buildDashboardItem(BuildContext context, {required DashboardItemData item}) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, item.route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: item.gradient[0].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                item.icon,
                size: 100,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                  Text(
                    item.label,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          await authProvider.logout();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        },
        icon: const Icon(Icons.logout, size: 22),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class DashboardItemData {
  final IconData icon;
  final String label;
  final String route;
  final List<Color> gradient;

  DashboardItemData({
    required this.icon,
    required this.label,
    required this.route,
    required this.gradient,
  });
}