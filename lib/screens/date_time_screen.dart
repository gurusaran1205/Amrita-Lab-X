import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/booking_provider.dart';

class BookingPage extends StatefulWidget {
  final String equipmentId; // from equipment selection screen

  const BookingPage({super.key, required this.equipmentId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final TextEditingController purposeController = TextEditingController();

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now, // ✅ future only
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => startTime = picked);
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => endTime = picked);
  }

  void submitBooking() async {
    if (selectedDate == null || startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select date, start time, and end time")),
      );
      return;
    }

    // Merge date & time
    final startDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      startTime!.hour,
      startTime!.minute,
    );
    final endDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End time must be after start time")),
      );
      return;
    }

    // Call API via AuthProvider
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final response = await bookingProvider.createBooking(
      equipmentId: widget.equipmentId,
      startTime: startDateTime,
      endTime: endDateTime,
      purpose: purposeController.text,
    );

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking created successfully")),
      );
      Navigator.pop(context); // go back
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Booking failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Equipment")),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date picker
            ListTile(
              title: Text(selectedDate == null
                  ? "Select Date"
                  : DateFormat.yMMMd().format(selectedDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: pickDate,
            ),

            // Start time
            ListTile(
              title: Text(startTime == null
                  ? "Select Start Time"
                  : startTime!.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: pickStartTime,
            ),

            // End time
            ListTile(
              title: Text(endTime == null
                  ? "Select End Time"
                  : endTime!.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: pickEndTime,
            ),

            // Purpose
            TextField(
              controller: purposeController,
              decoration: const InputDecoration(
                labelText: "Purpose",
                hintText: "E.g. Running model training",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: submitBooking,
              child: const Text("Submit Booking"),
            ),
          ],
        ),
      ),
    );
  }
}
