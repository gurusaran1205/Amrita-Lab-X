import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/booking_provider.dart';

class EquipmentAvailabilityPage extends StatefulWidget {
  final String equipmentId;
  final String equipmentName;

  const EquipmentAvailabilityPage({
    super.key,
    required this.equipmentId,
    required this.equipmentName,
  });

  @override
  State<EquipmentAvailabilityPage> createState() =>
      _EquipmentAvailabilityPageState();
}

class _EquipmentAvailabilityPageState extends State<EquipmentAvailabilityPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<BookingProvider>(context, listen: false);
    Provider.of<BookingProvider>(context, listen: false)
        .fetchEquipmentBookings(widget.equipmentId, auth.token!);
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Availability: ${widget.equipmentName}"),
      ),
      body: bookingProvider.bookings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime(DateTime.now().year + 1),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final booked = bookingProvider.isBooked(day);
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: booked ? Colors.redAccent : Colors.greenAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "${day.day}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_selectedDay != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    "Bookings on ${_selectedDay!.toLocal()}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView(
                      children: bookingProvider.bookings
                          .where((b) =>
                              DateTime.parse(b['startTime']).day ==
                              _selectedDay!.day)
                          .map((b) => ListTile(
                                title: Text(
                                    "From ${b['startTime']} to ${b['endTime']}"),
                                subtitle: Text("Status: ${b['status']}"),
                                leading: const Icon(Icons.schedule),
                              ))
                          .toList(),
                    ),
                  ),
                ]
              ],
            ),
    );
  }
}
