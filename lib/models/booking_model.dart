enum BookingStatus { confirmed, cancelled, completed, noShow }

class BookingModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String eventTitle;
  final DateTime eventDate;
  final String? eventImage;
  final int quantity;
  final BookingStatus status;
  final DateTime bookedAt;
  final DateTime? cancelledAt;

  BookingModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.eventTitle,
    required this.eventDate,
    this.eventImage,
    required this.quantity,
    required this.status,
    required this.bookedAt,
    this.cancelledAt,
  });

  // Convert from Firestore document
  factory BookingModel.fromFirestore(Map<String, dynamic> data, String id) {
    final statusString = data['status'] ?? 'confirmed';
    BookingStatus status;

    try {
      status = BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == statusString,
        orElse: () => BookingStatus.confirmed,
      );
    } catch (e) {
      status = BookingStatus.confirmed;
    }

    return BookingModel(
      id: id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      eventTitle: data['eventTitle'] ?? '',
      eventDate: (data['eventDate'] as dynamic)?.toDate() ?? DateTime.now(),
      eventImage: data['eventImage'],
      quantity: data['quantity'] ?? 1,
      status: status,
      bookedAt: (data['bookedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      cancelledAt: (data['cancelledAt'] as dynamic)?.toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'eventTitle': eventTitle,
      'eventDate': eventDate,
      'eventImage': eventImage,
      'quantity': quantity,
      'status': status.toString().split('.').last,
      'bookedAt': bookedAt,
      'cancelledAt': cancelledAt,
    };
  }

  bool get isActive => status == BookingStatus.confirmed;
  bool get isPast => eventDate.isBefore(DateTime.now());
}
