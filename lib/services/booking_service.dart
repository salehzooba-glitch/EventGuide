import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import '../core/errors.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Book tickets
  Future<Result<BookingModel>> bookTicket({
    required String eventId,
    required String userName,
    required String eventTitle,
    required DateTime eventDate,
    String? eventImage,
    int quantity = 1,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Failure('You must be logged in');
      }

      // Use transaction to prevent overbooking
      return await _firestore.runTransaction((transaction) async {
        DocumentReference eventRef = _firestore
            .collection('events')
            .doc(eventId);
        DocumentSnapshot eventSnapshot = await transaction.get(eventRef);

        if (!eventSnapshot.exists) {
          throw 'Event not found';
        }

        final eventData = eventSnapshot.data() as Map<String, dynamic>;
        final availableSeats = eventData['availableSeats'] ?? 0;

        if (availableSeats < quantity) {
          throw 'Not enough seats available';
        }

        // Update event seats
        transaction.update(eventRef, {
          'availableSeats': availableSeats - quantity,
          'attendees': FieldValue.arrayUnion([user.uid]),
          'attendeesCount': FieldValue.increment(quantity),
        });

        // Create booking
        DocumentReference bookingRef = _firestore.collection('bookings').doc();
        final booking = BookingModel(
          id: bookingRef.id,
          eventId: eventId,
          userId: user.uid,
          userName: userName,
          eventTitle: eventTitle,
          eventDate: eventDate,
          eventImage: eventImage,
          quantity: quantity,
          status: BookingStatus.confirmed,
          bookedAt: DateTime.now(),
        );

        transaction.set(bookingRef, booking.toFirestore());

        // Add to user's attended events
        transaction.update(_firestore.collection('users').doc(user.uid), {
          'attendedEvents': FieldValue.arrayUnion([eventId]),
        });

        return Success(booking);
      });
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // Get user bookings
  Stream<List<BookingModel>> getUserBookings() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Get upcoming bookings
  Stream<List<BookingModel>> getUpcomingBookings() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .where('eventDate', isGreaterThan: DateTime.now())
        .orderBy('eventDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Get past bookings
  Stream<List<BookingModel>> getPastBookings() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .where('eventDate', isLessThan: DateTime.now())
        .orderBy('eventDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Cancel booking
  Future<Result<void>> cancelBooking(String bookingId, String eventId) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // Delete booking
        transaction.delete(_firestore.collection('bookings').doc(bookingId));

        // Increase available seats
        transaction.update(_firestore.collection('events').doc(eventId), {
          'availableSeats': FieldValue.increment(1),
        });

        return const Success(null);
      });
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // Check if user has booked event
  Future<bool> hasUserBooked(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final query = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: 'confirmed')
        .get();

    return query.docs.isNotEmpty;
  }
}
