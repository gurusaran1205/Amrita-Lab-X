import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class BookingProvider with ChangeNotifier {
  final AuthProvider authProvider;
  final ApiService _apiService = ApiService();

  BookingProvider({required this.authProvider});

  // State variables
  List<Booking> _myBookings = [];
  List<Booking> _pendingBookings = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Booking> get myBookings => _myBookings;
  List<Booking> get pendingBookings => _pendingBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filtered bookings for tabs
  List<Booking> get activeBookings {
    final now = DateTime.now();
    return _myBookings.where((booking) {
      return booking.status.toLowerCase() == 'confirmed' &&
          booking.startTime.isBefore(now) &&
          booking.endTime.isAfter(now);
    }).toList();
  }

  List<Booking> get upcomingBookings {
    final now = DateTime.now();
    return _myBookings.where((booking) {
      return (booking.status.toLowerCase() == 'confirmed' ||
          booking.status.toLowerCase() == 'pending') &&
          booking.startTime.isAfter(now);
    }).toList();
  }

  List<Booking> get historyBookings {
    final now = DateTime.now();
    return _myBookings.where((booking) {
      return booking.endTime.isBefore(now) ||
          booking.status.toLowerCase() == 'cancelled' ||
          booking.status.toLowerCase() == 'completed';
    }).toList();
  }

  /// Fetch My Bookings
  Future<void> fetchMyBookings() async {
    debugPrint("--- BOOKING PROVIDER: Fetching my bookings ---");

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
      debugPrint("--- BOOKING PROVIDER: Calling API Service... ---");
      final response = await _apiService.getMyBookings(authProvider.token!);

      if (response.success && response.data != null) {
        _myBookings = response.data!;
        debugPrint("✅ Successfully fetched ${_myBookings.length} bookings");
      } else {
        _errorMessage = response.message;
        debugPrint("❌ Failed to fetch bookings: ${response.message}");
      }
    } catch (e) {
      _errorMessage = "Failed to load bookings: $e";
      debugPrint("❌ Exception while fetching bookings: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch Pending Bookings (Admin only)
  Future<void> fetchPendingBookings() async {
    debugPrint("--- BOOKING PROVIDER: Fetching pending bookings ---");

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
      debugPrint("--- BOOKING PROVIDER: Calling API Service... ---");
      // This would need to be implemented in api_service.dart similar to getMyBookings
      // For now, using placeholder
      _pendingBookings = []; // Implement getPendingBookings in ApiService
    } catch (e) {
      _errorMessage = "Failed to load pending bookings: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    debugPrint("--- BOOKING PROVIDER: Cancelling booking $bookingId ---");

    if (authProvider.token == null || authProvider.token!.isEmpty) {
      _errorMessage = "Authentication error: Not logged in.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.updateBookingStatus(
        token: authProvider.token!,
        bookingId: bookingId,
        status: 'cancelled',
      );

      if (response.success && response.data != null) {
        // Update the local booking list
        final index = _myBookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _myBookings[index] = response.data!;
        }
        debugPrint("✅ Successfully cancelled booking");
        return true;
      } else {
        _errorMessage = response.message;
        debugPrint("❌ Failed to cancel booking: ${response.message}");
        return false;
      }
    } catch (e) {
      _errorMessage = "Failed to cancel booking: $e";
      debugPrint("❌ Exception while cancelling booking: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update Booking Status (Admin)
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
      final response = await _apiService.updateBookingStatus(
        token: authProvider.token!,
        bookingId: bookingId,
        status: status,
      );

      if (response.success) {
        // Remove from pending bookings after successful update
        _pendingBookings.removeWhere((booking) => booking.id == bookingId);
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = "Failed to update booking status: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh bookings
  Future<void> refreshBookings() async {
    await fetchMyBookings();
  }
}