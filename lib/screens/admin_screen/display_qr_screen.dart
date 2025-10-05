import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class DisplayQrScreen extends StatelessWidget {
  final String qrData;
  final String title;

  const DisplayQrScreen({super.key, required this.qrData, required this.title});

  /// Decodes the Base64 image data and saves it to a temporary file.
  /// Returns the path to the saved file.
  Future<String?> _saveQrImageToFile(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      final tempDir = await getTemporaryDirectory();
      debugPrint('Temporary Directory Path: ${tempDir.path}');

      // Sanitize the title to use it as a filename, ensuring it's not empty
      final sanitizedTitle = title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').padRight(3, '_');
      final fileName = '$sanitizedTitle.png';
      final file = File('${tempDir.path}/$fileName');

      debugPrint('Attempting to save QR image to: ${file.path}');
      await file.writeAsBytes(bytes);

      if (await file.exists()) {
        debugPrint('Successfully saved QR image.');
        return file.path;
      } else {
        debugPrint('File does not exist after writing.');
        return null;
      }
    } catch (e) {
      // Catch and print the specific error for better debugging
      debugPrint("Error saving QR image: $e");
      return null;
    }
  }

  /// Handles the share button press.
  Future<void> _shareQrCode(BuildContext context, String base64String) async {
    final imagePath = await _saveQrImageToFile(base64String);

    if (imagePath != null && context.mounted) {
      final xFile = XFile(imagePath);
      await Share.shareXFiles(
        [xFile],
        text: 'QR Code for: $title',
      );
    } else if (context.mounted) {
      // Show a more specific error if the image could not be saved
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not share QR code. Failed to save image.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String base64String = qrData.split(',').last;
    final imageBytes = base64Decode(base64String);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.memory(imageBytes),
            ),
            const SizedBox(height: AppConstants.largePadding * 2),
            ElevatedButton.icon(
              onPressed: () => _shareQrCode(context, base64String),
              icon: const Icon(Icons.share),
              label: const Text('Share QR Code'),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            const Text(
              'You can print this QR code and place it on the corresponding lab entrance or equipment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}