class LocationModel {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? country;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
  });

  // Empty location
  factory LocationModel.empty() {
    return LocationModel(latitude: 0.0, longitude: 0.0);
  }

  // Convert from map
  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      address: map['address'],
      city: map['city'],
      country: map['country'],
    );
  }

  // Convert to map
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'country': country,
    };
  }

  // Check if location is valid
  bool get isValid => latitude != 0.0 && longitude != 0.0;
}
