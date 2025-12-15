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
  ];

  Future<void> _downloadAndShareReport(String endpoint, String baseFileName, String title) async {
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
        List<int> responseBytes = response.data as List<int>;
        List<int>? fileBytesToWrite;
        
        // Try to interpret as JSON/CSV data first
        try {
           final jsonContent = utf8.decode(responseBytes);
           
           if (jsonContent.trim().isEmpty) {
             throw Exception("Report data is empty");
           }
           
           // Try JSON
           dynamic decoded;
           try {
             decoded = jsonDecode(jsonContent);
           } catch (_) {
             // Not JSON
             decoded = null;
           }
           
           List<dynamic> dataList = [];
           bool isJsonList = false;

           if (decoded is List) {
             dataList = decoded;
             isJsonList = true;
           } else if (decoded is Map && decoded.containsKey('data') && decoded['data'] is List) {
             dataList = decoded['data'];
             isJsonList = true;
           }

           if (isJsonList) {
              if (dataList.isEmpty) {
                 throw Exception("No data available for this report");
              }
              
              // Generate Excel from valid JSON data
              var excel = Excel.createExcel();
              String sheetName = 'Report';
              if (excel.sheets.containsKey('Sheet1')) {
                excel.rename('Sheet1', sheetName);
              }
              Sheet sheetObject = excel[sheetName];

              if (dataList.isNotEmpty && dataList.first is Map) {
                Map<String, dynamic> firstRow = dataList.first as Map<String, dynamic>;
                List<String> headers = firstRow.keys.toList();
                List<CellValue> headerCells = headers.map((h) => TextCellValue(h.toUpperCase())).toList();
                sheetObject.appendRow(headerCells);

                for (var item in dataList) {
                   if (item is Map) {
                     List<CellValue> rowCells = headers.map((key) {
                       var val = item[key];
                       return TextCellValue(val?.toString() ?? '');
                     }).toList();
                     sheetObject.appendRow(rowCells);
                   }
                }
              }
              fileBytesToWrite = excel.save();
           } else {
             // Not JSON list. Could be CSV or just raw text? 
             // If we successfully decoded UTF8 but it's not JSON, might be CSV.
             // But if it was a binary file, utf8.decode often fails. 
             // If it didn't fail, maybe it's valid text but not data we expect.
             // Let's assume if it's not JSON, we treat it as raw file content if user specifically asked for xlsx and we got text?
             // Actually, if api returns binary xlsx, utf8.decode usually throws.
             // If we are here, it is valid text. 
             // fallback: assume it might be CSV.
              try {
                List<List<dynamic>> rows = const CsvToListConverter().convert(jsonContent);
                if (rows.isNotEmpty && rows.length > 1) {
                   // Convert CSV to Excel
                    var excel = Excel.createExcel();
                    Sheet sheetObject = excel['Sheet1'];
                    for (var row in rows) {
                      List<CellValue> rowData = row.map((e) => TextCellValue(e?.toString() ?? '')).toList();
                      sheetObject.appendRow(rowData);
                    }
                    fileBytesToWrite = excel.save();
                } else {
                   // Treat as raw bytes if CSV parse yields nothing useful? 
                   // Or just save the original bytes?
                   print("Text received but not JSON/CSV. Saving as is.");
                   fileBytesToWrite = responseBytes;
                }
              } catch (e) {
                 fileBytesToWrite = responseBytes;
              }
           }

        } catch (e) {
           // UTF-8 Decode failed -> likely boolean/binary data (Excel/Zip)
           print("UTF-8 Decode error (likely binary file): $e");
           fileBytesToWrite = responseBytes;
        }

        // 5. Generate Timestamped Filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final nameWithoutExt = baseFileName.replaceAll('.xlsx', '');
        final finalFileName = '${nameWithoutExt}_$timestamp.xlsx';

        if (fileBytesToWrite != null) {
          final xFile = XFile.fromData(
            Uint8List.fromList(fileBytesToWrite),
            name: finalFileName,
            mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          );

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
            content: Text('Error downloading report: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
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
