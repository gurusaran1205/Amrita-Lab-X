import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:http/http.dart' as http;
import '../models/department.dart';
import '../models/lab.dart';
import '../models/equipment.dart';
import '../models/booking.dart';

class ApiService {
  final String baseUrl = 'http://107.21.163.19';
  final String? token;

  ApiService({this.token});

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Get all departments
  Future<List<Department>> fetchDepartments() async {
    final response = await http.get(Uri.parse("$baseUrl/api/departments"),
        headers: _headers);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Department.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load departments");
    }
  }

  // Get labs by department id
  Future<List<Lab>> fetchLabs({required String departmentId}) async {
    final uri = Uri.parse("$baseUrl/api/labs")
        .replace(queryParameters: {'department': departmentId});
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Lab.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load labs");
    }
  }

  // Get equipment by lab id
  Future<List<Equipment>> fetchEquipment({required String labId}) async {
    final uri = Uri.parse("$baseUrl/api/equipment")
        .replace(queryParameters: {'lab': labId});
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Equipment.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load equipment");
    }
  }

  // Add a new department
  Future<bool> addDepartment(Department department) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/departments"),
      headers: _headers,
      body: json.encode(department.toJson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint("Failed to add department. Status: ${response.statusCode}, Body: ${response.body}");
      return false;
    }
  }

  // Add a new lab
  Future<bool> addLab(Lab lab) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/labs"),
      headers: _headers,
      body: json.encode(lab.toJson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint("Failed to add lab. Status: ${response.statusCode}, Body: ${response.body}");
      return false;
    }
  }

  // Add new equipment
  Future<bool> addEquipment(Equipment equipment) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/equipment"),
      headers: _headers,
      body: json.encode(equipment.toJson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint("Failed to add equipment. Status: ${response.statusCode}, Body: ${response.body}");
      return false;
    }
  }
  
  Future<String?> getLabEntranceQr(String labId) async {
    final uri = Uri.parse("$baseUrl/api/labs/$labId/qrcode");
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return json.decode(response.body)['qrCodeDataURL'];
    } else {
      throw Exception('Failed to get lab entrance QR code');
    }
  }

  Future<String?> getLabLogoutQr(String labId) async {
    final uri = Uri.parse("$baseUrl/api/labs/$labId/logout-qrcode");
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return json.decode(response.body)['qrCodeDataURL'];
    } else {
      throw Exception('Failed to get lab logout QR code');
    }
  }

  Future<String?> getEquipmentQr(String equipmentId) async {
    final uri = Uri.parse("$baseUrl/api/equipment/$equipmentId/qrcode");
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return json.decode(response.body)['qrCodeDataURL'];
    } else {
      throw Exception('Failed to get equipment QR code');
    }
  }

  // Fetch pending bookings for admin
  Future<List<Booking>> fetchPendingBookings() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/bookings/pending"),
      headers: _headers,
    );

    // --- CONSOLE LOG ADDED HERE ---
    debugPrint("--- FETCH PENDING BOOKINGS ---");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Response Body: ${response.body}");
    debugPrint("----------------------------");

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Booking.fromJson(e)).toList();
    } else if (response.statusCode == 403) {
      throw Exception("Access Denied. Admin role required.");
    } else {
      throw Exception("Failed to load pending bookings (Status code: ${response.statusCode})");
    }
  }

  // Update booking status for admin
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    final response = await http.put(
      Uri.parse("$baseUrl/api/bookings/$bookingId/status"),
      headers: _headers,
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 403) {
      throw Exception("Access Denied. Admin role required.");
    } else {
      throw Exception("Failed to update booking status (Status code: ${response.statusCode})");
    }
  }
}