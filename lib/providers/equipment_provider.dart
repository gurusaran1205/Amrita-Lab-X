import 'package:flutter/material.dart';
import '../models/department.dart';
import '../models/lab.dart';
import '../models/equipment.dart';
import '../services/equip_api.dart';
import 'auth_provider.dart';

class EquipmentProvider extends ChangeNotifier {
  final AuthProvider authProvider;

  EquipmentProvider({required this.authProvider});

  // Dropdown Data
  List<Department> departments = [];
  List<Lab> labs = [];
  List<Equipment> equipments = [];

  // Selections
  Department? selectedDept;
  Lab? selectedLab;
  Equipment? selectedEquipment;

  // Loading/Error
  bool isLoading = false;
  String? errorMessage;

  ApiService get _apiService => ApiService(token: authProvider.token);

  Future<void> loadDepartments() async {
    if (authProvider.token == null || authProvider.token!.isEmpty) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      departments = await _apiService.fetchDepartments();
      labs = [];
      equipments = [];
      selectedDept = null;
      selectedLab = null;
      selectedEquipment = null;
    } catch (e) {
      errorMessage = "Failed to load departments: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> selectDepartment(Department dept) async {
    selectedDept = dept;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      labs = await _apiService.fetchLabs(departmentId: dept.id);
      selectedLab = null;
      equipments = [];
      selectedEquipment = null;
    } catch (e) {
      errorMessage = "Failed to load labs: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> selectLab(Lab lab) async {
    selectedLab = lab;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      equipments = await _apiService.fetchEquipment(labId: lab.id);
      selectedEquipment = null;
    } catch (e) {
      errorMessage = "Failed to load equipments: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  void selectEquipment(Equipment equip) {
    selectedEquipment = equip;
    notifyListeners();
  }
}
