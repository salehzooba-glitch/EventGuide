class AppConfig {
  // App Information
  static const String appName = 'EventGuide';
  static const String appVersion = '1.0.0';
  static const String appBuild = '1';

  // API Keys (Use environment variables in production!)
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'YOUR_API_KEY_HERE',
  );

  // Feature Flags
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  static const bool enableDebugLogging = true;

  // Cache Settings
  static const Duration cacheDuration = Duration(days: 7);
  static const int maxCacheSize = 100; // MB

  // Network Settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}
