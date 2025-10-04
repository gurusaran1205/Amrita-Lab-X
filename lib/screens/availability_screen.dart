import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/availability_provider.dart';
import 'booking_confirmation_screen.dart';

class EquipmentAvailabilityPage extends StatefulWidget {
  final String equipmentId;

  const EquipmentAvailabilityPage({super.key, required this.equipmentId});

  @override
  State<EquipmentAvailabilityPage> createState() =>
      _EquipmentAvailabilityPageState();
}

class _EquipmentAvailabilityPageState extends State<EquipmentAvailabilityPage> {
  DateTime _selectedDay = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      setState(() => _isLoading = true);
      await context
          .read<AvailabilityProvider>()
          .fetchBookings(widget.equipmentId);
    } catch (e) {
      debugPrint("❌ Error loading bookings: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error loading bookings: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _checkAvailability() async {
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select both start and end time")));
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
          const SnackBar(content: Text("End time must be after start time")));
      return;
    }

    if (startDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot book past times")));
      return;
    }

    final provider = context.read<AvailabilityProvider>();
    try {
      setState(() => _isLoading = true);
      await provider.fetchBookings(widget.equipmentId);
      final available = provider.isSlotAvailable(startDate, endDate);

      if (available) {
        // ✅ Navigate to confirmation screen
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
            const SnackBar(content: Text("❌ Slot not available")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error checking availability: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvailabilityProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Select Availability")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _selectedDay,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                  onDaySelected: (selectedDay, _) =>
                      setState(() => _selectedDay = selectedDay),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickStartTime,
                  child: Text(_startTime == null
                      ? "Pick Start Time"
                      : "Start: ${_startTime!.format(context)}"),
                ),
                ElevatedButton(
                  onPressed: _pickEndTime,
                  child: Text(_endTime == null
                      ? "Pick End Time"
                      : "End: ${_endTime!.format(context)}"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkAvailability,
                  child: const Text("Check Availability"),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: provider.bookings.isEmpty
                      ? const Center(child: Text("No bookings found"))
                      : ListView.builder(
                          itemCount: provider.bookings.length,
                          itemBuilder: (context, i) {
                            final b = provider.bookings[i];
                            return ListTile(
                              title: Text(
                                "Booked: ${DateTime.parse(b['startTime']).toLocal()} → ${DateTime.parse(b['endTime']).toLocal()}",
                              ),
                              subtitle: Text("Status: ${b['status']}"),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
