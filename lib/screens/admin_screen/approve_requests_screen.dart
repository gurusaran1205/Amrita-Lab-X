import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking.dart';
import '../../utils/colors.dart';
import '../../widgets/loading_widget.dart';

class ApproveRequestsScreen extends StatefulWidget {
  const ApproveRequestsScreen({super.key});

  @override
  State<ApproveRequestsScreen> createState() => _ApproveRequestsScreenState();
}

class _ApproveRequestsScreenState extends State<ApproveRequestsScreen> {
  // State variables for search and filter
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'newest'; // 'newest', 'oldest', 'user', 'equipment'
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchPendingBookings();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRequest(
      BuildContext context, String bookingId, String status) async {
    final provider = context.read<BookingProvider>();
    final success = await provider.updateBookingStatus(bookingId, status);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Booking ${status == 'confirmed' ? 'approved' : 'rejected'} successfully!'),
            backgroundColor: AppColors.primaryMaroon,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Operation failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sort & Filter',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const Divider(height: 24),
                  const Text('Sort By',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  RadioListTile<String>(
                    title: const Text('Newest First'),
                    value: 'newest',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setModalState(() => _sortBy = value!);
                    },
                    activeColor: AppColors.primaryMaroon,
                  ),
                  RadioListTile<String>(
                    title: const Text('Oldest First'),
                    value: 'oldest',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setModalState(() => _sortBy = value!);
                    },
                    activeColor: AppColors.primaryMaroon,
                  ),
                  const Divider(height: 24),
                  const Text('Filter By',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  ListTile(
                    leading: const Icon(Icons.calendar_today,
                        color: AppColors.primaryMaroon),
                    title: Text(_filterDate == null
                        ? 'Select a Date'
                        : DateFormat('MMM dd, yyyy').format(_filterDate!)),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _filterDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primaryMaroon,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setModalState(() => _filterDate = pickedDate);
                      }
                    },
                  ),
                  if (_filterDate != null)
                    ListTile(
                      leading: const Icon(Icons.clear, color: AppColors.error),
                      title: const Text('Clear Date Filter'),
                      onTap: () {
                        setModalState(() => _filterDate = null);
                      },
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {}); // Apply changes to the main screen
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    // --- SEARCH AND FILTER LOGIC ---
    List<Booking> filteredBookings =
        bookingProvider.pendingBookings.where((booking) {
      final query = _searchQuery.toLowerCase();
      final matchesQuery = query.isEmpty ||
          booking.equipment.name.toLowerCase().contains(query) ||
          booking.user.name.toLowerCase().contains(query) ||
          booking.user.email.toLowerCase().contains(query) ||
          booking.purpose.toLowerCase().contains(query);

      final matchesDate = _filterDate == null ||
          DateUtils.isSameDay(booking.startTime.toLocal(), _filterDate);

      return matchesQuery && matchesDate;
    }).toList();

    // --- SORTING LOGIC ---
    filteredBookings.sort((a, b) {
      switch (_sortBy) {
        case 'oldest':
          return a.startTime.compareTo(b.startTime);
        case 'user':
          return a.user.name.compareTo(b.user.name);
        case 'equipment':
          return a.equipment.name.compareTo(b.equipment.name);
        case 'newest':
        default:
          return b.startTime.compareTo(a.startTime);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Approve Booking Requests'),
        backgroundColor: AppColors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(
                _isSearchVisible ? Icons.close : Icons.search,
                color: AppColors.textSecondary),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon:
                const Icon(Icons.filter_list, color: AppColors.textSecondary),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Animated Search Bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchVisible ? 80 : 0,
            color: AppColors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.lightGray,
                  ),
                ),
              ),
            ),
          ),
          
          // Active Filter Indicator
          if (_filterDate != null)
            Container(
              color: AppColors.lightGray,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Chip(
                label: Text(
                    'Date: ${DateFormat('MMM dd, yyyy').format(_filterDate!)}'),
                onDeleted: () {
                  setState(() => _filterDate = null);
                },
                deleteIconColor: AppColors.primaryMaroon,
              ),
            ),

          Expanded(
            child: _buildContent(bookingProvider, filteredBookings),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BookingProvider provider, List<Booking> bookings) {
    if (provider.isLoading && provider.pendingBookings.isEmpty) {
      return const Center(child: AmritaLoadingIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error: ${provider.errorMessage}',
            textAlign: TextAlign.center),
      ));
    }

    if (provider.pendingBookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: AppColors.textLight),
            SizedBox(height: 16),
            Text('No pending requests',
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    
    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: AppColors.textLight),
            SizedBox(height: 16),
            Text('No results found',
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
            Text('Try adjusting your search or filters.',
                style: TextStyle(color: AppColors.textLight)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchPendingBookings(),
      color: AppColors.primaryMaroon,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: _buildBookingCard(context, booking),
          );
        },
      ),
    );
  }

  // Card UI from previous step (no changes needed here)
  Widget _buildBookingCard(BuildContext context, Booking booking) {
    final formattedDate =
        DateFormat('MMM dd, yyyy').format(booking.startTime.toLocal());
    final formattedTime =
        '${DateFormat('hh:mm a').format(booking.startTime.toLocal())} - ${DateFormat('hh:mm a').format(booking.endTime.toLocal())}';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMaroon.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border(
          left: BorderSide(color: AppColors.primaryMaroon.withOpacity(0.5), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.biotech_outlined,
                    color: AppColors.primaryMaroon, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    booking.equipment.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                _buildInfoRow(Icons.person_outline, "User", booking.user.name),
                const SizedBox(height: 12),
                _buildInfoRow(
                    Icons.email_outlined, "Email", booking.user.email),
                const SizedBox(height: 12),
                _buildInfoRow(
                    Icons.calendar_today_outlined, "Date", formattedDate),
                const SizedBox(height: 12),
                _buildInfoRow(
                    Icons.access_time_outlined, "Time", formattedTime),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.notes_outlined, "Purpose", booking.purpose),
              ],
            ),
          ),
          _buildActionFooter(context, booking.id),
        ],
      ),
    );
  }
  
  Widget _buildActionFooter(BuildContext context, String bookingId) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2)))
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _handleRequest(context, bookingId, 'cancelled'),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                      SizedBox(width: 8),
                      Text('Reject', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ),
            Container(width: 1, color: Colors.grey.withOpacity(0.2)),
            Expanded(
              child: InkWell(
                onTap: () => _handleRequest(context, bookingId, 'confirmed'),
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, color: AppColors.primaryMaroon, size: 20),
                      SizedBox(width: 8),
                      Text('Approve', style: TextStyle(color: AppColors.primaryMaroon, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 16),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 15, height: 1.4),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
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