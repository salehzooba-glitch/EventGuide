import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/event_model.dart';
import '../models/location_model.dart';
import '../core/errors.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get nearby events stream
  Stream<List<EventModel>> getNearbyEvents({
    required LocationModel location,
    double radiusInKm = 1000,
    EventCategory? category,
    DateTime? fromDate,
  }) {
    // ignore: avoid_print
    print(
      '🔍 Getting events near: ${location.latitude}, ${location.longitude}',
    );

    Query query = _firestore
        .collection('events')
        .where('dateTime', isGreaterThan: fromDate ?? DateTime.now())
        .orderBy('dateTime');

    // NOTE: Category filtering is done locally (below) to avoid
    // requiring a Firestore composite index.

    return query.snapshots().map((snapshot) {
      // ignore: avoid_print
      print('📦 Firestore returned ${snapshot.docs.length} documents');

      List<EventModel> events = [];

      for (var doc in snapshot.docs) {
        try {
          // Calculate distance for this event
          double distance = 0.0;
          if (location.isValid) {
            var eventData = doc.data() as Map<String, dynamic>;
            double eventLat = 0.0;
            double eventLng = 0.0;

            // Parse location based on your format
            var locationData = eventData['location'];
            if (locationData is GeoPoint) {
              eventLat = locationData.latitude;
              eventLng = locationData.longitude;
            } else if (locationData is Map) {
              eventLat = (locationData['latitude'] as num?)?.toDouble() ?? 0.0;
              eventLng = (locationData['longitude'] as num?)?.toDouble() ?? 0.0;
            }

            // Calculate distance using Geolocator
            distance =
                Geolocator.distanceBetween(
                  location.latitude,
                  location.longitude,
                  eventLat,
                  eventLng,
                ) /
                1000; // Convert to kilometers
          }

          // Pass distance to EventModel
          var event = EventModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
            distance: distance,
          );

          // Only include events within radius
          if (distance <= radiusInKm) {
            // Filter by category locally
            if (category != null && event.category != category) {
              continue;
            }
            events.add(event);
          }
        } catch (e) {
          // ignore: avoid_print
          print('❌ Error parsing event ${doc.id}: $e');
        }
      }

      // Sort by distance (closest first)
      events.sort((a, b) => (a.distance ?? 999).compareTo(b.distance ?? 999));

      // ignore: avoid_print
      print('📊 Loaded ${events.length} events after filtering (category: $category)');
      return events;
    });
  }

  // Get event by ID
  Future<Result<EventModel>> getEventById(String eventId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('events')
          .doc(eventId)
          .get();

      if (!doc.exists) {
        return const Failure('Event not found');
      }

      final event = EventModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      return Success(event);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // Create new event
  Future<Result<String>> createEvent(EventModel event) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Failure('You must be logged in');
      }

      DocumentReference docRef = await _firestore
          .collection('events')
          .add(event.toFirestore());

      return Success(docRef.id);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // Update event
  Future<Result<void>> updateEvent(EventModel event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.id)
          .update(event.toFirestore());

      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // Delete event
  Future<Result<void>> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // Search events
  Stream<List<EventModel>> searchEvents(String query) {
    if (query.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('events')
        .where('dateTime', isGreaterThan: DateTime.now())
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => EventModel.fromFirestore(doc.data(), doc.id))
              .where((event) {
                return event.title.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    event.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    event.venueName.toLowerCase().contains(query.toLowerCase());
              })
              .toList();
        });
  }

  // Save event to user's saved events
  Future<Result<void>> saveEvent(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Failure('You must be logged in');
      }

      await _firestore.collection('users').doc(user.uid).update({
        'savedEvents': FieldValue.arrayUnion([eventId]),
      });

      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // Remove event from saved events
  Future<Result<void>> unsaveEvent(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Failure('You must be logged in');
      }

      await _firestore.collection('users').doc(user.uid).update({
        'savedEvents': FieldValue.arrayRemove([eventId]),
      });

      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
