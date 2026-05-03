import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'EventGuide';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String bookingsCollection = 'bookings';
  static const String reviewsCollection = 'reviews';

  // Location Settings
  static const double defaultRadiusKm = 50.0;
  static const double maxRadiusKm = 200.0;

  // Pagination
  static const int pageSize = 20;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  // Cache Settings
  static const int cacheDays = 7;
}

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2D9CDB);
  static const Color primaryGreen = Color(0xFF27AE60);
  static const Color primaryOrange = Color(0xFFF2994A);
  static const Color primaryRed = Color(0xFFEB5757);

  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);

  // Status Colors
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFEB5757);
  static const Color warning = Color(0xFFF2994A);
  static const Color info = Color(0xFF2D9CDB);
}

class AppStrings {
  // Auth Strings
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = 'Don\'t have an account?';
  static const String haveAccount = 'Already have an account?';

  // Event Strings
  static const String events = 'Events';
  static const String nearbyEvents = 'Events Near You';
  static const String searchEvents = 'Search events...';
  static const String noEvents = 'No events found';
  static const String bookNow = 'Book Now';
  static const String free = 'Free';

  // Error Messages
  static const String errorGeneral = 'Something went wrong';
  static const String errorNetwork = 'No internet connection';
  static const String errorAuth = 'Authentication failed';
  static const String errorBooking = 'Booking failed';

  // Success Messages
  static const String successBooking = 'Booking confirmed!';
  static const String successReview = 'Review submitted';
  static const String successProfile = 'Profile updated';
}

class AppImages {
  static const String logo = 'assets/images/logo.png';
  static const String placeholder = 'assets/images/placeholder.jpg';
  static const String emptyState = 'assets/images/empty_state.png';
  static const String errorState = 'assets/images/error_state.png';

  // For development (using placeholder images)
  static String getRandomPlaceholder(int id) {
    return 'https://picsum.photos/400/200?random=$id';
  }
}
