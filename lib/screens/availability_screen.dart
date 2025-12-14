import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../providers/availability_provider.dart';
import 'booking_confirmation_screen.dart';

class EquipmentAvailabilityPage extends StatefulWidget {
  final String equipmentId;

  const EquipmentAvailabilityPage({super.key, required this.equipmentId});

  @override
  State<EquipmentAvailabilityPage> createState() =>
      _EquipmentAvailabilityPageState();
}

class _EquipmentAvailabilityPageState extends State<EquipmentAvailabilityPage>
    with TickerProviderStateMixin {
  DateTime _selectedDay = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

  late AnimationController _contentController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadBookings();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(const Duration(milliseconds: 200), () {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    try {
      setState(() => _isLoading = true);
      await context
          .read<AvailabilityProvider>()
          .fetchBookings(widget.equipmentId);
    } catch (e) {
      debugPrint("❌ Error loading bookings: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildStyledSnackBar("Error loading bookings", isError: true),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryMaroon,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.black90,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryMaroon,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.black90,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _endTime = picked);
  
  }

  Future<void> _checkAvailability() async {
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildStyledSnackBar("Please select both start and end time",
            isError: true),
      );
      return;
    }

    final startDate = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endDate = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (endDate.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildStyledSnackBar("End time must be after start time",
            isError: true),
      );
      return;
    }

    if (startDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildStyledSnackBar("Cannot book past times", isError: true),
      );
      return;
    }

    final provider = context.read<AvailabilityProvider>();
    try {
      setState(() => _isLoading = true);
      await provider.fetchBookings(widget.equipmentId);
      final available = provider.isSlotAvailable(startDate, endDate);

      if (available) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingConfirmationScreen(
              equipmentId: widget.equipmentId,
              startDate: startDate,
              endDate: endDate,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildStyledSnackBar("Slot not available", isError: true),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildStyledSnackBar("Error checking availability", isError: true),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  SnackBar _buildStyledSnackBar(String message, {bool isError = false}) {
    return SnackBar(
      content: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: AppColors.white,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildTimeButton({
    required String label,
    required TimeOfDay? time,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: time != null ? color.withOpacity(0.3) : AppColors.divider,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: time != null
                  ? color.withOpacity(0.1)
                  : AppColors.black90.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              time != null ? _formatTime(time) : '--:-- --',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: time != null ? AppColors.textPrimary : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvailabilityProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Check Availability',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Select date & time slot',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AppColors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryMaroon,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primaryMaroon,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading availability...',
                      style: GoogleFonts.roboto(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Calendar Card
                        _buildAnimatedCard(
                          delay: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black90.withOpacity(0.06),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: TableCalendar(
                              firstDay: DateTime.now(),
                              lastDay: DateTime.now()
                                  .add(const Duration(days: 365)),
                              focusedDay: _selectedDay,
                              selectedDayPredicate: (day) =>
                                  isSameDay(day, _selectedDay),
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() => _selectedDay = selectedDay);
                              },
                              calendarStyle: CalendarStyle(
                                selectedDecoration: const BoxDecoration(
                                  color: AppColors.primaryMaroon,
                                  shape: BoxShape.circle,
                                ),
                                todayDecoration: BoxDecoration(
                                  color:
                                      AppColors.primaryMaroon.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                todayTextStyle: const TextStyle(
                                  color: AppColors.primaryMaroon,
                                  fontWeight: FontWeight.bold,
                                ),
                                selectedTextStyle: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                weekendTextStyle: const TextStyle(
                                  color: AppColors.error,
                                ),
                                outsideDaysVisible: false,
                              ),
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// Time Selection
                        _buildAnimatedCard(
                          delay: 100,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTimeButton(
                                  label: 'Start Time',
                                  time: _startTime,
                                  icon: Icons.play_circle_outline_rounded,
                                  color: AppColors.success,
                                  onTap: _pickStartTime,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTimeButton(
                                  label: 'End Time',
                                  time: _endTime,
                                  icon: Icons.stop_circle_outlined,
                                  color: AppColors.error,
                                  onTap: _pickEndTime,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// Check Availability Button
                        _buildAnimatedCard(
                          delay: 200,
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  (_startTime != null && _endTime != null)
                                      ? _checkAvailability
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryMaroon,
                                disabledBackgroundColor:
                                    AppColors.buttonDisabled,
                                elevation:
                                    (_startTime != null && _endTime != null)
                                        ? 4
                                        : 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: AppColors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.search_rounded,
                                                  color: (_startTime != null &&
                                                          _endTime != null)
                                                      ? AppColors.white
                                                      : AppColors.textLight,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Check Availability',
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        (_startTime != null &&
                                                                _endTime != null)
                                                            ? AppColors.white
                                                            : AppColors.textLight,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        /// Recent Bookings
                        if (provider.bookings.isNotEmpty)
                          ...provider.bookings.map(
                            (booking) => _buildAnimatedCard(
                              delay: 300,
                              child: _buildBookingCard(booking),
                            ),
                          ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final startTime = DateTime.parse(booking['startTime']).toLocal();
    final endTime = DateTime.parse(booking['endTime']).toLocal();
    final status = booking['status'] as String;

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'active':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'pending':
        statusColor = AppColors.warning;
        statusIcon = Icons.pending_rounded;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.info_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(startTime),
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEEE').format(startTime),
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.login_rounded,
                        color: AppColors.success,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start',
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('hh:mm a').format(startTime),
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1.5,
                  height: 40,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'End',
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('hh:mm a').format(endTime),
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
