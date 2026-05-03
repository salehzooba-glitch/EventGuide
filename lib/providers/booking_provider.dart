import 'dart:async';
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../core/errors.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService bookingService;

  List<BookingModel> _bookings = [];
  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> _pastBookings = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _bookingsSubscription;
  StreamSubscription? _upcomingSubscription;
  StreamSubscription? _pastSubscription;

  BookingProvider({required this.bookingService});

  // Getters
  List<BookingModel> get bookings => _bookings;
  List<BookingModel> get upcomingBookings => _upcomingBookings;
  List<BookingModel> get pastBookings => _pastBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load user bookings
  void loadUserBookings() {
    _isLoading = true;
    notifyListeners();

    _bookingsSubscription?.cancel();
    _upcomingSubscription?.cancel();
    _pastSubscription?.cancel();

    _bookingsSubscription = bookingService.getUserBookings().listen(
      (bookings) {
        debugPrint('📋 Received ${bookings.length} bookings from Firestore');
        _bookings = bookings;
        final now = DateTime.now();
        // Filter upcoming and past bookings locally to avoid
        // Firestore composite index requirements
        _upcomingBookings = bookings
            .where((b) => b.eventDate.isAfter(now) && b.isActive)
            .toList()
          ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
        _pastBookings = bookings
            .where((b) => b.eventDate.isBefore(now) || !b.isActive)
            .toList()
          ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
        debugPrint('📋 Upcoming: ${_upcomingBookings.length}, Past: ${_pastBookings.length}');
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('❌ Booking stream error: $e');
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Book tickets
  Future<bool> bookTickets({
    required String eventId,
    required String userName,
    required String eventTitle,
    required DateTime eventDate,
    String? eventImage,
    int quantity = 1,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await bookingService.bookTicket(
      eventId: eventId,
      userName: userName,
      eventTitle: eventTitle,
      eventDate: eventDate,
      eventImage: eventImage,
      quantity: quantity,
    );

    _isLoading = false;

    if (result is Success<BookingModel>) {
      notifyListeners();
      return true;
    } else if (result is Failure<BookingModel>) {
      _error = result.message;
      notifyListeners();
      return false;
    }

    notifyListeners();
    return false;
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId, String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await bookingService.cancelBooking(bookingId, eventId);

    _isLoading = false;

    if (result is Success) {
      notifyListeners();
      return true;
    } else if (result is Failure) {
      _error = result.message;
      notifyListeners();
      return false;
    }

    notifyListeners();
    return false;
  }

  // Check if user has booked event
  Future<bool> hasUserBooked(String eventId) async {
    return await bookingService.hasUserBooked(eventId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    _upcomingSubscription?.cancel();
    _pastSubscription?.cancel();
    super.dispose();
  }
}
