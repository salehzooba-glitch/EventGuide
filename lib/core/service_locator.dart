import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../services/booking_service.dart';
import '../services/location_service.dart';
import '../providers/user_provider.dart';
import '../providers/event_provider.dart';
import '../providers/booking_provider.dart';

class ServiceLocator {
  late final AuthService authService;
  late final EventService eventService;
  late final BookingService bookingService;
  late final LocationService locationService;

  void init() {
    authService = AuthService();
    eventService = EventService();
    bookingService = BookingService();
    locationService = LocationService();
  }

  List<SingleChildWidget> get providers => [
    ChangeNotifierProvider(
      create: (_) => UserProvider(authService: authService),
    ),
    ChangeNotifierProvider(
      create: (_) => EventProvider(eventService: eventService),
    ),
    ChangeNotifierProvider(
      create: (_) => BookingProvider(bookingService: bookingService),
    ),
  ];
}

final locator = ServiceLocator();
