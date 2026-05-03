import 'package:cloud_firestore/cloud_firestore.dart';

enum EventCategory { music, sports, tech, food, art, education, social, other }

class EventModel {
  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final DateTime dateTime;
  final double latitude;
  final double longitude;
  final String venueName;
  final String venueAddress;
  final int capacity;
  final int availableSeats;
  final String organizerId;
  final String organizerName;
  final String? imageUrl;
  final double ticketPrice;
  final bool isVerified;
  final DateTime createdAt;
  final List<String> attendees;
  final int attendeesCount;
  final double? distance;
  final double averageRating;
  final int totalRatings;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    required this.venueName,
    required this.venueAddress,
    required this.capacity,
    required this.availableSeats,
    required this.organizerId,
    required this.organizerName,
    this.imageUrl,
    required this.ticketPrice,
    required this.isVerified,
    required this.createdAt,
    required this.attendees,
    required this.attendeesCount,
    required this.averageRating,
    required this.totalRatings,
    this.distance,
  });

  // Convert from Firestore document
  factory EventModel.fromFirestore(
    Map<String, dynamic> data,
    String id, {
    double? distance,
  }) {
    // ignore: avoid_print
    print('\n🔍 PARSING EVENT: $id');
    // ignore: avoid_print
    print('   Title: ${data['title']}');

    final categoryString = data['category'] ?? 'other';
    EventCategory category;

    try {
      category = EventCategory.values.firstWhere(
        (e) => e.toString().split('.').last == categoryString,
        orElse: () => EventCategory.other,
      );
    } catch (e) {
      category = EventCategory.other;
    }

    // 🔧 FIXED: Handle location (now it's direct GeoPoint)
    double latitude = 0.0;
    double longitude = 0.0;

    var locationData = data['location'];
    // ignore: avoid_print
    print('📍 Location type: ${locationData.runtimeType}');

    if (locationData is GeoPoint) {
      latitude = locationData.latitude;
      longitude = locationData.longitude;
      // ignore: avoid_print
      print('📍 GeoPoint: $latitude, $longitude');
    } else {
      // ignore: avoid_print
      print('⚠️ Unknown location format');
    }

    // 🔧 FIXED: Handle attendees safely (convert any type to String)
    List<String> attendeesList = [];
    var attendeesData = data['attendees'];
    if (attendeesData is List) {
      attendeesList = attendeesData.map((item) => item.toString()).toList();
    }

    // 🔧 FIXED: Parse date safely
    DateTime dateTime;
    try {
      dateTime = (data['dateTime'] as Timestamp).toDate();
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Error parsing dateTime: $e');
      dateTime = DateTime.now();
    }

    return EventModel(
      id: id,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      category: category,
      dateTime: dateTime,
      latitude: latitude,
      longitude: longitude,
      venueName: data['venueName']?.toString() ?? '',
      venueAddress: data['venueAddress']?.toString() ?? '',
      capacity: data['capacity'] ?? 0,
      availableSeats: data['availableSeats'] ?? 0,
      organizerId: data['organizerId']?.toString() ?? '',
      organizerName: data['organizerName']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString(),
      ticketPrice: (data['ticketPrice'] as num?)?.toDouble() ?? 0.0,
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attendees: attendeesList,
      attendeesCount: data['attendeesCount'] ?? 0,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: data['totalRatings'] ?? 0,
      distance: distance,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'dateTime': dateTime,
      'location': {'latitude': latitude, 'longitude': longitude},
      'venueName': venueName,
      'venueAddress': venueAddress,
      'capacity': capacity,
      'availableSeats': availableSeats,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'imageUrl': imageUrl,
      'ticketPrice': ticketPrice,
      'isVerified': isVerified,
      'attendees': attendees,
      'attendeesCount': attendeesCount,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
    };
  }

  // Helper properties
  bool get isFree => ticketPrice == 0;
  bool get isSoldOut => availableSeats == 0;
  bool get isAlmostFull =>
      availableSeats < capacity * 0.2; // Less than 20% left

  double get occupancyRate {
    if (capacity == 0) return 0;
    return (capacity - availableSeats) / capacity;
  }

  // Add a helper method to format distance
  String get formattedDistance {
    if (distance == null) return 'Distance unknown';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)} m away';
    }
    return '${distance!.toStringAsFixed(1)} km away';
  }
}
