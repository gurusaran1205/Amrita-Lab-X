import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/equipment_provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/admin_header.dart'; // Import AdminHeader

class EditEquipmentScreen extends StatefulWidget {
  final String equipmentId;
  final String initialName;
  final String initialType;
  final String initialModel;
  final String initialDescription;
  final String initialStatus;
  final String labId;

  const EditEquipmentScreen({
    super.key,
    required this.equipmentId,
    required this.initialName,
    required this.initialType,
    required this.initialModel,
    required this.initialDescription,
    required this.initialStatus,
    required this.labId,
  });

  @override
  State<EditEquipmentScreen> createState() => _EditEquipmentScreenState();
}

class _EditEquipmentScreenState extends State<EditEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _modelController;
  late TextEditingController _descriptionController;
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _typeController = TextEditingController(text: widget.initialType);
    _modelController = TextEditingController(text: widget.initialModel);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _status = widget.initialStatus;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _modelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<EquipmentProvider>();

    final success = await provider.updateEquipment(
      id: widget.equipmentId,
      name: _nameController.text.trim(),
      type: _typeController.text.trim(),
      modelNumber: _modelController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _status,
      labId: widget.labId,
    );

    setState(() => _isLoading = false);

    if (success) {
      Fluttertoast.showToast(msg: "Equipment updated successfully!");
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
      appBar: const AdminHeader(title: "Edit Equipment"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                label: "Equipment Name",
                prefixIcon: const Icon(Icons.biotech),
                validator: (v) => v!.isEmpty ? "Name required" : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _typeController,
                label: "Type",
                prefixIcon: const Icon(Icons.category),
                validator: (v) => v!.isEmpty ? "Type required" : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _modelController,
                label: "Model Number",
                prefixIcon: const Icon(Icons.numbers),
                validator: (v) => v!.isEmpty ? "Model required" : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _descriptionController,
                label: "Description",
                prefixIcon: const Icon(Icons.description),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Description required" : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                value: _status,
                items: ['available', 'maintenance', 'broken'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
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
