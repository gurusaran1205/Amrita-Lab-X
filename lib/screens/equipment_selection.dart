import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/equipment_provider.dart';
import '../models/department.dart';
import '../models/lab.dart';
import '../models/equipment.dart';
import 'availability_screen.dart';

class EquipmentSelectionPage extends StatefulWidget {
  const EquipmentSelectionPage({super.key});

  @override
  State<EquipmentSelectionPage> createState() => _EquipmentSelectionPageState();
}

class _EquipmentSelectionPageState extends State<EquipmentSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<double> _headerAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<EquipmentProvider>(context, listen: false);
    provider.loadDepartments();

    // Initialize animations
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
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
                  // Animated Custom Header with Back Button
                  ScaleTransition(
                    scale: _headerAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFA4123F),
                            const Color(0xFFC41E3A),
                            const Color(0xFFA4123F).withOpacity(0.85),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(35),
                          bottomRight: Radius.circular(35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA4123F).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button and branding row
                          Row(
                            children: [
                              // Stylish Back Button
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 600),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => Navigator.pop(context),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          splashColor:
                                              Colors.white.withOpacity(0.3),
                                          highlightColor:
                                              Colors.white.withOpacity(0.2),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Icon(
                                              Icons.arrow_back_ios_new_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              // AMRITA branding
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'AMRITA',
                                      style: TextStyle(
                                        fontFamily: 'Proxima Nova',
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Lab Management',
                                      style: TextStyle(
                                        fontFamily: 'Proxima Nova',
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.95),
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Science icon with pulse animation
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 1500),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.9 + (value * 0.1),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.biotech_rounded,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Page title with gradient underline
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Equipment',
                                style: TextStyle(
                                  fontFamily: 'Proxima Nova',
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 1200),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Container(
                                    height: 3,
                                    width: 120 * value,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.white.withOpacity(0.3),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Animated Main Content
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Department Selection Card with stagger animation
                              _buildAnimatedCard(
                                delay: 0,
                                child: _buildSelectionCard(
                                  context,
                                  title: 'Department',
                                  icon: Icons.business_outlined,
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFA4123F).withOpacity(0.1),
                                      const Color(0xFFC41E3A).withOpacity(0.05),
                                    ],
                                  ),
                                  child: DropdownButtonFormField<Department>(
                                    decoration: _buildInputDecoration(
                                        'Choose Department'),
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
                              ),

                              const SizedBox(height: 20),

                              // Lab Selection Card
                              _buildAnimatedCard(
                                delay: 100,
                                child: _buildSelectionCard(
                                  context,
                                  title: 'Laboratory',
                                  icon: Icons.apartment_outlined,
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF4A90E2).withOpacity(0.1),
                                      const Color(0xFF5BA3F5).withOpacity(0.05),
                                    ],
                                  ),
                                  child: DropdownButtonFormField<Lab>(
                                    decoration: _buildInputDecoration(
                                        'Choose Laboratory'),
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
                                            if (lab != null)
                                              provider.selectLab(lab);
                                          },
                                    style: const TextStyle(
                                      fontFamily: 'Proxima Nova',
                                      color: Colors.black87,
                                    ),
                                    dropdownColor: Colors.white,
                                    iconEnabledColor: const Color(0xFFA4123F),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Equipment Selection Card
                              _buildAnimatedCard(
                                delay: 200,
                                child: _buildSelectionCard(
                                  context,
                                  title: 'Equipment',
                                  icon: Icons.precision_manufacturing_outlined,
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF50C878).withOpacity(0.1),
                                      const Color(0xFF66D98C).withOpacity(0.05),
                                    ],
                                  ),
                                  child: DropdownButtonFormField<Equipment>(
                                    decoration: _buildInputDecoration(
                                        'Choose Equipment'),
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
                              ),

                              const SizedBox(height: 40),

                              // Animated Submit Button
                              _buildAnimatedCard(
                                delay: 300,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: double.infinity,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    gradient: provider.selectedEquipment == null
                                        ? null
                                        : LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              const Color(0xFFA4123F),
                                              const Color(0xFFC41E3A),
                                              const Color(0xFFA4123F)
                                                  .withOpacity(0.85),
                                            ],
                                          ),
                                    boxShadow:
                                        provider.selectedEquipment == null
                                            ? null
                                            : [
                                                BoxShadow(
                                                  color: const Color(0xFFA4123F)
                                                      .withOpacity(0.4),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 8),
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        provider.selectedEquipment == null
                                            ? null
                                            : () {
                                                _showSuccessDialog(
                                                    context, provider);
                                              },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      disabledBackgroundColor: Colors.grey[300],
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          color:
                                              provider.selectedEquipment == null
                                                  ? Colors.grey[600]
                                                  : Colors.white,
                                          size: 26,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Confirm Selection',
                                          style: TextStyle(
                                            fontFamily: 'Proxima Nova',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: provider.selectedEquipment ==
                                                    null
                                                ? Colors.grey[600]
                                                : Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Selection Summary with animation
                              if (provider.selectedDept != null ||
                                  provider.selectedLab != null ||
                                  provider.selectedEquipment != null)
                                _buildAnimatedCard(
                                  delay: 400,
                                  child: _buildSelectionSummary(provider),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildSelectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Gradient gradient,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA4123F).withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFA4123F),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Proxima Nova',
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFA4123F), width: 2.5),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    );
  }

  Widget _buildSelectionSummary(EquipmentProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFA4123F).withOpacity(0.08),
            const Color(0xFFC41E3A).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFA4123F).withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA4123F).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: const Color(0xFFA4123F).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.summarize_rounded,
                  color: Color(0xFFA4123F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Current Selection',
                style: TextStyle(
                  fontFamily: 'Proxima Nova',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA4123F),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFFA4123F)),
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: 'Proxima Nova',
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  const Color(0xFFA4123F).withOpacity(0.02),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFA4123F),
                              const Color(0xFFC41E3A),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFA4123F).withOpacity(0.3),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Selection Confirmed!',
                  style: TextStyle(
                    fontFamily: 'Proxima Nova',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${provider.selectedDept?.name}\n${provider.selectedLab?.name}\n${provider.selectedEquipment?.name}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Proxima Nova',
                      color: Colors.grey[700],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EquipmentAvailabilityPage(
                            equipmentId: provider.selectedEquipment!.id,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA4123F),
                      elevation: 8,
                      shadowColor: const Color(0xFFA4123F).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontFamily: 'Proxima Nova',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
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
