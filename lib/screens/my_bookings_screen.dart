import 'package:flutter/material.dart';
import '../utils/colors.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList('active'),
          _buildBookingsList('upcoming'),
          _buildBookingsList('history'),
        ],
      ),
    );
  }

  Widget _buildBookingsList(String type) {
    // Mock data - replace with actual API data
    final bookings = _getMockBookings(type);

    if (bookings.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _buildBookingItem(bookings[index], type);
      },
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

  Widget _buildBookingItem(Map<String, dynamic> booking, String type) {
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
                            booking['equipment'],
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
                                booking['lab'],
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
                    _buildStatusBadge(booking['status']),
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
                        booking['date'],
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.access_time,
                        'Time',
                        booking['time'],
                      ),
                    ),
                  ],
                ),
                if (booking['duration'] != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    Icons.timelapse,
                    'Duration',
                    booking['duration'],
                  ),
                ],
              ],
            ),
          ),
          if (type == 'active') _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = AppColors.success;
        break;
      case 'upcoming':
        color = AppColors.info;
        break;
      case 'completed':
        color = AppColors.mediumGray;
        break;
      case 'cancelled':
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
        status,
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

  Widget _buildActionButtons() {
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
                // Show QR code
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
                _showCancelDialog();
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

  void _showCancelDialog() {
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
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancel booking API call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking cancelled successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
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

  List<Map<String, dynamic>> _getMockBookings(String type) {
    // Replace with actual API data
    switch (type) {
      case 'active':
        return [
          {
            'equipment': 'Oscilloscope',
            'lab': 'Electronics Lab',
            'date': 'Oct 04, 2025',
            'time': '10:00 AM - 12:00 PM',
            'duration': '2 hours',
            'status': 'Active',
          },
        ];
      case 'upcoming':
        return [
          {
            'equipment': 'Arduino Kit',
            'lab': 'IoT Lab',
            'date': 'Oct 05, 2025',
            'time': '02:00 PM - 04:00 PM',
            'duration': '2 hours',
            'status': 'Upcoming',
          },
          {
            'equipment': 'Raspberry Pi',
            'lab': 'Computer Lab',
            'date': 'Oct 06, 2025',
            'time': '11:00 AM - 01:00 PM',
            'duration': '2 hours',
            'status': 'Upcoming',
          },
        ];
      case 'history':
        return [
          {
            'equipment': 'Multimeter',
            'lab': 'Physics Lab',
            'date': 'Oct 02, 2025',
            'time': '11:30 AM - 01:30 PM',
            'duration': '2 hours',
            'status': 'Completed',
          },
          {
            'equipment': 'Function Generator',
            'lab': 'Electronics Lab',
            'date': 'Oct 01, 2025',
            'time': '03:00 PM - 05:00 PM',
            'duration': '2 hours',
            'status': 'Completed',
          },
          {
            'equipment': 'Spectrum Analyzer',
            'lab': 'Communication Lab',
            'date': 'Sep 28, 2025',
            'time': '10:00 AM - 12:00 PM',
            'duration': '2 hours',
            'status': 'Completed',
          },
        ];
      default:
        return [];
    }
  }
}
