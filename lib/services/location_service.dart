import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  // Get current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied';
    }

    return await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Open Google Maps for navigation
  Future<void> openGoogleMapsNavigation({
    required double destinationLat,
    required double destinationLng,
    String travelMode = 'driving',
  }) async {
    final String url =
        'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&travelmode=$travelMode';

    final Uri uri = Uri.parse(url);

    try {
      // Launch directly with external app mode — this opens in
      // the Google Maps app or browser without needing canLaunchUrl
      // (which is unreliable on Android 11+ due to package visibility)
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Fallback: try opening in any available browser
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        throw 'Could not open Google Maps. Please install a web browser.';
      }
    }
  }

  // Calculate distance between two points
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) /
        1000; // Convert to kilometers
  }
}
