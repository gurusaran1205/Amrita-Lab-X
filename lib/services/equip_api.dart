import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/department.dart';
import '../models/lab.dart';
import '../models/equipment.dart';

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
      print("Failed to add department. Status: ${response.statusCode}, Body: ${response.body}");
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
      print("Failed to add lab. Status: ${response.statusCode}, Body: ${response.body}");
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
      print("Failed to add equipment. Status: ${response.statusCode}, Body: ${response.body}");
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
}