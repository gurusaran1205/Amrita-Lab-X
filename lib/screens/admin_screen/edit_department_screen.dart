import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../providers/equipment_provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/admin_header.dart'; // Import AdminHeader

class EditDepartmentScreen extends StatefulWidget {
  final String departmentId;
  final String initialName;
  final String initialDescription;

  const EditDepartmentScreen({
    super.key,
    required this.departmentId,
    required this.initialName,
    required this.initialDescription,
  });

  @override
  State<EditDepartmentScreen> createState() => _EditDepartmentScreenState();
}

class _EditDepartmentScreenState extends State<EditDepartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<EquipmentProvider>();

    final success = await provider.updateDepartment(
      id: widget.departmentId, // ✅ FIXED: Correct parameter name
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      Fluttertoast.showToast(msg: "Department updated successfully!");
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: provider.errorMessage ?? "Failed to update",
        backgroundColor: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AdminHeader(title: "Edit Department"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                label: "Department Name",
                prefixIcon: const Icon(Icons.business),
                validator: (v) => v!.isEmpty ? "Name required" : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _descriptionController,
                label: "Description",
                maxLines: 3,
                prefixIcon: const Icon(Icons.description),
                validator: (v) => v!.isEmpty ? "Description required" : null,
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                text: "Save Changes",
                isLoading: _isLoading,
                onPressed: _handleUpdate,
              )
            ],
          ),
        ),
      ),
    );
  }
}
