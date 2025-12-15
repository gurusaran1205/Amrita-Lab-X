import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/colors.dart';
import '../../widgets/admin_header.dart'; // Import AdminHeader

class ReportsScreen extends StatefulWidget {
  final bool showAppBar; // New parameter to control AppBar visibility

  const ReportsScreen({super.key, this.showAppBar = false});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _downloadingReport;

  final List<Map<String, dynamic>> _reports = [
    {
      'title': 'Equipment Log',
      'subtitle': 'Export equipment usage history',
      'icon': Icons.history_edu,
      'endpoint': '/api/reports/export-usage',
      'fileName': 'equipment_log.xlsx',
    },
    {
      'title': 'Booking & Cancellation',
      'subtitle': 'Report of all bookings and cancellations',
      'icon': Icons.event_note,
      'endpoint': '/api/reports/export-bookings',
      'fileName': 'booking_report.xlsx',
    },
    {
      'title': 'User Activity Summary',
      'subtitle': 'Summary of user registrations and activity',
      'icon': Icons.people_alt_outlined,
      'endpoint': '/api/reports/export-users',
      'fileName': 'user_activity.xlsx',
    },
    {
      'title': 'Cross-Department Report',
      'subtitle': 'Inter-departmental resource usage',
      'icon': Icons.compare_arrows,
      'endpoint': '/api/reports/export-cross-dept',
      'fileName': 'cross_dept_report.xlsx',
    },
    {
      'title': 'Audit Logs',
      'subtitle': 'System-wide audit trail (Super Admin)',
      'icon': Icons.security,
      'endpoint': '/api/reports/export-audit',
      'fileName': 'audit_logs.xlsx',
    },
  ];

  Future<void> _downloadAndShareReport(String endpoint, String fileName, String title) async {
    setState(() {
      _isLoading = true;
      _downloadingReport = title;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.token;

      if (token == null) {
        throw Exception("Authentication token missing");
      }

      final response = await _apiService.downloadReport(endpoint, token);

      if (response.statusCode == 200 && response.data != null) {
        // 1. Convert downloaded bytes (CSV) to String
        final csvContent = utf8.decode(response.data as List<int>, allowMalformed: true);
        
        // 2. Parse CSV to List<List<dynamic>>
        List<List<dynamic>> rows = const CsvToListConverter().convert(csvContent);

        // 3. Create Excel file
        var excel = Excel.createExcel();
        // Use the default sheet properly
        String defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
        Sheet sheetObject = excel[defaultSheet];

        // 4. Append rows to Excel
        for (var row in rows) {
          List<CellValue> rowData = row.map((e) {
            String val = e?.toString() ?? '';
            return TextCellValue(val);
          }).toList();
          
          sheetObject.appendRow(rowData);
        }

        // 5. Encode Excel to bytes
        var fileBytes = excel.save();

        if (fileBytes != null) {
          final xFile = XFile.fromData(
            Uint8List.fromList(fileBytes),
            name: fileName,
            mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          );

          // 6. Share/Save the file
          if (mounted) {
             await Share.shareXFiles([xFile], text: 'Here is the $title');
          }
        }
      } else {
        throw Exception(response.message ?? "Failed to download");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _downloadingReport = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: widget.showAppBar ? const AdminHeader(title: "Reports") : null,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primaryMaroon),
                  const SizedBox(height: 20),
                  Text("Downloading $_downloadingReport...", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMaroon.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(report['icon'], color: AppColors.primaryMaroon),
                    ),
                    title: Text(report['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(report['subtitle'], style: const TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.download_rounded, color: AppColors.textSecondary),
                    onTap: () => _downloadAndShareReport(
                      report['endpoint'],
                      report['fileName'],
                      report['title'],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
