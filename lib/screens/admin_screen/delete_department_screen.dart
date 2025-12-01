import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/equipment_provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class DeleteDepartmentScreen extends StatefulWidget {
  const DeleteDepartmentScreen({super.key});

  @override
  State<DeleteDepartmentScreen> createState() => _DeleteDepartmentScreenState();
}

class _DeleteDepartmentScreenState extends State<DeleteDepartmentScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch departments when screen loads
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
      final success = await context.read<EquipmentProvider>().deleteDepartment(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Department deleted successfully")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Delete Department"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Consumer<EquipmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.departments.isEmpty) {
            return const Center(child: Text("No departments found."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: provider.departments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final dept = provider.departments[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryMaroon,
                    child: Icon(Icons.business, color: Colors.white),
                  ),
                  title: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(dept.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _handleDelete(dept.id, dept.name),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
