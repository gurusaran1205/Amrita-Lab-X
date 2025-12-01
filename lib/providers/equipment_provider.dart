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
    errorMessage = null;
    labs = [];
    notifyListeners();

    try {
      labs = await _apiService.fetchLabs(departmentId: dept.id);
      selectedLab = null;
      equipments = [];
      selectedEquipment = null;
    } catch (e) {
      errorMessage = "Failed to load labs: $e";
    }

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

  Future<bool> addDepartment({
    required String name,
    required String description,
  }) async {
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      errorMessage = "Authentication token not found. Please log in again.";
      notifyListeners();
      return false;
    }

    errorMessage = null;
    notifyListeners();

    try {
      final newDepartment = Department(
        id: '',
        name: name,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _apiService.addDepartment(newDepartment);

      if (success) {
        await loadDepartments();
        return true;
      } else {
        errorMessage = "Server failed to add the department.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "An error occurred: $e";
      notifyListeners();
      return false;
    }
  }

  // ✅ NEW: Update Department
  Future<bool> updateDepartment({
    required String id,
    required String name,
    required String description,
  }) async {
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      errorMessage = "Authentication token not found. Please log in again.";
      notifyListeners();
      return false;
    }

    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final updatedDept = Department(
        id: id,
        name: name,
        description: description,
        createdAt:
            DateTime.now(), // backend's createdAt will be ignored if provided
        updatedAt: DateTime.now(),
      );

      final success = await _apiService.updateDepartment(updatedDept);

      if (success) {
        await loadDepartments(); // refresh UI after successful update
        return true;
      } else {
        errorMessage = "Failed to update department.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Error updating department: $e";
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addLab({
    required String name,
    required String location,
    required String departmentId,
  }) async {
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      errorMessage = "Authentication token not found. Please log in again.";
      notifyListeners();
      return false;
    }

    errorMessage = null;
    notifyListeners();

    try {
      final newLab = Lab(
        id: '',
        name: name,
        location: location,
        department: DepartmentRef(id: departmentId, name: ''),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _apiService.addLab(newLab);

      if (success) {
        return true;
      } else {
        errorMessage = "Server failed to add the lab.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "An error occurred while adding the lab: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> addEquipment({
    required String name,
    required String type,
    required String modelNumber,
    required String description,
    required String labId,
  }) async {
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      errorMessage = "Authentication token not found. Please log in again.";
      notifyListeners();
      return false;
    }

    errorMessage = null;
    notifyListeners();

    try {
      final newEquipment = Equipment(
        id: '',
        name: name,
        type: type,
        modelNumber: modelNumber,
        description: description,
        status: 'available',
        lab: LabRef(id: labId, name: ''),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _apiService.addEquipment(newEquipment);

      if (success) {
        return true;
      } else {
        errorMessage = "Server failed to add the equipment.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "An error occurred while adding equipment: $e";
      notifyListeners();
      return false;
    }
  }
  // DELETE Department
  Future<bool> deleteDepartment(String deptId) async {
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      errorMessage = "Authentication token not found. Please log in again.";
      notifyListeners();
      return false;
    }

    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.deleteDepartment(deptId);

      if (success) {
        await loadDepartments(); // refresh list
        return true;
      } else {
        errorMessage = "Failed to delete department.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Error deleting department: $e";
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // UPDATE Lab
  Future<bool> updateLab({
    required String id,
    required String name,
    required String location,
    required String departmentId,
  }) async {
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      errorMessage = "Authentication token not found. Please log in again.";
      notifyListeners();
      return false;
    }

    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final updatedLab = Lab(
        id: id,
        name: name,
        location: location,
        department: DepartmentRef(id: departmentId, name: ''),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _apiService.updateLab(updatedLab);

      if (success) {
        if (selectedDept != null && selectedDept!.id == departmentId) {
          await selectDepartment(selectedDept!);
        }
        return true;
      } else {
        errorMessage = "Failed to update lab.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Error updating lab: $e";
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // DELETE Lab
  Future<bool> deleteLab(String labId) async {
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      errorMessage = "Authentication token not found. Please log in again.";
      notifyListeners();
      return false;
    }

    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.deleteLab(labId);

      if (success) {
        if (selectedDept != null) {
          await selectDepartment(selectedDept!);
        }
        return true;
      } else {
        errorMessage = "Failed to delete lab.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Error deleting lab: $e";
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // UPDATE Equipment
  Future<bool> updateEquipment({
    required String id,
    required String name,
    required String type,
    required String modelNumber,
    required String description,
    required String status,
    required String labId,
  }) async {
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      errorMessage = "Authentication token not found. Please log in again.";
      notifyListeners();
      return false;
    }

    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final updatedEquipment = Equipment(
        id: id,
        name: name,
        type: type,
        modelNumber: modelNumber,
        description: description,
        status: status,
        lab: LabRef(id: labId, name: ''),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _apiService.updateEquipment(updatedEquipment);

      if (success) {
        if (selectedLab != null && selectedLab!.id == labId) {
          await selectLab(selectedLab!);
        }
        return true;
      } else {
        errorMessage = "Failed to update equipment.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Error updating equipment: $e";
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // DELETE Equipment
  Future<bool> deleteEquipment(String equipmentId) async {
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      errorMessage = "Authentication token not found. Please log in again.";
      notifyListeners();
      return false;
    }

    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.deleteEquipment(equipmentId);

      if (success) {
        if (selectedLab != null) {
          await selectLab(selectedLab!);
        }
        return true;
      } else {
        errorMessage = "Failed to delete equipment.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Error deleting equipment: $e";
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
