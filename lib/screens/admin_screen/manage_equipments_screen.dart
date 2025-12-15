import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/equipment_provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../models/department.dart';
import '../../models/lab.dart';
import '../../widgets/admin_header.dart';

class ManageEquipmentsScreen extends StatefulWidget {
  const ManageEquipmentsScreen({super.key});

  @override
  State<ManageEquipmentsScreen> createState() => _ManageEquipmentsScreenState();
}

class _ManageEquipmentsScreenState extends State<ManageEquipmentsScreen> {
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
      appBar: const AdminHeader(title: "Manage Equipment"),

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

              // Lab Selector
              if (provider.selectedDept != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                  child: DropdownButtonFormField<Lab>(
                    decoration: const InputDecoration(
                      labelText: "Select Lab",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.science),
                    ),
                    value: provider.selectedLab,
                    items: provider.labs.map((lab) {
                      return DropdownMenuItem(
                        value: lab,
                        child: Text(lab.name),
                      );
                    }).toList(),
                    onChanged: (lab) {
                      if (lab != null) {
                        provider.selectLab(lab);
                      }
                    },
                  ),
                ),
              
              const SizedBox(height: 10),

              // Equipment List
              Expanded(
                child: provider.selectedLab == null
                    ? const Center(child: Text("Please select a department and lab"))
                    : provider.equipments.isEmpty
                        ? const Center(child: Text("No equipment found in this lab"))
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppConstants.defaultPadding),
                            itemCount: provider.equipments.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final equip = provider.equipments[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: AppColors.primaryMaroon,
                                    child: Icon(Icons.biotech, color: Colors.white),
                                  ),
                                  title: Text(equip.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text("${equip.type} - ${equip.status}"),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit, color: AppColors.primaryMaroon),
                                    onPressed: () async {
                                      await Navigator.pushNamed(
                                        context,
                                        '/edit_equipment',
                                        arguments: {
                                          'id': equip.id,
                                          'name': equip.name,
                                          'type': equip.type,
                                          'modelNumber': equip.modelNumber,
                                          'description': equip.description,
                                          'status': equip.status,
                                          'labId': provider.selectedLab!.id,
                                        },
                                      );
                                      // Refresh list after returning
                                      if (provider.selectedLab != null) {
                                        provider.selectLab(provider.selectedLab!);
                                      }
                                    },
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
