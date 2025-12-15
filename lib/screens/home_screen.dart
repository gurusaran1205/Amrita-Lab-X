import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../models/booking.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; // Added dependency
import '../utils/colors.dart';

/// Professional home screen for AmritaULABS
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  late DateTime _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _scrollController.addListener(_onScroll);
    // Update time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if app bar is collapsed (threshold can be adjusted)
    final isCollapsed = _scrollController.hasClients && 
                        _scrollController.offset > (160 - kToolbarHeight - 20);
    
    if (isCollapsed != _isCollapsed) {
      setState(() {
        _isCollapsed = isCollapsed;
      });
    }
  }

  // Method to handle pull-to-refresh
  Future<void> _refreshData() async {
    // Fetch real data from providers
    await Provider.of<BookingProvider>(context, listen: false).fetchMyBookings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data refreshed successfully!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primaryMaroon,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildSloganCard(context),
                  const SizedBox(height: 24),
                  _buildRecentBookings(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final dateStr = DateFormat('MMM dd').format(_currentTime);
    final dayStr = DateFormat('EEE').format(_currentTime);
    final timeStr = DateFormat('hh:mm a').format(_currentTime);
    final fullDateStr = '$dayStr, $dateStr';

    return SliverAppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      expandedHeight: 190,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryMaroon,
      elevation: 0,
      leading: Container(), // Hide default back button/drawer icon if any
      leadingWidth: 0,
      actions: [
        if (_isCollapsed) // Only show logout in AppBar actions when collapsed
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout_rounded, color: AppColors.white),
            tooltip: 'Logout',
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        centerTitle: true,
        title: _isCollapsed
            ? SizedBox(
                height: kToolbarHeight,
                child: Center(
                  child: Text(
                    'AMRITAULABS',
                    style: GoogleFonts.poppins( // Updated Font
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              )
            : null, // Hide standard title when expanded to use custom background layout
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryMaroon,
                AppColors.primaryMaroon.withAlpha((255 * 0.9).round()),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Stack(
                children: [
                   // Top Row: Title, Subtitle, Logout
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 'AMRITAULABS',
                                 style: GoogleFonts.poppins( // Updated Font
                                   color: AppColors.white,
                                   fontSize: 28,
                                   fontWeight: FontWeight.bold,
                                   letterSpacing: 1.0,
                                 ),
                               ),
                               const SizedBox(height: 2),
                               Text(
                                 'Laboratory Management System',
                                 style: GoogleFonts.inter( // Updated Font
                                   color: AppColors.white.withOpacity(0.9),
                                   fontSize: 13,
                                   fontWeight: FontWeight.w400,
                                   letterSpacing: 0.2,
                                 ),
                               ),
                             ],
                           ),
                           // Logout Icon in expanded state
                           IconButton(
                             onPressed: () => _handleLogout(context),
                             icon: const Icon(Icons.logout_rounded, color: AppColors.white),
                             tooltip: 'Logout',
                             padding: EdgeInsets.zero,
                             constraints: const BoxConstraints(),
                           ),
                         ],
                       ),
                    ],
                  ),
                  
                  // Bottom Row: Welcome and Time
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Welcome Section
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            final user = authProvider.user;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: GoogleFonts.inter( // Updated Font
                                    color: AppColors.white.withOpacity(0.9),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.name ?? 'Student',
                                  style: GoogleFonts.poppins( // Updated Font
                                    color: AppColors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        
                        // Time Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeStr,
                              style: GoogleFonts.poppins( // Updated Font
                                color: AppColors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              fullDateStr,
                              style: GoogleFonts.inter( // Updated Font
                                color: AppColors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.add_circle_outline,
                  title: 'Book\nEquipment',
                  backgroundColor: const Color(0xFFFBE9E7), // Light Red/Pink
                  iconColor: const Color(0xFFC62828), // Dark Red
                  borderColor: const Color(0xFFFFCCBC),
                  onTap: () {
                    Navigator.pushNamed(context, '/equipment');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.history,
                  title: 'View\nBookings',
                  backgroundColor: const Color(0xFFE3F2FD), // Light Blue
                  iconColor: const Color(0xFF1565C0), // Dark Blue
                  borderColor: const Color(0xFFBBDEFB),
                  onTap: () {
                    Navigator.pushNamed(context, '/my_bookings');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.qr_code_scanner,
                  title: 'Scan\nQR Code',
                  backgroundColor: const Color(0xFFE8F5E9), // Light Green
                  iconColor: const Color(0xFF2E7D32), // Dark Green
                  borderColor: const Color(0xFFC8E6C9),
                  onTap: () {
                    Navigator.pushNamed(context, '/qr_scanner');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Color backgroundColor,
        required Color iconColor,
        required Color borderColor,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSloganCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryMaroon,
              AppColors.primaryMaroon.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryMaroon.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '"EMPOWERING INNOVATION THROUGH EXCELLENCE IN LABORATORY EDUCATION"',
              style: GoogleFonts.poppins(
                fontSize: 16, // Slightly smaller for better fit
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                letterSpacing: 0.5,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '~ Amma',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.white.withOpacity(0.95),
                letterSpacing: 0.3,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookings(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Bookings',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/my_bookings');
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    color: AppColors.primaryMaroon,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<BookingProvider>(
            builder: (context, bookingProvider, child) {
              if (bookingProvider.isLoading && bookingProvider.myBookings.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryMaroon));
              }

              if (bookingProvider.errorMessage != null) {
                return Center(child: Text(bookingProvider.errorMessage!));
              }

              if (bookingProvider.myBookings.isEmpty) {
                return const Center(child: Text('No recent bookings found.'));
              }

              // Take the first 3 bookings
              final recentBookings = bookingProvider.myBookings.take(3).toList();

              return Column(
                children: recentBookings.map((booking) {
                  return _buildBookingStatusCard(booking);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingStatusCard(Booking booking) {
    // Convert to IST (UTC + 5:30)
    final istTime = booking.startTime.toUtc().add(const Duration(hours: 5, minutes: 30));
    
    final date = DateFormat('MMM dd, yyyy').format(istTime);
    final time = DateFormat('hh:mm a').format(istTime);
    
    bool isActive = booking.status.toLowerCase() == 'confirmed' &&
        booking.startTime.isBefore(DateTime.now()) &&
        booking.endTime.isAfter(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.03).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryMaroon.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.devices_other,
              color: AppColors.primaryMaroon,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.equipment.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking.equipment.labId,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$date • $time',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.success.withAlpha((255 * 0.1).round())
                  : AppColors.mediumGray.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isActive ? 'Active' : booking.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.success : AppColors.mediumGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}