import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/equipment_provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class ManageDepartmentsScreen extends StatefulWidget {
  const ManageDepartmentsScreen({super.key});

  @override
  State<ManageDepartmentsScreen> createState() => _ManageDepartmentsScreenState();
}

class _ManageDepartmentsScreenState extends State<ManageDepartmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EquipmentProvider>().loadDepartments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Manage Departments"),
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
                    icon: const Icon(Icons.edit, color: AppColors.primaryMaroon),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/edit_department',
                        arguments: {
                          'id': dept.id,
                          'name': dept.name,
                          'description': dept.description,
                        },
                      ).then((_) {
                        // Refresh list when returning from edit screen
                        context.read<EquipmentProvider>().loadDepartments();
                      });
                    },
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
