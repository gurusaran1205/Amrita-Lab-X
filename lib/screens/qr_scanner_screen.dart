import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../services/equip_api.dart';
import '../providers/auth_provider.dart';

enum ScanMode { entrance, equipment, logout }

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    autoStart: false,
  );
  ScanMode _scanMode = ScanMode.entrance;
  bool _isProcessing = false;
  bool _isCameraActive = false;
  final List<String> _messageLog = [];

  // Animation
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Initialize Animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addLog(String message, {bool isError = false}) {
    setState(() {
      _messageLog.insert(0, "${isError ? '❌' : '✅'} $message");
      if (_messageLog.length > 20) _messageLog.removeLast();
    });
  }

  Future<void> _startCamera() async {
    setState(() {
      _isCameraActive = true;
    });
    await _controller.start();
    _animationController.forward();
  }

  Future<void> _stopCamera() async {
    setState(() {
      _isCameraActive = false;
    });
    await _controller.stop();
    _animationController.stop();
  }

  Future<void> _processCode(String code) async {
    if (_isProcessing) return;

    // Stop camera immediately upon detection to save resources
    await _stopCamera();

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Parse JSON
      Map<String, dynamic> payload;
      try {
        payload = json.decode(code);
      } catch (e) {
        _showSnackBar('Invalid QR Code format', isError: true);
        _addLog('Scanned invalid QR format', isError: true);
        return;
      }

      final String type = payload['type'] ?? '';

      // 2. Validate Mode
      bool isValid = false;
      String errorMsg = '';

      switch (_scanMode) {
        case ScanMode.entrance:
          if (type == 'lab_entrance') isValid = true;
          else errorMsg = 'Expected Lab Entrance QR';
          break;
        case ScanMode.equipment:
          if (type == 'equipment') isValid = true;
          else errorMsg = 'Expected Equipment QR';
          break;
        case ScanMode.logout:
          if (type == 'logout') isValid = true;
          else errorMsg = 'Expected Logout QR';
          break;
      }

      if (!isValid) {
        _showSnackBar(errorMsg, isError: true);
        _addLog('Invalid QR for ${_scanMode.name} mode: $type', isError: true);
        return;
      }

      // 3. Call API
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService(token: authProvider.token);

      final result = await apiService.processScan(code);

      if (result['success'] == true) {
        final msg = result['message'] ?? 'Success';
        _showSnackBar(msg);
        _addLog(msg);
      } else {
        final msg = result['message'] ?? 'Failed';
        _showSnackBar(msg, isError: true);
        _addLog(msg, isError: true);
      }

    } catch (e) {
      _showSnackBar('Error processing scan: $e', isError: true);
      _addLog('Error: $e', isError: true);
    } finally {
      setState(() {
        _isProcessing = false;
      });
      // NOTE: Camera is NOT restarted here, as per user request.
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'QR Scanner',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.textSecondary),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner Area
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                if (_isCameraActive)
                  MobileScanner(
                    controller: _controller,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final String? code = barcodes.first.rawValue;
                        if (code != null) {
                          _processCode(code);
                        }
                      }
                    },
                  )
                else
                  Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code_scanner,
                            size: 80,
                            color: Colors.white54,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _startCamera,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Start Scanning'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryMaroon,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                if (_isCameraActive) ...[
                  _buildScannerOverlay(),
                  // Stop Button
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      onPressed: _stopCamera,
                      backgroundColor: Colors.red,
                      mini: true,
                      child: const Icon(Icons.stop, color: Colors.white),
                    ),
                  ),
                ],

                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryMaroon),
                    ),
                  ),
              ],
            ),
          ),

          // Mode Selector
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                _buildModeButton('Enter Lab', ScanMode.entrance, Icons.login),
                const SizedBox(width: 8),
                _buildModeButton('Equipment', ScanMode.equipment, Icons.build),
                const SizedBox(width: 8),
                _buildModeButton('Logout', ScanMode.logout, Icons.logout),
              ],
            ),
          ),

          // Message Log
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Session Log',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _messageLog.isEmpty
                        ? const Center(
                            child: Text(
                              'No scans yet',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _messageLog.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: Text(
                                  _messageLog[index],
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, ScanMode mode, IconData icon) {
    final isSelected = _scanMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _scanMode = mode;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryMaroon : AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryMaroon : AppColors.divider,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanWindowWidth = constraints.maxWidth * 0.7;
        final scanWindowHeight = scanWindowWidth;
        final scanWindow = Rect.fromCenter(
          center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
          width: scanWindowWidth,
          height: scanWindowHeight,
        );

        return Stack(
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ScannerOverlayPainter(
                    scanWindow: scanWindow,
                    scanLineOffset: _animation.value,
                  ),
                  child: Container(),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getOverlayText(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getOverlayText() {
    switch (_scanMode) {
      case ScanMode.entrance:
        return 'Scan Lab Entrance QR';
      case ScanMode.equipment:
        return 'Scan Equipment QR';
      case ScanMode.logout:
        return 'Scan Logout QR';
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Scan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Select the correct mode (Enter Lab, Equipment, or Logout).'),
            SizedBox(height: 8),
            Text('2. Point the camera at the corresponding QR code.'),
            SizedBox(height: 8),
            Text('3. Wait for the scan to process.'),
            SizedBox(height: 16),
            Text('Note: Ensure you are scanning the correct type of QR code for the selected mode.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final double borderRadius;
  final double scanLineOffset;

  ScannerOverlayPainter({
    required this.scanWindow,
    this.borderRadius = 12.0,
    required this.scanLineOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          scanWindow,
          Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(backgroundWithCutout, backgroundPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = AppColors.primaryMaroon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanWindow, Radius.circular(borderRadius)),
      borderPaint,
    );

    // Draw Scanning Line
    final linePaint = Paint()
      ..color = AppColors.primaryMaroon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final lineY = scanWindow.top + (scanWindow.height * scanLineOffset);

    // Draw line only within the scan window width
    canvas.drawLine(
      Offset(scanWindow.left, lineY),
      Offset(scanWindow.right, lineY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanLineOffset != scanLineOffset;
  }
}