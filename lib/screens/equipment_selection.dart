import 'package:amrita_ulabs/screens/calendar_screen.dart';
import 'package:amrita_ulabs/screens/date_time_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/equipment_provider.dart';
import '../models/department.dart';
import '../models/lab.dart';
import '../models/equipment.dart';
import 'date_time_screen.dart';

class EquipmentSelectionPage extends StatefulWidget {
  const EquipmentSelectionPage({super.key});

  @override
  State<EquipmentSelectionPage> createState() => _EquipmentSelectionPageState();
}

class _EquipmentSelectionPageState extends State<EquipmentSelectionPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<EquipmentProvider>(context, listen: false);
    provider.loadDepartments(); // Load departments on page load
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EquipmentProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Custom Header with AMRITA branding
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFA4123F),
                          const Color(0xFFA4123F).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA4123F).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'AMRITA',
                              style: TextStyle(
                                fontFamily: 'Proxima Nova',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.science_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lab Management System',
                          style: TextStyle(
                            fontFamily: 'Proxima Nova',
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Select Equipment',
                          style: TextStyle(
                            fontFamily: 'Proxima Nova',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Department Selection Card
                          _buildSelectionCard(
                            context,
                            title: 'Department',
                            icon: Icons.business_outlined,
                            child: DropdownButtonFormField<Department>(
                              decoration:
                                  _buildInputDecoration('Choose Department'),
                              value: provider.selectedDept,
                              items: provider.departments
                                  .map((dept) => DropdownMenuItem(
                                        value: dept,
                                        child: Text(
                                          dept.name,
                                          style: const TextStyle(
                                            fontFamily: 'Proxima Nova',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (dept) {
                                if (dept != null) {
                                  provider.selectDepartment(dept);
                                }
                              },
                              style: const TextStyle(
                                fontFamily: 'Proxima Nova',
                                color: Colors.black87,
                              ),
                              dropdownColor: Colors.white,
                              iconEnabledColor: const Color(0xFFA4123F),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Lab Selection Card
                          _buildSelectionCard(
                            context,
                            title: 'Laboratory',
                            icon: Icons.apartment_outlined,
                            child: DropdownButtonFormField<Lab>(
                              decoration:
                                  _buildInputDecoration('Choose Laboratory'),
                              value: provider.selectedLab,
                              items: provider.labs
                                  .map((lab) => DropdownMenuItem(
                                        value: lab,
                                        child: Text(
                                          lab.name,
                                          style: const TextStyle(
                                            fontFamily: 'Proxima Nova',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: provider.selectedDept == null
                                  ? null
                                  : (lab) {
                                      if (lab != null) provider.selectLab(lab);
                                    },
                              style: const TextStyle(
                                fontFamily: 'Proxima Nova',
                                color: Colors.black87,
                              ),
                              dropdownColor: Colors.white,
                              iconEnabledColor: const Color(0xFFA4123F),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Equipment Selection Card
                          _buildSelectionCard(
                            context,
                            title: 'Equipment',
                            icon: Icons.precision_manufacturing_outlined,
                            child: DropdownButtonFormField<Equipment>(
                              decoration:
                                  _buildInputDecoration('Choose Equipment'),
                              value: provider.selectedEquipment,
                              items: provider.equipments
                                  .map((equip) => DropdownMenuItem(
                                        value: equip,
                                        child: Text(
                                          equip.name,
                                          style: const TextStyle(
                                            fontFamily: 'Proxima Nova',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: provider.selectedLab == null
                                  ? null
                                  : (equip) {
                                      if (equip != null) {
                                        provider.selectEquipment(equip);
                                      }
                                    },
                              style: const TextStyle(
                                fontFamily: 'Proxima Nova',
                                color: Colors.black87,
                              ),
                              dropdownColor: Colors.white,
                              iconEnabledColor: const Color(0xFFA4123F),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Submit Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: provider.selectedEquipment == null
                                  ? null
                                  : LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFFA4123F),
                                        const Color(0xFFA4123F)
                                            .withOpacity(0.8),
                                      ],
                                    ),
                              boxShadow: provider.selectedEquipment == null
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: const Color(0xFFA4123F)
                                            .withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                            ),
                            child: ElevatedButton(
                              onPressed: provider.selectedEquipment == null
                                  ? null
                                  : () {
                                      _showSuccessDialog(context, provider);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledBackgroundColor: Colors.grey[300],
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: provider.selectedEquipment == null
                                        ? Colors.grey[600]
                                        : Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Confirm Selection',
                                    style: TextStyle(
                                      fontFamily: 'Proxima Nova',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: provider.selectedEquipment == null
                                          ? Colors.grey[600]
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Selection Summary
                          if (provider.selectedDept != null ||
                              provider.selectedLab != null ||
                              provider.selectedEquipment != null)
                            _buildSelectionSummary(provider),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSelectionCard(BuildContext context,
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFA4123F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFA4123F),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Proxima Nova',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Proxima Nova',
        color: Colors.grey[500],
        fontSize: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFA4123F), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildSelectionSummary(EquipmentProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFA4123F).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFA4123F).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.summarize_outlined,
                color: Color(0xFFA4123F),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Current Selection',
                style: TextStyle(
                  fontFamily: 'Proxima Nova',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA4123F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (provider.selectedDept != null)
            _buildSummaryItem(
                'Department', provider.selectedDept!.name, Icons.business),
          if (provider.selectedLab != null)
            _buildSummaryItem(
                'Laboratory', provider.selectedLab!.name, Icons.apartment),
          if (provider.selectedEquipment != null)
            _buildSummaryItem('Equipment', provider.selectedEquipment!.name,
                Icons.precision_manufacturing),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: 'Proxima Nova',
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Proxima Nova',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, EquipmentProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFFA4123F), size: 48),
                const SizedBox(height: 20),
                const Text(
                  'Selection Confirmed!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${provider.selectedDept?.name}\n${provider.selectedLab?.name}\n${provider.selectedEquipment?.name}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close dialog
                      // ✅ Navigate to BookingPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingPage(
                            equipmentId: provider.selectedEquipment!.id,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA4123F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
