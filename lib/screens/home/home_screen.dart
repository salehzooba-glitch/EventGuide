import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/event_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/event_model.dart';
import '../../widgets/event_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/loading_widgets.dart';
import '../../core/constants.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/location_model.dart';
import 'event_detail_screen.dart';
import '../booking/my_booking_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();
  double _maxDistance = 1000; // Default 50km
  bool _showDistanceFilter = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      // Load events with default location (Riyadh center)
      eventProvider.loadNearbyEvents(
        location: LocationModel(
          latitude: 24.7683343, // Default Riyadh coordinates
          longitude: 46.5903947,
        ),
      );

      // Try to get real location in background (don't wait)
      _getCurrentLocationInBackground();
    });
  }

  void _getCurrentLocationInBackground() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        final eventProvider = Provider.of<EventProvider>(
          context,
          listen: false,
        );
        eventProvider.updateLocation(
          LocationModel(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        );
      }
    } catch (e) {
      debugPrint('Location error (non-critical): $e');
    }
  }

  void _refreshEvents() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final location = eventProvider.currentLocation;

    if (location != null) {
      eventProvider.loadNearbyEvents(
        location: location,
        radiusInKm: _maxDistance,
        category: _selectedCategory != null
            ? EventCategory.values.firstWhere(
                (e) => e.toString().split('.').last == _selectedCategory,
                orElse: () => EventCategory.other,
              )
            : null,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeTab(),
      const MyBookingsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Guide'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              setState(() {
                _showDistanceFilter = !_showDistanceFilter;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              if (value == 'distance') {
                // Sort by distance is already default in service
                _refreshEvents();
              } else if (value == 'date') {
                // You can implement date sorting if needed
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'distance',
                child: Row(
                  children: [
                    Icon(Icons.navigation, size: 18),
                    SizedBox(width: 8),
                    Text('Closest first'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18),
                    SizedBox(width: 8),
                    Text('Date (earliest)'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.medical_services_outlined),
            onPressed: _fullDiagnostic,
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final name = userProvider.user?.fullName ?? 'there';
                    return Text(
                      'Hello, $name ',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                const Text(
                  AppStrings.nearbyEvents,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchEvents,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              Provider.of<EventProvider>(
                                context,
                                listen: false,
                              ).searchEvents('');
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    Provider.of<EventProvider>(
                      context,
                      listen: false,
                    ).searchEvents(value);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),

          // Category Filter
          SizedBox(
            height: 40,
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, child) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    CategoryChip(
                      label: 'All',
                      isSelected: _selectedCategory == null,
                      onTap: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                        _refreshEvents();
                      },
                    ),
                    const SizedBox(width: 8),
                    ...EventCategory.values.map((category) {
                      final categoryName = category.toString().split('.').last;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryChip(
                          category: category,
                          label: CategoryChip.getCategoryName(category),
                          isSelected: _selectedCategory == categoryName,
                          onTap: () {
                            setState(() {
                              _selectedCategory = categoryName;
                            });
                            _refreshEvents();
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),

          if (_showDistanceFilter)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Max distance: ${_maxDistance.toStringAsFixed(0)} km',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _maxDistance = 50.0;
                          });
                          _refreshEvents();
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  Slider(
                    value: _maxDistance,
                    min: 1,
                    max: 1000,
                    divisions: 999,
                    label: '${_maxDistance.toStringAsFixed(0)} km',
                    onChanged: (value) {
                      setState(() {
                        _maxDistance = value;
                      });
                    },
                    onChangeEnd: (value) {
                      _refreshEvents();
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // Event List
          Expanded(
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, child) {
                if (eventProvider.isLoading) {
                  return const LoadingIndicator(
                    message: 'Finding events near you...',
                  );
                }

                // Show search results if searching
                if (_searchController.text.isNotEmpty) {
                  return _buildEventList(eventProvider.searchResults);
                }

                return _buildEventList(eventProvider.events);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(List<EventModel> events) {
    if (events.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.event_busy,
        title: 'No Events Found',
        message: 'Try changing your search or category filter',
      );
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final savedEvents = userProvider.user?.savedEvents ?? [];

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(
              event: event,
              isSaved: savedEvents.contains(event.id),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventDetailScreen(event: event),
                  ),
                );
              },
              onSave: () {
                final eventProvider = Provider.of<EventProvider>(
                  context,
                  listen: false,
                );
                if (savedEvents.contains(event.id)) {
                  eventProvider.unsaveEvent(event.id);
                } else {
                  eventProvider.saveEvent(event.id);
                }
              },
            );
          },
        );
      },
    );
  }

  Future<void> _fullDiagnostic() async {
    // ignore: avoid_print
    print('\n🔍 ===== FIRESTORE DIAGNOSTIC =====');

    try {
      // 1. Check authentication
      final user = FirebaseAuth.instance.currentUser;
      // ignore: avoid_print
      print('👤 Logged in: ${user != null}');
      if (user != null) {
        // ignore: avoid_print
        print('   UID: ${user.uid}');
        // ignore: avoid_print
        print('   Email: ${user.email}');
      }

      // 2. Note about listing collections
      // ignore: avoid_print
      print('\n📁 Note: listCollections() is not supported on client SDKs.');
      // ignore: avoid_print
      print('✅ Checking known collections instead...');

      final collectionsToCheck = [
        'events',
        'users',
        'bookings',
        'test_permission',
      ];

      for (var colName in collectionsToCheck) {
        // ignore: avoid_print
        print('\n   📂 Checking Collection: "$colName"');
        var snapshot = await FirebaseFirestore.instance
            .collection(colName)
            .limit(3)
            .get();
        // ignore: avoid_print
        print('      📊 Documents found: ${snapshot.docs.length}');

        if (snapshot.docs.isNotEmpty) {
          // ignore: avoid_print
          print('      📄 First document fields:');
          var data = snapshot.docs.first.data();
          data.forEach((key, value) {
            // ignore: avoid_print
            print('         - $key: ${value.runtimeType}');
          });
        }
      }

      // 3. Specifically check 'events' collection
      // ignore: avoid_print
      print('\n🎯 Specifically checking "events" collection:');
      var eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .limit(5)
          .get();

      // ignore: avoid_print
      print('   Documents found: ${eventsSnapshot.docs.length}');

      if (eventsSnapshot.docs.isNotEmpty) {
        // ignore: avoid_print
        print('   ✅ EVENTS EXIST!');
        // ignore: avoid_print
        print(
          '   First event title: ${eventsSnapshot.docs.first.data()['title']}',
        );
      } else {
        // ignore: avoid_print
        print('   ❌ NO EVENTS in "events" collection');

        // Try alternative collection names
        // ignore: avoid_print
        print('\n🔄 Trying alternative collection names:');

        var possibleNames = [
          'Events',
          'event',
          'Event',
          'my_events',
          'local_events',
        ];

        for (var name in possibleNames) {
          try {
            var testSnapshot = await FirebaseFirestore.instance
                .collection(name)
                .limit(1)
                .get();
            // ignore: avoid_print
            print('   - "$name": ${testSnapshot.docs.length} documents');
          } catch (e) {
            // ignore: avoid_print
            print('   - "$name": Error - $e');
          }
        }
      }

      // 4. Test write permission
      // ignore: avoid_print
      print('\n✍️ Testing write permission...');
      try {
        await FirebaseFirestore.instance
            .collection('test_permission')
            .doc('test')
            .set({'timestamp': FieldValue.serverTimestamp()});
        // ignore: avoid_print
        print('   ✅ Can write to database');

        // Clean up
        await FirebaseFirestore.instance
            .collection('test_permission')
            .doc('test')
            .delete();
      } catch (e) {
        // ignore: avoid_print
        print('   ❌ Cannot write: $e');
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ Diagnostic error: $e');
    }

    // ignore: avoid_print
    print('🔍 ===== END DIAGNOSTIC =====\n');
  }
}
