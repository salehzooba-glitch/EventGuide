class ReviewModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String? userImage;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String>? images;

  ReviewModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images,
  });

  // Convert from Firestore document
  factory ReviewModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReviewModel(
      id: id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userImage: data['userImage'],
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      images: List<String>.from(data['images'] ?? []),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'images': images ?? [],
    };
  }
}
