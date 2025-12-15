import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/department.dart';
import '../../models/lab.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/admin_header.dart'; // Import AdminHeader

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({super.key});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _modelNumberController = TextEditingController();

  Department? _selectedDepartment;
  Lab? _selectedLab;
  String? _selectedType;
  bool _isLoading = false;
  bool _isLabsLoading = false;

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
    _modelNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleAddEquipment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedLab == null || _selectedType == null) {
      Fluttertoast.showToast(msg: 'Please complete all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<EquipmentProvider>();
    final success = await provider.addEquipment(
      name: _nameController.text.trim(),
      type: _selectedType!,
      modelNumber: _modelNumberController.text.trim(),
      description: '',
      labId: _selectedLab!.id,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Fluttertoast.showToast(msg: 'Equipment added successfully!');
      Navigator.of(context).pop();
    } else {
      Fluttertoast.showToast(
        msg: provider.errorMessage ?? 'Failed to add equipment',
        backgroundColor: AppColors.error,
      );
    }
  }

  void _onDepartmentChanged(Department? newDepartment) async {
    if (newDepartment == null) return;

    setState(() {
      _selectedDepartment = newDepartment;
      _selectedLab = null;
      _isLabsLoading = true;
    });

    final provider = context.read<EquipmentProvider>();
    await provider.selectDepartment(newDepartment);

    setState(() {
      _isLabsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AdminHeader(title: 'Add New Equipment'),

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
              _buildLabDropdown(),
              const SizedBox(height: AppConstants.defaultPadding),
              CustomTextField(
                controller: _nameController,
                label: 'Equipment Name',
                hintText: 'e.g., Oscilloscope',
                prefixIcon: const Icon(Icons.biotech_outlined),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildTypeDropdown(),
              const SizedBox(height: AppConstants.defaultPadding),
              CustomTextField(
                controller: _modelNumberController,
                label: 'Model Number',
                hintText: 'e.g., DSOX1204G',
                prefixIcon: const Icon(Icons.confirmation_number_outlined),
                validator: (value) => value == null || value.isEmpty
                    ? 'Model number is required'
                    : null,
              ),
              const SizedBox(height: AppConstants.largePadding * 2),
              PrimaryButton(
                text: 'Add Equipment',
                onPressed: _handleAddEquipment,
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
          Icons.biotech_outlined,
          size: 60,
          color: AppColors.primaryMaroon.withOpacity(0.8),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Text(
          'Add New Equipment',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          'Categorize the new equipment by selecting its department and lab.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Equipment Type',
        prefixIcon: const Icon(Icons.category_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
      ),
      hint: const Text('Select a Type'),
      items: ['Major', 'Minor'].map((String type) {
        return DropdownMenuItem<String>(
          value: type.toLowerCase(),
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedType = newValue;
        });
      },
      validator: (value) => value == null ? 'Please select a type' : null,
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
          onChanged: _onDepartmentChanged,
          validator: (value) =>
              value == null ? 'Please select a department' : null,
        );
      },
    );
  }

  Widget _buildLabDropdown() {
    return Consumer<EquipmentProvider>(
      builder: (context, provider, child) {
        if (_isLabsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_selectedDepartment == null) {
          return DropdownButtonFormField<Lab>(
            decoration: InputDecoration(
              labelText: 'Lab',
              prefixIcon: const Icon(Icons.science_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              ),
              filled: true,
              fillColor: AppColors.lightGray,
            ),
            hint: const Text('Select a department first'),
            items: const [],
            onChanged: null,
          );
        }

        return DropdownButtonFormField<Lab>(
          value: _selectedLab,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Lab',
            prefixIcon: const Icon(Icons.science_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
          ),
          hint: const Text('Select a Lab'),
          items: provider.labs.map((Lab lab) {
            return DropdownMenuItem<Lab>(
              value: lab,
              child: Text(lab.name),
            );
          }).toList(),
          onChanged: (Lab? newValue) {
            setState(() {
              _selectedLab = newValue;
            });
          },
          validator: (value) => value == null ? 'Please select a lab' : null,
        );
      },
    );
  }
}
