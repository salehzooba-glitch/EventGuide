import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/location_model.dart';
import '../services/event_service.dart';
import '../core/errors.dart';

class EventProvider extends ChangeNotifier {
  final EventService eventService;

  List<EventModel> _events = [];
  List<EventModel> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  LocationModel? _currentLocation;
  StreamSubscription? _eventsSubscription;
  StreamSubscription? _searchSubscription;
  EventCategory? _selectedCategory;

  EventProvider({required this.eventService});

  // Getters
  List<EventModel> get events => _events;
  List<EventModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LocationModel? get currentLocation => _currentLocation;
  EventCategory? get selectedCategory => _selectedCategory;

  // Load nearby events
  void loadNearbyEvents({
    required LocationModel location,
    double radiusInKm = 1000,
    EventCategory? category,
  }) {
    _currentLocation = location;
    _selectedCategory = category;
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Cancel previous subscription if exists
    _eventsSubscription?.cancel();

    _eventsSubscription = eventService
        .getNearbyEvents(
          location: location,
          radiusInKm: radiusInKm,
          category: category,
        )
        .listen(
          (events) {
            _events = events;
            _isLoading = false;
            _error = null;
            notifyListeners();

            // ignore: avoid_print
            print('📊 Loaded ${events.length} events');
            if (events.isNotEmpty) {
              // ignore: avoid_print
              print(
                '📍 Closest event: ${events.first.title} - ${events.first.formattedDistance}',
              );
            }
          },
          onError: (error) {
            // ignore: avoid_print
            print('❌ Event error: $error');
            _events = []; // Show empty list but don't crash
            _error = error.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  // Filter by category
  void filterByCategory(EventCategory? category) {
    _selectedCategory = category;
    notifyListeners();
    loadNearbyEvents(location: _currentLocation ?? LocationModel.empty());
  }

  // Search events
  void searchEvents(String query) {
    _searchSubscription?.cancel();

    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _searchSubscription = eventService
        .searchEvents(query)
        .listen(
          (results) {
            _searchResults = results;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            notifyListeners();
          },
        );
  }

  // Save event
  Future<bool> saveEvent(String eventId) async {
    final result = await eventService.saveEvent(eventId);
    if (result is Success) {
      return true;
    } else if (result is Failure) {
      _error = result.message;
      notifyListeners();
      return false;
    }
    return false;
  }

  // Unsave event
  Future<bool> unsaveEvent(String eventId) async {
    final result = await eventService.unsaveEvent(eventId);
    if (result is Success) {
      return true;
    } else if (result is Failure) {
      _error = result.message;
      notifyListeners();
      return false;
    }
    return false;
  }

  // Update location and refresh events
  void updateLocation(LocationModel location) {
    loadNearbyEvents(location: location, category: _selectedCategory);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _searchSubscription?.cancel();
    super.dispose();
  }
}
