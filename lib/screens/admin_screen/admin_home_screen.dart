import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/session_provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class AdminHomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToRequests;
  final VoidCallback onNavigateToLogouts;

  const AdminHomeScreen({
    super.key,
    required this.onNavigateToRequests,
    required this.onNavigateToLogouts,
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data for badges
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchPendingBookings();
      context.read<SessionProvider>().fetchPendingSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final sessionProvider = context.watch<SessionProvider>();

    final user = authProvider.user;
    final requestCount = bookingProvider.pendingBookings.length;
    final logoutCount = sessionProvider.pendingSessions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Custom Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryMaroon, Color(0xFF800020)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            user?.name ?? 'Admin',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () async {
                            await authProvider.logout();
                            if (mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/login', (route) => false);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Quick Actions Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          title: 'Review\nRequests',
                          icon: Icons.notifications_active_outlined,
                          color: const Color(0xFFFF6B6B),
                          count: requestCount,
                          onTap: widget.onNavigateToRequests,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          title: 'Approve\nLogouts',
                          icon: Icons.logout,
                          color: const Color(0xFFFFBE0B),
                          count: logoutCount,
                          onTap: widget.onNavigateToLogouts,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          title: 'QR\nManager',
                          icon: Icons.qr_code_scanner,
                          color: const Color(0xFF4ECDC4),
                          onTap: () => Navigator.pushNamed(context, '/qr_management'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildManagementTile(
                    context,
                    title: 'Manage Departments',
                    subtitle: 'Add, edit, or remove departments',
                    icon: Icons.business,
                    color: Colors.blueAccent,
                    route: '/manage_departments',
                  ),
                  _buildManagementTile(
                    context,
                    title: 'Manage Labs',
                    subtitle: 'Oversee laboratory details',
                    icon: Icons.science,
                    color: Colors.purpleAccent,
                    route: '/manage_labs',
                  ),
                  _buildManagementTile(
                    context,
                    title: 'Manage Equipment',
                    subtitle: 'Inventory and status control',
                    icon: Icons.biotech,
                    color: Colors.teal,
                    route: '/manage_equipments',
                  ),
                  _buildManagementTile(
                     context,
                     title: 'Manage Users',
                     subtitle: 'Block or unblock users',
                     icon: Icons.people_outline,
                     color: Colors.orangeAccent,
                     route: '/block_users',
                  ),
                  _buildManagementTile(
                     context,
                     title: 'View Reports',
                     subtitle: 'System analytics and logs',
                     icon: Icons.analytics_outlined,
                     color: Colors.blueGrey,
                     route: '/reports', // Note: Needs proper route or handling since ReportsScreen was a widget.
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    int? count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 140, // Fixed height for consistency
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                if (count != null && count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
