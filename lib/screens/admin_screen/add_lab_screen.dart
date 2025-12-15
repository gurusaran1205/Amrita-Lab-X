import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/department.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/admin_header.dart'; // Import AdminHeader

class AddLabScreen extends StatefulWidget {
  const AddLabScreen({super.key});

  @override
  State<AddLabScreen> createState() => _AddLabScreenState();
}

class _AddLabScreenState extends State<AddLabScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  Department? _selectedDepartment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EquipmentProvider>();
      if (provider.departments.isEmpty) {
        provider.loadDepartments();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleAddLab() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDepartment == null) {
      Fluttertoast.showToast(msg: 'Please select a department');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<EquipmentProvider>();
    final success = await provider.addLab(
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      departmentId: _selectedDepartment!.id,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Fluttertoast.showToast(msg: 'Lab added successfully!');
      Navigator.of(context).pop();
    } else {
      Fluttertoast.showToast(
        msg: provider.errorMessage ?? 'Failed to add lab',
        backgroundColor: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AdminHeader(title: 'Add New Laboratory'),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: AppConstants.largePadding * 2),
              _buildDepartmentDropdown(),
              const SizedBox(height: AppConstants.defaultPadding),
              CustomTextField(
                controller: _nameController,
                label: 'Lab Name',
                hintText: 'e.g., IoT Lab',
                prefixIcon: const Icon(Icons.science_outlined),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Lab name is required' : null,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              CustomTextField(
                controller: _locationController,
                label: 'Location',
                hintText: 'e.g., AB1, Room 203',
                prefixIcon: const Icon(Icons.location_on_outlined),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Location is required' : null,
              ),
              const SizedBox(height: AppConstants.largePadding * 2),
              PrimaryButton(
                text: 'Add Lab',
                onPressed: _handleAddLab,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.science_outlined,
          size: 60,
          color: AppColors.primaryMaroon.withOpacity(0.8),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Text(
          'Create a New Lab',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          'Assign the new lab to its parent department.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildDepartmentDropdown() {
    return Consumer<EquipmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.departments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return DropdownButtonFormField<Department>(
          value: _selectedDepartment,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Department',
            prefixIcon: const Icon(Icons.business_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
          ),
          hint: const Text('Select a Department'),
          items: provider.departments.map((Department department) {
            return DropdownMenuItem<Department>(
              value: department,
              child: Text(department.name),
            );
          }).toList(),
          onChanged: (Department? newValue) {
            setState(() {
              _selectedDepartment = newValue;
            });
          },
          validator: (value) =>
              value == null ? 'Please select a department' : null,
        );
      },
    );
  }
}
