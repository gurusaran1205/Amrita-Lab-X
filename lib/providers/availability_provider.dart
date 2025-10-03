import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';

class AvailabilityProvider with ChangeNotifier {
  final AuthProvider authProvider;
  final String baseUrl = "http://107.21.163.19/"; // keep one base

  AvailabilityProvider({required this.authProvider});

  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> get bookings => _bookings;

  Future<void> fetchBookings(String equipmentId) async {
    final url = Uri.parse('$baseUrl/api/bookings/equipment/$equipmentId');
    final res = await http.get(url, headers: {
      "Authorization": "Bearer ${authProvider.token}",
      "Content-Type": "application/json",
    });

    if (res.statusCode == 200) {
      _bookings = List<Map<String, dynamic>>.from(jsonDecode(res.body));
      notifyListeners();
    } else {
      throw Exception("Failed to fetch bookings");
    }
  }

  bool isSlotAvailable(DateTime start, DateTime end) {
    for (var booking in _bookings) {
      final existingStart = DateTime.parse(booking['startTime']);
      final existingEnd = DateTime.parse(booking['endTime']);
      if (start.isBefore(existingEnd) && end.isAfter(existingStart)) {
        return false; // overlap
      }
    }
    return true;
  }
}
