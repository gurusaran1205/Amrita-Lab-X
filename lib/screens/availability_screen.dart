import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/availability_provider.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AvailabilityProvider>().fetchBookings(widget.equipmentId);
    });
  }

  Future<void> _pickStartTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  void _checkAvailability() {
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both start and end time")),
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
        const SnackBar(content: Text("End time must be after start time")),
      );
      return;
    }

    if (startDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot book past times")),
      );
      return;
    }

    final available = context
        .read<AvailabilityProvider>()
        .isSlotAvailable(startDate, endDate);
    if (available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Slot is available")),
      );
      // Navigate to booking form (purpose input + confirm)
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Slot not available")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvailabilityProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Select Availability")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, _) {
              setState(() => _selectedDay = selectedDay);
            },
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
            child: ListView.builder(
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
