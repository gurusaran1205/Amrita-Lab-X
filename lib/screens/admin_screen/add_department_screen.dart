import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class AddDepartmentScreen extends StatefulWidget {
  const AddDepartmentScreen({super.key});

  @override
  State<AddDepartmentScreen> createState() => _AddDepartmentScreenState();
}

class _AddDepartmentScreenState extends State<AddDepartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleAddDepartment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<EquipmentProvider>();
    final success = await provider.addDepartment(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Fluttertoast.showToast(msg: 'Department added successfully!');
      Navigator.of(context).pop();
    } else {
      Fluttertoast.showToast(
        msg: provider.errorMessage ?? 'Failed to add department',
        backgroundColor: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New Department'),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: AppConstants.largePadding * 2),
              CustomTextField(
                controller: _nameController,
                label: 'Department Name',
                hintText: 'e.g., Computer Science',
                prefixIcon: const Icon(Icons.business_outlined),
                validator: (value) => value == null || value.isEmpty
                    ? 'Department name is required'
                    : null,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hintText: 'A short description of the department',
                prefixIcon: const Icon(Icons.description_outlined),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: AppConstants.largePadding * 2),
              PrimaryButton(
                text: 'Add Department',
                onPressed: _handleAddDepartment,
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
          Icons.add_business_outlined,
          size: 60,
          color: AppColors.primaryMaroon.withOpacity(0.8),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Text(
          'Create a New Department',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          'This will serve as a category for organizing labs and equipment.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}