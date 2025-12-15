import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/equipment_provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/admin_header.dart'; // Import AdminHeader


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
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            const AdminHeader(
              title: 'Manage Departments',
            ),


            // Content Section
            Expanded(
              child: Consumer<EquipmentProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryMaroon.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryMaroon,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Loading departments...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.departments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: AppColors.primaryMaroon.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: AppColors.primaryMaroon.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No departments found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start by adding your first department',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: provider.departments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
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
            ),
          ],
        ),
      ),
    );
  }
}