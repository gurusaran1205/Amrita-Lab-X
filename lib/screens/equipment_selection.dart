import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/equipment_provider.dart';
import '../models/department.dart';
import '../models/lab.dart';
import '../models/equipment.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_widget.dart';
import '../utils/colors.dart';
import 'availability_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class EquipmentSelectionPage extends StatefulWidget {
  const EquipmentSelectionPage({super.key});

  @override
  State<EquipmentSelectionPage> createState() => _EquipmentSelectionPageState();
}

class _EquipmentSelectionPageState extends State<EquipmentSelectionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _contentController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<EquipmentProvider>(context, listen: false);
    provider.loadDepartments();

    // Initialize animations
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _contentController.forward();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The provider is now accessed via Consumer in the body
    // final provider = Provider.of<EquipmentProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Book Equipment',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.primaryMaroon,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<EquipmentProvider>(
        builder: (context, provider, child) {
          String? loadingMessage;
          if (provider.isLoading) {
            loadingMessage = "Selecting Equipment List...";
          } else if (provider.isLabsLoading) {
            loadingMessage = "Fetching Laboratories...";
          } else if (provider.isEquipmentsLoading) {
            loadingMessage = "Loading Equipment...";
          }

          final isAnyLoading = provider.isLoading ||
                             provider.isLabsLoading ||
                             provider.isEquipmentsLoading;

          return LoadingOverlay(
            isLoading: isAnyLoading,
            message: loadingMessage,
            backgroundColor: AppColors.background,
            child: SafeArea( // Moved SafeArea inside LoadingOverlay content
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Intro Card
                    _buildSelectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Lab & Equipment',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please choose your department and lab to view available equipment.',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ... Rest of the form
                    _buildDropdownSection<Department>(
                      title: 'Department',
                      hint: 'Select Department',
                      value: provider.selectedDept,
                      items: provider.departments,
                      onChanged: (Department? dept) {
                        if (dept != null) {
                          provider.selectDepartment(dept);
                        }
                      },
                      itemLabelBuilder: (item) => (item as Department).name,
                      prefixIcon: Icons.business_rounded,
                    ),

                    if (provider.selectedDept != null) ...[
                      const SizedBox(height: 20),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: _buildDropdownSection<Lab>(
                          title: 'Laboratory',
                          hint: 'Select Laboratory',
                          value: provider.selectedLab,
                          items: provider.labs,
                          onChanged: (Lab? lab) {
                            if (lab != null) {
                              provider.selectLab(lab);
                            }
                          },
                          itemLabelBuilder: (item) => (item as Lab).name,
                          prefixIcon: Icons.science_rounded,
                        ),
                      ),
                    ],

                    if (provider.selectedLab != null) ...[
                      const SizedBox(height: 20),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: _buildDropdownSection<Equipment>(
                          title: 'Equipment',
                          hint: 'Select Equipment',
                          value: provider.selectedEquipment,
                          items: provider.equipments,
                          onChanged: (Equipment? equip) {
                            if (equip != null) {
                              provider.selectEquipment(equip);
                            }
                          },
                          itemLabelBuilder: (item) => (item as Equipment).name,
                          prefixIcon: Icons.build_rounded,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: provider.selectedEquipment != null
                            ? () => _showSuccessDialog(context, provider)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryMaroon,
                          disabledBackgroundColor: AppColors.buttonDisabled,
                          elevation: provider.selectedEquipment != null ? 4 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    if (provider.selectedEquipment != null) ...[
                      const SizedBox(height: 24),
                      _buildSelectionSummary(provider),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDropdownSection<T>({
    required String title,
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabelBuilder,
    required IconData prefixIcon,
  }) {
    return _buildSelectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryMaroon.withAlpha((255 * 0.1).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  prefixIcon,
                  color: AppColors.primaryMaroon,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<T>(
            decoration: _buildInputDecoration(hint),
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryMaroon),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabelBuilder(item),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            dropdownColor: AppColors.white,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.textLight,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inputFocusBorder, width: 1.5),
      ),
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildSelectionSummary(EquipmentProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryMaroon.withAlpha((255 * 0.05).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryMaroon.withAlpha((255 * 0.1).round()),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.summarize_outlined,
                color: AppColors.primaryMaroon,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Current Selection',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMaroon,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.1).round()),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha((255 * 0.1).round()),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.success,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Confirmed!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You have selected ${provider.selectedEquipment?.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      // Navigate to availability screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EquipmentAvailabilityPage(
                            equipmentId: provider.selectedEquipment!.id,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryMaroon,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View Availability',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
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
