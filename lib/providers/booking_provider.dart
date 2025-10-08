import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/equip_api.dart';
import 'auth_provider.dart';

class BookingProvider with ChangeNotifier {
  final AuthProvider authProvider;
  late final ApiService _apiService;

  BookingProvider({required this.authProvider}) {
    _apiService = ApiService(token: authProvider.token);
  }

  List<Booking> _pendingBookings = [];
  List<Booking> get pendingBookings => _pendingBookings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPendingBookings() async {
    // --- CONSOLE LOGS ADDED HERE ---
    debugPrint("--- BOOKING PROVIDER: Attempting to fetch pending bookings ---");
    debugPrint("Auth Token available: ${authProvider.token != null && authProvider.token!.isNotEmpty}");
    
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      _errorMessage = "Authentication error: Not logged in.";
      notifyListeners();
      debugPrint("--- BOOKING PROVIDER: Aborted. No auth token. ---");
      return;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint("--- BOOKING PROVIDER: Calling ApiService... ---");
      _pendingBookings = await _apiService.fetchPendingBookings();
    } catch (e) {
      _errorMessage = "Failed to load pending bookings: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      _errorMessage = "Authentication error: Not logged in.";
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.updateBookingStatus(bookingId, status);
      if (success) {
        // Remove the booking from the list after successful update
        _pendingBookings.removeWhere((booking) => booking.id == bookingId);
      }
      return success;
    } catch (e) {
      _errorMessage = "Failed to update booking status: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}