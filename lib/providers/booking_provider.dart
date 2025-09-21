import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingProvider extends ChangeNotifier {
  final String baseUrl =
      "http://107.21.163.19"; // TODO: replace with real base URL
  String? _token;

  List<Map<String, dynamic>> bookings = [];
  String? get token => _token;

  // Store token from login
  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  // ✅ Create booking
  Future<Map<String, dynamic>> createBooking({
    required String equipmentId,
    required DateTime startTime,
    required DateTime endTime,
    required String purpose,
  }) async {
    if (_token == null) {
      return {"success": false, "message": "Not authenticated"};
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/bookings"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode({
          "equipment": equipmentId,
          "startTime": startTime.toUtc().toIso8601String(),
          "endTime": endTime.toUtc().toIso8601String(),
          "purpose": purpose,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "message": error['message'] ?? "Booking failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ✅ Fetch bookings for user (optional)
  Future<List<Map<String, dynamic>>> getMyBookings() async {
    if (_token == null) return [];

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/bookings/me"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      if (response.statusCode == 200) {
        final List bookings = jsonDecode(response.body);
        return bookings.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  // ✅ Cancel a booking (optional)
  Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    if (_token == null) {
      return {"success": false, "message": "Not authenticated"};
    }

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/api/bookings/$bookingId"),
        headers: {
          "Authorization": "Bearer $_token",
        },
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": "Booking cancelled"};
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "message": error['message'] ?? "Failed to cancel"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  Future<void> fetchEquipmentBookings(String equipmentId, String token) async {
    final url = Uri.parse("$baseUrl/api/bookings/equipment/$equipmentId");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      bookings = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      notifyListeners();
    } else {
      throw Exception("Failed to load bookings");
    }
  }

  /// Check if a given [dateTime] falls into an already booked slot
  bool isBooked(DateTime dateTime) {
    for (var booking in bookings) {
      final start = DateTime.parse(booking['startTime']);
      final end = DateTime.parse(booking['endTime']);
      if (dateTime.isAfter(start) && dateTime.isBefore(end)) {
        return true;
      }
    }
    return false;
  }
}
