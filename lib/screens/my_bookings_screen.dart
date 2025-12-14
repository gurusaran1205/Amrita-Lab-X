import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import '../providers/booking_provider.dart';
import '../models/booking.dart';

/// My Bookings screen showing all user bookings
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
    _tabController = TabController(length: 4, vsync: this);
    
    // Fetch bookings when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchMyBookings();
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
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookingProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading bookings',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      bookingProvider.fetchMyBookings();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final allBookings = bookingProvider.myBookings;
          
          // Categorize bookings
          final now = DateTime.now();
          
          final activeBookings = allBookings.where((b) {
            final status = b.status.toLowerCase();
            if (['cancelled', 'rejected'].contains(status)) return false;
            if (status == 'checked_in') return true;
            return b.startTime.isBefore(now) && b.endTime.isAfter(now);
          }).toList();

          final upcomingBookings = allBookings.where((b) {
            final isFuture = b.startTime.isAfter(now);
            final isNotCancelled = !['cancelled', 'rejected'].contains(b.status.toLowerCase());
            return isFuture && isNotCancelled;
          }).toList();

          final historyBookings = allBookings.where((b) {
            final isPast = b.endTime.isBefore(now);
            final isCompleted = b.status.toLowerCase() == 'completed';
            // History now only includes past or completed, NOT rejected/cancelled
            return (isPast || isCompleted) && !['cancelled', 'rejected'].contains(b.status.toLowerCase());
          }).toList();

          final rejectedBookings = allBookings.where((b) {
            return ['cancelled', 'rejected'].contains(b.status.toLowerCase());
          }).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingsList(activeBookings, 'active'),
              _buildBookingsList(upcomingBookings, 'upcoming'),
              _buildBookingsList(historyBookings, 'history'),
              _buildBookingsList(rejectedBookings, 'rejected'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, String type) {
    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => Provider.of<BookingProvider>(context, listen: false).fetchMyBookings(),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: _buildEmptyState(type),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => Provider.of<BookingProvider>(context, listen: false).fetchMyBookings(),
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
      case 'rejected':
        message = 'No rejected bookings';
        icon = Icons.cancel_presentation;
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
    
    final dateStr = dateFormat.format(booking.startTime.toLocal());
    final timeStr = '${timeFormat.format(booking.startTime.toLocal())} - ${timeFormat.format(booking.endTime.toLocal())}';
    
    final duration = booking.endTime.difference(booking.startTime);
    final durationStr = '${duration.inHours} hours';

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
                                'Lab ID: ${booking.equipment.labId}', // Displaying Lab ID as Name is not available in Booking model
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
                        dateStr,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.access_time,
                        'Time',
                        timeStr,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  Icons.timelapse,
                  'Duration',
                  durationStr,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  Icons.description_outlined,
                  'Purpose',
                  booking.purpose,
                ),
              ],
            ),
            ),

          if (['pending', 'approved', 'upcoming'].contains(booking.status.toLowerCase()))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelConfirmation(booking),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancel Booking'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(Booking booking) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Are you sure you want to cancel this booking? This action cannot be undone.'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Cancellation Reason',
                hintText: 'e.g. Schedule conflict',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason for cancellation'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
              }

              Navigator.pop(context); // Close dialog
              final provider =
                  Provider.of<BookingProvider>(context, listen: false);
              
              final success = await provider.cancelBooking(
                  booking.id, reasonController.text.trim());

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking cancelled successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ??
                          'Failed to cancel booking'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
        color = AppColors.success;
        break;
      case 'upcoming':
      case 'pending':
        color = AppColors.info;
        break;
      case 'completed':
        color = AppColors.mediumGray;
        break;
      case 'cancelled':
      case 'rejected':
        color = AppColors.error;
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
        status.toUpperCase(),
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
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Column(
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
      ],
    );
  }


}
