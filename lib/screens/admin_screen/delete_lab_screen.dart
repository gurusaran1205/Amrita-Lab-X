import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/equipment_provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../models/department.dart';

class DeleteLabScreen extends StatefulWidget {
  const DeleteLabScreen({super.key});

  @override
  State<DeleteLabScreen> createState() => _DeleteLabScreenState();
}

class _DeleteLabScreenState extends State<DeleteLabScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EquipmentProvider>().loadDepartments();
    });
  }

  Future<void> _handleDelete(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete '$name'?\nThis action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<EquipmentProvider>().deleteLab(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lab deleted successfully")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Delete Lab"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Consumer<EquipmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.departments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Department Selector
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: DropdownButtonFormField<Department>(
                  decoration: const InputDecoration(
                    labelText: "Select Department",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  value: provider.selectedDept,
                  items: provider.departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept,
                      child: Text(dept.name),
                    );
                  }).toList(),
                  onChanged: (dept) {
                    if (dept != null) {
                      provider.selectDepartment(dept);
                    }
                  },
                ),
              ),
              
              // Labs List
              Expanded(
                child: provider.selectedDept == null
                    ? const Center(child: Text("Please select a department"))
                    : provider.labs.isEmpty
                        ? const Center(child: Text("No labs found in this department"))
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppConstants.defaultPadding),
                            itemCount: provider.labs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final lab = provider.labs[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: AppColors.primaryMaroon,
                                    child: Icon(Icons.science, color: Colors.white),
                                  ),
                                  title: Text(lab.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(lab.location),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: AppColors.error),
                                    onPressed: () => _handleDelete(lab.id, lab.name),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
