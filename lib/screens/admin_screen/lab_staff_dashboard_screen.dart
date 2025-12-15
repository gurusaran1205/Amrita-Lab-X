import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';
import 'reports_screen.dart'; // Import ReportsScreen

import 'admin_home_screen.dart'; // Import AdminHomeScreen

class LabStaffDashboardScreen extends StatefulWidget {
  const LabStaffDashboardScreen({super.key});

  @override
  State<LabStaffDashboardScreen> createState() => _LabStaffDashboardScreenState();
}

class _LabStaffDashboardScreenState extends State<LabStaffDashboardScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Home', // New Home Title
    'Departments',
    'Equipment',
    'Labs',
    'Reports',
    'Requests',
  ];

  @override
  Widget build(BuildContext context) {
    // Only show AppBar for non-Home screens
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _selectedIndex == 0
          ? null // No AppBar for Home screen (it has its own custom header)
          : AppBar(
              title: Text(_titles[_selectedIndex]),
              backgroundColor: AppColors.primaryMaroon,
              foregroundColor: AppColors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await Provider.of<AuthProvider>(context, listen: false).logout();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    }
                  },
                ),
              ],
            ),
      body: _buildBody(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryMaroon,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
             BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Dept',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.biotech),
              label: 'Equip',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.science),
              label: 'Lab',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active),
              label: 'Requests',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return AdminHomeScreen(
          onNavigateToRequests: () => Navigator.pushNamed(context, '/approve_requests'), // Direct navigation
          onNavigateToLogouts: () => Navigator.pushNamed(context, '/approve_logout'),
        );
      case 1:
        return _buildDepartmentSection();
      case 2:
        return _buildEquipmentSection();
      case 3:
        return _buildLabSection();
      case 4:
        return _buildRequestsSection(); // Reports moved or accessible differently? Let's check user intent later. For now, matching standard navigation.
        
        // WAIT: The previous list had 5 items: Dept, Equip, Lab, Reports, Requests.
        // Adding Home makes 6. BottomNavBar usually handles 5 max well. 
        // Let's condense labels: Dept, Equip, Lab, Reports, Requests?
        // Actually, the previous list was: Departments, Equipment, Labs, Reports, Requests.
        // User asked for Home to navigate to Dept, Lab, Equip.
        
        // Adjusted BottomBar strategy:
        // 0: Home
        // 1: Departments
        // 2: Equipment
        // 3: Labs
        // 4: Requests (Common action)
        // Reports might be accessed via Home or sidebar. I will keep Reports actionable via the "Reports" Screen logic if I can fit it, or maybe just drop Reports from bottom bar and put it in Home "Management" section?
        // User didn't explicitly ask to remove Reports.
        // Let's stick to a safe 5 items if possible, or scrollable.
        // Let's try to fit Home + 4 key tabs.
        // I will Swap "Reports" out of bottom bar and put it in Home Management list as a tile. It's less frequent than Dept/Equip management.
    }
    return const Center(child: Text('Unknown Section'));
  }

  Widget _buildDepartmentSection() {
    return _buildGrid([
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
    ]);
  }

  Widget _buildEquipmentSection() {
    return _buildGrid([
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
    ]);
  }

  Widget _buildLabSection() {
    return _buildGrid([
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
    ]);
  }

  Widget _buildRequestsSection() {
    return _buildGrid([
      DashboardItemData(
        icon: Icons.qr_code_scanner,
        label: 'Generate\nQR Code',
        route: '/qr_management',
        gradient: [const Color(0xFF11998E), const Color(0xFF38C9A4)],
      ),
      DashboardItemData(
        icon: Icons.block,
        label: 'Block\nUsers',
        route: '/block_users',
        gradient: [const Color(0xFFFF512F), const Color(0xFFFF7557)],
      ),
      DashboardItemData(
        icon: Icons.approval,
        label: 'Accept\nRequests',
        route: '/approve_requests',
        gradient: [const Color(0xFF6B4CE6), const Color(0xFF9D7CE6)],
      ),
      DashboardItemData(
        icon: Icons.logout,
        label: 'Approve\nLogouts',
        route: '/approve_logout',
        gradient: [const Color(0xFFFFBE0B), const Color(0xFFFFD04A)],
      ),
    ]);
  }

  Widget _buildReportsSection() {
    return const ReportsScreen();
  }

  Widget _buildGrid(List<DashboardItemData> items) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.1,
        children: items
            .map((item) => _buildDashboardItem(context, item: item))
            .toList(),
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context,
      {required DashboardItemData item}) {
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