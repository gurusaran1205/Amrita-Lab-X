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
}
