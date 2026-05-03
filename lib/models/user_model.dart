class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String? profileImage;
  final List<String> interests;
  final List<String> savedEvents;
  final List<String> attendedEvents;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.profileImage,
    required this.interests,
    required this.savedEvents,
    required this.attendedEvents,
    this.role = 'user',
    required this.createdAt,
    this.lastLogin,
  });

  // Convert from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      profileImage: data['profileImage'],
      interests: List<String>.from(data['interests'] ?? []),
      savedEvents: List<String>.from(data['savedEvents'] ?? []),
      attendedEvents: List<String>.from(data['attendedEvents'] ?? []),
      role: data['role'] ?? 'user',
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as dynamic)?.toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'profileImage': profileImage,
      'interests': interests,
      'savedEvents': savedEvents,
      'attendedEvents': attendedEvents,
      'role': role,
      'createdAt': createdAt,
      'lastLogin': lastLogin ?? DateTime.now(),
    };
  }

  // Create empty user
  factory UserModel.empty(String uid, String email) {
    return UserModel(
      uid: uid,
      fullName: '',
      email: email,
      interests: [],
      savedEvents: [],
      attendedEvents: [],
      createdAt: DateTime.now(),
    );
  }

  // Copy with new values
  UserModel copyWith({
    String? fullName,
    String? profileImage,
    List<String>? interests,
    List<String>? savedEvents,
    List<String>? attendedEvents,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      profileImage: profileImage ?? this.profileImage,
      interests: interests ?? this.interests,
      savedEvents: savedEvents ?? this.savedEvents,
      attendedEvents: attendedEvents ?? this.attendedEvents,
      role: role,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
