import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import '../providers/booking_provider.dart';
import '../models/booking.dart';

/// My Bookings screen showing all user bookings with real API integration
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch bookings when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchMyBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryMaroon),
            onPressed: () {
              context.read<BookingProvider>().refreshBookings();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryMaroon,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryMaroon,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryMaroon,
              ),
            );
          }

          if (bookingProvider.errorMessage != null) {
            return _buildErrorState(bookingProvider.errorMessage!);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingsList(bookingProvider.activeBookings, 'active'),
              _buildBookingsList(bookingProvider.upcomingBookings, 'upcoming'),
              _buildBookingsList(bookingProvider.historyBookings, 'history'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<BookingProvider>().refreshBookings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMaroon,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, String type) {
    if (bookings.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BookingProvider>().refreshBookings(),
      color: AppColors.primaryMaroon,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _buildBookingItem(bookings[index], type);
        },
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    String message;
    IconData icon;

    switch (type) {
      case 'active':
        message = 'No active bookings';
        icon = Icons.event_busy;
        break;
      case 'upcoming':
        message = 'No upcoming bookings';
        icon = Icons.event_available;
        break;
      default:
        message = 'No booking history';
        icon = Icons.history;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Book equipment to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(Booking booking, String type) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final duration = booking.endTime.difference(booking.startTime);
    final durationText = '${duration.inHours}h ${duration.inMinutes % 60}m';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMaroon.withAlpha((255 * 0.1).round()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.devices_other,
                        color: AppColors.primaryMaroon,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.equipment.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Lab ID: ${booking.equipment.labId}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(booking.status),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today_outlined,
                        'Date',
                        dateFormat.format(booking.startTime),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.access_time,
                        'Time',
                        '${timeFormat.format(booking.startTime)} - ${timeFormat.format(booking.endTime)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  Icons.timelapse,
                  'Duration',
                  durationText,
                ),
                if (booking.purpose.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    Icons.notes,
                    'Purpose',
                    booking.purpose,
                  ),
                ],
              ],
            ),
          ),
          if (type == 'active' && booking.status.toLowerCase() != 'cancelled')
            _buildActionButtons(booking),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String displayStatus = status;

    switch (status.toLowerCase()) {
      case 'confirmed':
        color = AppColors.success;
        displayStatus = 'Active';
        break;
      case 'pending':
        color = AppColors.warning;
        displayStatus = 'Pending';
        break;
      case 'completed':
        color = AppColors.mediumGray;
        displayStatus = 'Completed';
        break;
      case 'cancelled':
        color = AppColors.error;
        displayStatus = 'Cancelled';
        break;
      default:
        color = AppColors.mediumGray;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Booking booking) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                _showQRCode(booking);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code, size: 18),
                  SizedBox(width: 8),
                  Text('Show QR'),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.divider,
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                _showCancelDialog(booking);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Cancel'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQRCode(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO: Generate actual QR code with booking ID
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code,
                  size: 150,
                  color: AppColors.textLight,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Booking ID: ${booking.id}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final success = await context.read<BookingProvider>().cancelBooking(booking.id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Booking cancelled successfully'
                          : 'Failed to cancel booking',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );

                if (success) {
                  // Refresh the bookings list
                  context.read<BookingProvider>().refreshBookings();
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}