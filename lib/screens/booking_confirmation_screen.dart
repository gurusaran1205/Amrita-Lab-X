import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/availability_provider.dart'; // adjust import based on your folder structure

class BookingConfirmationScreen extends StatefulWidget {
  final String equipmentId;
  final DateTime startDate;
  final DateTime endDate;

  const BookingConfirmationScreen({
    super.key,
    required this.equipmentId,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final _purposeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Booking")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Equipment ID: ${widget.equipmentId}"),
            const SizedBox(height: 10),
            Text("Start Time: ${widget.startDate}"),
            const SizedBox(height: 10),
            Text("End Time: ${widget.endDate}"),
            const SizedBox(height: 20),
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: "Purpose of booking",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_purposeController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please enter purpose")),
                          );
                          return;
                        }

                        setState(() => _isLoading = true);
                        try {
                          await context.read<AvailabilityProvider>().bookSlot(
                                equipmentId: widget.equipmentId,
                                start: widget.startDate,
                                end: widget.endDate,
                                purpose: _purposeController.text,
                              );

                          // Navigate to success screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BookingSuccessScreen(),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("❌ Booking failed: $e")),
                          );
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Confirm Booking"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Confirmed")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Your booking is confirmed!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
