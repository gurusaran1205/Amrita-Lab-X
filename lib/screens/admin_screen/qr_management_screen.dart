import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/department.dart';
import '../../models/lab.dart';
import '../../models/equipment.dart';
import '../../providers/equipment_provider.dart';
import '../../providers/qr_provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'display_qr_screen.dart';

class QrManagementScreen extends StatefulWidget {
  const QrManagementScreen({super.key});

  @override
  State<QrManagementScreen> createState() => _QrManagementScreenState();
}

class _QrManagementScreenState extends State<QrManagementScreen> {
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

  Future<void> _generateAndShowQr(String type, String id, String title) async {
    final qrProvider = context.read<QrProvider>();
    final success = await qrProvider.generateQrCode(type: type, id: id);

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayQrScreen(
            qrData: qrProvider.qrCodeDataUrl!,
            title: title,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(qrProvider.errorMessage ?? 'Could not generate QR code'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Generate QR Codes'),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Consumer<EquipmentProvider>(
        builder: (context, equipmentProvider, child) {
          if (equipmentProvider.isLoading &&
              equipmentProvider.departments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDepartmentDropdown(equipmentProvider),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildLabDropdown(equipmentProvider),
                const SizedBox(height: AppConstants.largePadding),
                if (equipmentProvider.selectedLab != null)
                  _buildQrOptions(equipmentProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDepartmentDropdown(EquipmentProvider provider) {
    return DropdownButtonFormField<Department>(
      value: provider.selectedDept,
      decoration: const InputDecoration(labelText: 'Select Department'),
      items: provider.departments
          .map((dept) => DropdownMenuItem(value: dept, child: Text(dept.name)))
          .toList(),
      onChanged: (dept) {
        if (dept != null) provider.selectDepartment(dept);
      },
    );
  }

  Widget _buildLabDropdown(EquipmentProvider provider) {
    return DropdownButtonFormField<Lab>(
      value: provider.selectedLab,
      decoration: InputDecoration(
        labelText: 'Select Lab',
        enabled: provider.selectedDept != null,
      ),
      items: provider.labs
          .map((lab) => DropdownMenuItem(value: lab, child: Text(lab.name)))
          .toList(),
      onChanged: (lab) {
        if (lab != null) provider.selectLab(lab);
      },
    );
  }

  Widget _buildQrOptions(EquipmentProvider provider) {
    final qrProvider = context.watch<QrProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Lab QR Codes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        ElevatedButton.icon(
          icon: const Icon(Icons.sensor_door_outlined),
          label: const Text('Generate Lab Entrance QR'),
          onPressed: () => _generateAndShowQr(
            'lab_entrance',
            provider.selectedLab!.id,
            'Entrance: ${provider.selectedLab!.name}',
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Generate Lab Logout QR'),
          onPressed: () => _generateAndShowQr(
            'lab_logout',
            provider.selectedLab!.id,
            'Logout: ${provider.selectedLab!.name}',
          ),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkGray),
        ),
        const SizedBox(height: AppConstants.largePadding),
        const Text(
          'Equipment QR Codes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (provider.equipments.isEmpty)
          const Text('No equipment found in this lab.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.equipments.length,
            itemBuilder: (context, index) {
              final Equipment equipment = provider.equipments[index];
              return Card(
                child: ListTile(
                  title: Text(equipment.name),
                  subtitle: Text(equipment.modelNumber),
                  trailing: const Icon(Icons.qr_code_2),
                  onTap: () => _generateAndShowQr(
                    'equipment',
                    equipment.id,
                    equipment.name,
                  ),
                ),
              );
            },
          ),
        if (qrProvider.isLoading) ...[
          const SizedBox(height: 20),
          const Center(child: CircularProgressIndicator()),
          const Center(child: Text("Generating QR Code...")),
        ]
      ],
    );
  }
}
