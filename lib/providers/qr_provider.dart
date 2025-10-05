import 'package:flutter/material.dart';
import '../services/equip_api.dart';
import 'auth_provider.dart';

class QrProvider extends ChangeNotifier {
  // Make authProvider public but not final
  AuthProvider authProvider;
  
  QrProvider({required this.authProvider});
  
  // Method to update the authProvider dependency when it changes
  void updateAuthProvider(AuthProvider newAuthProvider) {
    authProvider = newAuthProvider;
  }

  ApiService get _apiService => ApiService(token: authProvider.token);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _qrCodeDataUrl;
  String? get qrCodeDataUrl => _qrCodeDataUrl;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> generateQrCode({
    required String type,
    required String id,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _qrCodeDataUrl = null;
    notifyListeners();

    try {
      String? result;
      switch (type) {
        case 'lab_entrance':
          result = await _apiService.getLabEntranceQr(id);
          break;
        case 'lab_logout':
          result = await _apiService.getLabLogoutQr(id);
          break;
        case 'equipment':
          result = await _apiService.getEquipmentQr(id);
          break;
        default:
          throw Exception('Invalid QR code type');
      }

      if (result != null) {
        _qrCodeDataUrl = result;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to generate QR code from server.');
        return false;
      }
    } catch (e) {
      _setError("An error occurred: $e");
      return false;
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}