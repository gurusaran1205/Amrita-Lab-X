import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';

class AvailabilityProvider with ChangeNotifier {
  final AuthProvider authProvider;
  final String baseUrl = "http://107.21.163.19";

  AvailabilityProvider({required this.authProvider});

  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> get bookings => _bookings;

  Future<void> fetchBookings(String equipmentId) async {
    final token = authProvider.token;
    if (token == null || token.isEmpty) {
      debugPrint("⚠️ No token found. Please log in first.");
      throw Exception("User not authenticated");
    }

    final url = Uri.parse('$baseUrl/api/bookings/equipment/$equipmentId');
    debugPrint("📡 Fetching bookings from: $url");

    final res = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      _bookings = List<Map<String, dynamic>>.from(jsonDecode(res.body));
      debugPrint("✅ Bookings fetched: ${_bookings.length}");
      notifyListeners();
    } else {
      debugPrint("❌ Failed to fetch bookings: ${res.statusCode} - ${res.body}");
      throw Exception("Failed to fetch bookings");
    }
  }

  /// ✅ Booking API call
  Future<void> bookSlot({
    required String equipmentId,
    required DateTime start,
    required DateTime end,
    required String purpose,
  }) async {
    final token = authProvider.token;
    if (token == null || token.isEmpty) {
      throw Exception("User not authenticated");
    }

    final url = Uri.parse('$baseUrl/api/bookings');
    debugPrint("📡 Booking slot at: $url");

    final body = jsonEncode({
      "equipmentId": equipmentId,
      "startTime": start.toUtc().toIso8601String(),
      "endTime": end.toUtc().toIso8601String(),
      "purpose": purpose,
    });

    final res = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: body,
    );

    if (res.statusCode == 201) {
      debugPrint("✅ Booking successful");
      await fetchBookings(equipmentId); // refresh bookings
    } else {
      debugPrint("❌ Booking failed: ${res.statusCode} - ${res.body}");
      throw Exception("Booking failed: ${res.body}");
    }
  }

  bool isSlotAvailable(DateTime start, DateTime end) {
    for (var booking in _bookings) {
      final existingStart = DateTime.parse(booking['startTime']).toLocal();
      final existingEnd = DateTime.parse(booking['endTime']).toLocal();

      if (start.isBefore(existingEnd) && end.isAfter(existingStart)) {
        debugPrint("⛔ Overlap found: $existingStart → $existingEnd");
        return false;
      }
    }
    debugPrint("✅ Slot available: $start → $end");
    return true;
  }
}
