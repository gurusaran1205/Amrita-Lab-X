import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/equipment_provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditLabScreen extends StatefulWidget {
  final String labId;
  final String initialName;
  final String initialLocation;
  final String departmentId;

  const EditLabScreen({
    super.key,
    required this.labId,
    required this.initialName,
    required this.initialLocation,
    required this.departmentId,
  });

  @override
  State<EditLabScreen> createState() => _EditLabScreenState();
}

class _EditLabScreenState extends State<EditLabScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _locationController = TextEditingController(text: widget.initialLocation);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<EquipmentProvider>();

    final success = await provider.updateLab(
      id: widget.labId,
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      departmentId: widget.departmentId,
    );

    setState(() => _isLoading = false);

    if (success) {
      Fluttertoast.showToast(msg: "Lab updated successfully!");
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
      appBar: AppBar(
        title: const Text("Edit Lab"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                label: "Lab Name",
                prefixIcon: const Icon(Icons.science),
                validator: (v) => v!.isEmpty ? "Name required" : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _locationController,
                label: "Location",
                prefixIcon: const Icon(Icons.location_on),
                validator: (v) => v!.isEmpty ? "Location required" : null,
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
